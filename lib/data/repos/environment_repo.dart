import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models.dart';
import 'ordering.dart';

/// A project shown in an environment folder.
typedef Placement = ({String projectId, String environmentId});

class EnvironmentRepo {
  EnvironmentRepo(this.db);
  final VersoDb db;

  Stream<List<Environment>> watchAll() =>
      (db.select(db.environments)
            ..where((t) => t.deleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.sortKey)]))
          .watch();

  Future<Environment> get(String id) => (db.select(db.environments)..where((t) => t.id.equals(id))).getSingle();

  /// The first live environment (where new projects go by default).
  Future<String> defaultId() async => (await watchAll().first).first.id;

  Future<String> create(String name, String icon, VColor color) async {
    final rows = await watchAll().first;
    final id = db.newId();
    final now = db.now();
    await db
        .into(db.environments)
        .insert(
          EnvironmentsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            name: name,
            icon: Value(icon),
            color: Value(color.value),
            colorCustom: Value(color.custom),
            sortKey: placeKey([for (final r in rows) (r.id, r.sortKey)]),
          ),
        );
    return id;
  }

  Future<void> update(String id, {String? name, String? icon, VColor? color}) =>
      (db.update(db.environments)..where((t) => t.id.equals(id))).write(
        EnvironmentsCompanion(
          updatedAt: Value(db.now()),
          name: name == null ? const Value.absent() : Value(name),
          icon: icon == null ? const Value.absent() : Value(icon),
          color: color == null ? const Value.absent() : Value(color.value),
          colorCustom: color == null ? const Value.absent() : Value(color.custom),
        ),
      );

  Future<void> move(String id, {String? afterId, String? beforeId}) async {
    final rows = await watchAll().first;
    final key = placeKey(
      [
        for (final r in rows)
          if (r.id != id) (r.id, r.sortKey),
      ],
      afterId: afterId,
      beforeId: beforeId,
    );
    await (db.update(
      db.environments,
    )..where((t) => t.id.equals(id))).write(EnvironmentsCompanion(sortKey: Value(key), updatedAt: Value(db.now())));
  }

  /// Deletes an environment that holds no live versions; otherwise throws.
  Future<void> softDelete(String id) async {
    final used = await db
        .customSelect(
          'SELECT COUNT(*) AS n FROM versions v JOIN projects p ON p.id = v.project_id '
          'WHERE v.environment_id = ? AND v.deleted = 0 AND p.deleted = 0',
          variables: [Variable.withString(id)],
        )
        .getSingle();
    if (used.read<int>('n') > 0) throw StateError('environment-not-empty');
    final live = await watchAll().first;
    if (live.length <= 1) throw StateError('last-environment');
    await (db.update(db.environments)..where((t) => t.id.equals(id))).write(
      EnvironmentsCompanion(deleted: const Value(true), updatedAt: Value(db.now())),
    );
  }

  /// Every (project, environment) pair that has live versions.
  Stream<List<Placement>> watchPlacements() => db
      .customSelect(
        'SELECT DISTINCT v.project_id AS p, v.environment_id AS e FROM versions v '
        'JOIN projects pr ON pr.id = v.project_id '
        'WHERE v.deleted = 0 AND pr.deleted = 0 AND v.environment_id IS NOT NULL',
        readsFrom: {db.versions, db.projects},
      )
      .watch()
      .map((rows) => [for (final r in rows) (projectId: r.read<String>('p'), environmentId: r.read<String>('e'))]);
}
