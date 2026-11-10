import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/repos/feature_repo.dart';
import '../../data/undo.dart';
import '../../state/providers.dart';
import '../common/animated_entry_list.dart';
import '../common/flip.dart';
import '../common/smooth_scroll.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';
import 'add_feature_row.dart';
import 'column_header.dart';
import 'drag_controller.dart';
import 'feature_card.dart';

/// Filters the board's features (search + filter menu); identity by default.
typedef FeatureFilterFn = List<FeatureView> Function(List<FeatureView> views);

sealed class _Row {
  String get id;
}

class _FeatureRow extends _Row {
  _FeatureRow(this.v, {this.hidden = false});
  final FeatureView v;

  /// The card being dragged: kept mounted (its recognizer drives the drag)
  /// but collapsed out of the way.
  final bool hidden;
  @override
  String get id => v.id;
}

class _Placeholder extends _Row {
  _Placeholder(this.height);
  final double height;
  @override
  String get id => '__placeholder';
}

class _DoneHeader extends _Row {
  _DoneHeader(this.count, this.expanded);
  final int count;
  final bool expanded;
  @override
  String get id => '__done';
}

/// One board column: header, animated feature list, Done group, add row.
class VersionColumn extends ConsumerStatefulWidget {
  const VersionColumn({
    super.key,
    required this.version,
    required this.versionNames,
    this.onVersionMenu,
    this.expandedBuilder,
    this.filter,
    this.width = 320,
  });

  final Version version;
  final Map<String, String> versionNames;
  final void Function(Version v, Offset globalPos)? onVersionMenu;
  final ExpandedBuilder? expandedBuilder;
  final FeatureFilterFn? filter;
  final double width;

  @override
  ConsumerState<VersionColumn> createState() => _VersionColumnState();
}

class _VersionColumnState extends ConsumerState<VersionColumn> {
  final _scroll = ScrollController();
  bool _doneExpanded = true;
  List<String> _openIds = const [];
  BoardDragController? _drag;
  DropColumn? _drop;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final d = BoardDrag.read(context);
    if (d != _drag) {
      if (_drop != null) _drag?.unregisterColumn(widget.version.id, _drop!);
      _drag = d;
      _drop = null;
    }
  }

  @override
  void dispose() {
    if (_drop != null) _drag?.unregisterColumn(widget.version.id, _drop!);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final v = widget.version;
    final concept = v.kind == 'concept';
    var views = ref.watch(featureViewsProvider(v.id)).value ?? const <FeatureView>[];
    if (widget.filter != null) views = widget.filter!(views);
    final drag = BoardDrag.watch(context);
    final draggingId = drag?.dragging?.id;
    final open = views.where((x) => !x.f.done).toList();
    final done = views.where((x) => x.f.done).toList();
    _openIds = [for (final x in open) x.id];
    final openShown = <_Row>[for (final x in open) _FeatureRow(x, hidden: x.id == draggingId)];
    if (drag != null && drag.active && drag.targetVersionId == v.id) {
      // targetIndex counts visible open cards; skip over the hidden one.
      var visible = 0, at = openShown.length;
      for (var i = 0; i < openShown.length; i++) {
        if (visible == drag.targetIndex) {
          at = i;
          break;
        }
        if (!(openShown[i] as _FeatureRow).hidden) visible++;
      }
      openShown.insert(at, _Placeholder(drag.cardSize.height));
    }
    final rows = <_Row>[
      ...openShown,
      if (done.isNotEmpty) _DoneHeader(done.length, _doneExpanded),
      if (_doneExpanded)
        for (final x in done) _FeatureRow(x, hidden: x.id == draggingId),
    ];

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeaderDrag(
          version: v,
          child: ColumnHeader(
            version: v,
            onMenu: widget.onVersionMenu == null ? null : (pos) => widget.onVersionMenu!(v, pos),
          ),
        ),
        Expanded(
          child: Scrollbar(
            controller: _scroll,
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 14),
              child: SmoothWheel(
                controller: _scroll,
                axis: Axis.vertical,
                child: FlipScope(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedEntryList<_Row>(
                        items: rows,
                        idOf: (r) => r.id,
                        itemBuilder: (context, r) => switch (r) {
                          _FeatureRow(:final v, :final hidden) => _Collapse(
                            collapsed: hidden,
                            child: FeatureCard(
                              key: ValueKey('fc-${v.id}'),
                              v: v,
                              version: widget.version,
                              versionNames: widget.versionNames,
                              expandedBuilder: widget.expandedBuilder,
                            ),
                          ),
                          _Placeholder(:final height) => _PlaceholderBox(height: height),
                          _DoneHeader(:final count, :final expanded) => _DoneHeaderRow(
                            count: count,
                            expanded: expanded,
                            onTap: () => setState(() => _doneExpanded = !_doneExpanded),
                          ),
                        },
                      ),
                      AddFeatureRow(versionId: v.id, label: concept ? 'Add idea' : 'Add feature'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final column = _ColumnDropTarget(
      version: v,
      child: Container(
        width: widget.width,
        margin: const EdgeInsets.only(right: 12),
        decoration: concept
            ? null
            : BoxDecoration(
                color: p.isDark ? const Color(0xFF0B0907) : Colors.white.withValues(alpha: .38),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: p.isDark ? const Color(0x0FFFFFFF) : Colors.white.withValues(alpha: .7)),
              ),
        child: concept
            ? CustomPaint(painter: _DashedRRect(p.isDark ? const Color(0x40E2C08D) : p.separator), child: body)
            : body,
      ),
    );
    return Builder(
      builder: (areaContext) {
        if (_drag != null && _drop == null) {
          _drop = DropColumn(areaContext, () => _openIds);
          _drag!.registerColumn(v.id, _drop!);
        }
        return column;
      },
    );
  }
}

/// Release-version headers can be dragged to reorder columns.
class _HeaderDrag extends StatelessWidget {
  const _HeaderDrag({required this.version, required this.child});
  final Version version;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (version.kind == 'concept') return child;
    final p = VersoPalette.of(context);
    return Draggable<Version>(
      data: version,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        type: MaterialType.transparency,
        child: Transform.translate(
          offset: const Offset(-40, -18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: p.surfaceRaised,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [BoxShadow(color: p.shadow.withValues(alpha: .3), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Text(
              version.name,
              style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: p.text),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: .4, child: child),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: child),
    );
  }
}

/// Accepts a dragged version header; drops before/after this column by half.
class _ColumnDropTarget extends ConsumerStatefulWidget {
  const _ColumnDropTarget({required this.version, required this.child});
  final Version version;
  final Widget child;

  @override
  ConsumerState<_ColumnDropTarget> createState() => _ColumnDropTargetState();
}

class _ColumnDropTargetState extends ConsumerState<_ColumnDropTarget> {
  bool? _before;

  bool _isBefore(Offset global) {
    final box = context.findRenderObject() as RenderBox;
    return box.globalToLocal(global).dx < box.size.width / 2 && widget.version.kind != 'concept';
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return DragTarget<Version>(
      onWillAcceptWithDetails: (d) => d.data.id != widget.version.id,
      onMove: (d) => setState(() => _before = _isBefore(d.offset)),
      onLeave: (_) => setState(() => _before = null),
      onAcceptWithDetails: (d) {
        final before = _isBefore(d.offset);
        setState(() => _before = null);
        ref
            .read(undoProvider)
            .run(
              moveVersionAction(
                ref.read(versionRepoProvider),
                d.data.id,
                beforeId: before ? widget.version.id : null,
                afterId: before ? null : widget.version.id,
              ),
            );
      },
      builder: (context, cand, rej) => Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          if (_before != null && cand.isNotEmpty)
            Positioned(
              top: 8,
              bottom: 8,
              left: _before! ? -7 : null,
              right: _before! ? null : 5,
              child: Container(
                width: 3,
                decoration: BoxDecoration(color: p.primary, borderRadius: BorderRadius.circular(2)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Collapse extends StatelessWidget {
  const _Collapse({required this.collapsed, required this.child});
  final bool collapsed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: collapsed ? 0 : 1),
      duration: Motion.smoothDur(context),
      curve: Curves.easeOutCubic,
      child: child,
      // Same tree shape at every t, so the card's state (and its drag
      // recognizer) survives.
      builder: (context, t, child) => ClipRect(
        clipBehavior: t == 1 ? Clip.none : Clip.hardEdge,
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: t,
          child: Opacity(opacity: t, child: child),
        ),
      ),
    );
  }
}

class _PlaceholderBox extends StatelessWidget {
  const _PlaceholderBox({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: p.primary.withValues(alpha: p.isDark ? .10 : .08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.primary.withValues(alpha: .35), width: 1.2),
      ),
    );
  }
}

class _DoneHeaderRow extends StatelessWidget {
  const _DoneHeaderRow({required this.count, required this.expanded, required this.onTap});
  final int count;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
          child: Row(
            children: [
              AnimatedRotation(
                turns: expanded ? .25 : 0,
                duration: Motion.dur(context),
                curve: Motion.curve(context),
                child: Icon(Icons.chevron_right_rounded, size: 18, color: p.textSecondary),
              ),
              const SizedBox(width: 2),
              Text(
                'Done · $count',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: p.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1, color: p.separator.withValues(alpha: .6))),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRRect extends CustomPainter {
  _DashedRRect(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final path = Path()..addRRect(RRect.fromRectAndRadius((Offset.zero & s).deflate(.75), const Radius.circular(22)));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;
    for (final ui.PathMetric m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 11) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRect o) => o.color != color;
}
