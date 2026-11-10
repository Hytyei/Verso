import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:verso/data/attachment_store.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';

void main() {
  late VersoDb db;
  late Directory root;
  late Directory inputs;
  late AttachmentStore store;
  late String f;

  setUp(() async {
    db = VersoDb(NativeDatabase.memory());
    root = await Directory.systemTemp.createTemp('verso_att');
    inputs = await Directory.systemTemp.createTemp('verso_in');
    store = AttachmentStore(db, root);
    final p = await ProjectRepo(db).create('P', const VColor.slot(0));
    final v = await VersionRepo(db).create(p, 'v1');
    f = await FeatureRepo(db).create(v, 'A');
  });
  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
    await inputs.delete(recursive: true);
  });

  File png(String name, int w, int h) {
    final file = File('${inputs.path}/$name');
    file.writeAsBytesSync(img.encodePng(img.Image(width: w, height: h)));
    return file;
  }

  test('addFile stores original and thumb', () async {
    final r = await store.addFile(f, png('small.png', 20, 10));
    expect(r.attachment, isNotNull);
    expect(store.original(r.attachment!).existsSync(), isTrue);
    expect(store.thumb(r.attachment!).existsSync(), isTrue);
    expect((r.attachment!.width, r.attachment!.height), (20, 10));
  });

  test('addFile rejects non-image and stores nothing', () async {
    final fake = File('${inputs.path}/notes.png')..writeAsStringSync('hello');
    final r = await store.addFile(f, fake);
    expect(r.attachment, isNull);
    expect(r.reason, isNotEmpty);
    expect(root.listSync(recursive: true).whereType<File>(), isEmpty);
    expect(await db.select(db.attachments).get(), isEmpty);
    final txt = File('${inputs.path}/notes.txt')..writeAsStringSync('hello');
    expect((await store.addFile(f, txt)).attachment, isNull);
  });

  test('addFile on 8000px image writes thumb with max side 512', () async {
    final r = await store.addFile(f, png('wide.png', 8000, 100));
    final t = img.decodePng(store.thumb(r.attachment!).readAsBytesSync())!;
    expect(t.width, 512);
    expect(t.height, lessThanOrEqualTo(512));
  });

  test('addBytes from clipboard png works', () async {
    final bytes = img.encodePng(img.Image(width: 4, height: 4));
    final r = await store.addBytes(f, bytes, 'png');
    expect(r.attachment!.originalName, startsWith('Pasted'));
  });

  test('images over the pixel limit are rejected before decoding', () async {
    final small = AttachmentStore(db, root, maxPixels: 100);
    final r = await small.addFile(f, png('big.png', 20, 10));
    expect(r.attachment, isNull);
    expect(r.reason, contains('too large'));
    expect(root.listSync(recursive: true).whereType<File>(), isEmpty);
  });

  test('files over the byte limit are rejected', () async {
    final small = AttachmentStore(db, root, maxBytes: 10);
    final r = await small.addFile(f, png('b.png', 20, 10));
    expect(r.attachment, isNull);
    expect(r.reason, contains('MB'));
  });
}
