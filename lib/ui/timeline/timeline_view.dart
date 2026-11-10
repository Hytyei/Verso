import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/undo.dart';
import '../../dev/perf_probe.dart';
import '../../state/providers.dart';
import '../common/format.dart';
import '../common/glass_menu.dart';
import '../editors/milestone_editor.dart';
import '../editors/version_editor.dart';
import '../glass/glass_surface.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';
import '../board/segment_stub.dart';
import 'timeline_layout.dart';
import 'timeline_painter.dart';
import 'timeline_scale.dart';

/// Zoomable, pannable timeline of versions, dated features and milestones.
class TimelineView extends ConsumerStatefulWidget {
  const TimelineView({super.key, required this.project, required this.topInset});
  final Project project;
  final double topInset;

  @override
  ConsumerState<TimelineView> createState() => TimelineViewState();
}

enum _DragMode { none, pan, move, resizeStart, resizeEnd }

class TimelineViewState extends ConsumerState<TimelineView> with SingleTickerProviderStateMixin {
  TimelineScale? _scale;
  TimelineScale? _target;
  double _scrollY = 0;
  Size _size = Size.zero;
  Ticker? _tickerOrNull;
  Ticker get _ticker => _tickerOrNull ??= createTicker(_tick);
  Duration _lastTick = Duration.zero;
  final _repaint = ValueNotifier(0);
  HitTarget? _hover;

  // Drag state.
  _DragMode _mode = _DragMode.none;
  HitTarget? _dragTarget;
  DateRange? _dragOrig;
  double _dragDx = 0;
  MapEntry<String, DateRange>? _preview;

  TimelineGeometry? _geom;
  TimelineLayoutResult? _layout;

  @override
  void initState() {
    super.initState();
    if (perfMode) _perfDrive();
  }

  /// Dev-only: zooms in and out and pans for the perf probe.
  Future<void> _perfDrive() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    for (var i = 0; i < 24 && mounted; i++) {
      if (_scale == null) continue;
      if (i % 8 < 4) {
        zoom(i % 8 < 2 ? 1.8 : 1 / 1.8);
      } else {
        _animateTo((_target ?? _scale!).panBy(i.isEven ? 300 : -300));
      }
      await Future<void>.delayed(const Duration(milliseconds: 420));
    }
  }

  /// Current (animated) scale; exposed for tests.
  TimelineScale get scale => _scale!;

  Rect? laneRect(String versionId) => _geom?.laneRects[versionId];

  Rect? handleRect(String id, {required bool start}) => _geom?.targets
      .where((t) => t.id == id && t.kind == (start ? HitKind.barStart : HitKind.barEnd))
      .map((t) => t.rect)
      .firstOrNull;

  @override
  void dispose() {
    _tickerOrNull?.dispose();
    _repaint.dispose();
    super.dispose();
  }

  // ---- scale animation ----

  void _animateTo(TimelineScale t) {
    _target = t;
    if (Motion.reduced(context)) {
      _scale = t;
      _repaint.value++;
      return;
    }
    if (!_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
  }

  void _tick(Duration now) {
    final dt = _lastTick == Duration.zero ? 1 / 120 : (now - _lastTick).inMicroseconds / 1e6;
    _lastTick = now;
    final cur = _scale!, tgt = _target!;
    final k = 1 - math.exp(-dt / .055);
    final lp = math.log(cur.pxPerDay) + (math.log(tgt.pxPerDay) - math.log(cur.pxPerDay)) * k;
    final o =
        cur.origin.microsecondsSinceEpoch + (tgt.origin.microsecondsSinceEpoch - cur.origin.microsecondsSinceEpoch) * k;
    _scale = TimelineScale(origin: DateTime.fromMicrosecondsSinceEpoch(o.round(), isUtc: true), pxPerDay: math.exp(lp));
    final done =
        (lp - math.log(tgt.pxPerDay)).abs() < 1e-4 &&
        (tgt.origin.difference(_scale!.origin).inMicroseconds / Duration.microsecondsPerDay * tgt.pxPerDay).abs() < .3;
    if (done) {
      _scale = tgt;
      _ticker.stop();
    }
    _repaint.value++;
  }

  /// Instant change (drag-pan follows the pointer exactly).
  void _jumpTo(TimelineScale t) {
    _tickerOrNull?.stop();
    _scale = t;
    _target = t;
    _repaint.value++;
  }

  TimelineScale _fitScale(DateRange r) {
    final w = math.max(200.0, _size.width - TimelineGeometry.labelW);
    final f = TimelineScale.fit(r.start, r.end, w);
    return TimelineScale(
      origin: f.origin.subtract(
        Duration(microseconds: (TimelineGeometry.labelW / f.pxPerDay * Duration.microsecondsPerDay).round()),
      ),
      pxPerDay: f.pxPerDay,
    );
  }

  void fit() {
    final e = _layout?.extent;
    if (e != null) _animateTo(_fitScale(e));
  }

  void today() {
    final n = DateTime.now().toUtc();
    _animateTo((_target ?? _scale!).centredOn(DateTime.utc(n.year, n.month, n.day, 12), _size.width));
  }

  void zoom(double factor, [double? anchorX]) =>
      _animateTo((_target ?? _scale!).zoomAt(factor, anchorX ?? (_size.width + TimelineGeometry.labelW) / 2));

  // ---- input ----

  void _onSignal(PointerSignalEvent e) {
    if (e is PointerScrollEvent) {
      GestureBinding.instance.pointerSignalResolver.register(e, (ev) {
        final s = ev as PointerScrollEvent;
        final keys = HardwareKeyboard.instance;
        if (keys.isControlPressed || keys.isMetaPressed) {
          zoom(math.exp(-s.scrollDelta.dy * .0018), s.localPosition.dx);
        } else if (keys.isShiftPressed || s.scrollDelta.dx != 0) {
          final d = s.scrollDelta.dx != 0 ? s.scrollDelta.dx : s.scrollDelta.dy;
          _animateTo((_target ?? _scale!).panBy(-d));
        } else {
          _scrollBy(s.scrollDelta.dy);
        }
      });
    } else if (e is PointerScaleEvent) {
      zoom(e.scale, e.localPosition.dx);
    }
  }

  void _scrollBy(double dy) {
    final g = _geom;
    if (g == null) return;
    final visible = _size.height - g.lanesTop - 20;
    final maxY = math.max(0.0, g.contentHeight - visible);
    _scrollY = (_scrollY + dy).clamp(0, maxY);
    _repaint.value++;
  }

  void _onPanStart(DragStartDetails d) {
    final hit = _geom?.hitTest(d.localPosition);
    _dragDx = 0;
    _preview = null;
    if (hit == null || hit.kind == HitKind.lane || hit.kind == HitKind.milestoneRow) {
      _mode = _DragMode.pan;
      return;
    }
    if (hit.kind == HitKind.milestone) {
      _mode = _DragMode.none;
      return;
    }
    _dragTarget = hit;
    _dragOrig = _rangeOf(hit.id);
    _mode = switch (hit.kind) {
      HitKind.barStart => _DragMode.resizeStart,
      HitKind.barEnd => _DragMode.resizeEnd,
      _ => _DragMode.move,
    };
  }

  DateRange? _rangeOf(String id) {
    for (final l in _layout!.lanes) {
      if (l.version.id == id) return l.range;
      for (final f in l.features) {
        if (f.feature.id == id) return f.range;
      }
    }
    return null;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_pinching) return;
    switch (_mode) {
      case _DragMode.pan:
        _jumpTo(_scale!.panBy(d.delta.dx));
        _scrollBy(-d.delta.dy);
      case _DragMode.none:
        break;
      default:
        _dragDx += d.delta.dx;
        final days = (_dragDx / _scale!.pxPerDay).round();
        final o = _dragOrig!;
        final shift = Duration(days: days);
        final r = switch (_mode) {
          _DragMode.move => DateRange(o.start.add(shift), o.end.add(shift)),
          _DragMode.resizeStart => DateRange(
            _minDate(o.start.add(shift), o.end.subtract(const Duration(days: 1))),
            o.end,
          ),
          _ => DateRange(o.start, _maxDate(o.end.add(shift), o.start.add(const Duration(days: 1)))),
        };
        _preview = MapEntry(_dragTarget!.id, r);
        _repaint.value++;
    }
  }

  // ---- pinch (phones): two fingers zoom; one finger keeps panning / dragging bars ----

  final _touches = <int, Offset>{};
  double? _pinchDist;
  bool get _pinching => _touches.length >= 2;

  void _pointerDown(PointerDownEvent e) {
    if (e.kind != PointerDeviceKind.touch) return;
    _touches[e.pointer] = e.localPosition;
    if (_touches.length == 2) {
      // A second finger joined: drop any bar drag, start zooming.
      _mode = _DragMode.none;
      _dragTarget = null;
      _preview = null;
      _pinchDist = _spread();
      _repaint.value++;
    }
  }

  void _pointerMove(PointerMoveEvent e) {
    if (!_touches.containsKey(e.pointer)) return;
    _touches[e.pointer] = e.localPosition;
    if (!_pinching) return;
    final d = _spread();
    final last = _pinchDist;
    _pinchDist = d;
    if (last == null || last < 1 || d < 1) return;
    final pts = _touches.values.take(2).toList();
    _jumpTo(_scale!.zoomAt(d / last, (pts[0].dx + pts[1].dx) / 2));
  }

  void _pointerUp(PointerEvent e) {
    _touches.remove(e.pointer);
    if (_touches.length < 2) _pinchDist = null;
  }

  double _spread() {
    final pts = _touches.values.take(2).toList();
    return (pts[0] - pts[1]).distance;
  }

  static DateTime _minDate(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
  static DateTime _maxDate(DateTime a, DateTime b) => a.isAfter(b) ? a : b;

  Future<void> _onPanEnd() async {
    final mode = _mode;
    final target = _dragTarget;
    final orig = _dragOrig;
    final preview = _preview;
    _mode = _DragMode.none;
    _dragTarget = null;
    if (mode == _DragMode.pan || mode == _DragMode.none || target == null || orig == null || preview == null) {
      _preview = null;
      _repaint.value++;
      return;
    }
    final r = preview.value;
    if (r.start == orig.start && r.end == orig.end) {
      _preview = null;
      _repaint.value++;
      return;
    }
    await _commitRange(target, orig, r);
    _preview = null;
    _repaint.value++;
  }

  /// Stores a dragged range. Versions keep [start, target]; features
  /// [start, end]. Ranges stored as one day (start only) stay single dates.
  Future<void> _commitRange(HitTarget t, DateRange before, DateRange after) async {
    final undo = ref.read(undoProvider);
    final isVersion = _layout!.lanes.any((l) => l.version.id == t.id);
    if (isVersion) {
      final repo = ref.read(versionRepoProvider);
      final v = await repo.get(t.id);
      await undo.run(
        dateChangeAction(
          'Move ${v.name}',
          () => repo.update(
            t.id,
            startDate: Value(after.start),
            targetDate: Value(_storedEnd(v.startDate, v.targetDate, after)),
          ),
          () => repo.update(t.id, startDate: Value(v.startDate), targetDate: Value(v.targetDate)),
        ),
      );
    } else {
      final repo = ref.read(featureRepoProvider);
      final f = await repo.get(t.id);
      await undo.run(
        dateChangeAction(
          'Move feature',
          () => repo.update(
            t.id,
            startDate: Value(after.start),
            endDate: Value(_storedEnd(f.startDate, f.endDate, after)),
          ),
          () => repo.update(t.id, startDate: Value(f.startDate), endDate: Value(f.endDate)),
        ),
      );
    }
  }

  /// End date to store for [r]: a one-day range is a single date.
  DateTime? _storedEnd(DateTime? start, DateTime? end, DateRange r) {
    final oneDay = r.end.difference(r.start).inDays <= 1;
    if (oneDay && (start == null || end == null)) return start == null ? r.start : null;
    return r.end;
  }

  Future<void> _onDoubleTap(Offset pos) async {
    final hit = _geom?.hitTest(pos);
    if (hit == null) return;
    final d = _scale!.dateAt(pos.dx);
    final day = DateTime.utc(d.year, d.month, d.day);
    if (hit.kind == HitKind.milestoneRow) {
      await showMilestoneEditor(context, projectId: widget.project.id, pos: localToGlobal(pos), initialDate: day);
    } else if (hit.kind == HitKind.lane && hit.versionId != null) {
      await ref
          .read(undoProvider)
          .run(
            createFeatureAction(
              ref.read(featureRepoProvider),
              hit.versionId!,
              'New feature',
              startDate: day,
              endDate: day.add(const Duration(days: 3)),
            ),
          );
    }
  }

  Offset localToGlobal(Offset p) => (context.findRenderObject() as RenderBox).localToGlobal(p);

  Future<void> _onTapUp(TapUpDetails d) async {
    final hit = _geom?.hitTest(d.localPosition);
    if (hit == null) return;
    final g = d.globalPosition;
    switch (hit.kind) {
      case HitKind.milestone:
        final m = _layout!.milestones.firstWhere((m) => m.id == hit.id);
        await showMilestoneEditor(context, projectId: widget.project.id, pos: g, milestone: m);
      case HitKind.versionBar || HitKind.barStart || HitKind.barEnd
          when _layout!.lanes.any((l) => l.version.id == hit.id):
        final v = _layout!.lanes.firstWhere((l) => l.version.id == hit.id).version;
        await showVersionEditor(context, ref, v, g + const Offset(300, 0));
      case HitKind.featureBar || HitKind.barStart || HitKind.barEnd:
        await _featureInfo(hit.id, g);
      default:
        break;
    }
  }

  Future<void> _featureInfo(String id, Offset g) async {
    Feature? f;
    for (final l in _layout!.lanes) {
      for (final b in l.features) {
        if (b.feature.id == id) f = b.feature;
      }
    }
    if (f == null) return;
    final names = {for (final l in _layout!.lanes) l.version.id: l.version.name};
    for (final v in _layout!.undated) {
      names[v.id] = v.name;
    }
    final feature = f;
    await showGlassPopover(
      context,
      anchor: Rect.fromLTWH(g.dx, g.dy, 0, 0),
      width: 300,
      builder: (ctx, close) {
        final p = VersoPalette.of(ctx);
        final small = TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: p.textSecondary);
        return GlassSurface(
          radius: 16,
          tint: p.isDark ? const Color(0xF51E1A16) : const Color(0xF5FFFFFF),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: TextStyle(fontFamily: 'Inter', fontSize: 14.5, fontWeight: FontWeight.w600, color: p.text),
              ),
              const SizedBox(height: 6),
              Text(
                '${names[feature.versionId] ?? ''} · ${dateRange(feature.startDate, feature.endDate)}',
                style: small,
              ),
              if (feature.delayCount > 0) ...[
                const SizedBox(height: 6),
                Text(
                  'Delayed ${feature.delayCount}× — first planned for ${names[feature.delayedFromVersionId] ?? 'an earlier version'}',
                  style: small.copyWith(color: p.coral),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final versions = segmentOf(
      ref.watch(versionsProvider(widget.project.id)).value ?? const <Version>[],
      ref.watch(selectedEnvironmentIdProvider),
    );
    final query = ref.watch(searchQueryProvider).trim().toLowerCase();
    var dated = ref.watch(datedFeaturesProvider(widget.project.id)).value ?? const <Feature>[];
    if (query.isNotEmpty) {
      dated = [
        for (final f in dated)
          if (f.title.toLowerCase().contains(query) || (f.notes ?? '').toLowerCase().contains(query)) f,
      ];
    }
    final milestones = ref.watch(milestonesProvider(widget.project.id)).value ?? const <Milestone>[];
    final layout = TimelineLayout.build(versions, dated, milestones);
    _layout = layout;
    final progress = <String, double>{
      for (final v in versions)
        v.id: (() {
          final pr = ref.watch(versionProgressProvider(v.id)).value;
          return pr == null || pr.total == 0 ? 0.0 : pr.done / pr.total;
        })(),
    };
    final names = {for (final v in versions) v.id: v.name};

    return LayoutBuilder(
      builder: (context, c) {
        _size = c.biggest;
        if (_scale == null) {
          final n = DateTime.now().toUtc();
          _scale = layout.extent != null
              ? _fitScale(layout.extent!)
              : TimelineScale(
                  origin: DateTime.utc(n.year, n.month, n.day),
                  pxPerDay: 14,
                ).centredOn(DateTime.utc(n.year, n.month, n.day), c.maxWidth);
          _target = _scale;
        }
        return Stack(
          children: [
            Positioned.fill(
              child: Listener(
                onPointerSignal: _onSignal,
                onPointerDown: _pointerDown,
                onPointerMove: _pointerMove,
                onPointerUp: _pointerUp,
                onPointerCancel: _pointerUp,
                child: MouseRegion(
                  onHover: (e) {
                    final h = _geom?.hitTest(e.localPosition);
                    if (h?.id != _hover?.id || h?.kind != _hover?.kind) {
                      _hover = h;
                      _repaint.value++;
                    }
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    // Hit-test where the pointer went down, not after the slop.
                    dragStartBehavior: DragStartBehavior.down,
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: (_) => _onPanEnd(),
                    onTapUp: _onTapUp,
                    onDoubleTapDown: (d) => _onDoubleTap(d.localPosition),
                    onDoubleTap: () {},
                    child: ValueListenableBuilder<int>(
                      valueListenable: _repaint,
                      builder: (context, _, _) {
                        final g = TimelineGeometry(
                          layout: layout,
                          scale: _scale!,
                          size: c.biggest,
                          top: widget.topInset,
                          scrollY: _scrollY,
                          preview: _preview,
                        );
                        _geom = g;
                        return MouseRegion(
                          cursor: switch (_hover?.kind) {
                            HitKind.barStart || HitKind.barEnd => SystemMouseCursors.resizeLeftRight,
                            HitKind.versionBar || HitKind.featureBar || HitKind.milestone => SystemMouseCursors.click,
                            _ => _mode == _DragMode.pan ? SystemMouseCursors.grabbing : SystemMouseCursors.basic,
                          },
                          child: RepaintBoundary(
                            child: CustomPaint(
                              size: c.biggest,
                              painter: TimelinePainter(
                                geometry: g,
                                palette: p,
                                progress: progress,
                                versionNames: names,
                                hover: _hover,
                                now: DateTime.now().toUtc(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Glass lane-label panel.
            Positioned(
              left: 0,
              top: widget.topInset,
              bottom: 0,
              width: TimelineGeometry.labelW - 10,
              child: IgnorePointer(
                child: GlassSurface(
                  large: true,
                  refract: false,
                  radius: 20,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _repaint,
                    builder: (context, _, _) => _geom == null
                        ? const SizedBox.expand()
                        : CustomPaint(
                            size: Size.infinite,
                            painter: LaneLabelPainter(
                              geometry: TimelineGeometry(
                                layout: layout,
                                scale: _scale!,
                                size: c.biggest,
                                top: 0,
                                scrollY: _scrollY,
                                preview: _preview,
                              ),
                              palette: p,
                              progress: progress,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: widget.topInset + 12,
              child: IgnorePointer(
                child: Text(
                  'Lanes',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: p.textSecondary,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 14,
              bottom: 14,
              child: _Controls(state: this, projectId: widget.project.id),
            ),
            if (layout.undated.isNotEmpty)
              Positioned(
                left: TimelineGeometry.labelW + 4,
                bottom: 14,
                right: 260,
                child: _UndatedTray(versions: layout.undated),
              ),
            if (layout.lanes.isEmpty)
              Positioned.fill(
                top: widget.topInset + TimelineGeometry.axisH + TimelineGeometry.milestoneH,
                left: TimelineGeometry.labelW,
                child: IgnorePointer(
                  child: Center(
                    child: Text(
                      'Give a version dates to see it here.\nDouble-click the milestone row to add a milestone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.textSecondary),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state, required this.projectId});
  final TimelineViewState state;
  final String projectId;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    Widget btn(Key key, IconData icon, String tip, VoidCallback onTap) => Tooltip(
      message: tip,
      child: GlassSurface(
        key: key,
        interactive: true,
        radius: 999,
        onTap: onTap,
        padding: const EdgeInsets.all(9),
        child: Icon(icon, size: 18, color: p.text),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Builder(
          builder: (c) => btn(const Key('timeline-add-milestone'), Icons.flag_rounded, 'Add milestone', () {
            final box = c.findRenderObject() as RenderBox;
            showMilestoneEditor(c, projectId: projectId, pos: box.localToGlobal(const Offset(-300, -360)));
          }),
        ),
        const SizedBox(width: 8),
        btn(const Key('timeline-fit'), Icons.fit_screen_rounded, 'Fit project', state.fit),
        const SizedBox(width: 8),
        btn(const Key('timeline-today'), Icons.today_rounded, 'Today', state.today),
        const SizedBox(width: 8),
        btn(const Key('timeline-zoom-out'), Icons.remove_rounded, 'Zoom out (Ctrl+wheel)', () => state.zoom(1 / 1.6)),
        const SizedBox(width: 8),
        btn(const Key('timeline-zoom-in'), Icons.add_rounded, 'Zoom in (Ctrl+wheel)', () => state.zoom(1.6)),
      ],
    );
  }
}

class _UndatedTray extends ConsumerWidget {
  const _UndatedTray({required this.versions});
  final List<Version> versions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    return Align(
      alignment: Alignment.bottomLeft,
      child: GlassSurface(
        key: const Key('undated-tray'),
        radius: 16,
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Undated',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: p.textSecondary),
            ),
            for (final v in versions)
              GestureDetector(
                onTapUp: (d) => showVersionEditor(context, ref, v, d.globalPosition + const Offset(300, -420)),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.text.withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      v.name,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, fontWeight: FontWeight.w600, color: p.text),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
