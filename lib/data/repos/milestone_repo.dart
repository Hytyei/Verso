import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models.dart';

class MilestoneRepo {
  MilestoneRepo(this.db);
  final VersoDb db;

  Stream<List<Milestone>> watchForProject(String projectId) =>
      (db.select(db.milestones)
            ..where((t) => t.projectId.equals(projectId) & t.deleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.date)]))
          .watch();

  Future<String> create(
    String projectId,
    String title,
    DateTime date, {
    MilestoneKind kind = MilestoneKind.other,
    VColor? color,
  }) async {
    final now = db.now();
    final id = db.newId();
    await db
        .into(db.milestones)
        .insert(
          MilestonesCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            projectId: projectId,
            title: title,
            date: date,
            kind: Value(kind.name),
            color: Value(color?.value),
            colorCustom: Value(color?.custom ?? false),
          ),
        );
    return id;
  }

  Future<void> update(
    String id, {
    String? title,
    DateTime? date,
    MilestoneKind? kind,
    Value<VColor?> color = const Value.absent(),
  }) => (db.update(db.milestones)..where((t) => t.id.equals(id))).write(
    MilestonesCompanion(
      updatedAt: Value(db.now()),
      title: title == null ? const Value.absent() : Value(title),
      date: date == null ? const Value.absent() : Value(date),
      kind: kind == null ? const Value.absent() : Value(kind.name),
      color: color.present ? Value(color.value?.value) : const Value.absent(),
      colorCustom: color.present ? Value(color.value?.custom ?? false) : const Value.absent(),
    ),
  );

  Future<void> setDeleted(String id, bool deleted) => (db.update(
    db.milestones,
  )..where((t) => t.id.equals(id))).write(MilestonesCompanion(deleted: Value(deleted), updatedAt: Value(db.now())));

  Future<void> softDelete(String id) => setDeleted(id, true);
}
