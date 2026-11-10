import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

const _uuid = Uuid();

@DriftDatabase(
  tables: [Projects, Environments, Versions, Features, Subitems, Milestones, Tags, FeatureTags, Attachments],
)
class VersoDb extends _$VersoDb {
  VersoDb(super.e, {int Function()? clock}) : _clock = clock ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch);

  /// Opens `<dir>\verso.db`.
  factory VersoDb.open(Directory dir) => VersoDb(
    driftDatabase(
      name: 'verso',
      native: DriftNativeOptions(databaseDirectory: () async => dir),
    ),
  );

  final int Function() _clock;

  /// UTC epoch ms; every write stamps `updatedAt` with this.
  int now() => _clock();

  String newId() => _uuid.v4();

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _insertDefaultEnvironment();
    },
    // Every step checks the actual schema first, so it is safe to run again: an
    // older Verso build that opens the file stamps user_version back down
    // without removing what newer builds added.
    onUpgrade: (m, from, to) async {
      await transaction(() async {
        if (!await _hasTable('environments')) {
          await m.createTable(environments);
        }
        if (!await _hasColumn('versions', 'environment_id')) {
          await m.addColumn(versions, versions.environmentId);
        }
        final noEnvironment = await customSelect(
          'SELECT COUNT(*) AS n FROM versions WHERE environment_id IS NULL',
        ).getSingle();
        if (noEnvironment.read<int>('n') > 0) {
          final envs = await customSelect(
            'SELECT id FROM environments WHERE deleted = 0 ORDER BY sort_key LIMIT 1',
          ).get();
          final id = envs.isEmpty ? await _insertDefaultEnvironment() : envs.first.read<String>('id');
          await customStatement('UPDATE versions SET environment_id = ? WHERE environment_id IS NULL', [id]);
        }
        if (!await _hasColumn('projects', 'paused')) {
          await m.addColumn(projects, projects.paused);
        }
        if (!await _hasColumn('subitems', 'parent_id')) {
          await m.addColumn(subitems, subitems.parentId);
        }
      });
    },
    beforeOpen: (d) async => customStatement('PRAGMA foreign_keys = OFF'),
  );

  Future<bool> _hasTable(String name) async => (await customSelect(
    "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
    variables: [Variable.withString(name)],
  ).get()).isNotEmpty;

  Future<bool> _hasColumn(String table, String column) async =>
      (await customSelect('PRAGMA table_info($table)').get()).any((r) => r.read<String>('name') == column);

  /// The folder every project starts in until the owner makes others.
  /// Same id on every device, so synced devices share one default folder.
  static const defaultEnvironmentId = 'env-default';

  Future<String> _insertDefaultEnvironment() async {
    const id = defaultEnvironmentId;
    // Created at time 0 so any real edit (rename, icon) on another device wins.
    const t = 0;
    await into(
      environments,
    ).insert(EnvironmentsCompanion.insert(id: id, createdAt: t, updatedAt: t, name: 'My apps', sortKey: 'a0'));
    return id;
  }
}
