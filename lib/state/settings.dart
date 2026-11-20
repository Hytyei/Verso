import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// Persisted UI preferences.
@immutable
class Settings {
  const Settings({
    this.themeMode = ThemeMode.system,
    this.reduceMotion = false,
    this.lastProjectId,
    this.lastView = 'board',
    this.sidebarCollapsed = false,
    this.googleClientId = '',
    this.googleClientSecret = '',
    this.syncUrl = defaultSyncUrl,
    this.stepsOnCards = true,
    this.timelineAll = false,
    this.overview = const OverviewFilter(),
  });

  final ThemeMode themeMode;
  final bool reduceMotion;
  final String? lastProjectId;
  final String lastView;
  final bool sidebarCollapsed;

  /// Google "Desktop app" OAuth client (empty = use the build-time default).
  final String googleClientId;
  final String googleClientSecret;

  /// verso-api address; empty turns sync off.
  final String syncUrl;
  static const defaultSyncUrl = 'https://verso-api.thehdv7.workers.dev';

  /// Collapsed cards list their steps (v1.5.0).
  final bool stepsOnCards;

  /// The timeline shows every project instead of the open one (v1.5.0).
  final bool timelineAll;

  /// What the all-projects timeline hides.
  final OverviewFilter overview;

  Settings copyWith({
    ThemeMode? themeMode,
    bool? reduceMotion,
    String? lastProjectId,
    String? lastView,
    bool? sidebarCollapsed,
    String? googleClientId,
    String? googleClientSecret,
    String? syncUrl,
    bool? stepsOnCards,
    bool? timelineAll,
    OverviewFilter? overview,
  }) => Settings(
    themeMode: themeMode ?? this.themeMode,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    lastProjectId: lastProjectId ?? this.lastProjectId,
    lastView: lastView ?? this.lastView,
    sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
    googleClientId: googleClientId ?? this.googleClientId,
    googleClientSecret: googleClientSecret ?? this.googleClientSecret,
    syncUrl: syncUrl ?? this.syncUrl,
    stepsOnCards: stepsOnCards ?? this.stepsOnCards,
    timelineAll: timelineAll ?? this.timelineAll,
    overview: overview ?? this.overview,
  );

  Map<String, Object?> toJson() => {
    'themeMode': themeMode.name,
    'reduceMotion': reduceMotion,
    'lastProjectId': lastProjectId,
    'lastView': lastView,
    'sidebarCollapsed': sidebarCollapsed,
    'googleClientId': googleClientId,
    'googleClientSecret': googleClientSecret,
    'syncUrl': syncUrl,
    'stepsOnCards': stepsOnCards,
    'timelineAll': timelineAll,
    'overview': overview.toJson(),
  };

  factory Settings.fromJson(Map<String, Object?> j) => Settings(
    themeMode: ThemeMode.values.firstWhere((m) => m.name == j['themeMode'], orElse: () => ThemeMode.system),
    reduceMotion: j['reduceMotion'] == true,
    lastProjectId: j['lastProjectId'] as String?,
    lastView: (j['lastView'] as String?) ?? 'board',
    sidebarCollapsed: j['sidebarCollapsed'] == true,
    googleClientId: (j['googleClientId'] as String?) ?? '',
    googleClientSecret: (j['googleClientSecret'] as String?) ?? '',
    syncUrl: (j['syncUrl'] as String?) ?? defaultSyncUrl,
    stepsOnCards: j['stepsOnCards'] != false,
    timelineAll: j['timelineAll'] == true,
    overview: j['overview'] is Map ? OverviewFilter.fromJson((j['overview'] as Map).cast()) : const OverviewFilter(),
  );
}

/// What the all-projects timeline hides. Stored as what is *hidden*, so new
/// projects and environments show up without touching the filter.
@immutable
class OverviewFilter {
  const OverviewFilter({
    this.hiddenEnvironments = const {},
    this.hiddenProjects = const {},
    this.hideReleased = false,
    this.hidePaused = true,
  });
  final Set<String> hiddenEnvironments;
  final Set<String> hiddenProjects;
  final bool hideReleased;
  final bool hidePaused;

  bool get isActive => hiddenEnvironments.isNotEmpty || hiddenProjects.isNotEmpty || hideReleased || !hidePaused;

  OverviewFilter copyWith({
    Set<String>? hiddenEnvironments,
    Set<String>? hiddenProjects,
    bool? hideReleased,
    bool? hidePaused,
  }) => OverviewFilter(
    hiddenEnvironments: hiddenEnvironments ?? this.hiddenEnvironments,
    hiddenProjects: hiddenProjects ?? this.hiddenProjects,
    hideReleased: hideReleased ?? this.hideReleased,
    hidePaused: hidePaused ?? this.hidePaused,
  );

  Map<String, Object?> toJson() => {
    'hiddenEnvironments': hiddenEnvironments.toList(),
    'hiddenProjects': hiddenProjects.toList(),
    'hideReleased': hideReleased,
    'hidePaused': hidePaused,
  };

  factory OverviewFilter.fromJson(Map<String, Object?> j) => OverviewFilter(
    hiddenEnvironments: {...((j['hiddenEnvironments'] as List?) ?? const []).cast<String>()},
    hiddenProjects: {...((j['hiddenProjects'] as List?) ?? const []).cast<String>()},
    hideReleased: j['hideReleased'] == true,
    hidePaused: j['hidePaused'] != false,
  );
}

/// Where settings live. Tests use [MemorySettingsStore].
abstract class SettingsStore {
  Settings load();
  void save(Settings s);
}

class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore([this._s = const Settings()]);
  Settings _s;
  @override
  Settings load() => _s;
  @override
  void save(Settings s) => _s = s;
}

/// `settings.json` beside the database.
class FileSettingsStore implements SettingsStore {
  FileSettingsStore(this.file);
  final File file;

  @override
  Settings load() {
    try {
      return Settings.fromJson(jsonDecode(file.readAsStringSync()) as Map<String, Object?>);
    } catch (_) {
      return const Settings();
    }
  }

  @override
  void save(Settings s) {
    try {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(s.toJson()));
    } catch (_) {
      // Settings are a convenience; never crash the UI over them.
    }
  }
}
