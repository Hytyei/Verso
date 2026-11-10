import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/undo.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../common/glass_menu.dart';
import '../common/toast.dart';
import 'color_picker.dart';
import 'confirm.dart';
import 'tag_editor.dart';

/// Right-click menu for a project in the sidebar.
/// [environmentId] is the folder the project was right-clicked in.
Future<void> showProjectMenu(BuildContext context, WidgetRef ref, Project project, String environmentId, Offset pos) {
  final repo = ref.read(projectRepoProvider);
  final envs = ref.read(environmentsProvider).value ?? const <Environment>[];
  final others = [
    for (final e in envs)
      if (e.id != environmentId) e,
  ];
  void togglePause() => ref.read(undoProvider).run(setPausedAction(repo, project.id, !project.paused));
  final pauseLabel = project.paused ? 'Move back from On Pause' : 'Move to On Pause';
  final pauseIcon = project.paused ? Icons.play_circle_outline_rounded : Icons.pause_circle_outline_rounded;
  return showGlassMenu(context, pos, [
    MenuItemSpec(pauseLabel, icon: pauseIcon, onTap: togglePause),
    MenuItemSpec(
      'Move to environment',
      icon: Icons.drive_file_move_outline,
      children: [
        for (final e in others)
          MenuItemSpec(
            e.name,
            onTap: () async {
              await ref
                  .read(undoProvider)
                  .run(
                    moveProjectToEnvironmentAction(
                      ref.read(versionRepoProvider),
                      project.id,
                      from: environmentId,
                      to: e.id,
                    ),
                  );
              openSegment(ref, project.id, e.id);
            },
          ),
        if (others.isNotEmpty) const MenuItemSpec.divider(),
        // On Pause is a subfolder of every environment, so it lives in this list too.
        MenuItemSpec(project.paused ? 'Out of On Pause' : 'On Pause', icon: pauseIcon, onTap: togglePause),
      ],
    ),
    MenuItemSpec(
      'Color…',
      icon: Icons.palette_outlined,
      onTap: () => showColorPopover(
        context,
        anchor: Rect.fromLTWH(pos.dx, pos.dy, 0, 0),
        value: VColor(project.color, custom: project.colorCustom),
        onChanged: (c) => c == null ? null : repo.update(project.id, color: c),
      ),
    ),
    MenuItemSpec('Tags…', icon: Icons.sell_outlined, onTap: () => showTagEditor(context, project.id, pos)),
    const MenuItemSpec.divider(),
    MenuItemSpec(
      'Delete project',
      icon: Icons.delete_outline_rounded,
      danger: true,
      onTap: () async {
        final ok = await confirmDanger(
          context,
          title: 'Delete ${project.name}?',
          message: 'All its versions and features go with it. You can undo this right after.',
        );
        if (!ok) return;
        final undo = ref.read(undoProvider);
        final action = deleteProjectAction(repo, project.id);
        await undo.run(action);
        if (context.mounted) {
          showToast(context, '${project.name} deleted', onUndo: () => undo.undoIfTop(action));
        }
      },
    ),
  ]);
}
