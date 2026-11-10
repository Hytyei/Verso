import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/environment_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';
import 'package:verso/data/undo.dart';

void main() {
  test('fresh database has the default environment', () async {
    final db = VersoDb(NativeDatabase.memory());
    final envs = await EnvironmentRepo(db).watchAll().first;
    expect(envs.single.name, 'My apps');
    await db.close();
  });

  test('migration assigns default environment', () async {
    final dir = await Directory.systemTemp.createTemp('verso_mig');
    final file = File('${dir.path}/v1.db');
    // Build a v1-shaped database: current schema minus environments.
    var db = VersoDb(NativeDatabase(file));
    final p = await ProjectRepo(db).create('Old', const VColor.slot(0));
    await VersionRepo(db).create(p, 'v1.0');
    await db.customStatement('DROP TABLE environments');
    await db.customStatement('ALTER TABLE versions DROP COLUMN environment_id');
    await db.customStatement('ALTER TABLE projects DROP COLUMN paused');
    await db.customStatement('ALTER TABLE subitems DROP COLUMN parent_id');
    await db.customStatement('PRAGMA user_version = 1');
    await db.close();

    db = VersoDb(NativeDatabase(file));
    final envs = await EnvironmentRepo(db).watchAll().first;
    expect(envs.single.name, 'My apps');
    final vs = await VersionRepo(db).listForProject(p);
    expect(vs.map((v) => v.environmentId).toSet(), {envs.single.id});
    await db.close();
    await dir.delete(recursive: true);
  });

  group('with data', () {
    late VersoDb db;
    late EnvironmentRepo envs;
    late VersionRepo versions;
    late String gpt, claude, p, v1, v2, v3;

    setUp(() async {
      db = VersoDb(NativeDatabase.memory());
      envs = EnvironmentRepo(db);
      versions = VersionRepo(db);
      gpt = (await envs.watchAll().first).single.id;
      await envs.update(gpt, name: 'ChatGPT');
      claude = await envs.create('Claude Code', 'terminal', const VColor.slot(2));
      p = await ProjectRepo(db).create('Tandem', const VColor.slot(0), environmentId: gpt);
      v1 = await versions.create(p, 'v1.0');
      v2 = await versions.create(p, 'v1.1');
      v3 = await versions.create(p, 'v1.2');
    });
    tearDown(() => db.close());

    test('new project and its versions use the given environment', () async {
      final vs = await versions.listForProject(p);
      expect(vs.map((v) => v.environmentId).toSet(), {gpt});
    });

    test('setEnvironmentFrom moves this and later versions only', () async {
      await versions.setEnvironmentFrom(v2, claude);
      final vs = {for (final v in await versions.listForProject(p)) v.id: v.environmentId};
      expect(vs[v1], gpt);
      expect(vs[v2], claude);
      expect(vs[v3], claude);
      expect(vs.values.where((e) => e == gpt).length, 2); // Concept + v1.0
    });

    test('new version continues in the last version environment', () async {
      await versions.setEnvironmentFrom(v3, claude);
      final v4 = await versions.createAfterLast(p);
      expect((await versions.get(v4)).environmentId, claude);
    });

    test('undo restores environments', () async {
      final undo = UndoStack();
      await undo.run(setEnvironmentFromAction(versions, v2, claude));
      expect((await versions.get(v3)).environmentId, claude);
      await undo.undo();
      expect((await versions.get(v2)).environmentId, gpt);
      expect((await versions.get(v3)).environmentId, gpt);
    });

    test('project appears in each environment it has versions in', () async {
      await versions.setEnvironmentFrom(v3, claude);
      final placements = await envs.watchPlacements().first;
      expect(placements.where((x) => x.projectId == p).map((x) => x.environmentId).toSet(), {gpt, claude});
    });

    test('moving a project to another environment moves the versions in that folder, undoably', () async {
      await versions.setEnvironmentFrom(v3, claude); // project now lives in both
      final astra = await envs.create('Astra', 'sparkle', const VColor.slot(1));
      final undo = UndoStack();
      await undo.run(moveProjectToEnvironmentAction(versions, p, from: gpt, to: astra));
      final after = {for (final v in await versions.listForProject(p)) v.name: v.environmentId};
      expect(after, {'Concept': astra, 'v1.0': astra, 'v1.1': astra, 'v1.2': claude});
      await undo.undo();
      final back = {for (final v in await versions.listForProject(p)) v.name: v.environmentId};
      expect(back, {'Concept': gpt, 'v1.0': gpt, 'v1.1': gpt, 'v1.2': claude});
    });

    test('delete refuses non-empty environment', () async {
      expect(() => envs.softDelete(gpt), throwsStateError);
      final empty = await envs.create('Astra', 'sparkle', const VColor.slot(1));
      await envs.softDelete(empty);
      expect((await envs.watchAll().first).map((e) => e.id), isNot(contains(empty)));
    });
  });
}
