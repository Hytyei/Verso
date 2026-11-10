import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/attachment_store.dart';
import '../data/db/database.dart';
import '../data/models.dart';
import '../data/repos/environment_repo.dart';
import '../data/repos/feature_repo.dart';
import '../data/repos/milestone_repo.dart';
import '../data/repos/project_repo.dart';
import '../data/repos/tag_repo.dart';
import '../data/repos/version_repo.dart';
import '../data/undo.dart';
import '../platform/window.dart';
import '../ui/theme/motion.dart';
import 'settings.dart';

/// Overridden in main() and in tests.
final dbProvider = Provider<VersoDb>((ref) => throw UnimplementedError('dbProvider not overridden'));
final dataDirProvider = Provider<Directory>((ref) => throw UnimplementedError('dataDirProvider not overridden'));
final settingsStoreProvider = Provider<SettingsStore>((ref) => MemorySettingsStore());
final windowApiProvider = Provider<WindowApi>((ref) => const NoopWindowApi());

final projectRepoProvider = Provider((ref) => ProjectRepo(ref.watch(dbProvider)));
final versionRepoProvider = Provider((ref) => VersionRepo(ref.watch(dbProvider)));
final featureRepoProvider = Provider((ref) => FeatureRepo(ref.watch(dbProvider)));
final milestoneRepoProvider = Provider((ref) => MilestoneRepo(ref.watch(dbProvider)));
final tagRepoProvider = Provider((ref) => TagRepo(ref.watch(dbProvider)));
final undoProvider = Provider((ref) => UndoStack());
final attachmentStoreProvider = Provider(
  (ref) => AttachmentStore(
    ref.watch(dbProvider),
    Directory('${ref.watch(dataDirProvider).path}${Platform.pathSeparator}attachments'),
  ),
);

class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() {
    final s = ref.watch(settingsStoreProvider).load();
    Motion.reduceSetting.value = s.reduceMotion;
    return s;
  }

  void update(Settings Function(Settings) f) {
    state = f(state);
    Motion.reduceSetting.value = state.reduceMotion;
    ref.read(settingsStoreProvider).save(state);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

final projectsProvider = StreamProvider<List<Project>>((ref) => ref.watch(projectRepoProvider).watchAll());

/// The open project: the last one used, else the first, else null.
class SelectedProject extends Notifier<String?> {
  @override
  String? build() {
    final projects = ref.watch(projectsProvider).value ?? const [];
    final last = ref.read(settingsProvider).lastProjectId;
    if (projects.any((p) => p.id == last)) return last;
    return projects.isEmpty ? null : projects.first.id;
  }

  void select(String id) {
    state = id;
    ref.read(settingsProvider.notifier).update((s) => s.copyWith(lastProjectId: id));
  }
}

final selectedProjectIdProvider = NotifierProvider<SelectedProject, String?>(SelectedProject.new);

final environmentRepoProvider = Provider((ref) => EnvironmentRepo(ref.watch(dbProvider)));
final environmentsProvider = StreamProvider<List<Environment>>((ref) => ref.watch(environmentRepoProvider).watchAll());
final placementsProvider = StreamProvider<List<Placement>>(
  (ref) => ref.watch(environmentRepoProvider).watchPlacements(),
);

/// The environment folder the open project is shown from. Keeps the chosen
/// one while the project still has versions there, otherwise falls back to
/// the project's latest segment (where development continues).
class SelectedEnvironment extends Notifier<String?> {
  String? _chosen;

  @override
  String? build() {
    final projectId = ref.watch(selectedProjectIdProvider);
    final placements = ref.watch(placementsProvider).value ?? const <Placement>[];
    if (projectId == null) return null;
    final envs = [
      for (final x in placements)
        if (x.projectId == projectId) x.environmentId,
    ];
    if (_chosen != null && envs.contains(_chosen)) return _chosen;
    final versions = ref.watch(versionsProvider(projectId)).value ?? const <Version>[];
    for (final v in versions.reversed) {
      if (v.environmentId != null && envs.contains(v.environmentId)) return v.environmentId;
    }
    return envs.isEmpty ? null : envs.first;
  }

  void set(String? envId) {
    _chosen = envId;
    state = envId;
  }
}

final selectedEnvironmentIdProvider = NotifierProvider<SelectedEnvironment, String?>(SelectedEnvironment.new);

/// Opens [projectId] as seen from the [environmentId] folder.
void openSegment(WidgetRef ref, String projectId, String environmentId) {
  ref.read(selectedProjectIdProvider.notifier).select(projectId);
  ref.read(selectedEnvironmentIdProvider.notifier).set(environmentId);
}

enum ViewMode { board, timeline }

class ViewModeNotifier extends Notifier<ViewMode> {
  @override
  ViewMode build() => ref.read(settingsProvider).lastView == 'timeline' ? ViewMode.timeline : ViewMode.board;

  void set(ViewMode m) {
    state = m;
    ref.read(settingsProvider.notifier).update((s) => s.copyWith(lastView: m.name));
  }
}

final viewModeProvider = NotifierProvider<ViewModeNotifier, ViewMode>(ViewModeNotifier.new);

class FeatureFilter {
  const FeatureFilter({this.tagIds = const {}, this.minPriority, this.done = DoneFilter.all});
  final Set<String> tagIds;
  final int? minPriority;
  final DoneFilter done;
  bool get isActive => tagIds.isNotEmpty || minPriority != null || done != DoneFilter.all;
  FeatureFilter copyWith({Set<String>? tagIds, int? Function()? minPriority, DoneFilter? done}) => FeatureFilter(
    tagIds: tagIds ?? this.tagIds,
    minPriority: minPriority != null ? minPriority() : this.minPriority,
    done: done ?? this.done,
  );
}

class ValueNotifierOf<T> extends Notifier<T> {
  ValueNotifierOf(this._initial);
  final T _initial;
  @override
  T build() => _initial;
  void set(T v) => state = v;
}

final searchQueryProvider = NotifierProvider<ValueNotifierOf<String>, String>(() => ValueNotifierOf(''));
final filterProvider = NotifierProvider<ValueNotifierOf<FeatureFilter>, FeatureFilter>(
  () => ValueNotifierOf(const FeatureFilter()),
);

/// Feature the keyboard acts on (Space, F2, Del, Ctrl+D).
final focusedFeatureProvider = NotifierProvider<ValueNotifierOf<String?>, String?>(() => ValueNotifierOf(null));

/// Card currently expanded on the board.
final expandedFeatureProvider = NotifierProvider<ValueNotifierOf<String?>, String?>(() => ValueNotifierOf(null));

final versionsProvider = StreamProvider.family<List<Version>, String>(
  (ref, projectId) => ref.watch(versionRepoProvider).watchForProject(projectId),
);
final featureViewsProvider = StreamProvider.family<List<FeatureView>, String>(
  (ref, versionId) => ref.watch(featureRepoProvider).watchFeatureViews(versionId),
);
final tagsProvider = StreamProvider.family<List<Tag>, String>(
  (ref, projectId) => ref.watch(tagRepoProvider).watchForProject(projectId),
);
final milestonesProvider = StreamProvider.family<List<Milestone>, String>(
  (ref, projectId) => ref.watch(milestoneRepoProvider).watchForProject(projectId),
);
final projectProgressProvider = StreamProvider.family<Progress, String>(
  (ref, projectId) => ref.watch(projectRepoProvider).watchProgress(projectId),
);
final versionProgressProvider = StreamProvider.family<Progress, String>(
  (ref, versionId) => ref.watch(versionRepoProvider).watchProgress(versionId),
);
final delayedInProvider = StreamProvider.family<int, String>(
  (ref, versionId) => ref.watch(versionRepoProvider).watchDelayedIn(versionId),
);
final datedFeaturesProvider = StreamProvider.family<List<Feature>, String>(
  (ref, projectId) => ref.watch(featureRepoProvider).watchDatedForProject(projectId),
);

/// Ctrl+N: the version whose add row should open (cleared once handled).
final addFeatureRequestProvider = NotifierProvider<ValueNotifierOf<String?>, String?>(() => ValueNotifierOf(null));

/// F2: the feature whose title should enter edit mode (cleared once handled).
final renameRequestProvider = NotifierProvider<ValueNotifierOf<String?>, String?>(() => ValueNotifierOf(null));
