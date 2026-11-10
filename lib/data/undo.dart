import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'db/database.dart';
import 'repos/feature_repo.dart';
import 'repos/version_repo.dart';
import 'repos/tag_repo.dart';
import 'repos/project_repo.dart';
import 'attachment_store.dart';

/// One reversible user action.
abstract class UndoableAction {
  String get label;
  Future<void> apply();
  Future<void> revert();
}

/// An action made from two closures.
class FnAction implements UndoableAction {
  FnAction(this.label, this._apply, this._revert);
  @override
  final String label;
  final Future<void> Function() _apply;
  final Future<void> Function() _revert;
  @override
  Future<void> apply() => _apply();
  @override
  Future<void> revert() => _revert();
}

/// Session-only undo/redo history (spec §8).
class UndoStack {
  UndoStack({this.limit = 200});
  final int limit;
  final _done = <UndoableAction>[];
  final _undone = <UndoableAction>[];
  final canUndo = ValueNotifier(false);
  final canRedo = ValueNotifier(false);

  Future<void> run(UndoableAction a) async {
    await a.apply();
    _done.add(a);
    if (_done.length > limit) _done.removeAt(0);
    _undone.clear();
    _sync();
  }

  Future<bool> undo() async {
    if (_done.isEmpty) return false;
    final a = _done.removeLast();
    await a.revert();
    _undone.add(a);
    _sync();
    return true;
  }

  /// Undoes [a] only if it is still the latest action (toast Undo buttons).
  Future<bool> undoIfTop(UndoableAction a) async {
    if (_done.isEmpty || !identical(_done.last, a)) return false;
    return undo();
  }

  Future<bool> redo() async {
    if (_undone.isEmpty) return false;
    final a = _undone.removeLast();
    await a.apply();
    _done.add(a);
    _sync();
    return true;
  }

  void _sync() {
    canUndo.value = _done.isNotEmpty;
    canRedo.value = _undone.isNotEmpty;
  }
}

UndoableAction createFeatureAction(
  FeatureRepo repo,
  String versionId,
  String title, {
  String? afterId,
  DateTime? startDate,
  DateTime? endDate,
}) {
  String? id;
  return FnAction('Add feature', () async {
    if (id == null) {
      id = await repo.create(versionId, title, afterId: afterId, startDate: startDate, endDate: endDate);
    } else {
      await repo.setDeleted(id!, false);
    }
  }, () => repo.setDeleted(id!, true));
}

UndoableAction deleteFeatureAction(FeatureRepo repo, String id) =>
    FnAction('Delete feature', () => repo.setDeleted(id, true), () => repo.setDeleted(id, false));

UndoableAction toggleDoneAction(FeatureRepo repo, String id, bool done) =>
    FnAction(done ? 'Complete' : 'Reopen', () => repo.setDone(id, done), () => repo.setDone(id, !done));

UndoableAction moveFeatureAction(FeatureRepo repo, String id, String versionId, {String? afterId, String? beforeId}) {
  Feature? before;
  return FnAction('Move feature', () async {
    before ??= await repo.get(id);
    await repo.moveTo(id, versionId, afterId: afterId, beforeId: beforeId);
  }, () => repo.restorePlacement(before!));
}

/// Delays a feature to [toVersionId], the next version, or (with
/// [createNew]) a freshly created version after the last one.
UndoableAction delayFeatureAction(
  FeatureRepo repo,
  VersionRepo versions,
  String id, {
  String? toVersionId,
  bool createNew = false,
}) {
  Feature? before;
  String? created;
  return FnAction(
    'Delay feature',
    () async {
      before ??= await repo.get(id);
      String? target = toVersionId;
      if (createNew) {
        if (created == null) {
          final v = await repo.db
              .select(repo.db.versions)
              .get()
              .then((vs) => vs.firstWhere((x) => x.id == before!.versionId));
          created = await versions.createAfterLast(v.projectId);
        } else {
          await versions.setDeleted(created!, false);
        }
        target = created;
      }
      await repo.delay(id, toVersionId: target);
    },
    () async {
      await repo.restorePlacement(before!);
      if (created != null) await versions.setDeleted(created!, true);
    },
  );
}

/// A generic edit: [apply] and [revert] restore field values.
UndoableAction editAction(String label, Future<void> Function() apply, Future<void> Function() revert) =>
    FnAction(label, apply, revert);

/// Date edits on a version or feature.
UndoableAction dateChangeAction(String label, Future<void> Function() apply, Future<void> Function() revert) =>
    FnAction(label, apply, revert);

/// Soft-deletes a version and its live children in one transaction, and
/// un-deletes exactly those rows on revert.
UndoableAction deleteVersionAction(VersoDb db, String versionId) {
  final ids = <String, List<String>>{};
  return FnAction('Delete version', () async {
    await db.transaction(() async {
      final v = await (db.select(db.versions)..where((t) => t.id.equals(versionId))).getSingle();
      if (v.kind == 'concept') throw StateError('concept-undeletable');
      final fs = await (db.select(
        db.features,
      )..where((t) => t.versionId.equals(versionId) & t.deleted.equals(false))).get();
      final fIds = fs.map((f) => f.id).toList();
      ids['features'] = fIds;
      ids['subitems'] = (await (db.select(
        db.subitems,
      )..where((t) => t.featureId.isIn(fIds) & t.deleted.equals(false))).get()).map((r) => r.id).toList();
      ids['links'] = (await (db.select(
        db.featureTags,
      )..where((t) => t.featureId.isIn(fIds) & t.deleted.equals(false))).get()).map((r) => r.id).toList();
      ids['attachments'] = (await (db.select(
        db.attachments,
      )..where((t) => t.featureId.isIn(fIds) & t.deleted.equals(false))).get()).map((r) => r.id).toList();
      await _setDeleted(db, versionId, ids, true);
    });
  }, () => db.transaction(() => _setDeleted(db, versionId, ids, false)));
}

Future<void> _setDeleted(VersoDb db, String versionId, Map<String, List<String>> ids, bool deleted) async {
  final now = db.now();
  await (db.update(
    db.versions,
  )..where((t) => t.id.equals(versionId))).write(VersionsCompanion(deleted: Value(deleted), updatedAt: Value(now)));
  await (db.update(db.features)..where((t) => t.id.isIn(ids['features']!))).write(
    FeaturesCompanion(deleted: Value(deleted), updatedAt: Value(now)),
  );
  await (db.update(db.subitems)..where((t) => t.id.isIn(ids['subitems']!))).write(
    SubitemsCompanion(deleted: Value(deleted), updatedAt: Value(now)),
  );
  await (db.update(db.featureTags)..where((t) => t.id.isIn(ids['links']!))).write(
    FeatureTagsCompanion(deleted: Value(deleted), updatedAt: Value(now)),
  );
  await (db.update(db.attachments)..where((t) => t.id.isIn(ids['attachments']!))).write(
    AttachmentsCompanion(deleted: Value(deleted), updatedAt: Value(now)),
  );
}

/// Moves a version and every later one to another environment (undoable).
UndoableAction setEnvironmentFromAction(VersionRepo versions, String versionId, String environmentId) {
  Map<String, String?>? before;
  return FnAction('Change environment', () async {
    before = await versions.setEnvironmentFrom(versionId, environmentId);
  }, () => versions.restoreEnvironments(before!));
}

UndoableAction deleteTagAction(TagRepo tags, String id) =>
    FnAction('Delete tag', () => tags.setDeleted(id, true), () => tags.setDeleted(id, false));

UndoableAction toggleSubitemAction(FeatureRepo repo, String id, bool done) =>
    FnAction('Check step', () => repo.updateSubitem(id, done: done), () => repo.updateSubitem(id, done: !done));

UndoableAction renameSubitemAction(FeatureRepo repo, String id, String before, String after) =>
    FnAction('Rename step', () => repo.updateSubitem(id, title: after), () => repo.updateSubitem(id, title: before));

/// Deletes a step with its whole subtree; undo restores exactly those.
UndoableAction deleteSubitemAction(FeatureRepo repo, String id) {
  List<String>? ids;
  return FnAction(
    'Delete step',
    () async {
      ids ??= [id, ...await repo.subitemDescendants(id)];
      for (final x in ids!) {
        await repo.setSubitemDeleted(x, true);
      }
    },
    () async {
      for (final x in ids!) {
        await repo.setSubitemDeleted(x, false);
      }
    },
  );
}

UndoableAction moveSubitemAction(FeatureRepo repo, String id, {String? parentId, String? afterId, String? beforeId}) {
  Subitem? before;
  return FnAction('Move step', () async {
    before ??= await (repo.db.select(repo.db.subitems)..where((t) => t.id.equals(id))).getSingle();
    await repo.moveSubitem(id, parentId: parentId, afterId: afterId, beforeId: beforeId);
  }, () => repo.restoreSubitemPlacement(before!));
}

/// One undo step for a whole notes editing session.
UndoableAction notesEditAction(FeatureRepo repo, String featureId, String? before, String? after) => FnAction(
  'Edit notes',
  () => repo.update(featureId, notes: Value(after)),
  () => repo.update(featureId, notes: Value(before)),
);

/// "Add version" (after the last one, in [environmentId]).
UndoableAction createVersionAction(VersionRepo versions, String projectId, {String? environmentId}) {
  String? id;
  return FnAction('Add version', () async {
    if (id == null) {
      id = await versions.createAfterLast(projectId, environmentId: environmentId);
    } else {
      await versions.setDeleted(id!, false);
    }
  }, () => versions.setDeleted(id!, true));
}

UndoableAction moveVersionAction(VersionRepo versions, String id, {String? afterId, String? beforeId}) {
  Version? before;
  return FnAction('Move version', () async {
    before ??= await versions.get(id);
    await versions.move(id, afterId: afterId, beforeId: beforeId);
  }, () => versions.restoreSortKey(id, before!.sortKey));
}

/// Creates a version after the last one and moves the feature to its top.
UndoableAction moveToNewVersionAction(FeatureRepo repo, VersionRepo versions, String featureId) {
  Feature? before;
  String? created;
  return FnAction(
    'Move to new version',
    () async {
      before ??= await repo.get(featureId);
      if (created == null) {
        final v = await versions.get(before!.versionId);
        created = await versions.createAfterLast(v.projectId);
      } else {
        await versions.setDeleted(created!, false);
      }
      await repo.moveTo(featureId, created!);
    },
    () async {
      await repo.restorePlacement(before!);
      await versions.setDeleted(created!, true);
    },
  );
}

UndoableAction removeAttachmentAction(AttachmentStore store, String id) =>
    FnAction('Remove image', () => store.setDeleted(id, true), () => store.setDeleted(id, false));

UndoableAction deleteProjectAction(ProjectRepo projects, String id) =>
    FnAction('Delete project', () => projects.setDeleted(id, true), () => projects.setDeleted(id, false));

/// Puts a project on pause (or resumes it).
UndoableAction setPausedAction(ProjectRepo projects, String id, bool paused) => FnAction(
  paused ? 'Pause project' : 'Resume project',
  () => projects.update(id, paused: paused),
  () => projects.update(id, paused: !paused),
);

/// Moves the project's versions that sit in [from] to the [to] environment
/// (the whole project when it lives only in [from]).
UndoableAction moveProjectToEnvironmentAction(
  VersionRepo versions,
  String projectId, {
  required String from,
  required String to,
}) {
  final before = <String, String?>{};
  return FnAction('Move project', () async {
    for (final v in await versions.listForProject(projectId)) {
      if (v.environmentId == from) {
        before[v.id] = v.environmentId;
        await versions.setEnvironment(v.id, to);
      }
    }
  }, () => versions.restoreEnvironments(before));
}
