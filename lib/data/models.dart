/// Plain value types shared by the data layer and the UI.
library;

enum VersionStatus { planned, active, released }

enum VersionKind { concept, release }

enum MilestoneKind { release, launch, deadline, other }

enum DoneFilter { all, open, done }

/// A stored color: either a palette slot (0-3, mapped per theme) or a
/// custom ARGB value used as-is in both themes.
class VColor {
  const VColor(this.value, {this.custom = false});
  const VColor.slot(int slot) : value = slot, custom = false;
  final int value;
  final bool custom;

  @override
  bool operator ==(Object other) => other is VColor && other.value == value && other.custom == custom;
  @override
  int get hashCode => Object.hash(value, custom);
  @override
  String toString() => custom ? 'VColor(#${value.toRadixString(16)})' : 'VColor.slot($value)';
}

/// The first version of a project.
const firstVersionName = 'v0.0.0';

/// Next version name: bumps the second number of the last version number in
/// the name and resets the third (v0.1.0 -> v0.2.0, v1.6.0 -> v1.7.0,
/// v1.2 -> v1.3.0, v2 -> v2.1.0). Names without a number get " next".
String bumpVersionName(String name) {
  final matches = RegExp(r'(\d+)(?:\.(\d+))?(?:\.(\d+))?').allMatches(name).toList();
  if (matches.isEmpty) return '$name next';
  final m = matches.last;
  final major = m.group(1)!;
  final minor = int.parse(m.group(2) ?? '0') + 1;
  return name.replaceRange(m.start, m.end, '$major.$minor.0');
}

/// Orders version names by their numbers (v3.5.0 < v4.0.0 < v4.10.0); names
/// without numbers sort after numbered ones, then alphabetically.
int compareVersionNames(String a, String b) {
  List<int>? nums(String s) {
    final m = RegExp(r'(\d+)(?:\.(\d+))?(?:\.(\d+))?').firstMatch(s);
    if (m == null) return null;
    return [for (var i = 1; i <= 3; i++) int.parse(m.group(i) ?? '0')];
  }

  final x = nums(a), y = nums(b);
  if (x == null || y == null) {
    if (x == null && y == null) return a.compareTo(b);
    return x == null ? 1 : -1;
  }
  for (var i = 0; i < 3; i++) {
    if (x[i] != y[i]) return x[i].compareTo(y[i]);
  }
  return 0;
}
