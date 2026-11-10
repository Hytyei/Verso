import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/undo.dart';
import '../common/toast.dart';
import 'confirm.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../common/glass_menu.dart';
import '../glass/glass_surface.dart';
import '../theme/palette.dart';
import 'color_picker.dart';

/// Popover to add, rename, recolor and delete a project's tags.
Future<void> showTagEditor(BuildContext context, String projectId, Offset pos) {
  return showGlassPopover(
    context,
    anchor: Rect.fromLTWH(pos.dx, pos.dy, 0, 0),
    width: 280,
    builder: (ctx, close) => _TagEditor(projectId: projectId),
  );
}

class _TagEditor extends ConsumerStatefulWidget {
  const _TagEditor({required this.projectId});
  final String projectId;

  @override
  ConsumerState<_TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends ConsumerState<_TagEditor> {
  final _add = TextEditingController();

  @override
  void dispose() {
    _add.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final repo = ref.read(tagRepoProvider);
    final tags = ref.watch(tagsProvider(widget.projectId)).value ?? const <Tag>[];
    return GlassSurface(
      radius: 16,
      tint: p.isDark ? const Color(0xF51E1A16) : const Color(0xF5FFFFFF),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tags',
            style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: p.text),
          ),
          const SizedBox(height: 8),
          for (final t in tags)
            Padding(
              key: ValueKey(t.id),
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Builder(
                    builder: (dot) => GestureDetector(
                      onTap: () {
                        final box = dot.findRenderObject() as RenderBox;
                        showColorPopover(
                          dot,
                          anchor: box.localToGlobal(Offset.zero) & box.size,
                          value: VColor(t.color, custom: t.colorCustom),
                          onChanged: (c) => c == null ? null : repo.update(t.id, color: c),
                        );
                      },
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: p.resolve(VColor(t.color, custom: t.colorCustom)),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: t.name,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.text),
                      decoration: const InputDecoration.collapsed(hintText: 'Tag'),
                      onFieldSubmitted: (s) => s.trim().isEmpty ? null : repo.update(t.id, name: s.trim()),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final n = await ref
                          .read(dbProvider)
                          .customSelect(
                            'SELECT COUNT(*) AS n FROM feature_tags WHERE tag_id = ? AND deleted = 0',
                            variables: [Variable.withString(t.id)],
                          )
                          .getSingle();
                      final uses = n.read<int>('n');
                      if (!context.mounted) return;
                      if (uses > 0) {
                        final ok = await confirmDanger(
                          context,
                          title: 'Delete tag "${t.name}"?',
                          message: 'It is on $uses ${uses == 1 ? 'feature' : 'features'}. You can undo this.',
                        );
                        if (!ok) return;
                      }
                      final undo = ref.read(undoProvider);
                      final action = deleteTagAction(repo, t.id);
                      await undo.run(action);
                      if (context.mounted) showToast(context, 'Tag deleted', onUndo: () => undo.undoIfTop(action));
                    },
                    child: Icon(Icons.close_rounded, size: 15, color: p.textSecondary),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          TextField(
            key: const Key('new-tag'),
            controller: _add,
            style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.text),
            decoration: InputDecoration.collapsed(
              hintText: '+ New tag',
              hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.primary),
            ),
            onSubmitted: (s) async {
              if (s.trim().isEmpty) return;
              _add.clear();
              await repo.create(widget.projectId, s.trim(), VColor.slot(tags.length % 4));
            },
          ),
        ],
      ),
    );
  }
}
