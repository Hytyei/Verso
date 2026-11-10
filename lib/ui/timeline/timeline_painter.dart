import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../theme/palette.dart';
import 'timeline_layout.dart';
import 'timeline_scale.dart';

enum HitKind { versionBar, featureBar, milestone, barStart, barEnd, lane, milestoneRow }

class HitTarget {
  const HitTarget(this.kind, this.id, this.rect, {this.versionId});
  final HitKind kind;
  final String id;
  final Rect rect;

  /// Lane the target belongs to (for lane / bar hits).
  final String? versionId;
}

/// Pixel geometry shared by the painter and hit testing.
class TimelineGeometry {
  TimelineGeometry({
    required this.layout,
    required this.scale,
    required this.size,
    required this.top,
    required this.scrollY,
    this.preview,
  }) {
    _build();
  }

  static const axisH = 40.0;
  static const milestoneH = 46.0;
  static const labelW = 190.0;
  static const barH = 24.0;
  static const featureH = 10.0;
  static const featureGap = 8.0;
  static const lanePad = 12.0;

  final TimelineLayoutResult layout;
  final TimelineScale scale;
  final Size size;

  /// Space above the axis (the floating toolbar).
  final double top;
  final double scrollY;

  /// Bar being dragged: id → previewed range.
  final MapEntry<String, DateRange>? preview;

  final List<HitTarget> targets = [];
  final Map<String, Rect> laneRects = {};
  final Map<String, Rect> barRects = {};
  double contentHeight = 0;

  double get axisTop => top;
  double get milestoneTop => top + axisH;
  double get lanesTop => top + axisH + milestoneH;

  DateRange _rangeOf(String id, DateRange r) => preview != null && preview!.key == id ? preview!.value : r;

  static double laneHeight(VersionLane l) =>
      lanePad * 2 +
      barH +
      (l.features.isEmpty ? 0 : featureGap + l.features.length * (featureH + featureGap) - featureGap);

  void _build() {
    var y = lanesTop - scrollY;
    for (final l in layout.lanes) {
      final h = laneHeight(l);
      final lane = Rect.fromLTWH(0, y, size.width, h);
      laneRects[l.version.id] = lane;
      targets.add(HitTarget(HitKind.lane, l.version.id, lane, versionId: l.version.id));
      if (l.range != null) {
        final r = _rangeOf(l.version.id, l.range!);
        final x0 = scale.xOf(r.start), x1 = math.max(scale.xOf(r.end), scale.xOf(r.start) + 6);
        final bar = Rect.fromLTRB(x0, y + lanePad, x1, y + lanePad + barH);
        barRects[l.version.id] = bar;
        targets.add(HitTarget(HitKind.versionBar, l.version.id, bar, versionId: l.version.id));
        targets.add(
          HitTarget(
            HitKind.barStart,
            l.version.id,
            Rect.fromLTRB(x0 - 4, bar.top, x0 + 6, bar.bottom),
            versionId: l.version.id,
          ),
        );
        targets.add(
          HitTarget(
            HitKind.barEnd,
            l.version.id,
            Rect.fromLTRB(x1 - 6, bar.top, x1 + 4, bar.bottom),
            versionId: l.version.id,
          ),
        );
      }
      var fy = y + lanePad + barH + featureGap;
      for (final f in l.features) {
        final r = _rangeOf(f.feature.id, f.range);
        final x0 = scale.xOf(r.start), x1 = math.max(scale.xOf(r.end), x0 + 6);
        final bar = Rect.fromLTRB(x0, fy, x1, fy + featureH);
        barRects[f.feature.id] = bar;
        final hit = bar.inflate(3);
        targets.add(HitTarget(HitKind.featureBar, f.feature.id, hit, versionId: l.version.id));
        targets.add(
          HitTarget(
            HitKind.barStart,
            f.feature.id,
            Rect.fromLTRB(x0 - 4, hit.top, x0 + 5, hit.bottom),
            versionId: l.version.id,
          ),
        );
        targets.add(
          HitTarget(
            HitKind.barEnd,
            f.feature.id,
            Rect.fromLTRB(x1 - 5, hit.top, x1 + 4, hit.bottom),
            versionId: l.version.id,
          ),
        );
        fy += featureH + featureGap;
      }
      y += h;
    }
    contentHeight = y + scrollY - lanesTop;
    targets.add(HitTarget(HitKind.milestoneRow, '', Rect.fromLTWH(0, milestoneTop, size.width, milestoneH)));
    for (final m in layout.milestones) {
      final x = scale.xOf(m.date);
      targets.add(
        HitTarget(
          HitKind.milestone,
          m.id,
          Rect.fromCenter(center: Offset(x, milestoneTop + 16), width: 22, height: 22),
        ),
      );
    }
  }

  /// Topmost target under [p] (handles beat bars, bars beat lanes).
  HitTarget? hitTest(Offset p) {
    if (p.dx < labelW) return null;
    const order = [
      HitKind.milestone,
      HitKind.barStart,
      HitKind.barEnd,
      HitKind.featureBar,
      HitKind.versionBar,
      HitKind.milestoneRow,
      HitKind.lane,
    ];
    for (final k in order) {
      for (final t in targets.reversed) {
        if (t.kind == k && t.rect.contains(p)) {
          if (t.kind == HitKind.lane && p.dy < lanesTop) continue;
          return t;
        }
      }
    }
    return null;
  }
}

/// Paints the whole timeline: grid, today line, lanes, bars, milestones, axis.
class TimelinePainter extends CustomPainter {
  TimelinePainter({
    required this.geometry,
    required this.palette,
    required this.progress,
    required this.versionNames,
    required this.hover,
    required this.now,
  });

  final TimelineGeometry geometry;
  final VersoPalette palette;
  final Map<String, double> progress;
  final Map<String, String> versionNames;
  final HitTarget? hover;
  final DateTime now;

  static final _textCache = <String, TextPainter>{};

  TextPainter _text(String s, TextStyle style) {
    final key = '$s|${style.fontSize}|${style.fontWeight}|${style.color?.toARGB32()}';
    return _textCache.putIfAbsent(key, () {
      if (_textCache.length > 600) _textCache.clear();
      return TextPainter(
        text: TextSpan(text: s, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout();
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final g = geometry;
    final p = palette;
    final s = g.scale;
    final ticks = s.ticks(size.width);

    // Grid.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(TimelineGeometry.labelW, g.milestoneTop, size.width, size.height));
    final grid = Paint()..strokeWidth = 1;
    for (final t in ticks) {
      final x = s.xOf(t.at).roundToDouble() + .5;
      grid.color = p.separator.withValues(alpha: t.major ? .9 : .45);
      canvas.drawLine(Offset(x, g.milestoneTop), Offset(x, size.height), grid);
    }
    // Lane separators.
    for (final r in g.laneRects.values) {
      canvas.drawLine(
        Offset(TimelineGeometry.labelW, r.bottom),
        Offset(size.width, r.bottom),
        Paint()..color = p.separator.withValues(alpha: .35),
      );
    }
    canvas.restore();

    // Lanes and bars.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(TimelineGeometry.labelW, g.lanesTop, size.width, size.height));
    for (final l in g.layout.lanes) {
      final lane = g.laneRects[l.version.id]!;
      if (lane.bottom < g.lanesTop || lane.top > size.height) continue;
      final color = p.resolve(VColor(l.version.color, custom: l.version.colorCustom));
      final tint = p.resolveTint(VColor(l.version.color, custom: l.version.colorCustom));
      final bar = g.barRects[l.version.id];
      if (bar != null && bar.right > TimelineGeometry.labelW && bar.left < size.width) {
        _versionBar(canvas, bar, l, color, tint);
      }
      for (final f in l.features) {
        final r = g.barRects[f.feature.id]!;
        if (r.right < TimelineGeometry.labelW || r.left > size.width) continue;
        final fc = f.feature.color == null ? color : p.resolve(VColor(f.feature.color!, custom: f.feature.colorCustom));
        _featureBar(canvas, r, f, fc);
      }
    }
    canvas.restore();

    // Today.
    final tx = s.xOf(now);
    if (tx > TimelineGeometry.labelW && tx < size.width) {
      final dash = Paint()
        ..color = p.coral
        ..strokeWidth = 1.4;
      for (var y = g.milestoneTop; y < size.height; y += 8) {
        canvas.drawLine(Offset(tx, y), Offset(tx, math.min(y + 4, size.height)), dash);
      }
      final label = _text(
        'Today',
        TextStyle(
          fontFamily: 'Inter',
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: p.isDark ? Colors.black : Colors.white,
        ),
      );
      final pill = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(tx, g.milestoneTop + 4), width: label.width + 12, height: 16),
        const Radius.circular(8),
      );
      canvas.drawRRect(pill, Paint()..color = p.coral);
      label.paint(canvas, Offset(tx - label.width / 2, g.milestoneTop + 4 - label.height / 2));
    }

    // Milestones.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(TimelineGeometry.labelW, g.milestoneTop, size.width, g.lanesTop));
    for (final m in g.layout.milestones) {
      final x = s.xOf(m.date);
      if (x < TimelineGeometry.labelW - 100 || x > size.width + 100) continue;
      final c = m.color == null ? p.primary : p.resolve(VColor(m.color!, custom: m.colorCustom));
      final cy = g.milestoneTop + 16;
      final hovered = hover?.kind == HitKind.milestone && hover?.id == m.id;
      final d = hovered ? 8.5 : 7.0;
      final path = Path()
        ..moveTo(x, cy - d)
        ..lineTo(x + d, cy)
        ..lineTo(x, cy + d)
        ..lineTo(x - d, cy)
        ..close();
      canvas.drawPath(path, Paint()..color = c);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = p.isDark ? Colors.black : Colors.white,
      );
      final t = _text(
        m.title,
        TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600, color: p.text),
      );
      t.paint(canvas, Offset(x - t.width / 2, cy + 10));
      canvas.drawLine(Offset(x, g.lanesTop), Offset(x, g.lanesTop + 4), Paint()..color = c);
    }
    canvas.restore();

    // Axis.
    final axis = Rect.fromLTWH(
      TimelineGeometry.labelW,
      g.axisTop,
      size.width - TimelineGeometry.labelW,
      TimelineGeometry.axisH,
    );
    canvas.save();
    canvas.clipRect(axis);
    for (final t in ticks) {
      final x = s.xOf(t.at);
      final tp = _text(
        t.label,
        TextStyle(
          fontFamily: 'Inter',
          fontSize: t.major ? 12.5 : 11.5,
          fontWeight: t.major ? FontWeight.w700 : FontWeight.w500,
          color: t.major ? p.text : p.textSecondary,
        ),
      );
      tp.paint(canvas, Offset(x + 5, axis.center.dy - tp.height / 2));
    }
    canvas.restore();
    canvas.drawLine(
      Offset(TimelineGeometry.labelW, axis.bottom - .5),
      Offset(size.width, axis.bottom - .5),
      Paint()..color = p.separator,
    );
  }

  void _versionBar(Canvas canvas, Rect bar, VersionLane l, Color color, Color tint) {
    final p = palette;
    final rr = RRect.fromRectAndRadius(bar, const Radius.circular(8));
    final hovered = hover != null && hover!.id == l.version.id && hover!.kind != HitKind.lane;
    canvas.drawRRect(
      rr.shift(const Offset(0, 2)),
      Paint()
        ..color = p.shadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(rr, Paint()..color = Color.alphaBlend(color.withValues(alpha: p.isDark ? .18 : .10), tint));
    if (l.isConcept) {
      canvas.save();
      canvas.clipRRect(rr);
      final hatch = Paint()
        ..color = color.withValues(alpha: .35)
        ..strokeWidth = 1.4;
      for (var x = bar.left - bar.height; x < bar.right; x += 7) {
        canvas.drawLine(Offset(x, bar.bottom), Offset(x + bar.height, bar.top), hatch);
      }
      canvas.restore();
    } else {
      final pr = (progress[l.version.id] ?? 0).clamp(0.0, 1.0);
      if (pr > 0) {
        canvas.save();
        canvas.clipRRect(rr);
        canvas.drawRect(
          Rect.fromLTWH(bar.left, bar.top, bar.width * pr, bar.height),
          Paint()..color = color.withValues(alpha: .85),
        );
        canvas.restore();
      }
    }
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = hovered ? 1.8 : 1
        ..color = color.withValues(alpha: hovered ? 1 : .55),
    );
    final label = _text(
      l.version.name,
      TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: p.text),
    );
    final lx = math.max(bar.left + 10, TimelineGeometry.labelW + 8);
    if (lx + label.width < bar.right - 6) {
      label.paint(canvas, Offset(lx, bar.center.dy - label.height / 2));
    } else if (bar.right + 6 + label.width < geometry.size.width) {
      label.paint(canvas, Offset(bar.right + 6, bar.center.dy - label.height / 2));
    }
    if (hovered) {
      final grip = Paint()..color = color;
      for (final x in [bar.left + 3, bar.right - 3]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, bar.center.dy), width: 3, height: 12),
            const Radius.circular(2),
          ),
          grip,
        );
      }
    }
  }

  void _featureBar(Canvas canvas, Rect r, FeatureBar f, Color color) {
    final p = palette;
    final rr = RRect.fromRectAndRadius(r, Radius.circular(r.height / 2));
    final done = f.feature.done;
    canvas.drawRRect(rr, Paint()..color = color.withValues(alpha: done ? .35 : .9));
    if (f.feature.delayCount > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(r.left, r.top - 2, 4, r.height + 4), const Radius.circular(2)),
        Paint()..color = p.coral,
      );
    }
    final label = _text(
      f.feature.title.split('\n').first,
      TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: done ? p.textSecondary : p.text),
    );
    final x = r.right + 6;
    if (x + 40 < geometry.size.width) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(x, r.top - 6, math.min(260, geometry.size.width - x), r.height + 12));
      label.paint(canvas, Offset(x, r.center.dy - label.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(TimelinePainter o) => true;
}

/// Lane names on the left (drawn over the glass label panel).
class LaneLabelPainter extends CustomPainter {
  LaneLabelPainter({required this.geometry, required this.palette, required this.progress});
  final TimelineGeometry geometry;
  final VersoPalette palette;
  final Map<String, double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final p = palette;
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, geometry.lanesTop, size.width, size.height));
    for (final l in geometry.layout.lanes) {
      final r = geometry.laneRects[l.version.id]!;
      if (r.bottom < geometry.lanesTop || r.top > size.height) continue;
      final c = p.resolve(VColor(l.version.color, custom: l.version.colorCustom));
      canvas.drawCircle(
        Offset(22, r.top + TimelineGeometry.lanePad + TimelineGeometry.barH / 2),
        4.5,
        Paint()..color = c,
      );
      final name = TextPainter(
        text: TextSpan(
          text: l.version.name,
          style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w700, color: p.text),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: size.width - 46);
      name.paint(canvas, Offset(34, r.top + TimelineGeometry.lanePad + TimelineGeometry.barH / 2 - name.height / 2));
      final sub = l.isConcept
          ? 'Concept design'
          : '${((progress[l.version.id] ?? 0) * 100).round()}% done · ${l.features.length} dated';
      final st = TextPainter(
        text: TextSpan(
          text: sub,
          style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: p.textSecondary),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: size.width - 46);
      st.paint(canvas, Offset(34, r.top + TimelineGeometry.lanePad + TimelineGeometry.barH + 2));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(LaneLabelPainter o) => true;
}
