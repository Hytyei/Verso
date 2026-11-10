import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/undo.dart';

void main() {
  test('pausing a project is stored and undoable', () async {
    final db = VersoDb(NativeDatabase.memory());
    final repo = ProjectRepo(db);
    final p = await repo.create('Tandem', const VColor.slot(0));
    expect((await repo.get(p)).paused, isFalse);
    final undo = UndoStack();
    await undo.run(setPausedAction(repo, p, true));
    expect((await repo.get(p)).paused, isTrue);
    await undo.undo();
    expect((await repo.get(p)).paused, isFalse);
    await db.close();
  });

  test('migration from v2 adds paused = false to existing projects', () async {
    final dir = await Directory.systemTemp.createTemp('verso_mig3');
    final file = File('${dir.path}/v2.db');
    var db = VersoDb(NativeDatabase(file));
    final p = await ProjectRepo(db).create('Old', const VColor.slot(0));
    await db.customStatement('ALTER TABLE projects DROP COLUMN paused');
    await db.customStatement('ALTER TABLE subitems DROP COLUMN parent_id');
    await db.customStatement('PRAGMA user_version = 2');
    await db.close();
    db = VersoDb(NativeDatabase(file));
    expect((await ProjectRepo(db).get(p)).paused, isFalse);
    await db.close();
    await dir.delete(recursive: true);
  });

  test('opening a database an older build stamped back to v2 (columns already there) still works', () async {
    final dir = await Directory.systemTemp.createTemp('verso_down');
    final file = File('${dir.path}/d.db');
    var db = VersoDb(NativeDatabase(file));
    final p = await ProjectRepo(db).create('Kept', const VColor.slot(0));
    await db.customStatement('PRAGMA user_version = 2'); // what an older app does on open
    await db.close();
    db = VersoDb(NativeDatabase(file));
    expect((await ProjectRepo(db).get(p)).name, 'Kept');
    await db.close();
    // Even from v1 with everything present.
    db = VersoDb(NativeDatabase(file));
    await db.customStatement('PRAGMA user_version = 1');
    await db.close();
    db = VersoDb(NativeDatabase(file));
    expect((await ProjectRepo(db).watchAll().first).single.name, 'Kept');
    await db.close();
    await dir.delete(recursive: true);
  });
}
