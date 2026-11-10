import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models.dart';
import 'ordering.dart';

class TagRepo {
  TagRepo(this.db);
  final VersoDb db;

  Stream<List<Tag>> watchForProject(String projectId) =>
      (db.select(db.tags)
            ..where((t) => t.projectId.equals(projectId) & t.deleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.sortKey)]))
          .watch();

  Future<String> create(String projectId, String name, VColor color) => db.transaction(() async {
    final rows = await watchForProject(projectId).first;
    final now = db.now();
    final id = db.newId();
    await db
        .into(db.tags)
        .insert(
          TagsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            projectId: projectId,
            name: name,
            color: Value(color.value),
            colorCustom: Value(color.custom),
            sortKey: placeKey([for (final r in rows) (r.id, r.sortKey)]),
          ),
        );
    return id;
  });

  Future<void> update(String id, {String? name, VColor? color}) =>
      (db.update(db.tags)..where((t) => t.id.equals(id))).write(
        TagsCompanion(
          updatedAt: Value(db.now()),
          name: name == null ? const Value.absent() : Value(name),
          color: color == null ? const Value.absent() : Value(color.value),
          colorCustom: color == null ? const Value.absent() : Value(color.custom),
        ),
      );

  Future<void> setDeleted(String id, bool deleted) => (db.update(
    db.tags,
  )..where((t) => t.id.equals(id))).write(TagsCompanion(deleted: Value(deleted), updatedAt: Value(db.now())));

  Future<void> softDelete(String id) => setDeleted(id, true);
}
