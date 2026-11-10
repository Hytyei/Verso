import 'dart:convert';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import 'google_oauth.dart';
import 'token_store.dart';

enum AuthStatus { signedOut, signingIn, signedIn }

class AuthState {
  const AuthState(this.status, {this.account, this.error});
  const AuthState.signedOut({String? error}) : this(AuthStatus.signedOut, error: error);
  final AuthStatus status;
  final GoogleAccount? account;
  final String? error;
}

/// Overridden in main() with the DPAPI store.
final tokenStoreProvider = Provider<TokenStore>((ref) => MemoryTokenStore());

/// Opens the consent page; tests replace it.
final openBrowserProvider = Provider<Future<void> Function(Uri)>((ref) => openInBrowser);

/// The sign-in flow itself; tests replace it.
typedef SignInFn =
    Future<GoogleSession> Function(
      OAuthConfig, {
      required Future<void> Function(Uri) openBrowser,
      required TokenStore store,
      Future<void>? cancelled,
      bool Function()? stillWanted,
    });
final signInFnProvider = Provider<SignInFn>((ref) => signInWithGoogle);

/// Refresh-token exchange; tests replace it.
final refreshFnProvider = Provider<Future<TokenResponse> Function(OAuthConfig, String)>((ref) => refreshTokens);

/// Client from Settings, else the build-time --dart-define values.
final oauthConfigProvider = Provider<OAuthConfig>((ref) {
  final s = ref.watch(settingsProvider);
  const defId = String.fromEnvironment('GOOGLE_CLIENT_ID');
  const defSecret = String.fromEnvironment('GOOGLE_CLIENT_SECRET');
  return OAuthConfig(
    clientId: s.googleClientId.trim().isNotEmpty ? s.googleClientId.trim() : defId,
    clientSecret: s.googleClientSecret.trim().isNotEmpty ? s.googleClientSecret.trim() : defSecret,
  );
});

class AuthController extends Notifier<AuthState> {
  int _attempt = 0;
  Completer<void>? _cancel;

  void _abortPending() {
    _attempt++;
    final c = _cancel;
    _cancel = null;
    if (c != null && !c.isCompleted) c.complete();
  }

  @override
  AuthState build() {
    unawaited(_restore());
    return const AuthState.signedOut();
  }

  Future<void> _restore() async {
    final s = await ref.read(tokenStoreProvider).read();
    if (s != null && state.status == AuthStatus.signedOut) {
      state = AuthState(AuthStatus.signedIn, account: s.account);
    }
  }

  bool get configured => ref.read(oauthConfigProvider).isConfigured;

  String? _idToken;
  int _idTokenExp = 0;

  void _keepIdToken(String? token) {
    if (token == null) return;
    try {
      final payload = token.split('.')[1];
      final claims = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(payload)))) as Map<String, Object?>;
      _idTokenExp = (claims['exp'] as num?)?.toInt() ?? 0;
      _idToken = token;
    } catch (_) {}
  }

  /// A Google ID token valid for at least another minute (for the sync
  /// server). Refreshes it with the stored refresh token when needed.
  Future<String> idToken() async {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (_idToken != null && _idTokenExp - 60 > nowSec) return _idToken!;
    final s = await ref.read(tokenStoreProvider).read();
    if (s == null) throw const OAuthException('Not signed in');
    final t = await ref.read(refreshFnProvider)(ref.read(oauthConfigProvider), s.refreshToken);
    if (t.idToken == null) throw const OAuthException('Google returned no ID token');
    _keepIdToken(t.idToken);
    return t.idToken!;
  }

  Future<void> signIn() async {
    _abortPending();
    final attempt = _attempt;
    final cancel = _cancel = Completer<void>();
    state = const AuthState(AuthStatus.signingIn);
    try {
      final session = await ref.read(signInFnProvider)(
        ref.read(oauthConfigProvider),
        openBrowser: ref.read(openBrowserProvider),
        store: ref.read(tokenStoreProvider),
        cancelled: cancel.future,
        stillWanted: () => attempt == _attempt,
      );
      if (attempt == _attempt) {
        _keepIdToken(session.tokens.idToken);
        state = AuthState(AuthStatus.signedIn, account: session.account);
      }
    } on OAuthException catch (e) {
      if (attempt == _attempt) state = AuthState.signedOut(error: e.message == 'Cancelled' ? null : e.message);
    } catch (e) {
      if (attempt == _attempt) state = AuthState.signedOut(error: '$e');
    }
  }

  /// Stops waiting for the browser (the loopback times out on its own).
  void cancel() {
    _abortPending();
    state = const AuthState.signedOut();
  }

  Future<void> signOut() async {
    _idToken = null;
    _abortPending();
    await signOutOfGoogle(ref.read(oauthConfigProvider), store: ref.read(tokenStoreProvider));
    state = const AuthState.signedOut();
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
