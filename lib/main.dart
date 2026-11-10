import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'auth/auth_controller.dart';
import 'auth/google_oauth.dart';
import 'platform/android_platform.dart';
import 'widgets/widget_bridge.dart';
import 'auth/token_store.dart';
import 'sync/sync_controller.dart';
import 'sync/sync_engine.dart';
import 'data/db/database.dart';
import 'data/import_tree.dart';
import 'dev/perf_probe.dart';
import 'dev/seed.dart';
import 'platform/window.dart';
import 'state/providers.dart';
import 'state/settings.dart';
import 'ui/board/board_view.dart';
import 'ui/editors/wiring.dart';

/// Data lives in %APPDATA%\Verso; VERSO_DATA_DIR overrides it (sandbox runs).
Directory dataDirectory() {
  final override = Platform.environment['VERSO_DATA_DIR'];
  if (override != null && override.isNotEmpty) return Directory(override);
  final appData = Platform.environment['APPDATA'] ?? Directory.systemTemp.path;
  return Directory('$appData${Platform.pathSeparator}Verso');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) return mainAndroid();
  final dir = dataDirectory()..createSync(recursive: true);
  final db = VersoDb.open(dir);
  if (Platform.environment['VERSO_SEED'] == '1') await seedSampleData(db);
  final importPath = Platform.environment['VERSO_IMPORT'];
  if (importPath != null && importPath.isNotEmpty) {
    // Dev/one-off: import a JSON tree (see data/import_tree.dart), log the result.
    final tree = jsonDecode(File(importPath).readAsStringSync()) as Map<String, Object?>;
    final r = await importTree(db, tree, merge: tree['merge'] == true);
    File(
      '${dir.path}${Platform.pathSeparator}import.log',
    ).writeAsStringSync('${DateTime.now().toIso8601String()} $r\n', mode: FileMode.append);
  }
  if (Platform.environment['VERSO_PERF'] == '1') startPerfProbe(dir);
  await setupWindow();
  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        dataDirProvider.overrideWithValue(dir),
        settingsStoreProvider.overrideWithValue(
          FileSettingsStore(File('${dir.path}${Platform.pathSeparator}settings.json')),
        ),
        windowApiProvider.overrideWithValue(const DesktopWindowApi()),
        boardHooksProvider.overrideWithValue(appBoardHooks),
        tokenStoreProvider.overrideWithValue(DpapiTokenStore(File('${dir.path}${Platform.pathSeparator}auth.bin'))),
        syncStateStoreProvider.overrideWithValue(
          FileSyncStateStore(File('${dir.path}${Platform.pathSeparator}sync_state.json')),
        ),
        launchUpdateCheckProvider.overrideWithValue(true),
      ],
      child: const VersoApp(),
    ),
  );
}

/// Android: the app's private storage, Keystore-protected sign-in, the phone
/// layout, and the home-screen widgets.
Future<void> mainAndroid() async {
  final dir = await getApplicationSupportDirectory();
  final db = VersoDb.open(dir);
  const android = AndroidPlatform();
  final settingsStore = FileSettingsStore(File('${dir.path}/settings.json'));
  // The page after Google sign-in sends the browser back to the app.
  LoopbackServer.returnUrl = 'verso://signed-in';
  // Widget checkbox taps run widgetBackgroundCallback; never let this block startup.
  unawaited(HomeWidget.registerInteractivityCallback(widgetBackgroundCallback).then((_) {}, onError: (_) {}));
  WidgetPublisher(db, () => settingsStore.load().lastProjectId).start();
  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        dataDirProvider.overrideWithValue(dir),
        settingsStoreProvider.overrideWithValue(settingsStore),
        boardHooksProvider.overrideWithValue(appBoardHooks),
        touchModeProvider.overrideWithValue(true),
        openBrowserProvider.overrideWithValue(android.openUrl),
        tokenStoreProvider.overrideWithValue(
          KeystoreTokenStore(File('${dir.path}/auth.bin'), protect: android.protect, unprotect: android.unprotect),
        ),
        syncStateStoreProvider.overrideWithValue(FileSyncStateStore(File('${dir.path}/sync_state.json'))),
        launchUpdateCheckProvider.overrideWithValue(true),
      ],
      child: const VersoApp(),
    ),
  );
}
