import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:verso/update/updater.dart';
import 'package:verso/version.dart';

void main() {
  test('compares version numbers numerically', () {
    expect(compareVersions('v1.10.0', '1.9.2'), 1);
    expect(compareVersions('1.4.0', 'v1.4.0'), 0);
    expect(compareVersions('v1.4', '1.4.1'), -1);
    expect(compareVersions('v2.0.0-beta', '1.99.0'), 1);
  });

  Map<String, Object?> release(String tag, List<String> assets) => {
    'tag_name': tag,
    'html_url': 'https://github.com/Hytyei/Verso/releases/tag/$tag',
    'body': 'notes',
    'assets': [
      for (final a in assets) {'name': a, 'browser_download_url': 'https://x/$a', 'size': 42},
    ],
  };

  test('offers a newer release with a file for this platform', () {
    final r = release('v1.5.0', ['Verso-1.5.0-android.apk', 'Verso-1.5.0-windows-x64.zip']);
    final a = parseLatestRelease(r, '1.4.0', android: true)!;
    expect((a.version, a.assetUrl, a.assetSize), ('1.5.0', 'https://x/Verso-1.5.0-android.apk', 42));
    expect(parseLatestRelease(r, '1.4.0', android: false)!.assetUrl, endsWith('windows-x64.zip'));
  });

  test('ignores same, older, draft, and file-less releases', () {
    expect(parseLatestRelease(release('v1.4.0', ['a.apk']), '1.4.0', android: true), isNull);
    expect(parseLatestRelease(release('v1.3.0', ['a.apk']), '1.4.0', android: true), isNull);
    expect(parseLatestRelease(release('v1.5.0', ['Verso-windows-x64.zip']), '1.4.0', android: true), isNull);
    expect(parseLatestRelease({...release('v1.5.0', ['a.apk']), 'draft': true}, '1.4.0', android: true), isNull);
    expect(parseLatestRelease(const {}, '1.4.0', android: true), isNull);
  });

  test('appVersionName matches pubspec.yaml', () {
    final line = File('pubspec.yaml').readAsLinesSync().firstWhere((l) => l.startsWith('version:'));
    expect(line.split(':')[1].trim().split('+').first, appVersionName);
  });
}
