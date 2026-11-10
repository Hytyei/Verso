import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';

import '../data/db/database.dart';
import '../data/repos/feature_repo.dart';
import '../state/settings.dart';
import 'widget_snapshot.dart';

const _providers = [
  'design.hadi.verso.widget.CurrentVersionWidget',
  'design.hadi.verso.widget.ProgressGlanceWidget',
];

/// Writes the snapshot for the home-screen widgets and redraws them.
Future<void> publishWidgetSnapshot(VersoDb db, {String? lastProjectId}) async {
  final snap = await buildWidgetSnapshot(db, lastProjectId: lastProjectId);
  await HomeWidget.saveWidgetData<String>('snapshot', jsonEncode(snap));
  for (final name in _providers) {
    await HomeWidget.updateWidget(qualifiedAndroidName: name);
  }
}

/// Keeps the widgets current while the app runs: one second after any
/// change (local edits and rows pulled by sync alike).
class WidgetPublisher {
  WidgetPublisher(this.db, this.lastProjectId);
  final VersoDb db;
  final String? Function() lastProjectId;
  StreamSubscription<Object?>? _sub;
  Timer? _debounce;

  void start() {
    _sub = db.tableUpdates().listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 1), publish);
    });
    publish();
  }

  Future<void> publish() async {
    try {
      await publishWidgetSnapshot(db, lastProjectId: lastProjectId());
    } catch (e) {
      debugPrint('widget snapshot failed: $e');
    }
  }

  void dispose() {
    _debounce?.cancel();
    _sub?.cancel();
  }
}

/// Runs in a background isolate when a widget checkbox is tapped
/// (`verso://toggle?feature=<id>`): marks the task done and redraws.
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null || uri.host != 'toggle') return;
  final id = uri.queryParameters['feature'];
  if (id == null || id.isEmpty) return;
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();
  final db = VersoDb.open(dir);
  try {
    await FeatureRepo(db).setDone(id, true);
    final settings = FileSettingsStore(File('${dir.path}${Platform.pathSeparator}settings.json')).load();
    await publishWidgetSnapshot(db, lastProjectId: settings.lastProjectId);
  } finally {
    await db.close();
  }
}
