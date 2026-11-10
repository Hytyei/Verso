/// Fractional indexing (after David Greenspan, "Implementing Fractional
/// Indexing"). Keys sort lexicographically by UTF-16 code unit, so a moved
/// row only needs a new key between its neighbours.
library;

const String _digits = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
const String _zero = 'a0';
final String _smallestInt = 'A${'0' * 26}';

int _integerLength(String head) {
  final c = head.codeUnitAt(0);
  if (c >= 0x61 && c <= 0x7A) return c - 0x61 + 2; // a..z
  if (c >= 0x41 && c <= 0x5A) return 0x5A - c + 2; // A..Z
  throw ArgumentError('invalid order key head: $head');
}

String _integerPart(String key) {
  final len = _integerLength(key[0]);
  if (len > key.length) throw ArgumentError('invalid order key: $key');
  return key.substring(0, len);
}

void _validate(String key) {
  if (key == _smallestInt) throw ArgumentError('invalid order key: $key');
  final i = _integerPart(key);
  final f = key.substring(i.length);
  if (f.endsWith('0')) throw ArgumentError('invalid order key: $key');
  for (final ch in key.split('')) {
    if (!_digits.contains(ch)) throw ArgumentError('invalid order key: $key');
  }
}

String _midpoint(String a, String? b) {
  if (b != null && a.compareTo(b) >= 0) {
    throw ArgumentError('$a >= $b');
  }
  if (a.endsWith('0') || (b != null && b.endsWith('0'))) {
    throw ArgumentError('trailing zero');
  }
  if (b != null) {
    var n = 0;
    while ((n < a.length ? a[n] : '0') == b[n]) {
      n++;
    }
    if (n > 0) {
      return b.substring(0, n) + _midpoint(n < a.length ? a.substring(n) : '', b.substring(n));
    }
  }
  final digitA = a.isNotEmpty ? _digits.indexOf(a[0]) : 0;
  final digitB = b != null ? _digits.indexOf(b[0]) : _digits.length;
  if (digitB - digitA > 1) {
    return _digits[((digitA + digitB) / 2).round()];
  }
  if (b != null && b.length > 1) return b.substring(0, 1);
  return _digits[digitA] + _midpoint(a.isNotEmpty ? a.substring(1) : '', null);
}

String? _increment(String x) {
  final head = x[0];
  final digs = x.substring(1).split('');
  var carry = true;
  for (var i = digs.length - 1; carry && i >= 0; i--) {
    final d = _digits.indexOf(digs[i]) + 1;
    if (d == _digits.length) {
      digs[i] = '0';
    } else {
      digs[i] = _digits[d];
      carry = false;
    }
  }
  if (carry) {
    if (head == 'Z') return 'a0';
    if (head == 'z') return null;
    final h = String.fromCharCode(head.codeUnitAt(0) + 1);
    if (h.compareTo('a') > 0) {
      digs.add('0');
    } else {
      digs.removeLast();
    }
    return h + digs.join();
  }
  return head + digs.join();
}

String? _decrement(String x) {
  final head = x[0];
  final digs = x.substring(1).split('');
  var borrow = true;
  for (var i = digs.length - 1; borrow && i >= 0; i--) {
    final d = _digits.indexOf(digs[i]) - 1;
    if (d == -1) {
      digs[i] = _digits[_digits.length - 1];
    } else {
      digs[i] = _digits[d];
      borrow = false;
    }
  }
  if (borrow) {
    if (head == 'a') return 'Z${_digits[_digits.length - 1]}';
    if (head == 'A') return null;
    final h = String.fromCharCode(head.codeUnitAt(0) - 1);
    if (h.compareTo('Z') < 0) {
      digs.add(_digits[_digits.length - 1]);
    } else {
      digs.removeLast();
    }
    return h + digs.join();
  }
  return head + digs.join();
}

/// A key strictly between [a] and [b]. `null` means the start / end.
String keyBetween(String? a, String? b) {
  if (a != null) _validate(a);
  if (b != null) _validate(b);
  if (a != null && b != null && a.compareTo(b) >= 0) {
    throw ArgumentError('$a >= $b');
  }
  if (a == null) {
    if (b == null) return _zero;
    final ib = _integerPart(b);
    final fb = b.substring(ib.length);
    if (ib == _smallestInt) return ib + _midpoint('', fb);
    if (ib.compareTo(b) < 0) return ib;
    final res = _decrement(ib);
    if (res == null) throw StateError('cannot decrement any more');
    return res;
  }
  if (b == null) {
    final ia = _integerPart(a);
    final fa = a.substring(ia.length);
    return _increment(ia) ?? ia + _midpoint(fa, null);
  }
  final ia = _integerPart(a);
  final fa = a.substring(ia.length);
  final ib = _integerPart(b);
  final fb = b.substring(ib.length);
  if (ia == ib) return ia + _midpoint(fa, fb);
  final i = _increment(ia);
  if (i == null) throw StateError('cannot increment any more');
  if (i.compareTo(b) < 0) return i;
  return ia + _midpoint(fa, null);
}

/// [n] ordered keys strictly between [a] and [b].
List<String> keysBetween(String? a, String? b, int n) {
  if (n <= 0) return const [];
  if (n == 1) return [keyBetween(a, b)];
  if (b == null) {
    var c = keyBetween(a, b);
    final out = [c];
    for (var i = 0; i < n - 1; i++) {
      c = keyBetween(c, b);
      out.add(c);
    }
    return out;
  }
  if (a == null) {
    var c = keyBetween(a, b);
    final out = [c];
    for (var i = 0; i < n - 1; i++) {
      c = keyBetween(a, c);
      out.add(c);
    }
    return out.reversed.toList();
  }
  final mid = n ~/ 2;
  final c = keyBetween(a, b);
  return [...keysBetween(a, c, mid), c, ...keysBetween(c, b, n - mid - 1)];
}
