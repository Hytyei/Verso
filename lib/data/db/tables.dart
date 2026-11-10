import 'package:drift/drift.dart';

/// Columns every synced row carries (spec §4).
mixin SyncColumns on Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Project')
class Projects extends Table with SyncColumns {
  TextColumn get name => text()();
  IntColumn get color => integer().withDefault(const Constant(0))();
  BoolColumn get colorCustom => boolean().withDefault(const Constant(false))();
  TextColumn get icon => text().nullable()();
  TextColumn get sortKey => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  /// "On Pause": shown faded in an On Pause subfolder of each environment.
  BoolColumn get paused => boolean().withDefault(const Constant(false))();
}

/// Where development happens (Claude Code, ChatGPT…); a sidebar folder.
@DataClassName('Environment')
class Environments extends Table with SyncColumns {
  TextColumn get name => text()();

  /// Built-in glyph key, or `file:<name>` for a custom image in the icons folder.
  TextColumn get icon => text().withDefault(const Constant('folder'))();
  IntColumn get color => integer().withDefault(const Constant(0))();
  BoolColumn get colorCustom => boolean().withDefault(const Constant(false))();
  TextColumn get sortKey => text()();
}

@DataClassName('Version')
class Versions extends Table with SyncColumns {
  TextColumn get projectId => text()();
  TextColumn get environmentId => text().nullable()();
  TextColumn get kind => text().withDefault(const Constant('release'))();
  TextColumn get name => text()();
  TextColumn get status => text().withDefault(const Constant('planned'))();
  IntColumn get color => integer().withDefault(const Constant(0))();
  BoolColumn get colorCustom => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  DateTimeColumn get releasedDate => dateTime().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get sortKey => text()();
}

@DataClassName('Feature')
class Features extends Table with SyncColumns {
  TextColumn get versionId => text()();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get doneAt => integer().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  IntColumn get color => integer().nullable()();
  BoolColumn get colorCustom => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get sortKey => text()();
  TextColumn get delayedFromVersionId => text().nullable()();
  IntColumn get delayCount => integer().withDefault(const Constant(0))();
}

@DataClassName('Subitem')
class Subitems extends Table with SyncColumns {
  TextColumn get featureId => text()();

  /// Parent step for nested steps (null = top level of the feature).
  TextColumn get parentId => text().nullable()();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  TextColumn get sortKey => text()();
}

@DataClassName('Milestone')
class Milestones extends Table with SyncColumns {
  TextColumn get projectId => text()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get kind => text().withDefault(const Constant('other'))();
  IntColumn get color => integer().nullable()();
  BoolColumn get colorCustom => boolean().withDefault(const Constant(false))();
}

@DataClassName('Tag')
class Tags extends Table with SyncColumns {
  TextColumn get projectId => text()();
  TextColumn get name => text()();
  IntColumn get color => integer().withDefault(const Constant(0))();
  BoolColumn get colorCustom => boolean().withDefault(const Constant(false))();
  TextColumn get sortKey => text()();
}

/// Link row; id is "<featureId>:<tagId>" so a re-link revives the same row.
@DataClassName('FeatureTag')
class FeatureTags extends Table with SyncColumns {
  TextColumn get featureId => text()();
  TextColumn get tagId => text()();
}

@DataClassName('Attachment')
class Attachments extends Table with SyncColumns {
  TextColumn get featureId => text()();
  TextColumn get fileName => text()();
  TextColumn get originalName => text()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  TextColumn get sortKey => text()();
}
