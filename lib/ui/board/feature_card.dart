import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/models.dart';
import '../../data/repos/feature_repo.dart';
import '../../data/undo.dart';
import '../../state/providers.dart';
import '../common/check_pop.dart';
import '../common/chips.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';
import 'drag_controller.dart';
import 'feature_actions.dart';

/// Builds the expanded body of a card (notes, sub-items, images). Set by
/// the board so the card stays independent of the editors.
typedef ExpandedBuilder = Widget Function(BuildContext context, FeatureView v);

/// A feature on the board: accent bar, round checkbox, freely wrapping
/// title, meta row (tags, priority, sub-items, attachments, notes, delay).
class FeatureCard extends ConsumerStatefulWidget {
  const FeatureCard({
    super.key,
    required this.v,
    required this.version,
    required this.versionNames,
    this.expandedBuilder,
  });

  final FeatureView v;
  final Version version;

  /// id → name, for "Delayed from v1.0".
  final Map<String, String> versionNames;
  final ExpandedBuilder? expandedBuilder;

  @override
  ConsumerState<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends ConsumerState<FeatureCard> {
  bool _hover = false;
  bool _editing = false;
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  BoardDragController? _drag;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final d = BoardDrag.read(context);
    if (d != _drag) {
      _drag?.unregisterCard(widget.v.id, context);
      _drag = d;
    }
    _drag?.registerCard(widget.v.id, context);
  }

  @override
  void didUpdateWidget(FeatureCard old) {
    super.didUpdateWidget(old);
    if (old.v.id != widget.v.id) _drag?.unregisterCard(old.v.id, context);
    _drag?.registerCard(widget.v.id, context);
  }

  @override
  void dispose() {
    _drag?.unregisterCard(widget.v.id, context);
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _dragStart(DragStartDetails d) {
    final drag = _drag;
    final box = context.findRenderObject() as RenderBox?;
    if (drag == null || box == null || _editing) return;
    drag.start(widget.v, widget.version.id, d.globalPosition, box.localToGlobal(Offset.zero) & box.size);
  }

  Future<void> _dragEnd() async {
    final r = _drag?.end();
    if (r == null) return;
    await ref
        .read(undoProvider)
        .run(
          moveFeatureAction(
            ref.read(featureRepoProvider),
            r.featureId,
            r.versionId,
            afterId: r.afterId,
            beforeId: r.beforeId,
          ),
        );
  }

  void startEdit() {
    _ctrl.text = widget.v.f.title;
    _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  Future<void> _commit() async {
    if (!_editing) return;
    final text = _ctrl.text.trim();
    setState(() => _editing = false);
    if (text.isNotEmpty && text != widget.v.f.title) {
      await FeatureActions(ref).rename(widget.v.id, widget.v.f.title, text);
    }
  }

  Color? _accent(VersoPalette p) {
    final f = widget.v.f;
    if (f.color != null) return p.resolve(VColor(f.color!, custom: f.colorCustom));
    if (widget.v.tags.isNotEmpty) {
      final t = widget.v.tags.first;
      return p.resolve(VColor(t.color, custom: t.colorCustom));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final v = widget.v;
    final f = v.f;
    final accent = _accent(p);
    final focused = ref.watch(focusedFeatureProvider.select((id) => id == v.id));
    ref.listen(renameRequestProvider, (_, id) {
      if (id == v.id) {
        startEdit();
        ref.read(renameRequestProvider.notifier).set(null);
      }
    });
    final expanded = ref.watch(expandedFeatureProvider.select((id) => id == v.id));
    final checkColor = accent ?? p.primary;
    final cardColor = f.color != null
        ? Color.alphaBlend(
            p.resolveTint(VColor(f.color!, custom: f.colorCustom)).withValues(alpha: p.isDark ? .55 : .5),
            p.surfaceRaised,
          )
        : p.surfaceRaised;

    final title = _editing
        ? CallbackShortcuts(
            bindings: {const SingleActivator(LogicalKeyboardKey.escape): () => setState(() => _editing = false)},
            child: TextField(
              key: Key('edit-${v.id}'),
              controller: _ctrl,
              focusNode: _focus,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _commit(),
              onTapOutside: (_) => _commit(),
              style: _titleStyle(p, false),
              decoration: const InputDecoration.collapsed(hintText: 'Feature'),
            ),
          )
        : Text(f.title, style: _titleStyle(p, f.done));

    final meta = <Widget>[
      if (f.delayCount > 0)
        TintChip(
          label: f.delayCount > 1
              ? 'Delayed ×${f.delayCount} · from ${widget.versionNames[f.delayedFromVersionId] ?? '?'}'
              : 'Delayed from ${widget.versionNames[f.delayedFromVersionId] ?? '?'}',
          color: p.coral,
          tint: p.coralTint,
          icon: Icons.schedule_rounded,
          muted: f.done,
        ),
      for (final t in v.tags)
        TintChip(
          label: t.name,
          color: p.resolve(VColor(t.color, custom: t.colorCustom)),
          tint: p.resolveTint(VColor(t.color, custom: t.colorCustom)),
        ),
      if (f.priority > 0) PriorityFlag(priority: f.priority),
      if (v.subTotal > 0) MetaCount(icon: Icons.checklist_rounded, text: '${v.subDone}/${v.subTotal}'),
      if (v.attachments > 0) MetaCount(icon: Icons.image_outlined, text: '${v.attachments}'),
      if ((f.notes ?? '').trim().isNotEmpty) const MetaCount(icon: Icons.notes_rounded),
    ];

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        key: Key('card-${v.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ref.read(focusedFeatureProvider.notifier).set(v.id);
          ref.read(expandedFeatureProvider.notifier).set(expanded ? null : v.id);
        },
        onDoubleTap: startEdit,
        onPanStart: _dragStart,
        onPanUpdate: (d) => _drag?.update(d.globalPosition),
        onPanEnd: (_) => _dragEnd(),
        onPanCancel: () => _drag?.cancel(),
        onSecondaryTapUp: (d) {
          ref.read(focusedFeatureProvider.notifier).set(v.id);
          showFeatureMenu(context, ref, v, widget.version, d.globalPosition);
        },
        child: AnimatedContainer(
          duration: Motion.smoothDur(context),
          curve: Motion.smooth,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: focused
                  ? p.primary.withValues(alpha: .55)
                  : (p.isDark ? const Color(0x12FFFFFF) : const Color(0x00FFFFFF)),
              width: focused ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: p.shadow.withValues(alpha: p.shadow.a * (_hover ? 1.6 : 1)),
                blurRadius: _hover ? 16 : 8,
                offset: Offset(0, _hover ? 4 : 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(13, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckPop(
                            key: Key('check-${v.id}'),
                            value: f.done,
                            color: checkColor,
                            onChanged: (d) => FeatureActions(ref).setDone(v.id, d),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(padding: const EdgeInsets.only(top: 2.5), child: title),
                          ),
                        ],
                      ),
                      if (meta.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 32, top: 7),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 5,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: meta,
                          ),
                        ),
                      AnimatedSize(
                        duration: Motion.dur(context),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: expanded && widget.expandedBuilder != null
                            ? Padding(
                                padding: const EdgeInsets.only(left: 32, top: 10),
                                child: widget.expandedBuilder!(context, v),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: AnimatedContainer(
                    key: Key('accent-${v.id}'),
                    duration: Motion.smoothDur(context),
                    width: accent == null ? 0 : 3.5,
                    color: accent ?? Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _titleStyle(VersoPalette p, bool done) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    height: 1.38,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    color: done ? p.textSecondary : p.text,
  );
}
