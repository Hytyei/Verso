import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/environment_repo.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';
import 'package:verso/state/overview.dart';
import 'package:verso/state/settings.dart';

void main() {
  late VersoDb db;
  late String tandem, kobel, paused, astra;
  late String tV1, tV2, kV1;

  setUp(() async {
    db = VersoDb(NativeDatabase.memory());
    final projects = ProjectRepo(db), versions = VersionRepo(db);
    astra = await EnvironmentRepo(db).create('Astra', 'web', const VColor.slot(1));
    tandem = await projects.create('Tandem', const VColor.slot(0));
    kobel = await projects.create('Kobel', const VColor.slot(1), environmentId: astra);
    paused = await projects.create('Old idea', const VColor.slot(2));
    await projects.update(paused, paused: true);
    tV1 = await versions.create(tandem, 'v1.0.0');
    await versions.update(tV1, status: VersionStatus.released);
    tV2 = await versions.create(tandem, 'v1.1.0');
    kV1 = await versions.create(kobel, 'v2.0.0');
    await versions.create(paused, 'v0.1.0');
  });
  tearDown(() => db.close());

  Future<List<String>> names(OverviewFilter f) async {
    final ps = await ProjectRepo(db).watchAll().first;
    final vs = await VersionRepo(db).watchAll().first;
    final byId = {for (final p in ps) p.id: p.name};
    return [for (final v in overviewVersions(ps, vs, f)) '${byId[v.projectId]} ${v.name}'];
  }

  test('every project in sidebar order, Concept first, paused hidden by default', () async {
    expect(await names(const OverviewFilter()), [
      'Tandem Concept',
      'Tandem v1.0.0',
      'Tandem v1.1.0',
      'Kobel Concept',
      'Kobel v2.0.0',
    ]);
  });

  test('hiding a project, an environment, or released versions', () async {
    expect(await names(OverviewFilter(hiddenProjects: {tandem})), ['Kobel Concept', 'Kobel v2.0.0']);
    expect(await names(OverviewFilter(hiddenEnvironments: {astra})), ['Tandem Concept', 'Tandem v1.0.0', 'Tandem v1.1.0']);
    expect(await names(const OverviewFilter(hideReleased: true)), contains('Tandem v1.1.0'));
    expect(await names(const OverviewFilter(hideReleased: true)), isNot(contains('Tandem v1.0.0')));
    expect(await names(const OverviewFilter(hidePaused: false)), contains('Old idea v0.1.0'));
  });

  test('progress for every version comes from one query', () async {
    final f = FeatureRepo(db);
    final a = await f.create(tV2, 'A');
    await f.create(tV2, 'B');
    await f.setDone(a, true);
    await f.create(kV1, 'C');
    final all = await VersionRepo(db).watchProgressAll().first;
    expect(all[tV2], (done: 1, total: 2));
    expect(all[kV1], (done: 0, total: 1));
  });

  test('the filter survives a settings round trip', () {
    final s = Settings(timelineAll: true, overview: OverviewFilter(hiddenProjects: {'p1'}, hideReleased: true));
    final back = Settings.fromJson(s.toJson());
    expect(back.timelineAll, isTrue);
    expect(back.overview.hiddenProjects, {'p1'});
    expect(back.overview.hideReleased, isTrue);
    expect(back.overview.hidePaused, isTrue);
    expect(const Settings().stepsOnCards, isTrue);
  });
}
