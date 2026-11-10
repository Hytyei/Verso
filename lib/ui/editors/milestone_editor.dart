import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../common/glass_menu.dart';
import '../glass/glass_surface.dart';
import '../shell/glass_segmented.dart';
import '../theme/palette.dart';
import 'color_picker.dart';
import 'date_chip.dart';

/// Creates ([milestone] null) or edits a milestone in a popover.
Future<void> showMilestoneEditor(
  BuildContext context, {
  required String projectId,
  required Offset pos,
  Milestone? milestone,
  DateTime? initialDate,
}) {
  return showGlassPopover(
    context,
    anchor: Rect.fromLTWH(pos.dx, pos.dy, 0, 0),
    width: 330,
    builder: (ctx, close) =>
        _MilestoneEditor(projectId: projectId, milestone: milestone, initialDate: initialDate, close: close),
  );
}

class _MilestoneEditor extends ConsumerStatefulWidget {
  const _MilestoneEditor({
    required this.projectId,
    required this.milestone,
    required this.initialDate,
    required this.close,
  });
  final String projectId;
  final Milestone? milestone;
  final DateTime? initialDate;
  final VoidCallback close;

  @override
  ConsumerState<_MilestoneEditor> createState() => _MilestoneEditorState();
}

class _MilestoneEditorState extends ConsumerState<_MilestoneEditor> {
  late final _title = TextEditingController(text: widget.milestone?.title ?? '');
  late DateTime _date = widget.milestone?.date ?? widget.initialDate ?? DateTime.now().toUtc();
  late MilestoneKind _kind = MilestoneKind.values.firstWhere(
    (k) => k.name == widget.milestone?.kind,
    orElse: () => MilestoneKind.release,
  );
  late VColor? _color = widget.milestone?.color == null
      ? null
      : VColor(widget.milestone!.color!, custom: widget.milestone!.colorCustom);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final repo = ref.read(milestoneRepoProvider);
    final m = widget.milestone;
    if (m == null) {
      await repo.create(widget.projectId, title, _date, kind: _kind, color: _color);
    } else {
      await repo.update(m.id, title: title, date: _date, kind: _kind, color: Value(_color));
    }
    widget.close();
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final label = TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600, color: p.textSecondary);
    return GlassSurface(
      radius: 18,
      tint: p.isDark ? const Color(0xF51E1A16) : const Color(0xF5FFFFFF),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('milestone-title'),
            controller: _title,
            autofocus: widget.milestone == null,
            style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: p.text),
            decoration: const InputDecoration.collapsed(hintText: 'Milestone, e.g. Play Store launch'),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 12),
          DateChip(
            key: const Key('milestone-date'),
            label: 'Date',
            date: _date,
            onChanged: (d) => setState(() => _date = d ?? _date),
          ),
          const SizedBox(height: 12),
          Text('Kind', style: label),
          const SizedBox(height: 6),
          GlassSegmented<MilestoneKind>(
            segmentWidth: 72,
            height: 28,
            items: const [
              (MilestoneKind.release, 'Release'),
              (MilestoneKind.launch, 'Launch'),
              (MilestoneKind.deadline, 'Deadline'),
              (MilestoneKind.other, 'Other'),
            ],
            value: _kind,
            onChanged: (k) => setState(() => _kind = k),
          ),
          const SizedBox(height: 12),
          Text('Color', style: label),
          const SizedBox(height: 6),
          ColorPicker(value: _color, allowNone: true, onChanged: (c) => setState(() => _color = c)),
          const SizedBox(height: 14),
          Row(
            children: [
              if (widget.milestone != null)
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: p.coral),
                  onPressed: () async {
                    await ref.read(milestoneRepoProvider).softDelete(widget.milestone!.id);
                    widget.close();
                  },
                  child: const Text('Delete'),
                ),
              const Spacer(),
              FilledButton(
                key: const Key('milestone-save'),
                style: FilledButton.styleFrom(
                  backgroundColor: p.primary,
                  foregroundColor: p.isDark ? Colors.black : Colors.white,
                ),
                onPressed: _save,
                child: Text(widget.milestone == null ? 'Add' : 'Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
