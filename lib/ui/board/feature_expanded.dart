import 'dart:async';

import 'package:drift/drift.dart' show Value;
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
import '../common/toast.dart';
import '../editors/date_chip.dart';
import '../editors/tag_editor.dart';
import '../theme/palette.dart';
import 'attachment_strip.dart';

final _subitemsProvider = StreamProvider.family<List<Subitem>, String>(
  (ref, featureId) => ref.watch(featureRepoProvider).watchSubitems(featureId),
);

/// Body of an expanded card: notes, steps, tags, priority, dates, images.
class FeatureExpanded extends ConsumerWidget {
  const FeatureExpanded({super.key, required this.v});
  final FeatureView v;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final projectId = ref.watch(selectedProjectIdProvider) ?? '';
    final label = TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600, color: p.textSecondary);
    final repo = ref.read(featureRepoProvider);
    final f = v.f;
    // Absorb taps/pans so editing inside doesn't collapse or drag the card.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      onDoubleTap: () {},
      onPanStart: (_) {},
      child: Focus(
        onKeyEvent: (node, e) {
          final ctrl = HardwareKeyboard.instance.isControlPressed;
          if (e is KeyDownEvent && ctrl && e.logicalKey == LogicalKeyboardKey.keyV) {
            pasteImage(context, ref.read, v.id);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _NotesField(featureId: v.id, initial: f.notes ?? ''),
            const SizedBox(height: 12),
            Text('Steps', style: label),
            const SizedBox(height: 4),
            _Steps(featureId: v.id),
            const SizedBox(height: 12),
            Text('Tags', style: label),
            const SizedBox(height: 6),
            _TagToggles(v: v, projectId: projectId),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text('Priority', style: label),
                ),
                for (var i = 0; i <= 3; i++)
                  Padding(
                    padding: EdgeInsets.zero,
                    child: _PriorityOption(
                      key: Key('priority-$i-${v.id}'),
                      level: i,
                      selected: f.priority == i,
                      onTap: () => ref
                          .read(undoProvider)
                          .run(
                            editAction(
                              'Priority',
                              () => repo.update(v.id, priority: i),
                              () => repo.update(v.id, priority: f.priority),
                            ),
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                DateChip(
                  key: Key('feature-start-${v.id}'),
                  label: 'Start',
                  date: f.startDate,
                  onChanged: (d) => ref
                      .read(undoProvider)
                      .run(
                        dateChangeAction(
                          'Start date',
                          () => repo.update(v.id, startDate: Value(d)),
                          () => repo.update(v.id, startDate: Value(f.startDate)),
                        ),
                      ),
                ),
                DateChip(
                  key: Key('feature-end-${v.id}'),
                  label: 'End',
                  date: f.endDate,
                  onChanged: (d) => ref
                      .read(undoProvider)
                      .run(
                        dateChangeAction(
                          'End date',
                          () => repo.update(v.id, endDate: Value(d)),
                          () => repo.update(v.id, endDate: Value(f.endDate)),
                        ),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AttachmentStrip(featureId: v.id),
          ],
        ),
      ),
    );
  }
}

class _NotesField extends ConsumerStatefulWidget {
  const _NotesField({required this.featureId, required this.initial});
  final String featureId;
  final String initial;

  @override
  ConsumerState<_NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends ConsumerState<_NotesField> {
  late final _ctrl = TextEditingController(text: widget.initial);
  Timer? _debounce;
  late String _saved = widget.initial;

  /// Notes when this editing session began (one undo step per session).
  late String _sessionStart = widget.initial;
  late final FeatureRepo _repo = ref.read(featureRepoProvider);
  late final UndoStack _undo = ref.read(undoProvider);

  static String? _norm(String t) => t.trim().isEmpty ? null : t;

  void _save() {
    _debounce?.cancel();
    final t = _ctrl.text;
    if (t == _saved) return;
    _saved = t;
    _repo.update(widget.featureId, notes: Value(_norm(t)));
  }

  /// Saves and records the whole session as one undoable edit.
  void _endSession() {
    _save();
    if (_saved == _sessionStart) return;
    _undo.run(notesEditAction(_repo, widget.featureId, _norm(_sessionStart), _norm(_saved)));
    _sessionStart = _saved;
  }

  @override
  void dispose() {
    _endSession();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: p.text.withValues(alpha: .04), borderRadius: BorderRadius.circular(10)),
      child: TextField(
        key: Key('notes-${widget.featureId}'),
        controller: _ctrl,
        maxLines: null,
        minLines: 2,
        onChanged: (_) {
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), _save);
        },
        onTapOutside: (_) => _endSession(),
        style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, height: 1.4, color: p.text),
        decoration: InputDecoration.collapsed(
          hintText: 'Notes…',
          hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.textSecondary),
        ),
      ),
    );
  }
}

/// Steps as a tree: any step can hold sub-steps to any depth. Each level is
/// reorderable by dragging its handle; "+" on a step adds a sub-step.
class _Steps extends ConsumerStatefulWidget {
  const _Steps({required this.featureId});
  final String featureId;

  @override
  ConsumerState<_Steps> createState() => _StepsState();
}

class _StepsState extends ConsumerState<_Steps> {
  /// Where the add field is open: '' = top level, a step id = under that step, null = closed.
  String? _addingUnder;
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  final _collapsed = <String>{};

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _openAdd(String under) {
    _ctrl.clear();
    setState(() => _addingUnder = under);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  Future<void> _submit() async {
    final t = _ctrl.text.trim();
    final under = _addingUnder;
    if (t.isEmpty || under == null) {
      setState(() => _addingUnder = null);
      return;
    }
    _ctrl.clear();
    await ref.read(featureRepoProvider).addSubitem(widget.featureId, t, parentId: under.isEmpty ? null : under);
    if (under.isNotEmpty) setState(() => _collapsed.remove(under));
    _focus.requestFocus();
  }

  Widget _addField(VersoPalette p, String under, double indent) => Padding(
    padding: EdgeInsets.only(left: indent + 26, top: 2, bottom: 2),
    child: CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): () => setState(() => _addingUnder = null)},
      child: TextField(
        key: Key('step-field-${under.isEmpty ? widget.featureId : under}'),
        controller: _ctrl,
        focusNode: _focus,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        onTapOutside: (_) {
          if (_ctrl.text.trim().isEmpty) setState(() => _addingUnder = null);
        },
        style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.text),
        decoration: InputDecoration.collapsed(
          hintText: under.isEmpty ? 'New step' : 'New sub-step',
          hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.textSecondary),
        ),
      ),
    ),
  );

  /// One level of the tree: siblings under [parentId], reorderable.
  Widget _level(VersoPalette p, Map<String?, List<Subitem>> byParent, String? parentId, int depth) {
    final repo = ref.read(featureRepoProvider);
    final siblings = byParent[parentId] ?? const <Subitem>[];
    final indent = depth * 18.0;
    return ReorderableListView.builder(
      key: ValueKey('steps-${parentId ?? 'root'}'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: siblings.length,
      proxyDecorator: (child, i, a) => Material(type: MaterialType.transparency, child: child),
      onReorder: (from, to) {
        final ids = [for (final s in siblings) s.id];
        final moving = ids.removeAt(from);
        final at = to > from ? to - 1 : to;
        ids.insert(at, moving);
        final pos = ids.indexOf(moving);
        ref
            .read(undoProvider)
            .run(
              moveSubitemAction(
                repo,
                moving,
                parentId: parentId,
                afterId: pos > 0 ? ids[pos - 1] : null,
                beforeId: pos + 1 < ids.length ? ids[pos + 1] : null,
              ),
            );
      },
      itemBuilder: (context, i) {
        final s = siblings[i];
        final kids = byParent[s.id] ?? const <Subitem>[];
        final open = !_collapsed.contains(s.id);
        return Column(
          key: ValueKey(s.id),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepRow(
              step: s,
              index: i,
              indent: indent,
              childCount: kids.length,
              open: open,
              onToggleOpen: () => setState(() => open ? _collapsed.add(s.id) : _collapsed.remove(s.id)),
              onToggle: (d) => ref.read(undoProvider).run(toggleSubitemAction(repo, s.id, d)),
              onAddChild: () => _openAdd(s.id),
              onDelete: () async {
                final undo = ref.read(undoProvider);
                final action = deleteSubitemAction(repo, s.id);
                await undo.run(action);
                if (context.mounted) {
                  showToast(
                    context,
                    kids.isEmpty ? 'Step deleted' : 'Step and its sub-steps deleted',
                    onUndo: () => undo.undoIfTop(action),
                  );
                }
              },
            ),
            if (open && kids.isNotEmpty) _level(p, byParent, s.id, depth + 1),
            if (_addingUnder == s.id) _addField(p, s.id, indent + 18),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final steps = ref.watch(_subitemsProvider(widget.featureId)).value ?? const <Subitem>[];
    final ids = {for (final s in steps) s.id};
    final byParent = <String?, List<Subitem>>{};
    for (final s in steps) {
      // A step whose parent is gone (deleted elsewhere) shows at the top level.
      final parent = s.parentId != null && ids.contains(s.parentId) ? s.parentId : null;
      (byParent[parent] ??= []).add(s);
    }
    for (final l in byParent.values) {
      l.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _level(p, byParent, null, 0),
        if (_addingUnder == '')
          _addField(p, '', 0)
        else
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: Key('add-step-${widget.featureId}'),
              style: TextButton.styleFrom(
                foregroundColor: p.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(0, 30),
              ),
              onPressed: () => _openAdd(''),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add step', style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
            ),
          ),
      ],
    );
  }
}

class _StepRow extends StatefulWidget {
  const _StepRow({
    required this.step,
    required this.index,
    required this.indent,
    required this.childCount,
    required this.open,
    required this.onToggleOpen,
    required this.onToggle,
    required this.onAddChild,
    required this.onDelete,
  });
  final Subitem step;
  final int index;
  final double indent;
  final int childCount;
  final bool open;
  final VoidCallback onToggleOpen;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAddChild;
  final VoidCallback onDelete;

  @override
  State<_StepRow> createState() => _StepRowState();
}

class _StepRowState extends State<_StepRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final s = widget.step;
    Widget action(Key key, IconData icon, String tip, VoidCallback onTap) => Tooltip(
      message: tip,
      child: GestureDetector(
        key: key,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(icon, size: 14, color: p.textSecondary),
        ),
      ),
    );
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Padding(
        padding: EdgeInsets.only(left: widget.indent, top: 2, bottom: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReorderableDragStartListener(
              index: widget.index,
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: AnimatedOpacity(
                  opacity: _hover ? 1 : .25,
                  duration: const Duration(milliseconds: 120),
                  child: Padding(
                    key: Key('step-handle-${s.id}'),
                    padding: const EdgeInsets.only(top: 1, right: 2),
                    child: Icon(Icons.drag_indicator_rounded, size: 15, color: p.textSecondary),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 16,
              child: widget.childCount == 0
                  ? null
                  : GestureDetector(
                      onTap: widget.onToggleOpen,
                      child: AnimatedRotation(
                        turns: widget.open ? .25 : 0,
                        duration: const Duration(milliseconds: 160),
                        child: Icon(Icons.chevron_right_rounded, size: 16, color: p.textSecondary),
                      ),
                    ),
            ),
            CheckPop(value: s.done, onChanged: widget.onToggle, color: p.primary, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  widget.childCount == 0 || widget.open ? s.title : '${s.title}  ·  ${widget.childCount}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    height: 1.35,
                    color: s.done ? p.textSecondary : p.text,
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _hover ? 1 : 0,
              duration: const Duration(milliseconds: 120),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  action(
                    Key('add-substep-${s.id}'),
                    Icons.subdirectory_arrow_right_rounded,
                    'Add sub-step',
                    widget.onAddChild,
                  ),
                  action(Key('delete-step-${s.id}'), Icons.close_rounded, 'Delete', widget.onDelete),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagToggles extends ConsumerWidget {
  const _TagToggles({required this.v, required this.projectId});
  final FeatureView v;
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final tags = ref.watch(tagsProvider(projectId)).value ?? const <Tag>[];
    final on = {for (final t in v.tags) t.id};
    final repo = ref.read(featureRepoProvider);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final t in tags)
          GestureDetector(
            key: Key('tag-toggle-${t.id}'),
            onTap: () {
              final next = on.contains(t.id) ? (on.toList()..remove(t.id)) : [...on, t.id];
              final before = on.toList();
              ref
                  .read(undoProvider)
                  .run(editAction('Tags', () => repo.setTags(v.id, next), () => repo.setTags(v.id, before)));
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: on.contains(t.id)
                  ? TintChip(
                      label: t.name,
                      color: p.resolve(VColor(t.color, custom: t.colorCustom)),
                      tint: p.resolveTint(VColor(t.color, custom: t.colorCustom)),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: p.separator),
                      ),
                      child: Text(
                        t.name,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: p.textSecondary),
                      ),
                    ),
            ),
          ),
        GestureDetector(
          onTapUp: (d) => showTagEditor(context, projectId, d.globalPosition),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                'Edit tags',
                style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600, color: p.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PriorityOption extends StatelessWidget {
  const _PriorityOption({super.key, required this.level, required this.selected, required this.onTap});
  final int level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? p.primary.withValues(alpha: .14) : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: selected ? p.primary.withValues(alpha: .5) : p.separator),
          ),
          child: level == 0
              ? Text(
                  'None',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, color: p.textSecondary),
                )
              : PriorityFlag(priority: level),
        ),
      ),
    );
  }
}
