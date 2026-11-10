import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../common/env_icon.dart';
import '../common/glass_menu.dart';
import '../common/toast.dart';
import '../glass/glass_surface.dart';
import '../theme/palette.dart';
import 'color_picker.dart';
import 'confirm.dart';

/// Creates (env null) or edits an environment: name, icon, color.
Future<void> showEnvironmentEditor(BuildContext context, Offset pos, {Environment? env}) {
  return showGlassPopover(
    context,
    anchor: Rect.fromLTWH(pos.dx, pos.dy, 0, 0),
    width: 320,
    builder: (ctx, close) => _EnvEditor(env: env, close: close),
  );
}

class _EnvEditor extends ConsumerStatefulWidget {
  const _EnvEditor({required this.env, required this.close});
  final Environment? env;
  final VoidCallback close;

  @override
  ConsumerState<_EnvEditor> createState() => _EnvEditorState();
}

class _EnvEditorState extends ConsumerState<_EnvEditor> {
  late final _name = TextEditingController(text: widget.env?.name ?? '');
  late String _icon = widget.env?.icon ?? 'terminal';
  late VColor _color = widget.env == null
      ? const VColor.slot(0)
      : VColor(widget.env!.color, custom: widget.env!.colorCustom);
  bool _over = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _useImage(String path) async {
    final ext = path.split('.').last.toLowerCase();
    if (!const {'png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp', 'ico'}.contains(ext)) {
      showToast(context, 'Not an image file');
      return;
    }
    final dir = envIconsDir(ref.read(dataDirProvider))..createSync(recursive: true);
    final name = '${ref.read(dbProvider).newId()}.$ext';
    await File(path).copy('${dir.path}${Platform.pathSeparator}$name');
    setState(() => _icon = 'file:$name');
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final repo = ref.read(environmentRepoProvider);
    if (widget.env == null) {
      await repo.create(name, _icon, _color);
    } else {
      await repo.update(widget.env!.id, name: name, icon: _icon, color: _color);
    }
    widget.close();
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final label = TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600, color: p.textSecondary);
    final preview = Environment(
      id: '',
      createdAt: 0,
      updatedAt: 0,
      deleted: false,
      name: '',
      icon: _icon,
      color: _color.value,
      colorCustom: _color.custom,
      sortKey: '',
    );
    return GlassSurface(
      radius: 18,
      tint: p.isDark ? const Color(0xF51E1A16) : const Color(0xF5FFFFFF),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EnvIcon(env: preview, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: const Key('env-name'),
                  controller: _name,
                  autofocus: widget.env == null,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: p.text),
                  decoration: const InputDecoration.collapsed(hintText: 'Environment, e.g. Claude Code'),
                  onSubmitted: (_) => _save(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Icon', style: label),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final e in envGlyphs.entries)
                GestureDetector(
                  key: Key('env-glyph-${e.key}'),
                  onTap: () => setState(() => _icon = e.key),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _icon == e.key ? p.primary.withValues(alpha: .16) : p.text.withValues(alpha: .04),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: _icon == e.key ? p.primary : Colors.transparent, width: 1.4),
                      ),
                      child: Icon(e.value, size: 18, color: p.text),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          DropTarget(
            onDragEntered: (_) => setState(() => _over = true),
            onDragExited: (_) => setState(() => _over = false),
            onDragDone: (d) {
              setState(() => _over = false);
              if (d.files.isNotEmpty) _useImage(d.files.first.path);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
              decoration: BoxDecoration(
                color: _over ? p.primary.withValues(alpha: .1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _over ? p.primary : p.separator),
              ),
              child: Text(
                _icon.startsWith('file:')
                    ? 'Custom image set — drop another to replace'
                    : 'Or drop an image for a custom icon',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: p.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Color', style: label),
          const SizedBox(height: 6),
          ColorPicker(value: _color, onChanged: (c) => setState(() => _color = c ?? _color)),
          const SizedBox(height: 14),
          Row(
            children: [
              if (widget.env != null)
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: p.coral),
                  onPressed: () async {
                    final ok = await confirmDanger(
                      context,
                      title: 'Delete ${widget.env!.name}?',
                      message: 'Only empty environments can be deleted.',
                    );
                    if (!ok) return;
                    try {
                      await ref.read(environmentRepoProvider).softDelete(widget.env!.id);
                      widget.close();
                    } on StateError catch (e) {
                      if (context.mounted) {
                        showToast(
                          context,
                          e.message == 'last-environment'
                              ? 'Keep at least one environment'
                              : 'Move its projects to another environment first',
                        );
                      }
                    }
                  },
                  child: const Text('Delete'),
                ),
              const Spacer(),
              FilledButton(
                key: const Key('env-save'),
                style: FilledButton.styleFrom(
                  backgroundColor: p.primary,
                  foregroundColor: p.isDark ? Colors.black : Colors.white,
                ),
                onPressed: _save,
                child: Text(widget.env == null ? 'Create' : 'Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
