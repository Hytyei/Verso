import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../auth/auth_controller.dart';
import '../platform/android_platform.dart';
import '../version.dart';
import 'updater.dart';

enum UpdatePhase { idle, checking, upToDate, available, downloading, needsPermission, installing, failed }

class UpdateState {
  const UpdateState(this.phase, {this.info, this.progress = 0, this.error, this.dismissed = false});
  final UpdatePhase phase;
  final UpdateInfo? info;
  final double progress;
  final String? error;

  /// The owner closed the banner for this version.
  final bool dismissed;

  UpdateState copyWith({UpdatePhase? phase, double? progress, String? error, bool? dismissed}) => UpdateState(
    phase ?? this.phase,
    info: info,
    progress: progress ?? this.progress,
    error: error,
    dismissed: dismissed ?? this.dismissed,
  );
}

/// Platform pieces of an update, swappable in tests.
class UpdatePlatform {
  const UpdatePlatform({
    required this.android,
    required this.fetch,
    required this.download,
    required this.canInstall,
    required this.openInstallSettings,
    required this.install,
  });
  final bool android;
  final Future<Map<String, Object?>> Function() fetch;
  final Future<File> Function(UpdateInfo info, void Function(double) onProgress) download;
  final Future<bool> Function() canInstall;
  final Future<void> Function() openInstallSettings;
  final Future<void> Function(File apk) install;

  static UpdatePlatform real() {
    const android = AndroidPlatform();
    return UpdatePlatform(
      android: Platform.isAndroid,
      fetch: fetchLatestRelease,
      download: (info, onProgress) async {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}${Platform.pathSeparator}updates${Platform.pathSeparator}Verso-${info.version}.apk');
        return downloadTo(info.assetUrl, file, onProgress: onProgress, expectedSize: info.assetSize);
      },
      canInstall: android.canInstall,
      openInstallSettings: android.openInstallSettings,
      install: (f) => android.installApk(f.path),
    );
  }
}

final updatePlatformProvider = Provider<UpdatePlatform>((ref) => UpdatePlatform.real());

/// Checks GitHub for a newer release. On Android it downloads the APK and
/// hands it to the package installer; on Windows it opens the release page.
class UpdateController extends Notifier<UpdateState> {
  @override
  UpdateState build() => const UpdateState(UpdatePhase.idle);

  Future<void> check() async {
    if (state.phase == UpdatePhase.checking || state.phase == UpdatePhase.downloading) return;
    final plat = ref.read(updatePlatformProvider);
    state = const UpdateState(UpdatePhase.checking);
    try {
      final info = parseLatestRelease(await plat.fetch(), appVersionName, android: plat.android);
      state = info == null ? const UpdateState(UpdatePhase.upToDate) : UpdateState(UpdatePhase.available, info: info);
    } catch (e) {
      state = UpdateState(UpdatePhase.failed, error: 'Couldn\'t check for updates ($e)');
    }
  }

  /// Download and install (Android) or open the release page (Windows).
  Future<void> update() async {
    final info = state.info;
    if (info == null) return;
    final plat = ref.read(updatePlatformProvider);
    if (!plat.android) {
      await ref.read(openBrowserProvider)(Uri.parse(info.pageUrl));
      return;
    }
    if (!await plat.canInstall()) {
      state = state.copyWith(phase: UpdatePhase.needsPermission);
      await plat.openInstallSettings();
      return;
    }
    state = state.copyWith(phase: UpdatePhase.downloading, progress: 0);
    try {
      final apk = await plat.download(info, (p) => state = state.copyWith(progress: p));
      state = state.copyWith(phase: UpdatePhase.installing, progress: 1);
      await plat.install(apk);
      // Android shows its own install dialog; if the owner backs out, the banner stays.
      state = state.copyWith(phase: UpdatePhase.available);
    } catch (e) {
      state = UpdateState(UpdatePhase.failed, info: info, error: 'Update failed ($e)');
    }
  }

  void dismiss() => state = state.copyWith(dismissed: true);
}

final updateProvider = NotifierProvider<UpdateController, UpdateState>(UpdateController.new);
