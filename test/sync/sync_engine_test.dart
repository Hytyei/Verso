import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:verso/data/attachment_store.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/environment_repo.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';
import 'package:verso/sync/sync_api.dart';
import 'package:verso/sync/sync_engine.dart';

/// In-process stand-in for verso-api with the same rules: last write wins,
/// server sequence for pulls, pages of 500, pushes of at most 40, blobs.
class FakeServer {
  late HttpServer server;
  final rows = <String, Map<String, dynamic>>{}; // "t:id" → {t,id,u,d,data,seq}
  final blobs = <String, Uint8List>{};
  int seq = 0;
  int requests = 0;

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(_handle);
  }

  String get url => 'http://127.0.0.1:${server.port}';

  Future<void> _handle(HttpRequest req) async {
    requests++;
    final res = req.response;
    if (req.headers.value('authorization') != 'Bearer good') {
      res.statusCode = 401;
      res.write(jsonEncode({'error': 'Sign in to sync'}));
      return res.close();
    }
    final path = req.uri.path;
    if (path == '/v1/sync' && req.method == 'POST') {
      final body = jsonDecode(await utf8.decoder.bind(req).join()) as Map<String, dynamic>;
      final push = (body['rows'] as List).cast<Map<String, dynamic>>();
      if (push.length > 40) {
        res.statusCode = 413;
        return res.close();
      }
      for (final r in push) {
        final key = '${r['t']}:${r['id']}';
        final cur = rows[key];
        if (cur == null || (r['u'] as int) > (cur['u'] as int)) rows[key] = {...r, 'seq': ++seq};
      }
      final cursor = body['cursor'] as int;
      final after = rows.values.where((r) => (r['seq'] as int) > cursor).toList()
        ..sort((a, b) => (a['seq'] as int).compareTo(b['seq'] as int));
      final page = after.take(500).toList();
      res.headers.contentType = ContentType.json;
      res.write(
        jsonEncode({
          'cursor': page.isEmpty ? cursor : page.last['seq'],
          'more': after.length > 500,
          'rows': [
            for (final r in page) {'t': r['t'], 'id': r['id'], 'u': r['u'], 'd': r['d'], 'data': r['data']},
          ],
        }),
      );
      return res.close();
    }
    final m = RegExp(r'^/v1/blobs/(.+)$').firstMatch(path);
    if (m != null) {
      final name = Uri.decodeComponent(m.group(1)!);
      if (req.method == 'PUT') {
        final b = BytesBuilder();
        await for (final c in req) {
          b.add(c);
        }
        blobs[name] = b.takeBytes();
        res.statusCode = 201;
        res.write('{}');
      } else if (!blobs.containsKey(name)) {
        res.statusCode = 404;
      } else if (req.method == 'GET') {
        res.add(blobs[name]!);
      }
      return res.close();
    }
    res.statusCode = 404;
    return res.close();
  }
}

class Device {
  Device(this.db, this.dir, this.server)
    : store = AttachmentStore(db, Directory('${dir.path}/attachments')),
      state = MemorySyncStateStore();
  final VersoDb db;
  final Directory dir;
  final FakeServer server;
  final AttachmentStore store;
  final MemorySyncStateStore state;

  Future<SyncResult> sync({String token = 'good'}) =>
      SyncEngine(db: db, api: SyncApi(server.url, () async => token), state: state, attachments: store).run();
}

void main() {
  late FakeServer server;
  late Device a, b;
  late Directory tmp;
  var clock = 1000000;

  setUp(() async {
    server = FakeServer();
    await server.start();
    tmp = await Directory.systemTemp.createTemp('verso_sync');
    // Two devices whose clocks keep moving forward.
    a = Device(VersoDb(NativeDatabase.memory(), clock: () => clock += 7), Directory('${tmp.path}/a'), server);
    b = Device(VersoDb(NativeDatabase.memory(), clock: () => clock += 7), Directory('${tmp.path}/b'), server);
  });
  tearDown(() async {
    await a.db.close();
    await b.db.close();
    await server.server.close(force: true);
    await tmp.delete(recursive: true);
  });

  test('a project made on one device appears on the other', () async {
    final p = await ProjectRepo(a.db).create('Tandem', const VColor.slot(0));
    final v = await VersionRepo(a.db).create(p, 'v1.0');
    final f = await FeatureRepo(a.db).create(v, 'Sign in');
    await FeatureRepo(a.db).addSubitem(f, 'Design');
    final up = await a.sync();
    expect(up.pushed, greaterThan(10)); // default env + project + concept + version + 5 tags + feature + step…
    final down = await b.sync();
    expect(down.pulled, greaterThanOrEqualTo(10)); // the shared default folder is not re-pulled
    expect((await ProjectRepo(b.db).watchAll().first).map((x) => x.name), contains('Tandem'));
    final views = await FeatureRepo(b.db).watchFeatureViews(v).first;
    expect(views.single.f.title, 'Sign in');
    expect(views.single.subTotal, 1);
    // Both devices share the same default folder instead of showing two.
    expect(await EnvironmentRepo(b.db).watchAll().first, hasLength(1));
  });

  test('the newer edit wins in both directions, and deletes travel', () async {
    final p = await ProjectRepo(a.db).create('Kobel', const VColor.slot(1));
    final v = await VersionRepo(a.db).create(p, 'v4.0');
    final f = await FeatureRepo(a.db).create(v, 'Old title');
    await a.sync();
    await b.sync();
    await FeatureRepo(b.db).update(f, title: 'New title from B');
    await b.sync();
    await a.sync();
    expect((await FeatureRepo(a.db).get(f)).title, 'New title from B');
    await FeatureRepo(a.db).softDelete(f);
    await a.sync();
    await b.sync();
    expect(await FeatureRepo(b.db).watchForVersion(v).first, isEmpty);
  });

  test('a second sync with nothing new pushes only boundary rows and pulls nothing', () async {
    await ProjectRepo(a.db).create('X', const VColor.slot(0));
    await a.sync();
    final again = await a.sync();
    expect(again.pulled, 0);
  });

  test('more than 40 changed rows go up in several pushes', () async {
    final p = await ProjectRepo(a.db).create('Big', const VColor.slot(0));
    final v = await VersionRepo(a.db).create(p, 'v1');
    for (var i = 0; i < 95; i++) {
      await FeatureRepo(a.db).create(v, 'F$i');
    }
    final r = await a.sync();
    expect(r.pushed, greaterThan(95));
    await b.sync();
    expect(await FeatureRepo(b.db).watchForVersion(v).first, hasLength(95));
  });

  test('images upload once and download with a thumbnail', () async {
    final p = await ProjectRepo(a.db).create('Pics', const VColor.slot(0));
    final v = await VersionRepo(a.db).create(p, 'v1');
    final f = await FeatureRepo(a.db).create(v, 'Shot');
    final res = await a.store.addBytes(f, img.encodePng(img.Image(width: 30, height: 20)), 'png');
    final up = await a.sync();
    expect(up.imagesUp, 1);
    expect(server.blobs, hasLength(1));
    final down = await b.sync();
    expect(down.imagesDown, 1);
    expect(b.store.original(res.attachment!).existsSync(), isTrue);
    expect(b.store.thumb(res.attachment!).existsSync(), isTrue);
    final again = await a.sync();
    expect(again.imagesUp, 0);
  });

  test('a rejected token surfaces as an error and changes nothing', () async {
    await ProjectRepo(a.db).create('X', const VColor.slot(0));
    await expectLater(a.sync(token: 'bad'), throwsA(isA<SyncApiException>().having((e) => e.status, 'status', 401)));
    expect((await a.state.read()).cursor, 0);
  });
}
