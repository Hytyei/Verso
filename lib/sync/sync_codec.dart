import 'package:drift/drift.dart';

import '../data/db/database.dart';
import 'sync_api.dart';

/// One synced table: its wire name, Drift table and JSON constructor.
class _Spec {
  _Spec(this.name, this.table, this.fromJson);
  final String name;
  final TableInfo<Table, DataClass> table;
  final Insertable<DataClass> Function(Map<String, dynamic>) fromJson;
}

/// Converts between local rows and [WireRow]s, for every synced table.
/// Rows travel as Drift's own JSON (camelCase keys, dates as epoch ms).
class SyncCodec {
  SyncCodec(this.db)
    : _specs = [
        _Spec('environments', db.environments as TableInfo<Table, DataClass>, (j) => Environment.fromJson(j)),
        _Spec('projects', db.projects as TableInfo<Table, DataClass>, (j) => Project.fromJson(j)),
        _Spec('versions', db.versions as TableInfo<Table, DataClass>, (j) => Version.fromJson(j)),
        _Spec('features', db.features as TableInfo<Table, DataClass>, (j) => Feature.fromJson(j)),
        _Spec('subitems', db.subitems as TableInfo<Table, DataClass>, (j) => Subitem.fromJson(j)),
        _Spec('milestones', db.milestones as TableInfo<Table, DataClass>, (j) => Milestone.fromJson(j)),
        _Spec('tags', db.tags as TableInfo<Table, DataClass>, (j) => Tag.fromJson(j)),
        _Spec('feature_tags', db.featureTags as TableInfo<Table, DataClass>, (j) => FeatureTag.fromJson(j)),
        _Spec('attachments', db.attachments as TableInfo<Table, DataClass>, (j) => Attachment.fromJson(j)),
      ];

  final VersoDb db;
  final List<_Spec> _specs;

  _Spec? _spec(String name) => _specs.where((s) => s.name == name).firstOrNull;

  /// Rows of every table with updatedAt >= [since] (the boundary is re-sent
  /// on purpose; the server ignores equal timestamps).
  Future<List<WireRow>> changedSince(int since) async {
    final out = <WireRow>[];
    for (final s in _specs) {
      final rows = await db
          .customSelect(
            'SELECT * FROM ${s.table.actualTableName} WHERE updated_at >= ? ORDER BY updated_at',
            variables: [Variable.withInt(since)],
            readsFrom: {s.table},
          )
          .get();
      for (final r in rows) {
        final d = await s.table.map(r.data);
        final j = d.toJson();
        out.add(
          WireRow(
            t: s.name,
            id: j['id'] as String,
            u: (j['updatedAt'] as num).toInt(),
            d: j['deleted'] == true,
            data: j,
          ),
        );
      }
    }
    return out;
  }

  /// Applies a pulled row if it is newer than the local copy. Writes it raw,
  /// keeping its updatedAt. Returns whether anything changed.
  Future<bool> apply(WireRow r) async {
    final s = _spec(r.t);
    if (s == null) return false;
    final local = await db
        .customSelect(
          'SELECT updated_at FROM ${s.table.actualTableName} WHERE id = ?',
          variables: [Variable.withString(r.id)],
          readsFrom: {s.table},
        )
        .getSingleOrNull();
    if (local != null && local.read<int>('updated_at') >= r.u) return false;
    try {
      await db.into(s.table).insertOnConflictUpdate(s.fromJson(r.data));
      return true;
    } catch (_) {
      // A row this app version can't read (newer schema): skip it.
      return false;
    }
  }
}
