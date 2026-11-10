import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/tag_repo.dart';
import 'package:verso/data/repos/version_repo.dart';
import 'package:verso/data/undo.dart';

void main() {
  late VersoDb db;
  late VersionRepo versions;
  late FeatureRepo features;
  late UndoStack undo;
  late String p, v1, v2;

  setUp(() async {
    db = VersoDb(NativeDatabase.memory());
    versions = VersionRepo(db);
    features = FeatureRepo(db);
    undo = UndoStack();
    p = await ProjectRepo(db).create('P', const VColor.slot(0));
    v1 = await versions.create(p, 'v1.0');
    v2 = await versions.create(p, 'v1.1');
  });
  tearDown(() => db.close());

  Future<void> attachmentRow(String featureId) async {
    final now = db.now();
    await db
        .into(db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: db.newId(),
            createdAt: now,
            updatedAt: now,
            featureId: featureId,
            fileName: 'x.png',
            originalName: 'x.png',
            width: 1,
            height: 1,
            sortKey: 'a0',
          ),
        );
  }

  test('undo delete version restores version, features, subitems, tags links, attachments', () async {
    final f = await features.create(v1, 'A');
    await features.addSubitem(f, 's');
    final tags = await TagRepo(db).watchForProject(p).first;
    await features.setTags(f, [tags.first.id]);
    await attachmentRow(f);
    await undo.run(deleteVersionAction(db, v1));
    expect((await versions.listForProject(p)).map((v) => v.id), isNot(contains(v1)));
    expect(await features.watchForVersion(v1).first, isEmpty);
    await undo.undo();
    expect((await versions.listForProject(p)).map((v) => v.id), contains(v1));
    final view = (await features.watchFeatureViews(v1).first).single;
    expect(view.subTotal, 1);
    expect(view.tags.single.id, tags.first.id);
    expect(view.attachments, 1);
  });

  test('undo delete version does not resurrect a feature deleted earlier', () async {
    final a = await features.create(v1, 'A');
    await features.create(v1, 'B');
    await features.softDelete(a);
    await undo.run(deleteVersionAction(db, v1));
    await undo.undo();
    expect((await features.watchForVersion(v1).first).map((f) => f.title), ['B']);
  });

  test('redo after undo reapplies', () async {
    final a = await features.create(v1, 'A');
    await undo.run(deleteFeatureAction(features, a));
    await undo.undo();
    expect(await features.watchForVersion(v1).first, hasLength(1));
    await undo.redo();
    expect(await features.watchForVersion(v1).first, isEmpty);
  });

  test('new action clears redo', () async {
    final a = await features.create(v1, 'A');
    await undo.run(toggleDoneAction(features, a, true));
    await undo.undo();
    expect(undo.canRedo.value, isTrue);
    await undo.run(toggleDoneAction(features, a, true));
    expect(undo.canRedo.value, isFalse);
    expect(await undo.redo(), isFalse);
  });

  test('undo move restores original version and position', () async {
    final a = await features.create(v1, 'A');
    await features.create(v1, 'B');
    await undo.run(moveFeatureAction(features, a, v2));
    expect((await features.get(a)).versionId, v2);
    await undo.undo();
    expect((await features.watchForVersion(v1).first).map((f) => f.title), ['A', 'B']);
  });

  test('undo delay restores version and history and removes created version', () async {
    final a = await features.create(v2, 'A');
    await undo.run(delayFeatureAction(features, versions, a, createNew: true));
    final vs = await versions.listForProject(p);
    expect(vs.last.name, 'v1.2.0');
    expect((await features.get(a)).versionId, vs.last.id);
    await undo.undo();
    final row = await features.get(a);
    expect(row.versionId, v2);
    expect(row.delayCount, 0);
    expect(row.delayedFromVersionId, isNull);
    expect((await versions.listForProject(p)).map((v) => v.name), ['Concept', 'v1.0', 'v1.1']);
    await undo.redo();
    expect((await features.get(a)).delayCount, 1);
    expect((await versions.listForProject(p)).last.name, 'v1.2.0');
  });

  test('undo create feature removes it', () async {
    await undo.run(createFeatureAction(features, v1, 'New'));
    expect(await features.watchForVersion(v1).first, hasLength(1));
    await undo.undo();
    expect(await features.watchForVersion(v1).first, isEmpty);
  });
}
