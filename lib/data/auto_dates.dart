import 'package:drift/drift.dart';

import 'db/database.dart';

/// Fills in a version's dates from its tasks (v1.5.0):
/// - **start:** the day a task is first added, when the version has no start date;
/// - **end:** the day its last open task gets done, when it has no end date. Such an
///   automatic end date is marked (`endAuto`) and removed again if a task reopens or
///   a new one arrives. Dates the owner sets are never touched.
///
/// The Concept stage keeps no dates. Pulled sync rows don't run this: the device that
/// made the change already did.
class AutoDates {
  AutoDates(this.db);
  final VersoDb db;

  /// Today (local calendar day) as UTC midnight, like dates picked in the app.
  DateTime get today {
    final local = DateTime.fromMillisecondsSinceEpoch(db.now(), isUtc: true).toLocal();
    return DateTime.utc(local.year, local.month, local.day);
  }

  /// Re-checks [versionId] after its tasks changed. [added]: a task just arrived
  /// (created, moved or delayed in), which is what starts a version.
  Future<void> refresh(String versionId, {bool added = false}) async {
    final v = await (db.select(db.versions)..where((t) => t.id.equals(versionId))).getSingleOrNull();
    if (v == null || v.deleted || v.kind == 'concept') return;
    final features =
        await (db.select(db.features)..where((t) => t.versionId.equals(versionId) & t.deleted.equals(false))).get();
    final allDone = features.isNotEmpty && features.every((f) => f.done);
    var c = const VersionsCompanion();
    if (added && features.isNotEmpty && v.startDate == null) {
      c = c.copyWith(startDate: Value(today));
    }
    if (allDone && v.targetDate == null) {
      c = c.copyWith(targetDate: Value(today), endAuto: const Value(true));
    } else if (!allDone && v.endAuto == true) {
      c = c.copyWith(targetDate: const Value(null), endAuto: const Value(false));
    }
    if (c == const VersionsCompanion()) return;
    await (db.update(db.versions)..where((t) => t.id.equals(versionId))).write(
      c.copyWith(updatedAt: Value(db.now())),
    );
  }
}
