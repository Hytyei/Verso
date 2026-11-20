import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';

void main() {
  late VersoDb db;
  late VersionRepo versions;
  late FeatureRepo features;
  late String project, v1;
  // 2026-11-20 10:00 UTC; the "today" AutoDates uses is the local calendar day.
  var clock = DateTime.utc(2026, 11, 20, 10).millisecondsSinceEpoch;
  DateTime day(int ms) {
    final l = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
    return DateTime.utc(l.year, l.month, l.day);
  }

  setUp(() async {
    clock = DateTime.utc(2026, 11, 20, 10).millisecondsSinceEpoch;
    db = VersoDb(NativeDatabase.memory(), clock: () => clock);
    versions = VersionRepo(db);
    features = FeatureRepo(db);
    project = await ProjectRepo(db).create('App', const VColor.slot(0));
    v1 = await versions.create(project, 'v1.0.0');
  });
  tearDown(() => db.close());

  test('the first task starts the version; later tasks keep that start', () async {
    expect((await versions.get(v1)).startDate?.toUtc(), isNull);
    final started = day(clock);
    await features.create(v1, 'A');
    expect((await versions.get(v1)).startDate?.toUtc(), started);
    clock += const Duration(days: 3).inMilliseconds;
    await features.create(v1, 'B');
    expect((await versions.get(v1)).startDate?.toUtc(), started);
  });

  test('the last done task ends it; reopening removes the automatic end', () async {
    final a = await features.create(v1, 'A');
    final b = await features.create(v1, 'B');
    await features.setDone(a, true);
    expect((await versions.get(v1)).targetDate?.toUtc(), isNull);
    clock += const Duration(days: 5).inMilliseconds;
    await features.setDone(b, true);
    var v = await versions.get(v1);
    expect(v.targetDate?.toUtc(), day(clock));
    expect(v.endAuto, isTrue);
    await features.setDone(b, false);
    v = await versions.get(v1);
    expect(v.targetDate?.toUtc(), isNull);
    expect(v.endAuto, isFalse);
  });

  test('a new task in a finished version reopens it too', () async {
    final a = await features.create(v1, 'A');
    await features.setDone(a, true);
    expect((await versions.get(v1)).targetDate?.toUtc(), isNotNull);
    await features.create(v1, 'Late addition');
    expect((await versions.get(v1)).targetDate?.toUtc(), isNull);
  });

  test('dates the owner set are never touched', () async {
    final mine = DateTime.utc(2027, 1, 15);
    await versions.update(v1, startDate: Value(DateTime.utc(2026, 1, 1)), targetDate: Value(mine));
    final a = await features.create(v1, 'A');
    await features.setDone(a, true);
    await features.setDone(a, false);
    final v = await versions.get(v1);
    expect(v.startDate?.toUtc(), DateTime.utc(2026, 1, 1));
    expect(v.targetDate?.toUtc(), mine);
  });

  test('setting the end by hand makes an automatic end the owner\'s', () async {
    final a = await features.create(v1, 'A');
    await features.setDone(a, true);
    await versions.update(v1, targetDate: Value(DateTime.utc(2026, 12, 1)));
    await features.setDone(a, false);
    expect((await versions.get(v1)).targetDate?.toUtc(), DateTime.utc(2026, 12, 1));
  });

  test('moving or delaying a task updates both versions', () async {
    final v2 = await versions.create(project, 'v1.1.0');
    final a = await features.create(v1, 'A');
    final b = await features.create(v1, 'B');
    await features.setDone(a, true);
    await features.moveTo(b, v2);
    expect((await versions.get(v1)).targetDate?.toUtc(), isNotNull, reason: 'v1 is now all done');
    expect((await versions.get(v2)).startDate?.toUtc(), isNotNull, reason: 'v2 got its first task');
    await features.delay(a, toVersionId: v2);
    expect((await versions.get(v1)).targetDate?.toUtc(), isNull, reason: 'v1 has no tasks left');
  });

  test('deleting the last open task finishes the version', () async {
    final a = await features.create(v1, 'A');
    final b = await features.create(v1, 'B');
    await features.setDone(a, true);
    await features.softDelete(b);
    expect((await versions.get(v1)).targetDate?.toUtc(), isNotNull);
  });

  test('the Concept stage keeps no dates', () async {
    final concept = (await versions.listForProject(project)).first;
    final a = await features.create(concept.id, 'Idea');
    await features.setDone(a, true);
    final c = await versions.get(concept.id);
    expect((c.startDate?.toUtc(), c.targetDate), (null, null));
  });

  test('a v4 database gains the v1.5.0 columns, data intact', () async {
    final dir = await Directory.systemTemp.createTemp('verso_v5');
    final file = File('${dir.path}/v4.db');
    var old = VersoDb(NativeDatabase(file));
    final p = await ProjectRepo(old).create('Kept', const VColor.slot(0));
    await old.customStatement('ALTER TABLE projects DROP COLUMN description');
    await old.customStatement('ALTER TABLE environments DROP COLUMN description');
    await old.customStatement('ALTER TABLE versions DROP COLUMN end_auto');
    await old.customStatement('PRAGMA user_version = 4');
    await old.close();
    old = VersoDb(NativeDatabase(file));
    final kept = await ProjectRepo(old).get(p);
    expect((kept.name, kept.description), ('Kept', null));
    final v = (await VersionRepo(old).listForProject(p)).first;
    expect(v.endAuto, isNull);
    await old.close();
    await dir.delete(recursive: true);
  });
}
