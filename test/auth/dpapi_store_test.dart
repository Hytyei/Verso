import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:verso/auth/token_store.dart';

void main() {
  test('DPAPI store round-trips and the file is not plain text', () async {
    final dir = await Directory.systemTemp.createTemp('verso_dpapi');
    final store = DpapiTokenStore(File('${dir.path}/auth.bin'));
    const s = StoredSession(
      refreshToken: 'refresh-secret-123',
      account: GoogleAccount(id: '1', email: 'owner@example.com', name: 'Owner', pictureUrl: null),
    );
    await store.write(s);
    final raw = await File('${dir.path}/auth.bin').readAsBytes();
    expect(String.fromCharCodes(raw).contains('refresh-secret-123'), isFalse);
    final back = await store.read();
    expect((back!.refreshToken, back.account.email), ('refresh-secret-123', 'owner@example.com'));
    await store.clear();
    expect(await store.read(), isNull);
    await dir.delete(recursive: true);
  }, skip: !Platform.isWindows);
}
