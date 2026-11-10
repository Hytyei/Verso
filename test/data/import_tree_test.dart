import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/import_tree.dart';
import 'package:verso/data/repos/environment_repo.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';

const tree = {
  'environments': [
    {
      'name': 'Claude App',
      'icon': 'sparkle',
      'color': 1,
      'projects': [
        {
          'name': 'Baladsho',
          'wip': true,
          'versions': [
            {
              'name': 'v1.0.0',
              'features': ['Restore purchases'],
            },
            {
              'name': 'v1.1.0',
              'features': [
                {
                  'title': 'Take Screenshots for Apps',
                  'steps': ['Snapp', 'Divar'],
                },
                'Set light UI as default',
              ],
            },
          ],
        },
        {
          'name': 'Nocturne Extension',
          'concept': ['Release Edge Version'],
        },
        {'name': 'CRTLab'},
      ],
    },
    {
      'name': 'Firefox',
      'icon': 'web',
      'projects': [
        {'name': 'Recon WFF'},
      ],
    },
  ],
};

void main() {
  late VersoDb db;
  setUp(() => db = VersoDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('imports environments, projects, versions, features and steps', () async {
    final r = await importTree(db, tree);
    expect((r.environments, r.projects, r.versions, r.features), (2, 4, 2, 4));
    final envs = await EnvironmentRepo(db).watchAll().first;
    // The empty default folder is reused for the first environment.
    expect(envs.map((e) => e.name), ['Claude App', 'Firefox']);
    expect(envs.first.icon, 'sparkle');
    final projects = await ProjectRepo(db).watchAll().first;
    expect(projects.map((p) => p.name), ['Baladsho', 'Nocturne Extension', 'CRTLab', 'Recon WFF']);
    final bal = projects.first;
    final vs = await VersionRepo(db).listForProject(bal.id);
    expect(vs.map((v) => v.name), ['Concept', 'v1.0.0', 'v1.1.0']);
    expect(vs.last.status, 'active'); // work in progress → latest version active
    final f = await FeatureRepo(db).watchFeatureViews(vs.last.id).first;
    expect(f.map((x) => x.f.title), ['Take Screenshots for Apps', 'Set light UI as default']);
    expect(f.first.subTotal, 2);
    final noc = projects[1];
    final concept = (await VersionRepo(db).listForProject(noc.id)).single;
    expect((await FeatureRepo(db).watchForVersion(concept.id).first).single.title, 'Release Edge Version');
    final placements = await EnvironmentRepo(db).watchPlacements().first;
    expect(placements.firstWhere((x) => x.projectId == projects.last.id).environmentId, envs.last.id);
  });

  test('importing twice adds nothing new', () async {
    await importTree(db, tree);
    final again = await importTree(db, tree);
    expect((again.projects, again.versions, again.features), (0, 0, 0));
    expect((await ProjectRepo(db).watchAll().first).length, 4);
  });
}
