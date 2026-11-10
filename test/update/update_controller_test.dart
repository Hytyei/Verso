import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/auth/auth_controller.dart';
import 'package:verso/update/update_controller.dart';

void main() {
  Map<String, Object?> latest(String tag) => {
    'tag_name': tag,
    'html_url': 'https://github.com/Hytyei/Verso/releases/tag/$tag',
    'assets': [
      {'name': 'Verso-${tag.substring(1)}-android.apk', 'browser_download_url': 'https://x/a.apk', 'size': 10},
      {'name': 'Verso-${tag.substring(1)}-windows-x64.zip', 'browser_download_url': 'https://x/w.zip', 'size': 10},
    ],
  };

  ({ProviderContainer c, List<String> log}) make({required bool android, bool canInstall = true, String tag = 'v9.0.0'}) {
    final log = <String>[];
    final c = ProviderContainer(
      overrides: [
        updatePlatformProvider.overrideWithValue(
          UpdatePlatform(
            android: android,
            fetch: () async => latest(tag),
            download: (info, onProgress) async {
              onProgress(.5);
              log.add('download ${info.assetUrl}');
              return File('x.apk');
            },
            canInstall: () async => canInstall,
            openInstallSettings: () async => log.add('settings'),
            install: (f) async => log.add('install ${f.path}'),
          ),
        ),
        openBrowserProvider.overrideWithValue((u) async => log.add('open $u')),
      ],
    );
    addTearDown(c.dispose);
    return (c: c, log: log);
  }

  test('a newer release becomes available; Android downloads then installs', () async {
    final t = make(android: true);
    await t.c.read(updateProvider.notifier).check();
    expect(t.c.read(updateProvider).phase, UpdatePhase.available);
    expect(t.c.read(updateProvider).info!.version, '9.0.0');
    await t.c.read(updateProvider.notifier).update();
    expect(t.log, ['download https://x/a.apk', 'install x.apk']);
  });

  test('without install permission, Android opens the setting first', () async {
    final t = make(android: true, canInstall: false);
    await t.c.read(updateProvider.notifier).check();
    await t.c.read(updateProvider.notifier).update();
    expect(t.log, ['settings']);
    expect(t.c.read(updateProvider).phase, UpdatePhase.needsPermission);
  });

  test('Windows opens the release page', () async {
    final t = make(android: false);
    await t.c.read(updateProvider.notifier).check();
    await t.c.read(updateProvider.notifier).update();
    expect(t.log, ['open https://github.com/Hytyei/Verso/releases/tag/v9.0.0']);
  });

  test('the same version is up to date', () async {
    final t = make(android: true, tag: 'v1.4.0');
    await t.c.read(updateProvider.notifier).check();
    expect(t.c.read(updateProvider).phase, UpdatePhase.upToDate);
  });
}
