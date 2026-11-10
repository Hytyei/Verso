import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/models.dart';
import '../../data/undo.dart';
import '../../state/providers.dart';
import '../common/env_icon.dart';
import '../common/glass_menu.dart';
import '../common/toast.dart';
import '../glass/glass_surface.dart';
import '../shell/glass_segmented.dart';
import '../theme/palette.dart';
import 'color_picker.dart';
import 'confirm.dart';
import 'date_chip.dart';

/// Opens the version (or Concept stage) editor next to [pos].
Future<void> showVersionEditor(BuildContext context, WidgetRef ref, Version v, Offset pos) {
  return showGlassPopover(
    context,
    anchor: Rect.fromLTWH(pos.dx - 300, pos.dy, 0, 0),
    width: 330,
    builder: (ctx, close) => _VersionEditor(versionId: v.id, close: close),
  );
}

class _VersionEditor extends ConsumerStatefulWidget {
  const _VersionEditor({required this.versionId, required this.close});
  final String versionId;
  final VoidCallback close;

  @override
  ConsumerState<_VersionEditor> createState() => _VersionEditorState();
}

class _VersionEditorState extends ConsumerState<_VersionEditor> {
  Version? _v;
  final _name = TextEditingController();
  final _desc = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await ref.read(versionRepoProvider).get(widget.versionId);
    if (!mounted) return;
    setState(() => _v = v);
    _name.text = v.name;
    _desc.text = v.description ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  /// Applies [change] undoably, restoring the full previous row on undo.
  Future<void> _edit(String label, Future<void> Function() change) async {
    final before = _v!;
    final repo = ref.read(versionRepoProvider);
    await ref
        .read(undoProvider)
        .run(
          editAction(
            label,
            change,
            () => repo.update(
              before.id,
              name: before.name,
              status: VersionStatus.values.firstWhere((s) => s.name == before.status),
              color: VColor(before.color, custom: before.colorCustom),
              startDate: Value(before.startDate),
              targetDate: Value(before.targetDate),
              releasedDate: Value(before.releasedDate),
              description: Value(before.description),
            ),
          ),
        );
    await _load();
  }

  /// Breaks the project at [v]: it and every later version move to [envId].
  Future<void> _moveEnvironment(Version v, String envId) async {
    if (envId == v.environmentId) return;
    final host = Overlay.of(context, rootOverlay: true);
    final undo = ref.read(undoProvider);
    final action = setEnvironmentFromAction(ref.read(versionRepoProvider), v.id, envId);
    await undo.run(action);
    final env = (ref.read(environmentsProvider).value ?? const <Environment>[]).where((e) => e.id == envId).firstOrNull;
    openSegment(ref, v.projectId, envId);
    widget.close();
    if (host.mounted) {
      showToastOn(
        host,
        '${v.name} and later now continue in ${env?.name ?? 'the new environment'}',
        onUndo: () => undo.undoIfTop(action),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final v = _v;
    final repo = ref.read(versionRepoProvider);
    final label = TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600, color: p.textSecondary);
    return GlassSurface(
      radius: 18,
      tint: p.isDark ? const Color(0xF51E1A16) : const Color(0xF5FFFFFF),
      padding: const EdgeInsets.all(16),
      child: v == null
          ? const SizedBox(height: 80)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (v.kind == 'concept')
                  Text(
                    'Concept stage',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: p.text),
                  )
                else
                  TextField(
                    key: const Key('version-name'),
                    controller: _name,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700, color: p.text),
                    decoration: const InputDecoration.collapsed(hintText: 'Version name'),
                    onSubmitted: (s) =>
                        s.trim().isEmpty ? null : _edit('Rename version', () => repo.update(v.id, name: s.trim())),
                    onTapOutside: (_) {
                      final s = _name.text.trim();
                      if (s.isNotEmpty && s != v.name) _edit('Rename version', () => repo.update(v.id, name: s));
                    },
                  ),
                if (v.kind != 'concept') ...[
                  const SizedBox(height: 14),
                  Text('Status', style: label),
                  const SizedBox(height: 6),
                  GlassSegmented<VersionStatus>(
                    segmentWidth: 94,
                    height: 30,
                    items: const [
                      (VersionStatus.planned, 'Planned'),
                      (VersionStatus.active, 'In progress'),
                      (VersionStatus.released, 'Released'),
                    ],
                    value: VersionStatus.values.firstWhere((s) => s.name == v.status),
                    onChanged: (s) => _edit(
                      'Change status',
                      () => repo.update(
                        v.id,
                        status: s,
                        releasedDate: s == VersionStatus.released && v.releasedDate == null
                            ? Value(DateTime.now().toUtc())
                            : const Value.absent(),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Text(v.kind == 'concept' ? 'Concept design period' : 'Dates', style: label),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    DateChip(
                      key: const Key('start-date'),
                      label: 'Start',
                      date: v.startDate,
                      onChanged: (d) => _edit('Set start', () => repo.update(v.id, startDate: Value(d))),
                    ),
                    DateChip(
                      key: const Key('target-date'),
                      label: v.kind == 'concept' ? 'End' : 'Target',
                      date: v.targetDate,
                      onChanged: (d) => _edit('Set target', () => repo.update(v.id, targetDate: Value(d))),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Environment', style: label),
                const SizedBox(height: 6),
                _EnvironmentPicker(version: v, onPicked: (envId) => _moveEnvironment(v, envId)),
                const SizedBox(height: 14),
                Text('Color', style: label),
                const SizedBox(height: 6),
                ColorPicker(
                  value: VColor(v.color, custom: v.colorCustom),
                  onChanged: (c) => c == null ? null : _edit('Color', () => repo.update(v.id, color: c)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _desc,
                  maxLines: null,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.text),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Description',
                    hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.textSecondary),
                  ),
                  onTapOutside: (_) {
                    final s = _desc.text.trim();
                    if (s != (v.description ?? ''))
                      _edit('Description', () => repo.update(v.id, description: Value(s.isEmpty ? null : s)));
                  },
                ),
                if (v.kind != 'concept') ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, color: p.separator),
                  const SizedBox(height: 4),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: p.coral, padding: EdgeInsets.zero),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete version'),
                    onPressed: () async {
                      final count = (ref.read(featureViewsProvider(v.id)).value ?? const []).length;
                      final ok = await confirmDanger(
                        context,
                        title: 'Delete ${v.name}?',
                        message: count == 0
                            ? 'This version has no features.'
                            : 'Its $count ${count == 1 ? 'feature' : 'features'} will be deleted too. You can undo this.',
                      );
                      if (!ok || !context.mounted) return;
                      final host = Overlay.of(context, rootOverlay: true);
                      widget.close();
                      final undo = ref.read(undoProvider);
                      final action = deleteVersionAction(ref.read(dbProvider), v.id);
                      await undo.run(action);
                      if (host.mounted) showToastOn(host, '${v.name} deleted', onUndo: () => undo.undoIfTop(action));
                    },
                  ),
                ],
              ],
            ),
    );
  }
}

class _EnvironmentPicker extends ConsumerWidget {
  const _EnvironmentPicker({required this.version, required this.onPicked});
  final Version version;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final envs = ref.watch(environmentsProvider).value ?? const <Environment>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final e in envs)
              GestureDetector(
                key: Key('pick-env-${e.id}'),
                onTap: () => onPicked(e.id),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 5, 10, 5),
                    decoration: BoxDecoration(
                      color: e.id == version.environmentId
                          ? p.primary.withValues(alpha: .14)
                          : p.text.withValues(alpha: .04),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: e.id == version.environmentId ? p.primary : Colors.transparent),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        EnvIcon(env: e, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          e.name,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: p.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Switching moves this version and every later one.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, color: p.textSecondary),
        ),
      ],
    );
  }
}
