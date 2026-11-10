import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models.dart';
import 'environment_repo.dart';
import 'ordering.dart';
import 'project_repo.dart' show Progress;

class VersionRepo {
  VersionRepo(this.db);
  final VersoDb db;

  /// Live versions in board order; the concept stage is always first.
  Stream<List<Version>> watchForProject(String projectId) =>
      (db.select(db.versions)
            ..where((t) => t.projectId.equals(projectId) & t.deleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.sortKey)]))
          .watch()
          .map(_conceptFirst);

  Future<List<Version>> listForProject(String projectId) async => _conceptFirst(
    await (db.select(db.versions)
          ..where((t) => t.projectId.equals(projectId) & t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.sortKey)]))
        .get(),
  );

  static List<Version> _conceptFirst(List<Version> vs) => [
    ...vs.where((v) => v.kind == 'concept'),
    ...vs.where((v) => v.kind != 'concept'),
  ];

  Future<Version> get(String id) => (db.select(db.versions)..where((t) => t.id.equals(id))).getSingle();

  Future<List<(String, String)>> _ordered(String projectId, {String? excluding}) async {
    final vs = await listForProject(projectId);
    return [
      for (final v in vs)
        if (v.id != excluding) (v.id, v.sortKey),
    ];
  }

  /// Appends a release version at the end.
  /// Appends a version. Its environment is [environmentId], else the last
  /// version's (the project keeps going where it left off), else the default.
  Future<String> create(String projectId, String name, {VColor? color, String? environmentId}) =>
      db.transaction(() async {
        final now = db.now();
        final id = db.newId();
        final existing = await listForProject(projectId);
        final count = existing.length;
        final envId =
            environmentId ??
            (existing.isEmpty ? null : _lastByKey(existing).environmentId) ??
            await EnvironmentRepo(db).defaultId();
        await db
            .into(db.versions)
            .insert(
              VersionsCompanion.insert(
                id: id,
                createdAt: now,
                updatedAt: now,
                projectId: projectId,
                environmentId: Value(envId),
                name: name,
                color: Value(color?.value ?? (count % 4)),
                colorCustom: Value(color?.custom ?? false),
                sortKey: placeKey(await _ordered(projectId)),
              ),
            );
        return id;
      });

  /// Creates a version after the last one, named by bumping the last
  /// release version's name ("v1.0" when there is none).
  Future<String> createAfterLast(String projectId, {String? environmentId}) async {
    final releases = (await listForProject(projectId)).where((v) => v.kind == 'release');
    final name = releases.isEmpty ? firstVersionName : bumpVersionName(releases.last.name);
    return create(projectId, name, environmentId: environmentId);
  }

  static Version _lastByKey(List<Version> vs) => vs.reduce((a, b) => a.sortKey.compareTo(b.sortKey) >= 0 ? a : b);

  /// "Break from here": moves [versionId] and every later version (board
  /// order) to [environmentId]. Returns the previous environment per id.
  Future<Map<String, String?>> setEnvironmentFrom(String versionId, String environmentId) => db.transaction(() async {
    final v = await get(versionId);
    final all = await listForProject(v.projectId);
    final at = all.indexWhere((x) => x.id == versionId);
    final before = <String, String?>{};
    final now = db.now();
    for (final x in all.skip(at)) {
      before[x.id] = x.environmentId;
      await (db.update(db.versions)..where((t) => t.id.equals(x.id))).write(
        VersionsCompanion(environmentId: Value(environmentId), updatedAt: Value(now)),
      );
    }
    return before;
  });

  /// Moves one version to [environmentId].
  Future<void> setEnvironment(String versionId, String environmentId) =>
      (db.update(db.versions)..where((t) => t.id.equals(versionId))).write(
        VersionsCompanion(environmentId: Value(environmentId), updatedAt: Value(db.now())),
      );

  /// Restores environments returned by [setEnvironmentFrom].
  Future<void> restoreEnvironments(Map<String, String?> before) => db.transaction(() async {
    final now = db.now();
    for (final e in before.entries) {
      await (db.update(db.versions)..where((t) => t.id.equals(e.key))).write(
        VersionsCompanion(environmentId: Value(e.value), updatedAt: Value(now)),
      );
    }
  });

  Future<void> update(
    String id, {
    String? name,
    VersionStatus? status,
    VColor? color,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> targetDate = const Value.absent(),
    Value<DateTime?> releasedDate = const Value.absent(),
    Value<String?> description = const Value.absent(),
  }) => (db.update(db.versions)..where((t) => t.id.equals(id))).write(
    VersionsCompanion(
      updatedAt: Value(db.now()),
      name: name == null ? const Value.absent() : Value(name),
      status: status == null ? const Value.absent() : Value(status.name),
      color: color == null ? const Value.absent() : Value(color.value),
      colorCustom: color == null ? const Value.absent() : Value(color.custom),
      startDate: startDate,
      targetDate: targetDate,
      releasedDate: releasedDate,
      description: description,
    ),
  );

  /// Moves a release version; it can never land before the concept stage.
  Future<void> move(String id, {String? afterId, String? beforeId}) => db.transaction(() async {
    final v = await get(id);
    if (v.kind == 'concept') return;
    final ordered = await _ordered(v.projectId, excluding: id);
    final concept = (await listForProject(v.projectId)).where((x) => x.kind == 'concept');
    final conceptId = concept.isEmpty ? null : concept.first.id;
    if (conceptId != null && beforeId == conceptId) {
      afterId = conceptId;
      beforeId = null;
    }
    final key = placeKey(ordered, afterId: afterId, beforeId: beforeId);
    await (db.update(
      db.versions,
    )..where((t) => t.id.equals(id))).write(VersionsCompanion(sortKey: Value(key), updatedAt: Value(db.now())));
  });

  /// Raw restore used by undo.
  Future<void> restoreSortKey(String id, String key) => (db.update(
    db.versions,
  )..where((t) => t.id.equals(id))).write(VersionsCompanion(sortKey: Value(key), updatedAt: Value(db.now())));

  /// Soft-deletes a release version. The concept stage cannot be deleted.
  Future<void> softDelete(String id) async {
    final v = await get(id);
    if (v.kind == 'concept') throw StateError('concept-undeletable');
    await setDeleted(id, true);
  }

  Future<void> setDeleted(String id, bool deleted) => (db.update(
    db.versions,
  )..where((t) => t.id.equals(id))).write(VersionsCompanion(deleted: Value(deleted), updatedAt: Value(db.now())));

  Stream<Progress> watchProgress(String versionId) => db
      .customSelect(
        'SELECT COALESCE(SUM(done),0) AS d, COUNT(id) AS t FROM features '
        'WHERE version_id = ? AND deleted = 0',
        variables: [Variable.withString(versionId)],
        readsFrom: {db.features},
      )
      .watchSingle()
      .map((r) => (done: r.read<int>('d'), total: r.read<int>('t')));

  /// Number of live features delayed *into* this version.
  Stream<int> watchDelayedIn(String versionId) => db
      .customSelect(
        'SELECT COUNT(id) AS n FROM features WHERE version_id = ? AND deleted = 0 AND delay_count > 0',
        variables: [Variable.withString(versionId)],
        readsFrom: {db.features},
      )
      .watchSingle()
      .map((r) => r.read<int>('n'));
}
