import 'package:flutter/material.dart';

import '../../data/repos/feature_repo.dart';

/// A column the controller can drop into.
class DropColumn {
  DropColumn(this.area, this.openIds);

  /// Context of the column's whole area (for its global rect).
  final BuildContext area;

  /// Current open (unchecked) feature ids in board order.
  final List<String> Function() openIds;
}

/// Drag state for moving feature cards between and within columns.
/// Cards and columns register their contexts; the controller measures
/// them from the render tree while dragging.
class BoardDragController extends ChangeNotifier {
  final Map<String, DropColumn> _columns = {};
  final Map<String, BuildContext> _cards = {};

  FeatureView? dragging;
  String? fromVersionId;
  Offset pointer = Offset.zero;
  Offset grab = Offset.zero;
  Size cardSize = Size.zero;

  String? targetVersionId;

  /// Insert position among the target's open cards (dragged card excluded).
  int targetIndex = 0;

  bool get active => dragging != null;

  void registerColumn(String versionId, DropColumn c) => _columns[versionId] = c;
  void unregisterColumn(String versionId, DropColumn c) {
    if (_columns[versionId] == c) _columns.remove(versionId);
  }

  void registerCard(String featureId, BuildContext ctx) => _cards[featureId] = ctx;
  void unregisterCard(String featureId, BuildContext ctx) {
    if (_cards[featureId] == ctx) _cards.remove(featureId);
  }

  Rect? _rectOf(BuildContext ctx) {
    final ro = ctx.findRenderObject();
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) return null;
    return ro.localToGlobal(Offset.zero) & ro.size;
  }

  void start(FeatureView v, String versionId, Offset globalPointer, Rect cardRect) {
    dragging = v;
    fromVersionId = versionId;
    pointer = globalPointer;
    grab = globalPointer - cardRect.topLeft;
    cardSize = cardRect.size;
    _retarget();
    notifyListeners();
  }

  void update(Offset globalPointer) {
    if (!active) return;
    pointer = globalPointer;
    final before = (targetVersionId, targetIndex);
    _retarget();
    if (before != (targetVersionId, targetIndex)) notifyListeners();
    _ghostTick.value++;
  }

  /// Ticks on every pointer move (the ghost listens; columns don't).
  final ValueNotifier<int> _ghostTick = ValueNotifier(0);
  Listenable get ghost => _ghostTick;

  void _retarget() {
    String? target;
    for (final e in _columns.entries) {
      final r = _rectOf(e.value.area);
      if (r != null && pointer.dx >= r.left && pointer.dx <= r.right) {
        target = e.key;
        break;
      }
    }
    targetVersionId = target;
    if (target == null) return;
    final ids = _columns[target]!.openIds().where((id) => id != dragging?.id);
    var i = 0;
    for (final id in ids) {
      final ctx = _cards[id];
      final r = ctx == null ? null : _rectOf(ctx);
      if (r != null && r.center.dy < pointer.dy) i++;
    }
    targetIndex = i;
  }

  /// Finishes the drag; returns where to move, or null to cancel / no-op.
  ({String featureId, String versionId, String? afterId, String? beforeId})? end() {
    final v = dragging;
    final target = targetVersionId;
    final index = targetIndex;
    dragging = null;
    targetVersionId = null;
    notifyListeners();
    if (v == null || target == null) return null;
    final ids = _columns[target]!.openIds().where((id) => id != v.id).toList();
    final i = index.clamp(0, ids.length);
    final afterId = i > 0 ? ids[i - 1] : null;
    final beforeId = i < ids.length ? ids[i] : null;
    if (target == fromVersionId && !v.f.done) {
      final current = _columns[target]!.openIds();
      final at = current.indexOf(v.id);
      final curAfter = at > 0 ? current[at - 1] : null;
      final curBefore = at >= 0 && at + 1 < current.length ? current[at + 1] : null;
      if (curAfter == afterId && curBefore == beforeId) return null;
    }
    return (featureId: v.id, versionId: target, afterId: afterId, beforeId: beforeId);
  }

  void cancel() {
    if (!active) return;
    dragging = null;
    targetVersionId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ghostTick.dispose();
    super.dispose();
  }
}

/// Provides the board's drag controller to columns and cards.
class BoardDrag extends InheritedNotifier<BoardDragController> {
  const BoardDrag({super.key, required BoardDragController controller, required super.child})
    : super(notifier: controller);

  /// Listening lookup (rebuilds on target changes).
  static BoardDragController? watch(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BoardDrag>()?.notifier;

  /// Non-listening lookup.
  static BoardDragController? read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<BoardDrag>()?.notifier;
}
