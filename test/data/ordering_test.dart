import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/ordering.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';

void main() {
  test('placeKey with a stale beforeId still lands after afterId and before the next key', () {
    final k = placeKey([('a', 'a0'), ('b', 'a1')], afterId: 'a', beforeId: 'gone');
    expect(k.compareTo('a0') > 0 && k.compareTo('a1') < 0, isTrue);
  });

  test('placeKey survives duplicate neighbour keys', () {
    final k = placeKey([('a', 'a0'), ('b', 'a0'), ('c', 'a1')], afterId: 'a', beforeId: 'b');
    expect(k.compareTo('a0') > 0 && k.compareTo('a1') < 0, isTrue);
  });

  test('moving a card between two cards that share a key works', () async {
    final db = VersoDb(NativeDatabase.memory());
    final p = await ProjectRepo(db).create('P', const VColor.slot(0));
    final v = await VersionRepo(db).create(p, 'v1');
    final f = FeatureRepo(db);
    final a = await f.create(v, 'A');
    final b = await f.create(v, 'B');
    final c = await f.create(v, 'C');
    await (db.update(
      db.features,
    )..where((t) => t.id.equals(b))).write(FeaturesCompanion(sortKey: Value((await f.get(a)).sortKey)));
    await f.moveTo(c, v, afterId: a, beforeId: b);
    expect((await f.watchForVersion(v).first).map((x) => x.title).last, isNot('C'));
    await db.close();
  });

  test('concurrent creates never share a sort key', () async {
    final db = VersoDb(NativeDatabase.memory());
    final p = await ProjectRepo(db).create('P', const VColor.slot(0));
    final v = await VersionRepo(db).create(p, 'v1');
    final f = FeatureRepo(db);
    await Future.wait([for (var i = 0; i < 10; i++) f.create(v, 'F$i')]);
    final keys = (await f.watchForVersion(v).first).map((x) => x.sortKey).toList();
    expect(keys.toSet().length, 10);
    await db.close();
  });
}
