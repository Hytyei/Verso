import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/models.dart';
import '../../data/repos/feature_repo.dart';
import '../../data/undo.dart';
import '../../state/providers.dart';
import '../common/glass_menu.dart';
import '../common/toast.dart';
import '../editors/color_picker.dart';

/// Undoable feature operations shared by cards, menus and shortcuts.
class FeatureActions {
  FeatureActions(this.ref);
  final WidgetRef ref;

  UndoStack get _undo => ref.read(undoProvider);
  FeatureRepo get _repo => ref.read(featureRepoProvider);

  Future<void> setDone(String id, bool done) => _undo.run(toggleDoneAction(_repo, id, done));

  Future<void> create(String versionId, String title, {String? afterId}) =>
      _undo.run(createFeatureAction(_repo, versionId, title, afterId: afterId));

  Future<void> delete(BuildContext context, String id) async {
    final action = deleteFeatureAction(_repo, id);
    final undo = _undo;
    await undo.run(action);
    if (context.mounted) showToast(context, 'Feature deleted', onUndo: () => undo.undoIfTop(action));
  }

  /// Delays to [toVersionId], the next version (null), or a new one.
  Future<void> delay(String id, {String? toVersionId, bool createNew = false}) => _undo.run(
    delayFeatureAction(_repo, ref.read(versionRepoProvider), id, toVersionId: toVersionId, createNew: createNew),
  );

  /// Plain move to the top of [versionId] (or of a new version).
  Future<void> moveTo(String id, String versionId, {bool createNew = false, String? projectId}) async {
    if (createNew) {
      await _undo.run(moveToNewVersionAction(_repo, ref.read(versionRepoProvider), id));
      return;
    }
    final target = versionId;
    final first = (await _repo.watchForVersion(target).first).where((f) => !f.done && f.id != id).firstOrNull;
    await _undo.run(moveFeatureAction(_repo, id, target, beforeId: first?.id));
  }

  Future<void> setPriority(Feature f, int p) => _undo.run(
    editAction('Priority', () => _repo.update(f.id, priority: p), () => _repo.update(f.id, priority: f.priority)),
  );

  Future<void> setColor(Feature f, VColor? c) => _undo.run(
    editAction(
      'Color',
      () => _repo.update(f.id, color: Value(c)),
      () => _repo.update(f.id, color: Value(f.color == null ? null : VColor(f.color!, custom: f.colorCustom))),
    ),
  );

  Future<void> rename(String id, String before, String after) =>
      _undo.run(editAction('Rename', () => _repo.update(id, title: after), () => _repo.update(id, title: before)));
}

/// A feature's right-click menu.
Future<void> showFeatureMenu(BuildContext context, WidgetRef ref, FeatureView v, Version version, Offset pos) {
  final actions = FeatureActions(ref);
  final versions = ref.read(versionsProvider(version.projectId)).value ?? const <Version>[];
  final releases = versions.where((x) => x.kind == 'release').toList();
  final concept = version.kind == 'concept';
  final idx = releases.indexWhere((x) => x.id == version.id);
  final later = concept ? releases : releases.skip(idx + 1).toList();
  return showGlassMenu(context, pos, [
    MenuItemSpec(
      v.f.done ? 'Mark as not done' : 'Mark as done',
      icon: v.f.done ? Icons.radio_button_unchecked_rounded : Icons.check_circle_outline_rounded,
      shortcut: 'Space',
      onTap: () => actions.setDone(v.id, !v.f.done),
    ),
    if (concept)
      MenuItemSpec(
        'Move to build',
        icon: Icons.rocket_launch_outlined,
        children: [
          for (final r in releases) MenuItemSpec(r.name, onTap: () => actions.moveTo(v.id, r.id)),
          if (releases.isNotEmpty) const MenuItemSpec.divider(),
          MenuItemSpec(
            'New version',
            icon: Icons.add_rounded,
            onTap: () => actions.moveTo(v.id, '', createNew: true, projectId: version.projectId),
          ),
        ],
      )
    else if (!v.f.done)
      MenuItemSpec(
        'Delay to',
        icon: Icons.schedule_rounded,
        shortcut: 'Ctrl+D',
        children: [
          if (later.isNotEmpty)
            MenuItemSpec('Next: ${later.first.name}', onTap: () => actions.delay(v.id, toVersionId: later.first.id)),
          for (final r in later.skip(1)) MenuItemSpec(r.name, onTap: () => actions.delay(v.id, toVersionId: r.id)),
          if (later.isNotEmpty) const MenuItemSpec.divider(),
          MenuItemSpec('New version', icon: Icons.add_rounded, onTap: () => actions.delay(v.id, createNew: true)),
        ],
      ),
    MenuItemSpec(
      'Move to',
      icon: Icons.drive_file_move_outline,
      children: [
        for (final x in versions)
          if (x.id != version.id) MenuItemSpec(x.name, onTap: () => actions.moveTo(v.id, x.id)),
      ],
    ),
    MenuItemSpec(
      'Priority',
      icon: Icons.flag_outlined,
      children: [
        for (var i = 0; i <= 3; i++)
          MenuItemSpec(
            const ['None', 'Low', 'Medium', 'High'][i],
            icon: v.f.priority == i ? Icons.check_rounded : null,
            onTap: () => actions.setPriority(v.f, i),
          ),
      ],
    ),
    MenuItemSpec(
      'Color…',
      icon: Icons.palette_outlined,
      onTap: () => showColorPopover(
        context,
        anchor: Rect.fromLTWH(pos.dx, pos.dy, 0, 0),
        allowNone: true,
        value: v.f.color == null ? null : VColor(v.f.color!, custom: v.f.colorCustom),
        onChanged: (c) => actions.setColor(v.f, c),
      ),
    ),
    const MenuItemSpec.divider(),
    MenuItemSpec(
      'Delete',
      icon: Icons.delete_outline_rounded,
      danger: true,
      shortcut: 'Del',
      onTap: () => actions.delete(context, v.id),
    ),
  ]);
}
