import 'package:drift/drift.dart' show Value;
import 'db/database.dart';
import 'models.dart';
import 'repos/environment_repo.dart';
import 'repos/feature_repo.dart';
import 'repos/project_repo.dart';
import 'repos/version_repo.dart';

/// What an import added.
typedef ImportResult = ({int environments, int projects, int versions, int features});

/// Imports a tree of environments → projects → (concept ideas, versions →
/// features → steps), e.g. converted from a Todoist project.
///
/// JSON shape:
/// `{environments: [{name, icon?, color?, projects: [{name, wip?, concept?: [feature],
///   versions?: [{name, status?, features: [feature]}]}]}]}`
/// where a feature is a string or `{title, steps?: [step], priority?: 0-3, done?: bool, notes?}`
/// and a step is a string or `{title, done?}`.
///
/// Idempotent by name. Without [merge], existing projects and versions are left
/// alone (only new ones are filled). With [merge]:
/// - a project is found by name in any environment (the owner may have moved it);
/// - existing versions, the Concept stage and existing features receive only the
///   features / steps they don't have yet (matched by title, case-insensitive);
/// - new versions are placed in version-number order among the existing ones.
Future<ImportResult> importTree(VersoDb db, Map<String, Object?> tree, {bool merge = false}) async {
  final envRepo = EnvironmentRepo(db);
  final projects = ProjectRepo(db);
  final versions = VersionRepo(db);
  final features = FeatureRepo(db);
  var nEnv = 0, nProj = 0, nVer = 0, nFeat = 0;

  String norm(String s) => s.trim().toLowerCase();
  Map<String, Object?> asMap(Object? item) =>
      item is String ? <String, Object?>{'title': item} : (item as Map).cast<String, Object?>();

  Future<void> addSteps(String featureId, List<Object?> steps) async {
    final have = {for (final s in await features.watchSubitems(featureId).first) norm(s.title)};
    for (final raw in steps) {
      final m = asMap(raw);
      final title = (m['title'] as String? ?? '').trim();
      if (title.isEmpty || have.contains(norm(title))) continue;
      final id = await features.addSubitem(featureId, title);
      if (m['done'] == true) await features.updateSubitem(id, done: true);
      have.add(norm(title));
    }
  }

  Future<void> addFeatures(String versionId, List<Object?> list) async {
    final existing = {for (final f in await features.watchForVersion(versionId).first) norm(f.title): f.id};
    for (final item in list) {
      final m = asMap(item);
      final title = (m['title'] as String? ?? '').trim();
      if (title.isEmpty) continue;
      final steps = (m['steps'] as List?) ?? const [];
      final known = existing[norm(title)];
      if (known != null) {
        if (merge) await addSteps(known, steps);
        continue;
      }
      final id = await features.create(versionId, title);
      final priority = (m['priority'] as num?)?.toInt() ?? 0;
      final notes = (m['notes'] as String?)?.trim();
      if (priority > 0 || (notes != null && notes.isNotEmpty)) {
        await features.update(
          id,
          priority: priority > 0 ? priority.clamp(0, 3) : null,
          notes: notes == null || notes.isEmpty ? const Value.absent() : Value(notes),
        );
      }
      if (m['done'] == true) await features.setDone(id, true);
      await addSteps(id, steps);
      existing[norm(title)] = id;
      nFeat++;
    }
  }

  final envList = (tree['environments'] as List? ?? const []).cast<Map>();
  for (final (ei, raw) in envList.indexed) {
    final e = raw.cast<String, Object?>();
    final name = (e['name'] as String).trim();
    final icon = e['icon'] as String? ?? 'folder';
    final color = VColor.slot((e['color'] as num?)?.toInt() ?? ei % 4);

    // The environment is created lazily: in merge mode every project may
    // already live elsewhere, and then no new folder is needed.
    String? envId;
    Future<String> ensureEnv() async {
      if (envId != null) return envId!;
      final existing = await envRepo.watchAll().first;
      var env = existing.where((x) => norm(x.name) == norm(name)).firstOrNull;
      if (env == null) {
        final placements = await envRepo.watchPlacements().first;
        final emptyDefault = existing.length == 1 && existing.first.name == 'My apps' && placements.isEmpty;
        if (emptyDefault) {
          await envRepo.update(existing.first.id, name: name, icon: icon, color: color);
        } else {
          await envRepo.create(name, icon, color);
        }
        env = (await envRepo.watchAll().first).firstWhere((x) => norm(x.name) == norm(name));
        nEnv++;
      }
      return envId = env.id;
    }

    final projectList = ((e['projects'] as List?) ?? const []).cast<Map>();
    if (projectList.isEmpty && !merge) await ensureEnv();
    for (final (pi, rawP) in projectList.indexed) {
      final p = rawP.cast<String, Object?>();
      final pName = (p['name'] as String).trim();
      final all = await projects.watchAll().first;
      Project? proj;
      if (merge) {
        proj = all.where((x) => norm(x.name) == norm(pName)).firstOrNull;
      } else {
        final id = await ensureEnv();
        final placements = await envRepo.watchPlacements().first;
        proj = all
            .where((x) => x.name == pName && placements.any((pl) => pl.projectId == x.id && pl.environmentId == id))
            .firstOrNull;
      }
      final String projectId;
      final bool created;
      if (proj == null) {
        projectId = await projects.create(pName, VColor.slot((pi + ei) % 4), environmentId: await ensureEnv());
        nProj++;
        created = true;
      } else {
        projectId = proj.id;
        created = false;
      }
      final concept = (await versions.listForProject(projectId)).first;
      if (created || merge) await addFeatures(concept.id, (p['concept'] as List?) ?? const []);

      String? lastCreated;
      for (final rawV in ((p['versions'] as List?) ?? const []).cast<Map>()) {
        final v = rawV.cast<String, Object?>();
        final vName = (v['name'] as String).trim();
        final status = VersionStatus.values.where((s) => s.name == v['status']).firstOrNull;
        final have = await versions.listForProject(projectId);
        final existing = have.where((x) => norm(x.name) == norm(vName)).firstOrNull;
        if (existing != null) {
          if (merge) await addFeatures(existing.id, (v['features'] as List?) ?? const []);
          continue;
        }
        // New versions continue in the environment of the project's latest version.
        final envForVersion = have.isEmpty ? await ensureEnv() : have.last.environmentId;
        final vid = await versions.create(projectId, vName, environmentId: envForVersion);
        // Keep version-number order: go before the first existing release that is newer.
        final newer = have
            .where((x) => x.kind == 'release' && compareVersionNames(x.name, vName) > 0)
            .firstOrNull;
        if (newer != null) await versions.move(vid, beforeId: newer.id);
        if (status != null) await versions.update(vid, status: status);
        lastCreated = vid;
        nVer++;
        await addFeatures(vid, (v['features'] as List?) ?? const []);
      }
      if (p['wip'] == true && lastCreated != null) {
        await versions.update(lastCreated, status: VersionStatus.active);
      }
    }
  }
  return (environments: nEnv, projects: nProj, versions: nVer, features: nFeat);
}
