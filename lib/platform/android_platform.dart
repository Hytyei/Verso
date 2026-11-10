import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../auth/token_store.dart';

/// Android-only services from `MainActivity.kt` (channel `verso/platform`).
class AndroidPlatform {
  const AndroidPlatform([this._channel = const MethodChannel('verso/platform')]);
  final MethodChannel _channel;

  Future<Uint8List> protect(Uint8List data) async =>
      (await _channel.invokeMethod<Uint8List>('protect', {'data': data}))!;
  Future<Uint8List> unprotect(Uint8List data) async =>
      (await _channel.invokeMethod<Uint8List>('unprotect', {'data': data}))!;

  Future<void> openUrl(Uri url) => _channel.invokeMethod('openUrl', {'url': url.toString()});
  Future<String> appVersion() async => (await _channel.invokeMethod<String>('appVersion')) ?? '0.0.0';

  /// Whether Android lets Verso install APKs ("install unknown apps").
  Future<bool> canInstall() async => (await _channel.invokeMethod<bool>('canInstall')) ?? false;
  Future<void> openInstallSettings() => _channel.invokeMethod('openInstallSettings');
  Future<void> installApk(String path) => _channel.invokeMethod('installApk', {'path': path});
}

/// Session file in the app's private storage, encrypted with a byte-level
/// protector (in the app: AES-GCM with an Android Keystore key).
class KeystoreTokenStore implements TokenStore {
  KeystoreTokenStore(this.file, {required this.protect, required this.unprotect});
  final File file;
  final Future<Uint8List> Function(Uint8List) protect;
  final Future<Uint8List> Function(Uint8List) unprotect;

  @override
  Future<StoredSession?> read() async {
    try {
      if (!file.existsSync()) return null;
      final plain = await unprotect(await file.readAsBytes());
      return StoredSession.fromJson(jsonDecode(utf8.decode(plain)) as Map<String, Object?>);
    } catch (_) {
      return null; // unreadable (key reset, reinstall): signed out
    }
  }

  @override
  Future<void> write(StoredSession s) async {
    await file.parent.create(recursive: true);
    await file.writeAsBytes(await protect(Uint8List.fromList(utf8.encode(jsonEncode(s.toJson())))), flush: true);
  }

  @override
  Future<void> clear() async {
    if (file.existsSync()) await file.delete();
  }
}
