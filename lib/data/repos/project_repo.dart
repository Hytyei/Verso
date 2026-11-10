import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models.dart';
import '../sort_key.dart';
import 'environment_repo.dart';
import 'ordering.dart';

typedef Progress = ({int done, int total});

class ProjectRepo {
  ProjectRepo(this.db);
  final VersoDb db;

  static const defaultTags = [('Feature', 0), ('Fix', 1), ('UI', 2), ('Backend', 3), ('Polish', 0)];

  Stream<List<Project>> watchAll() =>
      (db.select(db.projects)
            ..where((t) => t.deleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.sortKey)]))
          .watch();

  Future<Project> get(String id) => (db.select(db.projects)..where((t) => t.id.equals(id))).getSingle();

  Future<List<(String, String)>> _ordered({String? excluding}) async {
    final rows =
        await (db.select(db.projects)
              ..where((t) => t.deleted.equals(false))
              ..orderBy([(t) => OrderingTerm(expression: t.sortKey)]))
            .get();
    return [
      for (final r in rows)
        if (r.id != excluding) (r.id, r.sortKey),
    ];
  }

  /// Creates a project with its Concept stage and the default tags.
  /// Creates a project in [environmentId] (default: the first environment).
  Future<String> create(String name, VColor color, {String? environmentId}) => db.transaction(() async {
    final envId = environmentId ?? await EnvironmentRepo(db).defaultId();
    final now = db.now();
    final id = db.newId();
    await db
        .into(db.projects)
        .insert(
          ProjectsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            name: name,
            color: Value(color.value),
            colorCustom: Value(color.custom),
            sortKey: placeKey(await _ordered()),
          ),
        );
    await db
        .into(db.versions)
        .insert(
          VersionsCompanion.insert(
            id: db.newId(),
            createdAt: now,
            updatedAt: now,
            projectId: id,
            kind: const Value('concept'),
            environmentId: Value(envId),
            name: 'Concept',
            color: const Value(1),
            sortKey: keyBetween(null, null),
          ),
        );
    final keys = keysBetween(null, null, defaultTags.length);
    for (var i = 0; i < defaultTags.length; i++) {
      await db
          .into(db.tags)
          .insert(
            TagsCompanion.insert(
              id: db.newId(),
              createdAt: now,
              updatedAt: now,
              projectId: id,
              name: defaultTags[i].$1,
              color: Value(defaultTags[i].$2),
              sortKey: keys[i],
            ),
          );
    }
    return id;
  });

  Future<void> update(String id, {String? name, VColor? color, bool? archived, bool? paused}) =>
      (db.update(db.projects)..where((t) => t.id.equals(id))).write(
        ProjectsCompanion(
          updatedAt: Value(db.now()),
          name: name == null ? const Value.absent() : Value(name),
          color: color == null ? const Value.absent() : Value(color.value),
          colorCustom: color == null ? const Value.absent() : Value(color.custom),
          archived: archived == null ? const Value.absent() : Value(archived),
          paused: paused == null ? const Value.absent() : Value(paused),
        ),
      );

  Future<void> move(String id, {String? afterId, String? beforeId}) async {
    final key = placeKey(
      await _ordered(excluding: id),
      afterId: afterId,
      beforeId: beforeId,
    );
    await (db.update(
      db.projects,
    )..where((t) => t.id.equals(id))).write(ProjectsCompanion(sortKey: Value(key), updatedAt: Value(db.now())));
  }

  Future<void> softDelete(String id) => setDeleted(id, true);

  Future<void> setDeleted(String id, bool deleted) => (db.update(
    db.projects,
  )..where((t) => t.id.equals(id))).write(ProjectsCompanion(deleted: Value(deleted), updatedAt: Value(db.now())));

  /// Done / total over live features in live *release* versions.
  Stream<Progress> watchProgress(String projectId) => db
      .customSelect(
        'SELECT COALESCE(SUM(f.done),0) AS d, COUNT(f.id) AS t FROM features f '
        'JOIN versions v ON v.id = f.version_id '
        "WHERE v.project_id = ? AND v.deleted = 0 AND v.kind = 'release' AND f.deleted = 0",
        variables: [Variable.withString(projectId)],
        readsFrom: {db.features, db.versions},
      )
      .watchSingle()
      .map((r) => (done: r.read<int>('d'), total: r.read<int>('t')));
}
