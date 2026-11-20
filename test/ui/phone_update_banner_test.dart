import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/state/providers.dart';
import 'package:verso/update/update_controller.dart';

import 'harness.dart';

void main() {
  testWidgets('a phone with no projects still shows the update banner', (t) async {
    final h = await Harness.pump(
      t,
      size: const Size(412, 900),
      overrides: [
        touchModeProvider.overrideWithValue(true),
        updatePlatformProvider.overrideWithValue(
          UpdatePlatform(
            android: true,
            fetch: () async => {
              'tag_name': 'v99.0.0',
              'html_url': 'https://github.com/Hytyei/Verso/releases/tag/v99.0.0',
              'assets': [
                {'name': 'Verso-99.0.0-android.apk', 'browser_download_url': 'https://x/a.apk', 'size': 1},
              ],
            },
            download: (info, onProgress) async => File('x.apk'),
            canInstall: () async => true,
            openInstallSettings: () async {},
            install: (_) async {},
          ),
        ),
      ],
    );
    expect(find.text('Track your first app'), findsOneWidget);
    expect(find.byKey(const Key('update-banner')), findsNothing);

    await t.runAsync(() => h.container.read(updateProvider.notifier).check());
    await Harness.settle(t);
    expect(find.byKey(const Key('update-banner')), findsOneWidget);
    expect(find.text('Verso 99.0.0 is ready'), findsOneWidget);
    await h.dispose(t);
  });
}
