import '../sort_key.dart';

/// Picks a sort key for an item placed among [ordered] (id, key) pairs that
/// exclude the item itself. With neither neighbour given it goes last.
///
/// Robust to stale ids and duplicate keys: the key is always placed after
/// the anchor's key and before the next strictly greater key, so it never
/// collides and never throws.
String placeKey(List<(String id, String key)> ordered, {String? afterId, String? beforeId}) {
  final list = [...ordered]..sort((x, y) => x.$2.compareTo(y.$2));
  String? nextAbove(String k) {
    for (final e in list) {
      if (e.$2.compareTo(k) > 0) return e.$2;
    }
    return null;
  }

  String? lastBelow(String k) {
    String? r;
    for (final e in list) {
      if (e.$2.compareTo(k) < 0) r = e.$2;
    }
    return r;
  }

  final after = afterId == null ? null : list.where((e) => e.$1 == afterId).firstOrNull;
  final before = beforeId == null ? null : list.where((e) => e.$1 == beforeId).firstOrNull;
  if (after != null) return keyBetween(after.$2, nextAbove(after.$2));
  if (before != null) return keyBetween(lastBelow(before.$2), before.$2);
  return keyBetween(list.isEmpty ? null : list.last.$2, null);
}

/// Whether any two entries share a key (needs [renumber]).
bool hasDuplicateKeys(List<(String id, String key)> ordered) =>
    ordered.map((e) => e.$2).toSet().length != ordered.length;

/// Fresh, evenly spread keys for [ordered] in its current order.
List<(String id, String key)> renumber(List<(String id, String key)> ordered) {
  final keys = keysBetween(null, null, ordered.length);
  return [for (var i = 0; i < ordered.length; i++) (ordered[i].$1, keys[i])];
}
