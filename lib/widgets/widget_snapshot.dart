import '../data/db/database.dart';
import '../data/repos/environment_repo.dart';
import '../data/repos/feature_repo.dart';
import '../data/repos/project_repo.dart';
import '../data/repos/version_repo.dart';

/// How many open tasks a widget may show.
const widgetOpenLimit = 8;

/// The version a widget shows for a project: the first *active* release, else
/// the first one not released yet, else the Concept stage. [versions] are in
/// board order with Concept first.
Version? widgetVersionOf(List<Version> versions) {
  if (versions.isEmpty) return null;
  final releases = versions.where((v) => v.kind == 'release').toList();
  return releases.where((v) => v.status == 'active').firstOrNull ??
      releases.where((v) => v.status != 'released').firstOrNull ??
      versions.firstWhere((v) => v.kind == 'concept', orElse: () => versions.first);
}

/// The JSON the Android widgets read (android/.../widget/WidgetData.kt):
/// `{last, projects: [{id, name, env, slot, custom, version: {id, name, done, total}, open: [{id, title}]}]}`.
/// Paused and archived projects are left out.
Future<Map<String, Object?>> buildWidgetSnapshot(VersoDb db, {String? lastProjectId}) async {
  final envs = {for (final e in await EnvironmentRepo(db).watchAll().first) e.id: e.name};
  final versionsRepo = VersionRepo(db);
  final featuresRepo = FeatureRepo(db);
  final out = <Map<String, Object?>>[];
  for (final p in await ProjectRepo(db).watchAll().first) {
    if (p.paused || p.archived) continue;
    final v = widgetVersionOf(await versionsRepo.listForProject(p.id));
    if (v == null) continue;
    final features = await featuresRepo.watchForVersion(v.id).first;
    final open = features.where((f) => !f.done).take(widgetOpenLimit);
    out.add({
      'id': p.id,
      'name': p.name,
      'env': envs[v.environmentId] ?? '',
      'slot': p.colorCustom ? 0 : p.color,
      'custom': p.colorCustom ? p.color : null,
      'version': {
        'id': v.id,
        'name': v.name,
        'done': features.where((f) => f.done).length,
        'total': features.length,
      },
      'open': [
        for (final f in open) {'id': f.id, 'title': f.title},
      ],
    });
  }
  return {'last': lastProjectId, 'projects': out};
}
