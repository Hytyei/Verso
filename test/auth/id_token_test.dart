import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/auth/auth_controller.dart';
import 'package:verso/auth/google_oauth.dart';
import 'package:verso/auth/token_store.dart';

String jwt(int exp) {
  String b64(Object o) => base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${b64({'alg': 'RS256'})}.${b64({'sub': '1', 'exp': exp})}.sig';
}

void main() {
  test('idToken refreshes with the stored refresh token and caches until near expiry', () async {
    final store = MemoryTokenStore();
    await store.write(
      const StoredSession(
        refreshToken: 'rt',
        account: GoogleAccount(id: '1', email: 'e', name: 'n', pictureUrl: null),
      ),
    );
    var refreshes = 0;
    final exp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
    final c = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        refreshFnProvider.overrideWithValue((cfg, rt) async {
          refreshes++;
          expect(rt, 'rt');
          return TokenResponse(accessToken: 'a', idToken: jwt(exp), refreshToken: rt, expiresIn: 3600);
        }),
      ],
    );
    addTearDown(c.dispose);
    final t1 = await c.read(authProvider.notifier).idToken();
    final t2 = await c.read(authProvider.notifier).idToken();
    expect(t1, t2);
    expect(refreshes, 1);
  });

  test('idToken without a session fails clearly', () async {
    final c = ProviderContainer(overrides: [tokenStoreProvider.overrideWithValue(MemoryTokenStore())]);
    addTearDown(c.dispose);
    await expectLater(c.read(authProvider.notifier).idToken(), throwsA(isA<OAuthException>()));
  });
}
