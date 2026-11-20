import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../data/models.dart';
import '../data/repos/project_repo.dart' show Progress;
import 'providers.dart';
import 'settings.dart';

/// The versions the all-projects timeline shows, in display order: projects in
/// sidebar order, and within each its Concept stage first, then releases in
/// board order. Versions in hidden environments or projects are left out, and
/// so are released versions and paused projects when the filter says so.
List<Version> overviewVersions(List<Project> projects, List<Version> versions, OverviewFilter f) {
  final byProject = <String, List<Version>>{};
  for (final v in versions) {
    (byProject[v.projectId] ??= []).add(v);
  }
  return [
    for (final p in projects)
      if (!p.archived && !f.hiddenProjects.contains(p.id) && !(f.hidePaused && p.paused))
        for (final v in [
          ...?byProject[p.id]?.where((v) => v.kind == 'concept'),
          ...?byProject[p.id]?.where((v) => v.kind != 'concept'),
        ])
          if (!f.hiddenEnvironments.contains(v.environmentId) &&
              !(f.hideReleased && v.status == VersionStatus.released.name))
            v,
  ];
}

final allVersionsProvider = StreamProvider<List<Version>>((ref) => ref.watch(versionRepoProvider).watchAll());
final allDatedFeaturesProvider = StreamProvider<List<Feature>>(
  (ref) => ref.watch(featureRepoProvider).watchDatedAll(),
);
final allMilestonesProvider = StreamProvider<List<Milestone>>((ref) => ref.watch(milestoneRepoProvider).watchAll());
final allProgressProvider = StreamProvider<Map<String, Progress>>(
  (ref) => ref.watch(versionRepoProvider).watchProgressAll(),
);
