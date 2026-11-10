import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/import_tree.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/environment_repo.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';

void main() {
  late VersoDb db;
  late String kobel, v4, concept, semester2;

  setUp(() async {
    db = VersoDb(NativeDatabase.memory());
    // Existing data: Kobel lives in "Opera FX" (moved there by the owner), with v4.0.0 open.
    final envs = EnvironmentRepo(db);
    final opera = await envs.create('Opera FX', 'web', const VColor.slot(0));
    kobel = await ProjectRepo(db).create('Kobel App', const VColor.slot(0), environmentId: opera);
    v4 = await VersionRepo(db).create(kobel, 'v4.0.0');
    await FeatureRepo(db).create(v4, 'UI Manual Redesign');
    concept = (await VersionRepo(db).listForProject(kobel)).first.id;
    semester2 = await FeatureRepo(db).create(concept, 'Semester 2');
  });
  tearDown(() => db.close());

  Map<String, Object?> tree() => {
    'environments': [
      {
        'name': 'Claude Code',
        'projects': [
          {
            'name': 'Kobel App',
            'concept': [
              {'title': 'Semester 1', 'done': true},
              {'title': 'Semester 2', 'steps': [{'title': 'First 3 Sessions', 'done': true}]},
            ],
            'versions': [
              {
                'name': 'v4.0.0',
                'features': [
                  'UI Manual Redesign',
                  {'title': 'Make it less crowded', 'done': true, 'notes': 'from Todoist'},
                ],
              },
              {
                'name': 'v3.5.0',
                'status': 'released',
                'features': [
                  {'title': 'Football-themed notifications', 'done': true},
                ],
              },
            ],
          },
        ],
      },
    ],
  };

  test('merge finds the project wherever it lives and adds only what is missing', () async {
    final r = await importTree(db, tree(), merge: true);
    final projects = await ProjectRepo(db).watchAll().first;
    expect(projects.map((p) => p.name), ['Kobel App']); // no duplicate in a new "Claude Code" folder
    final f4 = await FeatureRepo(db).watchForVersion(v4).first;
    expect(f4.map((f) => f.title), ['UI Manual Redesign', 'Make it less crowded']);
    final added = f4.last;
    expect(added.done, isTrue);
    expect(added.notes, 'from Todoist');
    expect(r.features, greaterThanOrEqualTo(2));
  });

  test('a released version is created in version order and its features are done', () async {
    await importTree(db, tree(), merge: true);
    final vs = await VersionRepo(db).listForProject(kobel);
    expect(vs.map((v) => v.name), ['Concept', 'v3.5.0', 'v4.0.0']);
    final v35 = vs[1];
    expect(v35.status, 'released');
    expect((await FeatureRepo(db).watchForVersion(v35.id).first).single.done, isTrue);
  });

  test('concept ideas and steps under existing features merge too', () async {
    await importTree(db, tree(), merge: true);
    final c = await FeatureRepo(db).watchForVersion(concept).first;
    expect(c.map((f) => f.title).toSet(), {'Semester 1', 'Semester 2'});
    final steps = await FeatureRepo(db).watchSubitems(semester2).first;
    expect(steps.single.title, 'First 3 Sessions');
    expect(steps.single.done, isTrue);
  });

  test('merging twice adds nothing the second time', () async {
    await importTree(db, tree(), merge: true);
    final again = await importTree(db, tree(), merge: true);
    expect((again.projects, again.versions, again.features), (0, 0, 0));
  });
}
