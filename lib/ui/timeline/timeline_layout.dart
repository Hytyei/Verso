import '../../data/db/database.dart';

/// A time span; [end] is exclusive.
class DateRange {
  const DateRange(this.start, this.end);
  final DateTime start;
  final DateTime end;

  /// From optional dates: swaps inverted ends, and widens single or equal
  /// dates to one day. Null when both are missing.
  static DateRange? of(DateTime? a, DateTime? b) {
    if (a == null && b == null) return null;
    final x = (a ?? b)!.toUtc();
    final y = (b ?? a)!.toUtc();
    final s = x.isBefore(y) ? x : y;
    final e = x.isBefore(y) ? y : x;
    return DateRange(s, e == s ? s.add(const Duration(days: 1)) : e);
  }

  DateRange union(DateRange o) =>
      DateRange(o.start.isBefore(start) ? o.start : start, o.end.isAfter(end) ? o.end : end);
}

class FeatureBar {
  const FeatureBar(this.feature, this.range);
  final Feature feature;
  final DateRange range;
}

class VersionLane {
  const VersionLane({required this.version, required this.range, required this.features, required this.isConcept});
  final Version version;

  /// Null when the version itself has no dates (features may still).
  final DateRange? range;
  final List<FeatureBar> features;
  final bool isConcept;
}

class TimelineLayoutResult {
  const TimelineLayoutResult({
    required this.lanes,
    required this.undated,
    required this.milestones,
    required this.extent,
  });
  final List<VersionLane> lanes;

  /// Versions without their own dates (shown in the Undated tray).
  final List<Version> undated;
  final List<Milestone> milestones;

  /// Span of everything dated, or null when nothing is.
  final DateRange? extent;
}

/// Arranges versions, dated features and milestones into timeline lanes.
/// The concept lane comes first; lane order otherwise follows [versions].
class TimelineLayout {
  static TimelineLayoutResult build(List<Version> versions, List<Feature> dated, List<Milestone> milestones) {
    final ordered = [...versions.where((v) => v.kind == 'concept'), ...versions.where((v) => v.kind != 'concept')];
    final byVersion = <String, List<FeatureBar>>{};
    for (final f in dated) {
      final r = DateRange.of(f.startDate, f.endDate);
      if (r != null) (byVersion[f.versionId] ??= []).add(FeatureBar(f, r));
    }
    for (final list in byVersion.values) {
      list.sort((a, b) => a.range.start.compareTo(b.range.start));
    }
    final lanes = <VersionLane>[];
    final undated = <Version>[];
    DateRange? extent;
    void grow(DateRange r) => extent = extent == null ? r : extent!.union(r);

    for (final v in ordered) {
      final r = DateRange.of(v.startDate, v.targetDate);
      final fs = byVersion[v.id] ?? const <FeatureBar>[];
      if (r == null) undated.add(v);
      if (r == null && fs.isEmpty) continue;
      if (r != null) grow(r);
      for (final f in fs) {
        grow(f.range);
      }
      lanes.add(VersionLane(version: v, range: r, features: fs, isConcept: v.kind == 'concept'));
    }
    final ms = [...milestones]..sort((a, b) => a.date.compareTo(b.date));
    for (final m in ms) {
      grow(DateRange.of(m.date, null)!);
    }
    return TimelineLayoutResult(lanes: lanes, undated: undated, milestones: ms, extent: extent);
  }
}
