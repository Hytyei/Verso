import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/sort_key.dart';

void main() {
  test('first key', () => expect(keyBetween(null, null), isNotEmpty));
  test('between', () {
    final k = keyBetween('a0', 'a1');
    expect(k.compareTo('a0') > 0 && k.compareTo('a1') < 0, isTrue);
  });
  test('before first / after last', () {
    expect(keyBetween(null, 'a0').compareTo('a0') < 0, isTrue);
    expect(keyBetween('a0', null).compareTo('a0') > 0, isTrue);
  });
  test('1000 inserts at head stay ordered and short', () {
    String? first;
    final ks = <String>[];
    for (var i = 0; i < 1000; i++) {
      first = keyBetween(null, first);
      ks.add(first);
    }
    final asc = ks.reversed.toList();
    expect(asc, [...asc]..sort());
    expect(ks.last.length, lessThan(40));
  });
  test('ping-pong move 500x between neighbours keeps order', () {
    var lo = 'a0', hi = 'a1';
    for (var i = 0; i < 500; i++) {
      final m = keyBetween(lo, hi);
      expect(lo.compareTo(m) < 0 && m.compareTo(hi) < 0, isTrue);
      i.isEven ? lo = m : hi = m;
    }
  });
  test('moving one item back and forth between same neighbours does not grow', () {
    final a = keyBetween('a0', 'a1');
    final b = keyBetween('a0', 'a1');
    expect(a, b);
  });
  test('keysBetween returns n ordered keys', () {
    final ks = keysBetween('a0', 'a1', 10);
    expect(ks, [...ks]..sort());
    expect(ks.toSet().length, 10);
    expect(ks.first.compareTo('a0') > 0 && ks.last.compareTo('a1') < 0, isTrue);
  });
  test('invalid order throws', () => expect(() => keyBetween('a1', 'a0'), throwsArgumentError));
}
