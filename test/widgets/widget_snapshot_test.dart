import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';
import 'package:verso/widgets/widget_snapshot.dart';

void main() {
  late VersoDb db;
  setUp(() => db = VersoDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('shows the active version, its counts and only open tasks', () async {
    final p = await ProjectRepo(db).create('Baladsho', const VColor.slot(2));
    final versions = VersionRepo(db);
    final v1 = await versions.create(p, 'v1.0.0');
    await versions.update(v1, status: VersionStatus.released);
    final v2 = await versions.create(p, 'v1.1.0');
    final v3 = await versions.create(p, 'v1.2.0');
    await versions.update(v3, status: VersionStatus.active);
    final f = FeatureRepo(db);
    final a = await f.create(v3, 'Audio drills');
    final b = await f.create(v3, 'Keyboard');
    await f.setDone(b, true);
    await f.create(v2, 'Not this one');

    final snap = await buildWidgetSnapshot(db, lastProjectId: p);
    expect(snap['last'], p);
    final proj = (snap['projects'] as List).single as Map;
    expect(proj['name'], 'Baladsho');
    expect(proj['slot'], 2);
    expect(proj['custom'], isNull);
    final v = proj['version'] as Map;
    expect((v['name'], v['done'], v['total']), ('v1.2.0', 1, 2));
    expect(proj['open'], [
      {'id': a, 'title': 'Audio drills'},
    ]);
  });

  test('without an active version: the first unreleased, then Concept', () async {
    final p = await ProjectRepo(db).create('Kobel', const VColor(0xFF112233, custom: true));
    final versions = VersionRepo(db);
    final v1 = await versions.create(p, 'v1.0.0');
    await versions.update(v1, status: VersionStatus.released);
    var proj = ((await buildWidgetSnapshot(db))['projects'] as List).single as Map;
    expect((proj['version'] as Map)['name'], 'Concept');
    expect(proj['custom'], 0xFF112233);

    await versions.create(p, 'v1.1.0');
    proj = ((await buildWidgetSnapshot(db))['projects'] as List).single as Map;
    expect((proj['version'] as Map)['name'], 'v1.1.0');
  });

  test('paused projects are left out', () async {
    final p = await ProjectRepo(db).create('Paused one', const VColor.slot(0));
    await ProjectRepo(db).update(p, paused: true);
    expect((await buildWidgetSnapshot(db))['projects'], isEmpty);
  });
}
