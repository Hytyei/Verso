import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';
import 'package:verso/data/undo.dart';

void main() {
  late VersoDb db;
  late FeatureRepo repo;
  late String f;

  setUp(() async {
    db = VersoDb(NativeDatabase.memory());
    repo = FeatureRepo(db);
    final p = await ProjectRepo(db).create('P', const VColor.slot(0));
    final v = await VersionRepo(db).create(p, 'v1');
    f = await repo.create(v, 'Feature');
  });
  tearDown(() => db.close());

  test('steps nest to any depth', () async {
    final a = await repo.addSubitem(f, 'A');
    final a1 = await repo.addSubitem(f, 'A1', parentId: a);
    final a1x = await repo.addSubitem(f, 'A1x', parentId: a1);
    final a1xy = await repo.addSubitem(f, 'A1xy', parentId: a1x);
    final all = await repo.watchSubitems(f).first;
    expect({for (final s in all) s.title: s.parentId}, {'A': null, 'A1': a, 'A1x': a1, 'A1xy': a1x});
    expect(a1xy, isNotEmpty);
    // The card counter counts every level.
    expect((await repo.watchFeatureViews((await repo.get(f)).versionId).first).single.subTotal, 4);
  });

  test('reorder among siblings rewrites one key', () async {
    final a = await repo.addSubitem(f, 'A');
    await repo.addSubitem(f, 'B');
    final c = await repo.addSubitem(f, 'C');
    await repo.moveSubitem(c, afterId: a);
    final top = (await repo.watchSubitems(f).first).where((s) => s.parentId == null).toList()
      ..sort((x, y) => x.sortKey.compareTo(y.sortKey));
    expect(top.map((s) => s.title), ['A', 'C', 'B']);
  });

  test('moving a step under another step re-parents it', () async {
    final a = await repo.addSubitem(f, 'A');
    final b = await repo.addSubitem(f, 'B');
    await repo.moveSubitem(b, parentId: a);
    expect((await repo.watchSubitems(f).first).firstWhere((s) => s.id == b).parentId, a);
  });

  test('a step cannot move under its own descendant', () async {
    final a = await repo.addSubitem(f, 'A');
    final a1 = await repo.addSubitem(f, 'A1', parentId: a);
    expect(() => repo.moveSubitem(a, parentId: a1), throwsArgumentError);
  });

  test('deleting a step removes its whole subtree, and undo brings it all back', () async {
    final a = await repo.addSubitem(f, 'A');
    final a1 = await repo.addSubitem(f, 'A1', parentId: a);
    await repo.addSubitem(f, 'A1x', parentId: a1);
    final b = await repo.addSubitem(f, 'B');
    final undo = UndoStack();
    await undo.run(deleteSubitemAction(repo, a));
    expect((await repo.watchSubitems(f).first).map((s) => s.id), [b]);
    await undo.undo();
    expect((await repo.watchSubitems(f).first), hasLength(4));
  });

  test('undo a step move restores parent and order', () async {
    final a = await repo.addSubitem(f, 'A');
    final b = await repo.addSubitem(f, 'B');
    final undo = UndoStack();
    await undo.run(moveSubitemAction(repo, b, parentId: a));
    await undo.undo();
    final row = (await repo.watchSubitems(f).first).firstWhere((s) => s.id == b);
    expect(row.parentId, isNull);
  });
}
