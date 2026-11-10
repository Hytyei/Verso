import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/auth/google_oauth.dart';
import 'package:verso/auth/token_store.dart';

String _jwt(Map<String, Object?> claims) {
  String b64(Object o) => base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${b64({'alg': 'RS256'})}.${b64(claims)}.sig';
}

void main() {
  test('pkce challenge is base64url sha256 of verifier', () {
    final v = pkceVerifier();
    expect(v.length, inInclusiveRange(43, 128));
    expect(RegExp(r'^[A-Za-z0-9\-._~]+$').hasMatch(v), isTrue);
    final expected = base64Url.encode(sha256.convert(ascii.encode(v)).bytes).replaceAll('=', '');
    expect(pkceChallenge(v), expected);
    expect(pkceChallenge(v).contains('='), isFalse);
  });

  test('auth url carries client id, redirect, scopes, state, challenge', () {
    const cfg = OAuthConfig(clientId: 'cid.apps.googleusercontent.com', clientSecret: 's');
    final u = authorizationUrl(cfg, redirectUri: 'http://127.0.0.1:5555', state: 'st', codeChallenge: 'ch');
    expect(u.host, 'accounts.google.com');
    expect(u.queryParameters['client_id'], 'cid.apps.googleusercontent.com');
    expect(u.queryParameters['redirect_uri'], 'http://127.0.0.1:5555');
    expect(u.queryParameters['response_type'], 'code');
    expect(u.queryParameters['scope'], 'openid email profile');
    expect(u.queryParameters['state'], 'st');
    expect(u.queryParameters['code_challenge'], 'ch');
    expect(u.queryParameters['code_challenge_method'], 'S256');
    expect(u.queryParameters['access_type'], 'offline');
  });

  test('decodeIdToken reads the account', () {
    final a = decodeIdToken(_jwt({'sub': '42', 'email': 'a@b.c', 'name': 'Ada', 'picture': 'https://p/x.png'}));
    expect((a.id, a.email, a.name, a.pictureUrl), ('42', 'a@b.c', 'Ada', 'https://p/x.png'));
  });

  test('loopback rejects wrong state', () async {
    final server = await LoopbackServer.start();
    final code = server.waitForCode('expected');
    final client = HttpClient();
    final req = await client.getUrl(Uri.parse('${server.redirectUri}/?code=abc&state=evil'));
    final res = await req.close();
    await res.drain<void>();
    await expectLater(code, throwsA(isA<OAuthException>()));
    client.close();
  });

  test('loopback reports a denied consent', () async {
    final server = await LoopbackServer.start();
    final code = server.waitForCode('s');
    final client = HttpClient();
    await (await (await client.getUrl(
      Uri.parse('${server.redirectUri}/?error=access_denied&state=s'),
    )).close()).drain<void>();
    await expectLater(
      code,
      throwsA(isA<OAuthException>().having((e) => e.message, 'message', contains('access_denied'))),
    );
    client.close();
  });

  group('full flow against a fake token endpoint', () {
    late HttpServer fake;
    late List<Map<String, String>> tokenRequests;
    late List<String> revoked;
    late OAuthConfig cfg;

    setUp(() async {
      tokenRequests = [];
      revoked = [];
      fake = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      fake.listen((req) async {
        final body = Uri.splitQueryString(await utf8.decoder.bind(req).join());
        if (req.uri.path == '/token') {
          tokenRequests.add(body);
          req.response.headers.contentType = ContentType.json;
          req.response.write(
            jsonEncode({
              'access_token': 'at',
              'expires_in': 3599,
              'refresh_token': 'rt-1',
              'id_token': _jwt({
                'sub': '7',
                'email': 'owner@example.com',
                'name': 'Owner',
                'picture': 'https://p/o.png',
              }),
            }),
          );
        } else if (req.uri.path == '/revoke') {
          revoked.add(body['token'] ?? '');
        }
        await req.response.close();
      });
      final base = 'http://127.0.0.1:${fake.port}';
      cfg = OAuthConfig(
        clientId: 'cid',
        clientSecret: 'secret',
        tokenEndpoint: Uri.parse('$base/token'),
        revokeEndpoint: Uri.parse('$base/revoke'),
      );
    });
    tearDown(() => fake.close(force: true));

    Future<void> fakeBrowser(Uri authUrl) async {
      // Plays the browser: Google redirects back with a code and the same state.
      final redirect = authUrl.queryParameters['redirect_uri']!;
      final state = authUrl.queryParameters['state']!;
      final c = HttpClient();
      await (await (await c.getUrl(Uri.parse('$redirect/?code=the-code&state=$state'))).close()).drain<void>();
      c.close();
    }

    test('signs in and stores refresh token', () async {
      final store = MemoryTokenStore();
      final session = await signInWithGoogle(cfg, openBrowser: fakeBrowser, store: store);
      expect(session.account.email, 'owner@example.com');
      expect(tokenRequests.single['grant_type'], 'authorization_code');
      expect(tokenRequests.single['code'], 'the-code');
      expect(tokenRequests.single['client_secret'], 'secret');
      expect(tokenRequests.single['code_verifier'], isNotEmpty);
      final saved = await store.read();
      expect(saved!.refreshToken, 'rt-1');
      expect(saved.account.name, 'Owner');
    });

    test('a cancelled sign-in never stores a session', () async {
      final store = MemoryTokenStore();
      final cancel = Completer<void>();
      final run = signInWithGoogle(
        cfg,
        store: store,
        cancelled: cancel.future,
        openBrowser: (url) async {
          // The user cancels in Verso, then finishes consent in the old tab.
          cancel.complete();
          await Future<void>.delayed(const Duration(milliseconds: 20));
          try {
            await fakeBrowser(url);
          } catch (_) {}
        },
      );
      await expectLater(run, throwsA(isA<OAuthException>()));
      expect(await store.read(), isNull);
    });

    test('a sign-in that is no longer wanted does not store', () async {
      final store = MemoryTokenStore();
      await expectLater(
        signInWithGoogle(cfg, openBrowser: fakeBrowser, store: store, stillWanted: () => false),
        throwsA(isA<OAuthException>()),
      );
      expect(await store.read(), isNull);
    });

    test('sign out revokes and clears store', () async {
      final store = MemoryTokenStore();
      await signInWithGoogle(cfg, openBrowser: fakeBrowser, store: store);
      await signOutOfGoogle(cfg, store: store);
      expect(revoked, ['rt-1']);
      expect(await store.read(), isNull);
    });
  });

  test('stored session round-trips through json', () {
    const s = StoredSession(
      refreshToken: 'r',
      account: GoogleAccount(id: '1', email: 'e', name: 'n', pictureUrl: null),
    );
    final back = StoredSession.fromJson(jsonDecode(jsonEncode(s.toJson())) as Map<String, Object?>);
    expect((back.refreshToken, back.account.email, back.account.pictureUrl), ('r', 'e', null));
  });
}
