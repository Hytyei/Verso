import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:verso/auth/token_store.dart';
import 'package:verso/platform/android_platform.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('verso_ks'));
  tearDown(() => dir.deleteSync(recursive: true));

  // A stand-in "cipher": reverses the bytes, so plain text never hits the file.
  Future<Uint8List> flip(Uint8List b) async => Uint8List.fromList(b.reversed.toList());

  const session = StoredSession(
    refreshToken: 'rt-123',
    account: GoogleAccount(id: 'sub', email: 'a@b.c', name: 'A', pictureUrl: null),
  );

  test('round-trips a session through the protector', () async {
    final store = KeystoreTokenStore(File('${dir.path}/auth.bin'), protect: flip, unprotect: flip);
    await store.write(session);
    expect(File('${dir.path}/auth.bin').readAsStringSync().contains('rt-123'), isFalse);
    final back = await store.read();
    expect(back!.refreshToken, 'rt-123');
    expect(back.account.email, 'a@b.c');
    await store.clear();
    expect(await store.read(), isNull);
  });

  test('an unreadable file means signed out, not a crash', () async {
    File('${dir.path}/auth.bin').writeAsBytesSync([1, 2, 3]);
    final store = KeystoreTokenStore(
      File('${dir.path}/auth.bin'),
      protect: flip,
      unprotect: (_) async => throw Exception('key gone'),
    );
    expect(await store.read(), isNull);
  });
}
