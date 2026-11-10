import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models.dart';
import 'ordering.dart';

/// Everything a board card needs, in one object.
class FeatureView {
  const FeatureView(this.f, this.tags, this.subDone, this.subTotal, this.attachments, {this.subTitles = const []});
  final Feature f;

  /// Sub-item titles, for search.
  final List<String> subTitles;
  final List<Tag> tags;
  final int subDone;
  final int subTotal;
  final int attachments;
  String get id => f.id;
}

class FeatureRepo {
  FeatureRepo(this.db);
  final VersoDb db;

  Future<Feature> get(String id) => (db.select(db.features)..where((t) => t.id.equals(id))).getSingle();

  /// Live features: undone by sortKey, then done by doneAt.
  Stream<List<Feature>> watchForVersion(String versionId) => (db.select(
    db.features,
  )..where((t) => t.versionId.equals(versionId) & t.deleted.equals(false))).watch().map(_boardOrder);

  static List<Feature> _boardOrder(List<Feature> fs) {
    final open = fs.where((f) => !f.done).toList()..sort((a, b) => a.sortKey.compareTo(b.sortKey));
    final done = fs.where((f) => f.done).toList()..sort((a, b) => (a.doneAt ?? 0).compareTo(b.doneAt ?? 0));
    return [...open, ...done];
  }

  /// Live features of the project that have a start or end date.
  Stream<List<Feature>> watchDatedForProject(String projectId) => db
      .customSelect(
        'SELECT f.* FROM features f JOIN versions v ON v.id = f.version_id '
        'WHERE v.project_id = ? AND v.deleted = 0 AND f.deleted = 0 '
        'AND (f.start_date IS NOT NULL OR f.end_date IS NOT NULL)',
        variables: [Variable.withString(projectId)],
        readsFrom: {db.features, db.versions},
      )
      .watch()
      .asyncMap((rows) => Future.wait(rows.map((r) => db.features.mapFromRow(r))));

  /// Live features of [versionId] as (id, key), key order. Repairs
  /// duplicate keys (renumbers the column) so placement can always fit
  /// between neighbours. Call inside a transaction.
  Future<List<(String, String)>> _openOrdered(String versionId, {String? excluding}) async {
    final rows =
        await (db.select(db.features)
              ..where((t) => t.versionId.equals(versionId) & t.deleted.equals(false))
              ..orderBy([(t) => OrderingTerm(expression: t.sortKey), (t) => OrderingTerm(expression: t.createdAt)]))
            .get();
    var all = [for (final r in rows) (r.id, r.sortKey)];
    if (hasDuplicateKeys(all)) {
      all = renumber(all);
      final now = db.now();
      for (final e in all) {
        await (db.update(
          db.features,
        )..where((t) => t.id.equals(e.$1))).write(FeaturesCompanion(sortKey: Value(e.$2), updatedAt: Value(now)));
      }
    }
    return [
      for (final e in all)
        if (e.$1 != excluding) e,
    ];
  }

  Future<String> create(String versionId, String title, {String? afterId, DateTime? startDate, DateTime? endDate}) =>
      db.transaction(() async {
        final now = db.now();
        final id = db.newId();
        await db
            .into(db.features)
            .insert(
              FeaturesCompanion.insert(
                id: id,
                createdAt: now,
                updatedAt: now,
                versionId: versionId,
                title: title,
                startDate: Value(startDate),
                endDate: Value(endDate),
                sortKey: placeKey(await _openOrdered(versionId), afterId: afterId),
              ),
            );
        return id;
      });

  Future<void> update(
    String id, {
    String? title,
    Value<String?> notes = const Value.absent(),
    int? priority,
    Value<VColor?> color = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
  }) => (db.update(db.features)..where((t) => t.id.equals(id))).write(
    FeaturesCompanion(
      updatedAt: Value(db.now()),
      title: title == null ? const Value.absent() : Value(title),
      notes: notes,
      priority: priority == null ? const Value.absent() : Value(priority),
      color: color.present ? Value(color.value?.value) : const Value.absent(),
      colorCustom: color.present ? Value(color.value?.custom ?? false) : const Value.absent(),
      startDate: startDate,
      endDate: endDate,
    ),
  );

  Future<void> setDone(String id, bool done) => (db.update(db.features)..where((t) => t.id.equals(id))).write(
    FeaturesCompanion(updatedAt: Value(db.now()), done: Value(done), doneAt: Value(done ? db.now() : null)),
  );

  Future<void> moveTo(String id, String versionId, {String? afterId, String? beforeId}) => db.transaction(() async {
    final key = placeKey(
      await _openOrdered(versionId, excluding: id),
      afterId: afterId,
      beforeId: beforeId,
    );
    await (db.update(db.features)..where((t) => t.id.equals(id))).write(
      FeaturesCompanion(versionId: Value(versionId), sortKey: Value(key), updatedAt: Value(db.now())),
    );
  });

  /// Raw restore used by undo: puts back exact version, key and delay history.
  Future<void> restorePlacement(Feature f) => (db.update(db.features)..where((t) => t.id.equals(f.id))).write(
    FeaturesCompanion(
      versionId: Value(f.versionId),
      sortKey: Value(f.sortKey),
      delayedFromVersionId: Value(f.delayedFromVersionId),
      delayCount: Value(f.delayCount),
      updatedAt: Value(db.now()),
    ),
  );

  /// The release version after the feature's version, or null.
  Future<Version?> nextVersionFor(String featureId) async {
    final f = await get(featureId);
    final cur = await (db.select(db.versions)..where((t) => t.id.equals(f.versionId))).getSingle();
    final releases =
        await (db.select(db.versions)
              ..where((t) => t.projectId.equals(cur.projectId) & t.deleted.equals(false) & t.kind.equals('release'))
              ..orderBy([(t) => OrderingTerm(expression: t.sortKey)]))
            .get();
    if (cur.kind == 'concept') return releases.isEmpty ? null : releases.first;
    final i = releases.indexWhere((v) => v.id == cur.id);
    return i >= 0 && i + 1 < releases.length ? releases[i + 1] : null;
  }

  /// Delays a feature to [toVersionId] (default: the next release version),
  /// placing it on top and recording where it was first planned.
  Future<void> delay(String id, {String? toVersionId}) => db.transaction(() async {
    final f = await get(id);
    final target = toVersionId ?? (await nextVersionFor(id))?.id;
    if (target == null) throw StateError('no-next-version');
    final ordered = await _openOrdered(target, excluding: id);
    final key = placeKey(ordered, beforeId: ordered.isEmpty ? null : ordered.first.$1);
    await (db.update(db.features)..where((t) => t.id.equals(id))).write(
      FeaturesCompanion(
        versionId: Value(target),
        sortKey: Value(key),
        delayedFromVersionId: Value(f.delayedFromVersionId ?? f.versionId),
        delayCount: Value(f.delayCount + 1),
        updatedAt: Value(db.now()),
      ),
    );
  });

  Future<void> softDelete(String id) => setDeleted(id, true);

  Future<void> setDeleted(String id, bool deleted) => (db.update(
    db.features,
  )..where((t) => t.id.equals(id))).write(FeaturesCompanion(deleted: Value(deleted), updatedAt: Value(db.now())));

  // ---- sub-items ----

  Stream<List<Subitem>> watchSubitems(String featureId) =>
      (db.select(db.subitems)
            ..where((t) => t.featureId.equals(featureId) & t.deleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.sortKey)]))
          .watch();

  /// Adds a step at the end of [parentId]'s children (top level when null).
  Future<String> addSubitem(String featureId, String title, {String? parentId}) => db.transaction(() async {
    final rows = [
      for (final r in await watchSubitems(featureId).first)
        if (r.parentId == parentId) r,
    ];
    final now = db.now();
    final id = db.newId();
    await db
        .into(db.subitems)
        .insert(
          SubitemsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            featureId: featureId,
            parentId: Value(parentId),
            title: title,
            sortKey: placeKey([for (final r in rows) (r.id, r.sortKey)]),
          ),
        );
    return id;
  });

  Future<void> updateSubitem(String id, {String? title, bool? done}) =>
      (db.update(db.subitems)..where((t) => t.id.equals(id))).write(
        SubitemsCompanion(
          updatedAt: Value(db.now()),
          title: title == null ? const Value.absent() : Value(title),
          done: done == null ? const Value.absent() : Value(done),
        ),
      );

  Future<void> deleteSubitem(String id) => setSubitemDeleted(id, true);

  /// Live step ids under [id], at every depth (not including [id]).
  Future<List<String>> subitemDescendants(String id) async {
    final s = await (db.select(db.subitems)..where((t) => t.id.equals(id))).getSingle();
    final all = await watchSubitems(s.featureId).first;
    final out = <String>[];
    void walk(String p) {
      for (final c in all.where((x) => x.parentId == p)) {
        out.add(c.id);
        walk(c.id);
      }
    }

    walk(id);
    return out;
  }

  /// Moves a step: to [parentId] (null = top level) between siblings
  /// [afterId] / [beforeId]. Refuses to move a step under its own subtree.
  Future<void> moveSubitem(String id, {String? parentId, String? afterId, String? beforeId}) =>
      db.transaction(() async {
        if (parentId == id || (parentId != null && (await subitemDescendants(id)).contains(parentId))) {
          throw ArgumentError('A step cannot move under itself');
        }
        final s = await (db.select(db.subitems)..where((t) => t.id.equals(id))).getSingle();
        final siblings = [
          for (final r in await watchSubitems(s.featureId).first)
            if (r.parentId == parentId && r.id != id) (r.id, r.sortKey),
        ];
        final key = placeKey(siblings, afterId: afterId, beforeId: beforeId);
        await (db.update(db.subitems)..where((t) => t.id.equals(id))).write(
          SubitemsCompanion(parentId: Value(parentId), sortKey: Value(key), updatedAt: Value(db.now())),
        );
      });

  /// Raw restore for undo.
  Future<void> restoreSubitemPlacement(Subitem s) => (db.update(db.subitems)..where((t) => t.id.equals(s.id))).write(
    SubitemsCompanion(parentId: Value(s.parentId), sortKey: Value(s.sortKey), updatedAt: Value(db.now())),
  );

  Future<void> setSubitemDeleted(String id, bool deleted) => (db.update(
    db.subitems,
  )..where((t) => t.id.equals(id))).write(SubitemsCompanion(deleted: Value(deleted), updatedAt: Value(db.now())));

  // ---- tags ----

  Stream<List<Tag>> watchTags(String featureId) => db
      .customSelect(
        'SELECT t.* FROM tags t JOIN feature_tags ft ON ft.tag_id = t.id '
        'WHERE ft.feature_id = ? AND ft.deleted = 0 AND t.deleted = 0 ORDER BY t.sort_key',
        variables: [Variable.withString(featureId)],
        readsFrom: {db.tags, db.featureTags},
      )
      .watch()
      .asyncMap((rows) => Future.wait(rows.map((r) => db.tags.mapFromRow(r))));

  /// Makes the feature's live tag links exactly [tagIds].
  Future<void> setTags(String featureId, List<String> tagIds) => db.transaction(() async {
    final now = db.now();
    final existing = await (db.select(db.featureTags)..where((t) => t.featureId.equals(featureId))).get();
    for (final link in existing) {
      final want = tagIds.contains(link.tagId);
      if (link.deleted == want) {
        await (db.update(db.featureTags)..where((t) => t.id.equals(link.id))).write(
          FeatureTagsCompanion(deleted: Value(!want), updatedAt: Value(now)),
        );
      }
    }
    for (final tagId in tagIds) {
      if (existing.any((l) => l.tagId == tagId)) continue;
      await db
          .into(db.featureTags)
          .insert(
            FeatureTagsCompanion.insert(
              id: '$featureId:$tagId',
              createdAt: now,
              updatedAt: now,
              featureId: featureId,
              tagId: tagId,
            ),
          );
    }
  });

  // ---- board view ----

  Stream<List<FeatureView>> watchFeatureViews(String versionId) => db
      .customSelect(
        'SELECT f.id FROM features f WHERE f.version_id = ? AND f.deleted = 0',
        variables: [Variable.withString(versionId)],
        readsFrom: {db.features, db.subitems, db.featureTags, db.tags, db.attachments},
      )
      .watch()
      .asyncMap((_) => _loadViews(versionId));

  Future<List<FeatureView>> _loadViews(String versionId) async {
    final fs = _boardOrder(
      await (db.select(db.features)..where((t) => t.versionId.equals(versionId) & t.deleted.equals(false))).get(),
    );
    if (fs.isEmpty) return const [];
    final ids = fs.map((f) => f.id).toList();
    final subs = await (db.select(db.subitems)..where((t) => t.featureId.isIn(ids) & t.deleted.equals(false))).get();
    final atts = await (db.select(db.attachments)..where((t) => t.featureId.isIn(ids) & t.deleted.equals(false))).get();
    final links = await (db.select(
      db.featureTags,
    )..where((t) => t.featureId.isIn(ids) & t.deleted.equals(false))).get();
    final tagRows = links.isEmpty
        ? <Tag>[]
        : await (db.select(db.tags)
                ..where((t) => t.id.isIn(links.map((l) => l.tagId).toSet()) & t.deleted.equals(false))
                ..orderBy([(t) => OrderingTerm(expression: t.sortKey)]))
              .get();
    return [
      for (final f in fs)
        FeatureView(
          f,
          [
            for (final t in tagRows)
              if (links.any((l) => l.featureId == f.id && l.tagId == t.id)) t,
          ],
          subs.where((s) => s.featureId == f.id && s.done).length,
          subs.where((s) => s.featureId == f.id).length,
          atts.where((a) => a.featureId == f.id).length,
          subTitles: [
            for (final s in subs)
              if (s.featureId == f.id) s.title,
          ],
        ),
    ];
  }
}
