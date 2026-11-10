import 'dart:math' as math;

import '../common/format.dart';

enum TickLevel { day, week, month, quarter, year }

/// An axis tick.
class Tick {
  const Tick(this.at, this.label, this.major);
  final DateTime at;
  final String label;

  /// Starts a bigger unit (a month at day level, a year at month level…).
  final bool major;
}

const _day = Duration.microsecondsPerDay;

/// Maps dates (UTC) to x pixels: x = 0 at [origin], [pxPerDay] wide days.
/// Immutable; zoom and pan return new scales.
class TimelineScale {
  const TimelineScale({required this.origin, required this.pxPerDay});
  final DateTime origin;
  final double pxPerDay;

  static const double minPxPerDay = 0.05;
  static const double maxPxPerDay = 400;

  /// Minimum label spacing the levels aim for.
  static const double labelGap = 64;

  double xOf(DateTime d) => (d.difference(origin).inMicroseconds / _day) * pxPerDay;

  DateTime dateAt(double x) => origin.add(Duration(microseconds: (x / pxPerDay * _day).round()));

  /// Zooms by [factor] keeping the date under [anchorX] fixed.
  TimelineScale zoomAt(double factor, double anchorX) {
    final px = (pxPerDay * factor).clamp(minPxPerDay, maxPxPerDay).toDouble();
    final anchor = dateAt(anchorX);
    return TimelineScale(
      origin: anchor.subtract(Duration(microseconds: (anchorX / px * _day).round())),
      pxPerDay: px,
    );
  }

  /// Content follows the pointer: dragging right ([dx] > 0) shows earlier dates.
  TimelineScale panBy(double dx) => TimelineScale(
    origin: origin.subtract(Duration(microseconds: (dx / pxPerDay * _day).round())),
    pxPerDay: pxPerDay,
  );

  /// Centres [d] in a viewport [width] px wide.
  TimelineScale centredOn(DateTime d, double width) => TimelineScale(
    origin: d.subtract(Duration(microseconds: (width / 2 / pxPerDay * _day).round())),
    pxPerDay: pxPerDay,
  );

  /// Fits [start]..[end] into [width] with a margin on both sides.
  static TimelineScale fit(DateTime start, DateTime end, double width, {double margin = 60}) {
    final days = math.max(1.0, end.difference(start).inMicroseconds / _day);
    final px = ((width - 2 * margin) / days).clamp(minPxPerDay, maxPxPerDay).toDouble();
    return TimelineScale(
      origin: start.subtract(Duration(microseconds: (margin / px * _day).round())),
      pxPerDay: px,
    );
  }

  TickLevel get level {
    if (pxPerDay >= 48) return TickLevel.day;
    if (pxPerDay * 7 >= labelGap) return TickLevel.week;
    if (pxPerDay * 30 >= labelGap) return TickLevel.month;
    if (pxPerDay * 91 >= labelGap) return TickLevel.quarter;
    return TickLevel.year;
  }

  int get _yearStep {
    final need = labelGap / (365 * pxPerDay);
    for (final s in const [1, 2, 5, 10, 20, 50]) {
      if (s >= need) return s;
    }
    return 100;
  }

  DateTime _floor(DateTime d) {
    final u = d.toUtc();
    switch (level) {
      case TickLevel.day:
        return DateTime.utc(u.year, u.month, u.day);
      case TickLevel.week:
        final day = DateTime.utc(u.year, u.month, u.day);
        return day.subtract(Duration(days: day.weekday - DateTime.monday));
      case TickLevel.month:
        return DateTime.utc(u.year, u.month);
      case TickLevel.quarter:
        return DateTime.utc(u.year, ((u.month - 1) ~/ 3) * 3 + 1);
      case TickLevel.year:
        final s = _yearStep;
        return DateTime.utc((u.year ~/ s) * s);
    }
  }

  DateTime _next(DateTime d) => switch (level) {
    TickLevel.day => DateTime.utc(d.year, d.month, d.day + 1),
    TickLevel.week => DateTime.utc(d.year, d.month, d.day + 7),
    TickLevel.month => DateTime.utc(d.year, d.month + 1),
    TickLevel.quarter => DateTime.utc(d.year, d.month + 3),
    TickLevel.year => DateTime.utc(d.year + _yearStep),
  };

  Tick _tick(DateTime d, DateTime? prev) => switch (level) {
    TickLevel.day => d.day == 1 ? Tick(d, '${monthName(d.month)} 1', true) : Tick(d, '${d.day}', false),
    TickLevel.week => Tick(d, '${monthName(d.month)} ${d.day}', prev == null || prev.month != d.month),
    TickLevel.month => Tick(d, monthName(d.month), d.month == 1),
    TickLevel.quarter => Tick(d, 'Q${(d.month - 1) ~/ 3 + 1} ${d.year}', d.month == 1),
    TickLevel.year => Tick(d, '${d.year}', d.year % 10 == 0),
  };

  /// Ticks covering x ∈ [0, width].
  List<Tick> ticks(double width) {
    final out = <Tick>[];
    var d = _floor(dateAt(0));
    if (xOf(d) < -0.5) d = _next(d);
    DateTime? prev;
    while (xOf(d) <= width && out.length < 2000) {
      out.add(_tick(d, prev));
      prev = d;
      d = _next(d);
    }
    return out;
  }
}
