import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/attachment_store.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/tag_repo.dart';
import 'package:verso/data/repos/version_repo.dart';
import 'package:verso/data/undo.dart';
import 'dart:io';

void main() {
  late VersoDb db;
  late FeatureRepo features;
  late VersionRepo versions;
  late TagRepo tags;
  late UndoStack undo;
  late String p, v1, v2;

  setUp(() async {
    db = VersoDb(NativeDatabase.memory());
    features = FeatureRepo(db);
    versions = VersionRepo(db);
    tags = TagRepo(db);
    undo = UndoStack();
    p = await ProjectRepo(db).create('P', const VColor.slot(0));
    v1 = await versions.create(p, 'v1.0');
    v2 = await versions.create(p, 'v1.1');
  });
  tearDown(() => db.close());

  test('undo tag delete restores it on every feature', () async {
    final f = await features.create(v1, 'A');
    final t = (await tags.watchForProject(p).first).first;
    await features.setTags(f, [t.id]);
    await undo.run(deleteTagAction(tags, t.id));
    expect((await features.watchFeatureViews(v1).first).single.tags, isEmpty);
    await undo.undo();
    expect((await features.watchFeatureViews(v1).first).single.tags.single.id, t.id);
  });

  test('sub-item delete, toggle and rename are undoable', () async {
    final f = await features.create(v1, 'A');
    final s = await features.addSubitem(f, 'step');
    await undo.run(toggleSubitemAction(features, s, true));
    await undo.run(renameSubitemAction(features, s, 'step', 'Step one'));
    await undo.run(deleteSubitemAction(features, s));
    expect(await features.watchSubitems(f).first, isEmpty);
    await undo.undo();
    expect((await features.watchSubitems(f).first).single.title, 'Step one');
    await undo.undo();
    expect((await features.watchSubitems(f).first).single.title, 'step');
    await undo.undo();
    expect((await features.watchSubitems(f).first).single.done, isFalse);
  });

  test('notes edit is one undo step', () async {
    final f = await features.create(v1, 'A');
    await undo.run(notesEditAction(features, f, null, 'final text'));
    expect((await features.get(f)).notes, 'final text');
    await undo.undo();
    expect((await features.get(f)).notes, isNull);
  });

  test('add version is undoable', () async {
    await undo.run(createVersionAction(versions, p));
    expect((await versions.listForProject(p)).last.name, 'v1.2.0');
    await undo.undo();
    expect((await versions.listForProject(p)).map((v) => v.name), ['Concept', 'v1.0', 'v1.1']);
    await undo.redo();
    expect((await versions.listForProject(p)).last.name, 'v1.2.0');
  });

  test('version reorder is undoable', () async {
    await undo.run(moveVersionAction(versions, v2, beforeId: v1));
    expect((await versions.listForProject(p)).map((v) => v.name), ['Concept', 'v1.1', 'v1.0']);
    await undo.undo();
    expect((await versions.listForProject(p)).map((v) => v.name), ['Concept', 'v1.0', 'v1.1']);
  });

  test('move to a new version: undo removes the created version', () async {
    final f = await features.create(v1, 'A');
    await undo.run(moveToNewVersionAction(features, versions, f));
    final vs = await versions.listForProject(p);
    expect((await features.get(f)).versionId, vs.last.id);
    await undo.undo();
    expect((await features.get(f)).versionId, v1);
    expect((await versions.listForProject(p)).length, 3);
  });

  test('image removal and project delete are on the stack', () async {
    final dir = await Directory.systemTemp.createTemp('verso_u');
    final store = AttachmentStore(db, dir);
    final f = await features.create(v1, 'A');
    final now = db.now();
    await db
        .into(db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: 'att',
            createdAt: now,
            updatedAt: now,
            featureId: f,
            fileName: 'x.png',
            originalName: 'x',
            width: 1,
            height: 1,
            sortKey: 'a0',
          ),
        );
    await undo.run(removeAttachmentAction(store, 'att'));
    expect(await store.watchForFeature(f).first, isEmpty);
    await undo.undo();
    expect(await store.watchForFeature(f).first, hasLength(1));
    final projects = ProjectRepo(db);
    await undo.run(deleteProjectAction(projects, p));
    expect(await projects.watchAll().first, isEmpty);
    await undo.undo();
    expect(await projects.watchAll().first, hasLength(1));
    await dir.delete(recursive: true);
  });
}
