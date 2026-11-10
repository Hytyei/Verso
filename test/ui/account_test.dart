import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/auth/auth_controller.dart';
import 'package:verso/auth/google_oauth.dart';
import 'package:verso/auth/token_store.dart';
import 'package:verso/state/settings.dart';

import 'board_test.dart' show seedBasic;
import 'harness.dart';

void main() {
  const account = GoogleAccount(id: '7', email: 'owner@example.com', name: 'Owner', pictureUrl: null);

  testWidgets('without a client id, sign-in points to Settings', (t) async {
    final h = await Harness.pump(t, seed: (db) => seedBasic(db));
    await t.tap(find.byKey(const Key('sign-in-google')));
    await Harness.settle(t);
    expect(find.text('Add your Google client ID in Settings first'), findsOneWidget);
    expect(find.byKey(const Key('google-client-id')), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('signing in shows the account and sign out returns to the button', (t) async {
    final store = MemoryTokenStore();
    OAuthConfig? used;
    final h = await Harness.pump(
      t,
      settings: const Settings(googleClientId: 'cid.apps.googleusercontent.com', googleClientSecret: 's'),
      seed: (db) => seedBasic(db),
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        signInFnProvider.overrideWithValue((c, {required openBrowser, required store, cancelled, stillWanted}) async {
          used = c;
          await store.write(const StoredSession(refreshToken: 'rt', account: account));
          return GoogleSession(
            account,
            const TokenResponse(accessToken: 'a', idToken: 'i', refreshToken: 'rt', expiresIn: 1),
          );
        }),
      ],
    );
    await t.tap(find.byKey(const Key('sign-in-google')));
    await Harness.settle(t);
    expect(used!.clientId, 'cid.apps.googleusercontent.com');
    expect(find.text('Owner'), findsOneWidget);
    // The second line shows sync state; the email lives in the account menu.
    expect(find.text('Ready to sync'), findsOneWidget);
    await t.tapAt(t.getCenter(find.byKey(const Key('account-signed-in'))), buttons: kPrimaryButton);
    await Harness.settle(t);
    expect(find.text('owner@example.com'), findsOneWidget);
    expect(find.text('Sync now'), findsOneWidget);
    await t.tap(find.text('Sign out'));
    await Harness.settle(t);
    expect(find.byKey(const Key('sign-in-google')), findsOneWidget);
    expect(await t.runAsync(() => store.read()), isNull);
    await h.dispose(t);
  });

  testWidgets('a stored session is restored on launch', (t) async {
    final store = MemoryTokenStore();
    await store.write(const StoredSession(refreshToken: 'rt', account: account));
    final h = await Harness.pump(
      t,
      seed: (db) => seedBasic(db),
      overrides: [tokenStoreProvider.overrideWithValue(store)],
    );
    expect(find.text('Owner'), findsOneWidget);
    await h.dispose(t);
  });
}
