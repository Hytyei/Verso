import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// The public repo whose releases the app updates from.
const releasesApi = 'https://api.github.com/repos/Hytyei/Verso/releases/latest';

/// Compares dotted version numbers ("v1.10.0" > "1.9.2"); a leading "v" and
/// any "-suffix" / "+build" are ignored.
int compareVersions(String a, String b) {
  List<int> parts(String s) {
    final core = s.trim().replaceFirst(RegExp(r'^[vV]'), '').split(RegExp(r'[-+]')).first;
    return [for (final x in core.split('.')) int.tryParse(x) ?? 0];
  }

  final x = parts(a), y = parts(b);
  for (var i = 0; i < 3; i++) {
    final d = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
    if (d != 0) return d.sign;
  }
  return 0;
}

class UpdateInfo {
  const UpdateInfo({required this.version, required this.assetUrl, required this.assetSize, required this.pageUrl, required this.notes});
  final String version;

  /// The `.apk` (Android) or `-windows-x64.zip` (Windows) download.
  final String assetUrl;
  final int assetSize;
  final String pageUrl;
  final String notes;
}

/// Reads GitHub's "latest release" JSON. Returns the update when its tag is
/// newer than [current] and it carries a file for this platform.
UpdateInfo? parseLatestRelease(Map<String, Object?> json, String current, {required bool android}) {
  if (json['draft'] == true || json['prerelease'] == true) return null;
  final tag = json['tag_name'] as String? ?? '';
  if (tag.isEmpty || compareVersions(tag, current) <= 0) return null;
  final assets = (json['assets'] as List? ?? const []).cast<Map>();
  final asset = assets.where((a) {
    final name = (a['name'] as String? ?? '').toLowerCase();
    return android ? name.endsWith('.apk') : name.endsWith('windows-x64.zip');
  }).firstOrNull;
  if (asset == null) return null;
  return UpdateInfo(
    version: tag.replaceFirst(RegExp(r'^[vV]'), ''),
    assetUrl: asset['browser_download_url'] as String,
    assetSize: (asset['size'] as num?)?.toInt() ?? 0,
    pageUrl: json['html_url'] as String? ?? '',
    notes: json['body'] as String? ?? '',
  );
}

/// GET the latest release. Throws on network errors.
Future<Map<String, Object?>> fetchLatestRelease({HttpClient? client}) async {
  final c = client ?? HttpClient();
  c.connectionTimeout = const Duration(seconds: 15);
  try {
    final req = await c.getUrl(Uri.parse(releasesApi));
    req.headers
      ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
      ..set(HttpHeaders.userAgentHeader, 'Verso-app');
    final res = await req.close().timeout(const Duration(seconds: 20));
    final body = await res.transform(utf8.decoder).join();
    if (res.statusCode == 404) return const {}; // no release yet
    if (res.statusCode != 200) throw HttpException('GitHub answered ${res.statusCode}');
    return (jsonDecode(body) as Map).cast<String, Object?>();
  } finally {
    if (client == null) c.close();
  }
}

/// Downloads [url] to [file], reporting progress 0..1 (follows GitHub's redirect to its CDN).
Future<File> downloadTo(String url, File file, {void Function(double)? onProgress, int expectedSize = 0}) async {
  final c = HttpClient()..connectionTimeout = const Duration(seconds: 20);
  try {
    final req = await c.getUrl(Uri.parse(url));
    req.headers.set(HttpHeaders.userAgentHeader, 'Verso-app');
    final res = await req.close();
    if (res.statusCode != 200) throw HttpException('Download failed (${res.statusCode})');
    final total = res.contentLength > 0 ? res.contentLength : expectedSize;
    await file.parent.create(recursive: true);
    final part = File('${file.path}.part');
    final sink = part.openWrite();
    var got = 0;
    await for (final chunk in res) {
      sink.add(chunk);
      got += chunk.length;
      if (total > 0) onProgress?.call((got / total).clamp(0, 1));
    }
    await sink.close();
    if (total > 0 && got != total) throw const HttpException('Download was cut off');
    if (file.existsSync()) file.deleteSync();
    return part.renameSync(file.path);
  } finally {
    c.close();
  }
}
