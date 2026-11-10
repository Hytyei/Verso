import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'token_store.dart';

export 'token_store.dart' show GoogleAccount, StoredSession;

/// A Google "Desktop app" OAuth client (from Google Cloud Console).
class OAuthConfig {
  const OAuthConfig({
    required this.clientId,
    required this.clientSecret,
    this.authEndpoint,
    this.tokenEndpoint,
    this.revokeEndpoint,
  });
  final String clientId;

  /// Desktop clients get a secret that Google itself says is not confidential.
  final String clientSecret;
  final Uri? authEndpoint;
  final Uri? tokenEndpoint;
  final Uri? revokeEndpoint;

  Uri get auth => authEndpoint ?? Uri.parse('https://accounts.google.com/o/oauth2/v2/auth');
  Uri get token => tokenEndpoint ?? Uri.parse('https://oauth2.googleapis.com/token');
  Uri get revoke => revokeEndpoint ?? Uri.parse('https://oauth2.googleapis.com/revoke');
  bool get isConfigured => clientId.trim().isNotEmpty;
}

class OAuthException implements Exception {
  const OAuthException(this.message);
  final String message;
  @override
  String toString() => 'OAuthException: $message';
}

const _unreserved = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

String _random(int n) {
  final r = Random.secure();
  return List.generate(n, (_) => _unreserved[r.nextInt(_unreserved.length)]).join();
}

/// RFC 7636 code verifier (64 unreserved characters).
String pkceVerifier() => _random(64);

/// S256 challenge: base64url(sha256(verifier)) without padding.
String pkceChallenge(String verifier) =>
    base64Url.encode(sha256.convert(ascii.encode(verifier)).bytes).replaceAll('=', '');

Uri authorizationUrl(
  OAuthConfig c, {
  required String redirectUri,
  required String state,
  required String codeChallenge,
}) => c.auth.replace(
  queryParameters: {
    'client_id': c.clientId,
    'redirect_uri': redirectUri,
    'response_type': 'code',
    'scope': 'openid email profile',
    'state': state,
    'code_challenge': codeChallenge,
    'code_challenge_method': 'S256',
    'access_type': 'offline',
    'prompt': 'consent',
  },
);

/// Reads the account from an ID token's payload. The token came straight
/// from Google's token endpoint over TLS, so it is not re-verified here;
/// the sync Worker verifies its signature.
GoogleAccount decodeIdToken(String idToken) {
  final parts = idToken.split('.');
  if (parts.length < 2) throw const OAuthException('Malformed ID token');
  final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))) as Map<String, Object?>;
  return GoogleAccount(
    id: payload['sub'] as String? ?? '',
    email: payload['email'] as String? ?? '',
    name: (payload['name'] as String?) ?? (payload['email'] as String? ?? ''),
    pictureUrl: payload['picture'] as String?,
  );
}

/// One-shot local HTTP server that receives Google's redirect.
class LoopbackServer {
  LoopbackServer._(this._server);
  final HttpServer _server;

  static Future<LoopbackServer> start() async =>
      LoopbackServer._(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));

  String get redirectUri => 'http://127.0.0.1:${_server.port}';

  bool _cancelled = false;

  /// Stops waiting: [waitForCode] then throws "Cancelled".
  Future<void> cancel() async {
    _cancelled = true;
    await _server.close(force: true);
  }

  /// Resolves with the authorization code; throws [OAuthException] on a
  /// state mismatch, a denied consent, cancel, or [timeout]. Closes the server.
  Future<String> waitForCode(String expectedState, {Duration timeout = const Duration(minutes: 5)}) async {
    try {
      await for (final req in _server.timeout(timeout, onTimeout: (s) => s.close())) {
        final q = req.uri.queryParameters;
        if (q.isEmpty) {
          req.response.statusCode = 404;
          await req.response.close();
          continue;
        }
        final error = q['error'];
        final ok = error == null && q['state'] == expectedState && (q['code'] ?? '').isNotEmpty;
        req.response.headers.contentType = ContentType.html;
        req.response.write(
          _page(
            ok ? 'Signed in to Verso' : 'Sign-in failed',
            ok ? 'You can close this tab and return to Verso.' : 'Return to Verso and try again.',
          ),
        );
        await req.response.close();
        if (error != null) throw OAuthException('Google returned $error');
        if (q['state'] != expectedState) throw const OAuthException('State mismatch');
        if ((q['code'] ?? '').isEmpty) throw const OAuthException('No authorization code');
        return q['code']!;
      }
      throw OAuthException(_cancelled ? 'Cancelled' : 'Timed out waiting for the browser');
    } finally {
      await _server.close(force: true);
    }
  }

  Future<void> close() => _server.close(force: true);

  static String _page(String title, String body) =>
      '<!doctype html><meta charset="utf-8"><title>$title</title>'
      '<body style="font-family:system-ui;background:#EEF2F8;color:#1E2A3B;display:grid;place-items:center;height:100vh;margin:0">'
      '<div style="text-align:center"><h2>$title</h2><p>$body</p></div></body>';
}

class TokenResponse {
  const TokenResponse({
    required this.accessToken,
    required this.idToken,
    required this.refreshToken,
    required this.expiresIn,
  });
  final String accessToken;
  final String? idToken;
  final String? refreshToken;
  final int expiresIn;
}

Future<Map<String, Object?>> _postForm(Uri url, Map<String, String> form) async {
  final client = HttpClient();
  try {
    final req = await client.postUrl(url);
    req.headers.contentType = ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');
    req.write(Uri(queryParameters: form).query);
    final res = await req.close();
    final body = await utf8.decoder.bind(res).join();
    if (res.statusCode >= 400) throw OAuthException('HTTP ${res.statusCode}: $body');
    return body.isEmpty ? const {} : jsonDecode(body) as Map<String, Object?>;
  } finally {
    client.close();
  }
}

Future<TokenResponse> exchangeCode(
  OAuthConfig c, {
  required String code,
  required String verifier,
  required String redirectUri,
}) async {
  final j = await _postForm(c.token, {
    'grant_type': 'authorization_code',
    'code': code,
    'code_verifier': verifier,
    'redirect_uri': redirectUri,
    'client_id': c.clientId,
    'client_secret': c.clientSecret,
  });
  return TokenResponse(
    accessToken: j['access_token'] as String? ?? '',
    idToken: j['id_token'] as String?,
    refreshToken: j['refresh_token'] as String?,
    expiresIn: (j['expires_in'] as num?)?.toInt() ?? 0,
  );
}

/// Exchanges a refresh token for a fresh access + ID token.
Future<TokenResponse> refreshTokens(OAuthConfig c, String refreshToken) async {
  final j = await _postForm(c.token, {
    'grant_type': 'refresh_token',
    'refresh_token': refreshToken,
    'client_id': c.clientId,
    'client_secret': c.clientSecret,
  });
  return TokenResponse(
    accessToken: j['access_token'] as String? ?? '',
    idToken: j['id_token'] as String?,
    refreshToken: refreshToken,
    expiresIn: (j['expires_in'] as num?)?.toInt() ?? 0,
  );
}

class GoogleSession {
  const GoogleSession(this.account, this.tokens);
  final GoogleAccount account;
  final TokenResponse tokens;
}

/// Opens the browser for consent, receives the code on a loopback port,
/// exchanges it with PKCE, and stores the refresh token.
///
/// [cancelled] stops the wait (the loopback port closes at once);
/// [stillWanted] is checked right before anything is stored, so a sign-in
/// the user abandoned can never leave a session behind.
Future<GoogleSession> signInWithGoogle(
  OAuthConfig c, {
  required Future<void> Function(Uri url) openBrowser,
  required TokenStore store,
  Future<void>? cancelled,
  bool Function()? stillWanted,
}) async {
  if (!c.isConfigured) throw const OAuthException('No Google client ID configured');
  final server = await LoopbackServer.start();
  cancelled?.then((_) => server.cancel());
  final redirect = server.redirectUri; // the port is gone once the server closes
  final verifier = pkceVerifier();
  final state = _random(24);
  final codeFuture = server.waitForCode(state);
  // If opening the browser fails, stop listening instead of waiting 5 min.
  codeFuture.ignore();
  try {
    await openBrowser(authorizationUrl(c, redirectUri: redirect, state: state, codeChallenge: pkceChallenge(verifier)));
  } catch (e) {
    await server.cancel();
    throw OAuthException('Could not open the browser: $e');
  }
  final code = await codeFuture;
  if (stillWanted != null && !stillWanted()) throw const OAuthException('Cancelled');
  final tokens = await exchangeCode(c, code: code, verifier: verifier, redirectUri: redirect);
  if (tokens.idToken == null) throw const OAuthException('Google returned no ID token');
  final account = decodeIdToken(tokens.idToken!);
  if (account.id.isEmpty) throw const OAuthException('ID token has no subject');
  if (stillWanted != null && !stillWanted()) throw const OAuthException('Cancelled');
  if (tokens.refreshToken != null) {
    await store.write(StoredSession(refreshToken: tokens.refreshToken!, account: account));
  }
  return GoogleSession(account, tokens);
}

/// Revokes the stored refresh token (best effort) and forgets it.
Future<void> signOutOfGoogle(OAuthConfig c, {required TokenStore store}) async {
  final s = await store.read();
  if (s != null) {
    try {
      await _postForm(c.revoke, {'token': s.refreshToken});
    } catch (_) {
      // Offline or already revoked: still sign out locally.
    }
  }
  await store.clear();
}

/// Opens [url] in the default browser (Windows).
Future<void> openInBrowser(Uri url) async {
  await Process.run('rundll32', ['url.dll,FileProtocolHandler', url.toString()]);
}
