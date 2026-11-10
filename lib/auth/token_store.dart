import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

/// The signed-in Google account.
class GoogleAccount {
  const GoogleAccount({required this.id, required this.email, required this.name, required this.pictureUrl});
  final String id;
  final String email;
  final String name;
  final String? pictureUrl;

  Map<String, Object?> toJson() => {'id': id, 'email': email, 'name': name, 'picture': pictureUrl};
  factory GoogleAccount.fromJson(Map<String, Object?> j) => GoogleAccount(
    id: j['id'] as String? ?? '',
    email: j['email'] as String? ?? '',
    name: j['name'] as String? ?? '',
    pictureUrl: j['picture'] as String?,
  );
}

/// What survives a restart: the refresh token and the account it belongs to.
class StoredSession {
  const StoredSession({required this.refreshToken, required this.account});
  final String refreshToken;
  final GoogleAccount account;

  Map<String, Object?> toJson() => {'refresh_token': refreshToken, 'account': account.toJson()};
  factory StoredSession.fromJson(Map<String, Object?> j) => StoredSession(
    refreshToken: j['refresh_token'] as String? ?? '',
    account: GoogleAccount.fromJson((j['account'] as Map).cast<String, Object?>()),
  );
}

abstract class TokenStore {
  Future<StoredSession?> read();
  Future<void> write(StoredSession s);
  Future<void> clear();
}

class MemoryTokenStore implements TokenStore {
  StoredSession? _s;
  @override
  Future<StoredSession?> read() async => _s;
  @override
  Future<void> write(StoredSession s) async => _s = s;
  @override
  Future<void> clear() async => _s = null;
}

/// Session file encrypted with Windows DPAPI (current user scope): only
/// this Windows account on this PC can decrypt it.
class DpapiTokenStore implements TokenStore {
  DpapiTokenStore(this.file);
  final File file;

  @override
  Future<StoredSession?> read() async {
    try {
      if (!file.existsSync()) return null;
      final plain = _unprotect(await file.readAsBytes());
      return StoredSession.fromJson(jsonDecode(utf8.decode(plain)) as Map<String, Object?>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(StoredSession s) async {
    await file.parent.create(recursive: true);
    await file.writeAsBytes(_protect(utf8.encode(jsonEncode(s.toJson()))), flush: true);
  }

  @override
  Future<void> clear() async {
    if (file.existsSync()) await file.delete();
  }
}

// ---- DPAPI via FFI ----

final class _Blob extends Struct {
  @Uint32()
  external int cbData;
  external Pointer<Uint8> pbData;
}

typedef _CryptNative =
    Int32 Function(
      Pointer<_Blob>,
      Pointer<Utf16>,
      Pointer<_Blob>,
      Pointer<Void>,
      Pointer<Void>,
      Uint32,
      Pointer<_Blob>,
    );
typedef _CryptDart =
    int Function(Pointer<_Blob>, Pointer<Utf16>, Pointer<_Blob>, Pointer<Void>, Pointer<Void>, int, Pointer<_Blob>);
typedef _CryptUnNative =
    Int32 Function(
      Pointer<_Blob>,
      Pointer<Pointer<Utf16>>,
      Pointer<_Blob>,
      Pointer<Void>,
      Pointer<Void>,
      Uint32,
      Pointer<_Blob>,
    );
typedef _CryptUnDart =
    int Function(
      Pointer<_Blob>,
      Pointer<Pointer<Utf16>>,
      Pointer<_Blob>,
      Pointer<Void>,
      Pointer<Void>,
      int,
      Pointer<_Blob>,
    );

final _crypt32 = DynamicLibrary.open('crypt32.dll');
final _kernel32 = DynamicLibrary.open('kernel32.dll');
final _protectFn = _crypt32.lookupFunction<_CryptNative, _CryptDart>('CryptProtectData');
final _unprotectFn = _crypt32.lookupFunction<_CryptUnNative, _CryptUnDart>('CryptUnprotectData');
final _localFree = _kernel32
    .lookupFunction<Pointer<Void> Function(Pointer<Void>), Pointer<Void> Function(Pointer<Void>)>('LocalFree');
const _uiForbidden = 0x1;

Uint8List _run(Uint8List data, bool protect) {
  final input = calloc<_Blob>();
  final output = calloc<_Blob>();
  final buf = calloc<Uint8>(data.isEmpty ? 1 : data.length);
  try {
    buf.asTypedList(data.length).setAll(0, data);
    input.ref
      ..cbData = data.length
      ..pbData = buf;
    final ok = protect
        ? _protectFn(input, nullptr, nullptr, nullptr, nullptr, _uiForbidden, output)
        : _unprotectFn(input, nullptr, nullptr, nullptr, nullptr, _uiForbidden, output);
    if (ok == 0) throw const FileSystemException('DPAPI failed');
    final result = Uint8List.fromList(output.ref.pbData.asTypedList(output.ref.cbData));
    _localFree(output.ref.pbData.cast());
    return result;
  } finally {
    calloc.free(buf);
    calloc.free(input);
    calloc.free(output);
  }
}

Uint8List _protect(List<int> data) => _run(Uint8List.fromList(data), true);
Uint8List _unprotect(List<int> data) => _run(Uint8List.fromList(data), false);
