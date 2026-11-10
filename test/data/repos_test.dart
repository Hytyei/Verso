import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/tag_repo.dart';
import 'package:verso/data/repos/version_repo.dart';

void main() {
  late VersoDb db;
  late ProjectRepo projects;
  late VersionRepo versions;
  late FeatureRepo features;
  late TagRepo tags;
  var clock = 1000;

  setUp(() {
    clock = 1000;
    db = VersoDb(NativeDatabase.memory(), clock: () => clock++);
    projects = ProjectRepo(db);
    versions = VersionRepo(db);
    features = FeatureRepo(db);
    tags = TagRepo(db);
  });
  tearDown(() => db.close());

  Future<(String, String, String, String)> seed() async {
    final p = await projects.create('Tandem', const VColor.slot(0));
    final v1 = await versions.create(p, 'v1.0');
    final v2 = await versions.create(p, 'v1.1');
    final concept = (await versions.watchForProject(p).first).first.id;
    return (p, concept, v1, v2);
  }

  test('create project inserts 5 default tags', () async {
    final p = await projects.create('Tandem', const VColor.slot(0));
    final t = await tags.watchForProject(p).first;
    expect(t.map((e) => e.name), ['Feature', 'Fix', 'UI', 'Backend', 'Polish']);
  });

  test('project create makes concept version first', () async {
    final (p, concept, v1, _) = await seed();
    final vs = await versions.watchForProject(p).first;
    expect(vs.first.kind, 'concept');
    expect(vs.first.name, 'Concept');
    expect(vs.map((v) => v.id).toList(), [concept, v1, vs[2].id]);
  });

  test('concept cannot be deleted', () async {
    final (_, concept, _, _) = await seed();
    expect(() => versions.softDelete(concept), throwsStateError);
  });

  test('release cannot move before concept', () async {
    final (p, concept, v1, v2) = await seed();
    await versions.move(v2, beforeId: concept);
    final vs = await versions.watchForProject(p).first;
    expect(vs.first.id, concept);
    expect(vs[1].id, v2);
    expect(vs[2].id, v1);
  });

  test('softDelete hides row but keeps it in table', () async {
    final (_, _, v1, _) = await seed();
    final f = await features.create(v1, 'Login');
    await features.softDelete(f);
    expect(await features.watchForVersion(v1).first, isEmpty);
    final raw = await (db.select(db.features)..where((t) => t.id.equals(f))).getSingle();
    expect(raw.deleted, isTrue);
  });

  test('update bumps updatedAt', () async {
    final (_, _, v1, _) = await seed();
    final f = await features.create(v1, 'Login');
    final before = await features.get(f);
    await features.update(f, title: 'Sign in');
    final after = await features.get(f);
    expect(after.title, 'Sign in');
    expect(after.updatedAt, greaterThan(before.updatedAt));
  });

  test('feature move to another version rewrites only that row', () async {
    final (_, _, v1, v2) = await seed();
    final a = await features.create(v1, 'A');
    await features.create(v1, 'B');
    await features.create(v2, 'C');
    final stamps = {for (final f in await db.select(db.features).get()) f.id: f.updatedAt};
    await features.moveTo(a, v2);
    final rows = await db.select(db.features).get();
    for (final r in rows) {
      if (r.id == a) {
        expect(r.versionId, v2);
        expect(r.updatedAt, greaterThan(stamps[a]!));
      } else {
        expect(r.updatedAt, stamps[r.id]);
      }
    }
  });

  test('move to empty version works', () async {
    final (_, _, v1, v2) = await seed();
    final a = await features.create(v1, 'A');
    await features.moveTo(a, v2);
    expect((await features.watchForVersion(v2).first).single.id, a);
  });

  test('move places between neighbours', () async {
    final (_, _, v1, _) = await seed();
    final a = await features.create(v1, 'A');
    final b = await features.create(v1, 'B');
    final c = await features.create(v1, 'C');
    await features.moveTo(c, v1, afterId: a, beforeId: b);
    expect((await features.watchForVersion(v1).first).map((f) => f.title), ['A', 'C', 'B']);
  });

  test('setDone true moves item after undone items in watchForVersion', () async {
    final (_, _, v1, _) = await seed();
    final a = await features.create(v1, 'A');
    await features.create(v1, 'B');
    await features.setDone(a, true);
    final list = await features.watchForVersion(v1).first;
    expect(list.map((f) => f.title), ['B', 'A']);
    expect(list.last.doneAt, isNotNull);
  });

  test('version progress counts only live features', () async {
    final (_, _, v1, _) = await seed();
    final a = await features.create(v1, 'A');
    await features.create(v1, 'B');
    final c = await features.create(v1, 'C');
    await features.setDone(a, true);
    await features.softDelete(c);
    final p = await versions.watchProgress(v1).first;
    expect((p.done, p.total), (1, 2));
  });

  test('progress excludes concept features', () async {
    final (p, concept, v1, _) = await seed();
    await features.create(concept, 'idea');
    final f = await features.create(v1, 'A');
    await features.setDone(f, true);
    final pr = await projects.watchProgress(p).first;
    expect((pr.done, pr.total), (1, 1));
  });

  test('title of 5000 chars round-trips', () async {
    final (_, _, v1, _) = await seed();
    final long = 'x' * 5000;
    final f = await features.create(v1, long);
    expect((await features.get(f)).title, long);
  });

  test('delay moves to next version top and sets delayedFrom once', () async {
    final (_, _, v1, v2) = await seed();
    await features.create(v2, 'Existing');
    final f = await features.create(v1, 'Late');
    await features.delay(f);
    final list = await features.watchForVersion(v2).first;
    expect(list.first.id, f);
    expect(list.first.delayedFromVersionId, v1);
    expect(list.first.delayCount, 1);
  });

  test('second delay keeps original delayedFrom and count 2', () async {
    final (p, _, v1, v2) = await seed();
    final v3 = await versions.create(p, 'v1.2');
    final f = await features.create(v1, 'Late');
    await features.delay(f);
    await features.delay(f);
    final row = await features.get(f);
    expect(row.versionId, v3);
    expect(row.delayedFromVersionId, v1);
    expect(row.delayCount, 2);
    expect(v2, isNotEmpty);
  });

  test('delay from last version throws no-next-version', () async {
    final (_, _, _, v2) = await seed();
    final f = await features.create(v2, 'Late');
    expect(() => features.delay(f), throwsA(isA<StateError>().having((e) => e.message, 'message', 'no-next-version')));
  });

  test('createAfterLast bumps the last version name', () async {
    final (p, _, _, _) = await seed();
    final id = await versions.createAfterLast(p);
    final vs = await versions.watchForProject(p).first;
    expect(vs.last.id, id);
    expect(vs.last.name, 'v1.2.0');
  });

  test('bumpVersionName', () {
    // Always bump the second number and reset the third.
    expect(bumpVersionName('v0.0.0'), 'v0.1.0');
    expect(bumpVersionName('v0.1.0'), 'v0.2.0');
    expect(bumpVersionName('v1.6.0'), 'v1.7.0');
    expect(bumpVersionName('v4.0.3'), 'v4.1.0');
    expect(bumpVersionName('v1.2'), 'v1.3.0');
    expect(bumpVersionName('v2'), 'v2.1.0');
    expect(bumpVersionName('1.9.9'), '1.10.0');
    expect(bumpVersionName('Release 3.4.1 beta'), 'Release 3.5.0 beta');
    expect(bumpVersionName('Beta'), 'Beta next');
  });

  test('the first version of a project is v0.0.0', () async {
    final p = await projects.create('Fresh', const VColor.slot(0));
    final id = await versions.createAfterLast(p);
    expect((await versions.get(id)).name, 'v0.0.0');
    final id2 = await versions.createAfterLast(p);
    expect((await versions.get(id2)).name, 'v0.1.0');
  });

  test('feature views carry tags, sub-item counts and attachment counts', () async {
    final (p, _, v1, _) = await seed();
    final f = await features.create(v1, 'A');
    final t = await tags.watchForProject(p).first;
    await features.setTags(f, [t[0].id, t[2].id]);
    await features.addSubitem(f, 'one');
    final s2 = await features.addSubitem(f, 'two');
    await features.updateSubitem(s2, done: true);
    final view = (await features.watchFeatureViews(v1).first).single;
    expect(view.tags.map((e) => e.name), ['Feature', 'UI']);
    expect((view.subDone, view.subTotal), (1, 2));
    expect(view.attachments, 0);
    await features.setTags(f, [t[2].id]);
    final again = (await features.watchFeatureViews(v1).first).single;
    expect(again.tags.map((e) => e.name), ['UI']);
  });

  test('update can clear a nullable date', () async {
    final (_, _, v1, _) = await seed();
    await versions.update(v1, targetDate: Value(DateTime.utc(2026, 12, 1)));
    await versions.update(v1, targetDate: const Value(null));
    expect((await versions.get(v1)).targetDate, isNull);
  });
}
