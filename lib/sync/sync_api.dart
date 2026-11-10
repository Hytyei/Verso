import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// One row on the wire: table, id, updatedAt, deleted, and the row as JSON.
class WireRow {
  const WireRow({required this.t, required this.id, required this.u, required this.d, required this.data});
  final String t;
  final String id;
  final int u;
  final bool d;
  final Map<String, dynamic> data;

  Map<String, Object?> toJson() => {'t': t, 'id': id, 'u': u, 'd': d, 'data': data};
  factory WireRow.fromJson(Map<String, dynamic> j) => WireRow(
    t: j['t'] as String,
    id: j['id'] as String,
    u: (j['u'] as num).toInt(),
    d: j['d'] == true,
    data: (j['data'] as Map).cast<String, dynamic>(),
  );
}

class SyncPage {
  const SyncPage({required this.cursor, required this.more, required this.rows});
  final int cursor;
  final bool more;
  final List<WireRow> rows;
}

class SyncApiException implements Exception {
  const SyncApiException(this.status, this.message);
  final int status;
  final String message;
  @override
  String toString() => status == 0 ? message : '$message ($status)';
}

/// HTTP client for verso-api. [token] returns a fresh Google ID token.
class SyncApi {
  SyncApi(this.baseUrl, this.token, {this.timeout = const Duration(seconds: 30)});
  final String baseUrl;
  final Future<String> Function() token;
  final Duration timeout;

  /// Rows per push; the server accepts at most 40.
  static const maxPush = 40;

  Uri _u(String path) =>
      Uri.parse(baseUrl.endsWith('/') ? '${baseUrl.substring(0, baseUrl.length - 1)}$path' : '$baseUrl$path');

  Future<HttpClientResponse> _send(String method, String path, {List<int>? body, String? contentType}) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final req = await client.openUrl(method, _u(path)).timeout(timeout);
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${await token()}');
      if (contentType != null) req.headers.set(HttpHeaders.contentTypeHeader, contentType);
      if (body != null) {
        req.contentLength = body.length;
        req.add(body);
      }
      return await req.close().timeout(timeout);
    } on SocketException catch (e) {
      throw SyncApiException(0, 'Offline or server unreachable (${e.message})');
    } on TimeoutException {
      throw const SyncApiException(0, 'The server took too long to answer');
    } finally {
      client.close();
    }
  }

  Future<Never> _fail(HttpClientResponse res) async {
    final text = await utf8.decoder.bind(res).join();
    String msg;
    try {
      msg = (jsonDecode(text) as Map)['error'] as String? ?? 'Request failed';
    } catch (_) {
      msg = 'Request failed';
    }
    throw SyncApiException(res.statusCode, msg);
  }

  Future<SyncPage> sync(int cursor, List<WireRow> rows) async {
    final res = await _send(
      'POST',
      '/v1/sync',
      body: utf8.encode(
        jsonEncode({
          'cursor': cursor,
          'rows': [for (final r in rows) r.toJson()],
        }),
      ),
      contentType: 'application/json',
    );
    if (res.statusCode != 200) await _fail(res);
    final j = jsonDecode(await utf8.decoder.bind(res).join()) as Map<String, dynamic>;
    return SyncPage(
      cursor: (j['cursor'] as num).toInt(),
      more: j['more'] == true,
      rows: [for (final r in (j['rows'] as List)) WireRow.fromJson((r as Map).cast<String, dynamic>())],
    );
  }

  Future<bool> hasBlob(String name) async {
    final res = await _send('HEAD', '/v1/blobs/${Uri.encodeComponent(name)}');
    await res.drain<void>();
    if (res.statusCode == 404) return false;
    if (res.statusCode != 200) throw SyncApiException(res.statusCode, 'Could not check an image');
    return true;
  }

  Future<void> putBlob(String name, Uint8List bytes) async {
    final res = await _send(
      'PUT',
      '/v1/blobs/${Uri.encodeComponent(name)}',
      body: bytes,
      contentType: 'application/octet-stream',
    );
    if (res.statusCode != 201) await _fail(res);
    await res.drain<void>();
  }

  /// The image bytes, or null when the server doesn't have them.
  Future<Uint8List?> getBlob(String name) async {
    final res = await _send('GET', '/v1/blobs/${Uri.encodeComponent(name)}');
    if (res.statusCode == 404) {
      await res.drain<void>();
      return null;
    }
    if (res.statusCode != 200) await _fail(res);
    final b = BytesBuilder(copy: false);
    await for (final c in res) {
      b.add(c);
    }
    return b.takeBytes();
  }
}
