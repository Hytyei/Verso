// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorCustomMeta = const VerificationMeta('colorCustom');
  @override
  late final GeneratedColumn<bool> colorCustom = GeneratedColumn<bool>(
    'color_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("color_custom" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta('sortKey');
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pausedMeta = const VerificationMeta('paused');
  @override
  late final GeneratedColumn<bool> paused = GeneratedColumn<bool>(
    'paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("paused" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    name,
    color,
    colorCustom,
    icon,
    sortKey,
    archived,
    paused,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<Project> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(_colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('color_custom')) {
      context.handle(_colorCustomMeta, colorCustom.isAcceptableOrUnknown(data['color_custom']!, _colorCustomMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(_iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('sort_key')) {
      context.handle(_sortKeyMeta, sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta));
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta, archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    if (data.containsKey('paused')) {
      context.handle(_pausedMeta, paused.isAcceptableOrUnknown(data['paused']!, _pausedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      colorCustom: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}color_custom'])!,
      icon: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}icon']),
      sortKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sort_key'])!,
      archived: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
      paused: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}paused'])!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final bool deleted;
  final String name;
  final int color;
  final bool colorCustom;
  final String? icon;
  final String sortKey;
  final bool archived;

  /// "On Pause": shown faded in an On Pause subfolder of each environment.
  final bool paused;
  const Project({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.color,
    required this.colorCustom,
    this.icon,
    required this.sortKey,
    required this.archived,
    required this.paused,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['color_custom'] = Variable<bool>(colorCustom);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['sort_key'] = Variable<String>(sortKey);
    map['archived'] = Variable<bool>(archived);
    map['paused'] = Variable<bool>(paused);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      color: Value(color),
      colorCustom: Value(colorCustom),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      sortKey: Value(sortKey),
      archived: Value(archived),
      paused: Value(paused),
    );
  }

  factory Project.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      colorCustom: serializer.fromJson<bool>(json['colorCustom']),
      icon: serializer.fromJson<String?>(json['icon']),
      sortKey: serializer.fromJson<String>(json['sortKey']),
      archived: serializer.fromJson<bool>(json['archived']),
      paused: serializer.fromJson<bool>(json['paused']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'colorCustom': serializer.toJson<bool>(colorCustom),
      'icon': serializer.toJson<String?>(icon),
      'sortKey': serializer.toJson<String>(sortKey),
      'archived': serializer.toJson<bool>(archived),
      'paused': serializer.toJson<bool>(paused),
    };
  }

  Project copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? deleted,
    String? name,
    int? color,
    bool? colorCustom,
    Value<String?> icon = const Value.absent(),
    String? sortKey,
    bool? archived,
    bool? paused,
  }) => Project(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    color: color ?? this.color,
    colorCustom: colorCustom ?? this.colorCustom,
    icon: icon.present ? icon.value : this.icon,
    sortKey: sortKey ?? this.sortKey,
    archived: archived ?? this.archived,
    paused: paused ?? this.paused,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      colorCustom: data.colorCustom.present ? data.colorCustom.value : this.colorCustom,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
      archived: data.archived.present ? data.archived.value : this.archived,
      paused: data.paused.present ? data.paused.value : this.paused,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('colorCustom: $colorCustom, ')
          ..write('icon: $icon, ')
          ..write('sortKey: $sortKey, ')
          ..write('archived: $archived, ')
          ..write('paused: $paused')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deleted, name, color, colorCustom, icon, sortKey, archived, paused);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.color == this.color &&
          other.colorCustom == this.colorCustom &&
          other.icon == this.icon &&
          other.sortKey == this.sortKey &&
          other.archived == this.archived &&
          other.paused == this.paused);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<int> color;
  final Value<bool> colorCustom;
  final Value<String?> icon;
  final Value<String> sortKey;
  final Value<bool> archived;
  final Value<bool> paused;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.colorCustom = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.archived = const Value.absent(),
    this.paused = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
    this.colorCustom = const Value.absent(),
    this.icon = const Value.absent(),
    required String sortKey,
    this.archived = const Value.absent(),
    this.paused = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       sortKey = Value(sortKey);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<int>? color,
    Expression<bool>? colorCustom,
    Expression<String>? icon,
    Expression<String>? sortKey,
    Expression<bool>? archived,
    Expression<bool>? paused,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (colorCustom != null) 'color_custom': colorCustom,
      if (icon != null) 'icon': icon,
      if (sortKey != null) 'sort_key': sortKey,
      if (archived != null) 'archived': archived,
      if (paused != null) 'paused': paused,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<int>? color,
    Value<bool>? colorCustom,
    Value<String?>? icon,
    Value<String>? sortKey,
    Value<bool>? archived,
    Value<bool>? paused,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      color: color ?? this.color,
      colorCustom: colorCustom ?? this.colorCustom,
      icon: icon ?? this.icon,
      sortKey: sortKey ?? this.sortKey,
      archived: archived ?? this.archived,
      paused: paused ?? this.paused,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (colorCustom.present) {
      map['color_custom'] = Variable<bool>(colorCustom.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<String>(sortKey.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (paused.present) {
      map['paused'] = Variable<bool>(paused.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('colorCustom: $colorCustom, ')
          ..write('icon: $icon, ')
          ..write('sortKey: $sortKey, ')
          ..write('archived: $archived, ')
          ..write('paused: $paused, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnvironmentsTable extends Environments with TableInfo<$EnvironmentsTable, Environment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvironmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('folder'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorCustomMeta = const VerificationMeta('colorCustom');
  @override
  late final GeneratedColumn<bool> colorCustom = GeneratedColumn<bool>(
    'color_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("color_custom" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta('sortKey');
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, updatedAt, deleted, name, icon, color, colorCustom, sortKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'environments';
  @override
  VerificationContext validateIntegrity(Insertable<Environment> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(_iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('color')) {
      context.handle(_colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('color_custom')) {
      context.handle(_colorCustomMeta, colorCustom.isAcceptableOrUnknown(data['color_custom']!, _colorCustomMeta));
    }
    if (data.containsKey('sort_key')) {
      context.handle(_sortKeyMeta, sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta));
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Environment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Environment(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      color: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      colorCustom: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}color_custom'])!,
      sortKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sort_key'])!,
    );
  }

  @override
  $EnvironmentsTable createAlias(String alias) {
    return $EnvironmentsTable(attachedDatabase, alias);
  }
}

class Environment extends DataClass implements Insertable<Environment> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final bool deleted;
  final String name;

  /// Built-in glyph key, or `file:<name>` for a custom image in the icons folder.
  final String icon;
  final int color;
  final bool colorCustom;
  final String sortKey;
  const Environment({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.icon,
    required this.color,
    required this.colorCustom,
    required this.sortKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    map['color_custom'] = Variable<bool>(colorCustom);
    map['sort_key'] = Variable<String>(sortKey);
    return map;
  }

  EnvironmentsCompanion toCompanion(bool nullToAbsent) {
    return EnvironmentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      colorCustom: Value(colorCustom),
      sortKey: Value(sortKey),
    );
  }

  factory Environment.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Environment(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      colorCustom: serializer.fromJson<bool>(json['colorCustom']),
      sortKey: serializer.fromJson<String>(json['sortKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'colorCustom': serializer.toJson<bool>(colorCustom),
      'sortKey': serializer.toJson<String>(sortKey),
    };
  }

  Environment copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? deleted,
    String? name,
    String? icon,
    int? color,
    bool? colorCustom,
    String? sortKey,
  }) => Environment(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    colorCustom: colorCustom ?? this.colorCustom,
    sortKey: sortKey ?? this.sortKey,
  );
  Environment copyWithCompanion(EnvironmentsCompanion data) {
    return Environment(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      colorCustom: data.colorCustom.present ? data.colorCustom.value : this.colorCustom,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Environment(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('colorCustom: $colorCustom, ')
          ..write('sortKey: $sortKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, deleted, name, icon, color, colorCustom, sortKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Environment &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.colorCustom == this.colorCustom &&
          other.sortKey == this.sortKey);
}

class EnvironmentsCompanion extends UpdateCompanion<Environment> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> color;
  final Value<bool> colorCustom;
  final Value<String> sortKey;
  final Value<int> rowid;
  const EnvironmentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.colorCustom = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnvironmentsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.colorCustom = const Value.absent(),
    required String sortKey,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       sortKey = Value(sortKey);
  static Insertable<Environment> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<bool>? colorCustom,
    Expression<String>? sortKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (colorCustom != null) 'color_custom': colorCustom,
      if (sortKey != null) 'sort_key': sortKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnvironmentsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? color,
    Value<bool>? colorCustom,
    Value<String>? sortKey,
    Value<int>? rowid,
  }) {
    return EnvironmentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      colorCustom: colorCustom ?? this.colorCustom,
      sortKey: sortKey ?? this.sortKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (colorCustom.present) {
      map['color_custom'] = Variable<bool>(colorCustom.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<String>(sortKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvironmentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('colorCustom: $colorCustom, ')
          ..write('sortKey: $sortKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VersionsTable extends Versions with TableInfo<$VersionsTable, Version> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _environmentIdMeta = const VerificationMeta('environmentId');
  @override
  late final GeneratedColumn<String> environmentId = GeneratedColumn<String>(
    'environment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('release'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorCustomMeta = const VerificationMeta('colorCustom');
  @override
  late final GeneratedColumn<bool> colorCustom = GeneratedColumn<bool>(
    'color_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("color_custom" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta('targetDate');
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releasedDateMeta = const VerificationMeta('releasedDate');
  @override
  late final GeneratedColumn<DateTime> releasedDate = GeneratedColumn<DateTime>(
    'released_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta('sortKey');
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    projectId,
    environmentId,
    kind,
    name,
    status,
    color,
    colorCustom,
    startDate,
    targetDate,
    releasedDate,
    description,
    sortKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'versions';
  @override
  VerificationContext validateIntegrity(Insertable<Version> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta, projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('environment_id')) {
      context.handle(
        _environmentIdMeta,
        environmentId.isAcceptableOrUnknown(data['environment_id']!, _environmentIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('color')) {
      context.handle(_colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('color_custom')) {
      context.handle(_colorCustomMeta, colorCustom.isAcceptableOrUnknown(data['color_custom']!, _colorCustomMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta, startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('target_date')) {
      context.handle(_targetDateMeta, targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta));
    }
    if (data.containsKey('released_date')) {
      context.handle(_releasedDateMeta, releasedDate.isAcceptableOrUnknown(data['released_date']!, _releasedDateMeta));
    }
    if (data.containsKey('description')) {
      context.handle(_descriptionMeta, description.isAcceptableOrUnknown(data['description']!, _descriptionMeta));
    }
    if (data.containsKey('sort_key')) {
      context.handle(_sortKeyMeta, sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta));
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Version map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Version(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      projectId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      environmentId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}environment_id']),
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      color: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      colorCustom: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}color_custom'])!,
      startDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      targetDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}target_date']),
      releasedDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}released_date']),
      description: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}description']),
      sortKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sort_key'])!,
    );
  }

  @override
  $VersionsTable createAlias(String alias) {
    return $VersionsTable(attachedDatabase, alias);
  }
}

class Version extends DataClass implements Insertable<Version> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final bool deleted;
  final String projectId;
  final String? environmentId;
  final String kind;
  final String name;
  final String status;
  final int color;
  final bool colorCustom;
  final DateTime? startDate;
  final DateTime? targetDate;
  final DateTime? releasedDate;
  final String? description;
  final String sortKey;
  const Version({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.projectId,
    this.environmentId,
    required this.kind,
    required this.name,
    required this.status,
    required this.color,
    required this.colorCustom,
    this.startDate,
    this.targetDate,
    this.releasedDate,
    this.description,
    required this.sortKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || environmentId != null) {
      map['environment_id'] = Variable<String>(environmentId);
    }
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    map['status'] = Variable<String>(status);
    map['color'] = Variable<int>(color);
    map['color_custom'] = Variable<bool>(colorCustom);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    if (!nullToAbsent || releasedDate != null) {
      map['released_date'] = Variable<DateTime>(releasedDate);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sort_key'] = Variable<String>(sortKey);
    return map;
  }

  VersionsCompanion toCompanion(bool nullToAbsent) {
    return VersionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      projectId: Value(projectId),
      environmentId: environmentId == null && nullToAbsent ? const Value.absent() : Value(environmentId),
      kind: Value(kind),
      name: Value(name),
      status: Value(status),
      color: Value(color),
      colorCustom: Value(colorCustom),
      startDate: startDate == null && nullToAbsent ? const Value.absent() : Value(startDate),
      targetDate: targetDate == null && nullToAbsent ? const Value.absent() : Value(targetDate),
      releasedDate: releasedDate == null && nullToAbsent ? const Value.absent() : Value(releasedDate),
      description: description == null && nullToAbsent ? const Value.absent() : Value(description),
      sortKey: Value(sortKey),
    );
  }

  factory Version.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Version(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      projectId: serializer.fromJson<String>(json['projectId']),
      environmentId: serializer.fromJson<String?>(json['environmentId']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      status: serializer.fromJson<String>(json['status']),
      color: serializer.fromJson<int>(json['color']),
      colorCustom: serializer.fromJson<bool>(json['colorCustom']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      releasedDate: serializer.fromJson<DateTime?>(json['releasedDate']),
      description: serializer.fromJson<String?>(json['description']),
      sortKey: serializer.fromJson<String>(json['sortKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'projectId': serializer.toJson<String>(projectId),
      'environmentId': serializer.toJson<String?>(environmentId),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(status),
      'color': serializer.toJson<int>(color),
      'colorCustom': serializer.toJson<bool>(colorCustom),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'releasedDate': serializer.toJson<DateTime?>(releasedDate),
      'description': serializer.toJson<String?>(description),
      'sortKey': serializer.toJson<String>(sortKey),
    };
  }

  Version copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? deleted,
    String? projectId,
    Value<String?> environmentId = const Value.absent(),
    String? kind,
    String? name,
    String? status,
    int? color,
    bool? colorCustom,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> targetDate = const Value.absent(),
    Value<DateTime?> releasedDate = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? sortKey,
  }) => Version(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    projectId: projectId ?? this.projectId,
    environmentId: environmentId.present ? environmentId.value : this.environmentId,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    status: status ?? this.status,
    color: color ?? this.color,
    colorCustom: colorCustom ?? this.colorCustom,
    startDate: startDate.present ? startDate.value : this.startDate,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    releasedDate: releasedDate.present ? releasedDate.value : this.releasedDate,
    description: description.present ? description.value : this.description,
    sortKey: sortKey ?? this.sortKey,
  );
  Version copyWithCompanion(VersionsCompanion data) {
    return Version(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      environmentId: data.environmentId.present ? data.environmentId.value : this.environmentId,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      color: data.color.present ? data.color.value : this.color,
      colorCustom: data.colorCustom.present ? data.colorCustom.value : this.colorCustom,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      targetDate: data.targetDate.present ? data.targetDate.value : this.targetDate,
      releasedDate: data.releasedDate.present ? data.releasedDate.value : this.releasedDate,
      description: data.description.present ? data.description.value : this.description,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Version(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('projectId: $projectId, ')
          ..write('environmentId: $environmentId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('color: $color, ')
          ..write('colorCustom: $colorCustom, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('releasedDate: $releasedDate, ')
          ..write('description: $description, ')
          ..write('sortKey: $sortKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deleted,
    projectId,
    environmentId,
    kind,
    name,
    status,
    color,
    colorCustom,
    startDate,
    targetDate,
    releasedDate,
    description,
    sortKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Version &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.projectId == this.projectId &&
          other.environmentId == this.environmentId &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.status == this.status &&
          other.color == this.color &&
          other.colorCustom == this.colorCustom &&
          other.startDate == this.startDate &&
          other.targetDate == this.targetDate &&
          other.releasedDate == this.releasedDate &&
          other.description == this.description &&
          other.sortKey == this.sortKey);
}

class VersionsCompanion extends UpdateCompanion<Version> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> projectId;
  final Value<String?> environmentId;
  final Value<String> kind;
  final Value<String> name;
  final Value<String> status;
  final Value<int> color;
  final Value<bool> colorCustom;
  final Value<DateTime?> startDate;
  final Value<DateTime?> targetDate;
  final Value<DateTime?> releasedDate;
  final Value<String?> description;
  final Value<String> sortKey;
  final Value<int> rowid;
  const VersionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.projectId = const Value.absent(),
    this.environmentId = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.color = const Value.absent(),
    this.colorCustom = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.releasedDate = const Value.absent(),
    this.description = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VersionsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String projectId,
    this.environmentId = const Value.absent(),
    this.kind = const Value.absent(),
    required String name,
    this.status = const Value.absent(),
    this.color = const Value.absent(),
    this.colorCustom = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.releasedDate = const Value.absent(),
    this.description = const Value.absent(),
    required String sortKey,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       projectId = Value(projectId),
       name = Value(name),
       sortKey = Value(sortKey);
  static Insertable<Version> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? projectId,
    Expression<String>? environmentId,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? status,
    Expression<int>? color,
    Expression<bool>? colorCustom,
    Expression<DateTime>? startDate,
    Expression<DateTime>? targetDate,
    Expression<DateTime>? releasedDate,
    Expression<String>? description,
    Expression<String>? sortKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (projectId != null) 'project_id': projectId,
      if (environmentId != null) 'environment_id': environmentId,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (color != null) 'color': color,
      if (colorCustom != null) 'color_custom': colorCustom,
      if (startDate != null) 'start_date': startDate,
      if (targetDate != null) 'target_date': targetDate,
      if (releasedDate != null) 'released_date': releasedDate,
      if (description != null) 'description': description,
      if (sortKey != null) 'sort_key': sortKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VersionsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? projectId,
    Value<String?>? environmentId,
    Value<String>? kind,
    Value<String>? name,
    Value<String>? status,
    Value<int>? color,
    Value<bool>? colorCustom,
    Value<DateTime?>? startDate,
    Value<DateTime?>? targetDate,
    Value<DateTime?>? releasedDate,
    Value<String?>? description,
    Value<String>? sortKey,
    Value<int>? rowid,
  }) {
    return VersionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      projectId: projectId ?? this.projectId,
      environmentId: environmentId ?? this.environmentId,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      status: status ?? this.status,
      color: color ?? this.color,
      colorCustom: colorCustom ?? this.colorCustom,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      releasedDate: releasedDate ?? this.releasedDate,
      description: description ?? this.description,
      sortKey: sortKey ?? this.sortKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (environmentId.present) {
      map['environment_id'] = Variable<String>(environmentId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (colorCustom.present) {
      map['color_custom'] = Variable<bool>(colorCustom.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (releasedDate.present) {
      map['released_date'] = Variable<DateTime>(releasedDate.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<String>(sortKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('projectId: $projectId, ')
          ..write('environmentId: $environmentId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('color: $color, ')
          ..write('colorCustom: $colorCustom, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('releasedDate: $releasedDate, ')
          ..write('description: $description, ')
          ..write('sortKey: $sortKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeaturesTable extends Features with TableInfo<$FeaturesTable, Feature> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeaturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionIdMeta = const VerificationMeta('versionId');
  @override
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("done" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<int> doneAt = GeneratedColumn<int>(
    'done_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorCustomMeta = const VerificationMeta('colorCustom');
  @override
  late final GeneratedColumn<bool> colorCustom = GeneratedColumn<bool>(
    'color_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("color_custom" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta('sortKey');
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _delayedFromVersionIdMeta = const VerificationMeta('delayedFromVersionId');
  @override
  late final GeneratedColumn<String> delayedFromVersionId = GeneratedColumn<String>(
    'delayed_from_version_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _delayCountMeta = const VerificationMeta('delayCount');
  @override
  late final GeneratedColumn<int> delayCount = GeneratedColumn<int>(
    'delay_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    versionId,
    title,
    done,
    doneAt,
    priority,
    color,
    colorCustom,
    notes,
    startDate,
    endDate,
    sortKey,
    delayedFromVersionId,
    delayCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'features';
  @override
  VerificationContext validateIntegrity(Insertable<Feature> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('version_id')) {
      context.handle(_versionIdMeta, versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta));
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('done')) {
      context.handle(_doneMeta, done.isAcceptableOrUnknown(data['done']!, _doneMeta));
    }
    if (data.containsKey('done_at')) {
      context.handle(_doneAtMeta, doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta, priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('color')) {
      context.handle(_colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('color_custom')) {
      context.handle(_colorCustomMeta, colorCustom.isAcceptableOrUnknown(data['color_custom']!, _colorCustomMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta, startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta, endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('sort_key')) {
      context.handle(_sortKeyMeta, sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta));
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    if (data.containsKey('delayed_from_version_id')) {
      context.handle(
        _delayedFromVersionIdMeta,
        delayedFromVersionId.isAcceptableOrUnknown(data['delayed_from_version_id']!, _delayedFromVersionIdMeta),
      );
    }
    if (data.containsKey('delay_count')) {
      context.handle(_delayCountMeta, delayCount.isAcceptableOrUnknown(data['delay_count']!, _delayCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Feature map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Feature(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      versionId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}version_id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      done: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}done'])!,
      doneAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}done_at']),
      priority: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      color: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color']),
      colorCustom: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}color_custom'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      startDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      sortKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sort_key'])!,
      delayedFromVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delayed_from_version_id'],
      ),
      delayCount: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}delay_count'])!,
    );
  }

  @override
  $FeaturesTable createAlias(String alias) {
    return $FeaturesTable(attachedDatabase, alias);
  }
}

class Feature extends DataClass implements Insertable<Feature> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final bool deleted;
  final String versionId;
  final String title;
  final bool done;
  final int? doneAt;
  final int priority;
  final int? color;
  final bool colorCustom;
  final String? notes;
  final DateTime? startDate;
  final DateTime? endDate;
  final String sortKey;
  final String? delayedFromVersionId;
  final int delayCount;
  const Feature({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.versionId,
    required this.title,
    required this.done,
    this.doneAt,
    required this.priority,
    this.color,
    required this.colorCustom,
    this.notes,
    this.startDate,
    this.endDate,
    required this.sortKey,
    this.delayedFromVersionId,
    required this.delayCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['version_id'] = Variable<String>(versionId);
    map['title'] = Variable<String>(title);
    map['done'] = Variable<bool>(done);
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<int>(doneAt);
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['color_custom'] = Variable<bool>(colorCustom);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['sort_key'] = Variable<String>(sortKey);
    if (!nullToAbsent || delayedFromVersionId != null) {
      map['delayed_from_version_id'] = Variable<String>(delayedFromVersionId);
    }
    map['delay_count'] = Variable<int>(delayCount);
    return map;
  }

  FeaturesCompanion toCompanion(bool nullToAbsent) {
    return FeaturesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      versionId: Value(versionId),
      title: Value(title),
      done: Value(done),
      doneAt: doneAt == null && nullToAbsent ? const Value.absent() : Value(doneAt),
      priority: Value(priority),
      color: color == null && nullToAbsent ? const Value.absent() : Value(color),
      colorCustom: Value(colorCustom),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      startDate: startDate == null && nullToAbsent ? const Value.absent() : Value(startDate),
      endDate: endDate == null && nullToAbsent ? const Value.absent() : Value(endDate),
      sortKey: Value(sortKey),
      delayedFromVersionId: delayedFromVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(delayedFromVersionId),
      delayCount: Value(delayCount),
    );
  }

  factory Feature.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Feature(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      versionId: serializer.fromJson<String>(json['versionId']),
      title: serializer.fromJson<String>(json['title']),
      done: serializer.fromJson<bool>(json['done']),
      doneAt: serializer.fromJson<int?>(json['doneAt']),
      priority: serializer.fromJson<int>(json['priority']),
      color: serializer.fromJson<int?>(json['color']),
      colorCustom: serializer.fromJson<bool>(json['colorCustom']),
      notes: serializer.fromJson<String?>(json['notes']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      sortKey: serializer.fromJson<String>(json['sortKey']),
      delayedFromVersionId: serializer.fromJson<String?>(json['delayedFromVersionId']),
      delayCount: serializer.fromJson<int>(json['delayCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'versionId': serializer.toJson<String>(versionId),
      'title': serializer.toJson<String>(title),
      'done': serializer.toJson<bool>(done),
      'doneAt': serializer.toJson<int?>(doneAt),
      'priority': serializer.toJson<int>(priority),
      'color': serializer.toJson<int?>(color),
      'colorCustom': serializer.toJson<bool>(colorCustom),
      'notes': serializer.toJson<String?>(notes),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'sortKey': serializer.toJson<String>(sortKey),
      'delayedFromVersionId': serializer.toJson<String?>(delayedFromVersionId),
      'delayCount': serializer.toJson<int>(delayCount),
    };
  }

  Feature copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? deleted,
    String? versionId,
    String? title,
    bool? done,
    Value<int?> doneAt = const Value.absent(),
    int? priority,
    Value<int?> color = const Value.absent(),
    bool? colorCustom,
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    String? sortKey,
    Value<String?> delayedFromVersionId = const Value.absent(),
    int? delayCount,
  }) => Feature(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    versionId: versionId ?? this.versionId,
    title: title ?? this.title,
    done: done ?? this.done,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
    priority: priority ?? this.priority,
    color: color.present ? color.value : this.color,
    colorCustom: colorCustom ?? this.colorCustom,
    notes: notes.present ? notes.value : this.notes,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    sortKey: sortKey ?? this.sortKey,
    delayedFromVersionId: delayedFromVersionId.present ? delayedFromVersionId.value : this.delayedFromVersionId,
    delayCount: delayCount ?? this.delayCount,
  );
  Feature copyWithCompanion(FeaturesCompanion data) {
    return Feature(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      title: data.title.present ? data.title.value : this.title,
      done: data.done.present ? data.done.value : this.done,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
      priority: data.priority.present ? data.priority.value : this.priority,
      color: data.color.present ? data.color.value : this.color,
      colorCustom: data.colorCustom.present ? data.colorCustom.value : this.colorCustom,
      notes: data.notes.present ? data.notes.value : this.notes,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
      delayedFromVersionId: data.delayedFromVersionId.present
          ? data.delayedFromVersionId.value
          : this.delayedFromVersionId,
      delayCount: data.delayCount.present ? data.delayCount.value : this.delayCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Feature(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('versionId: $versionId, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt, ')
          ..write('priority: $priority, ')
          ..write('color: $color, ')
          ..write('colorCustom: $colorCustom, ')
          ..write('notes: $notes, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('sortKey: $sortKey, ')
          ..write('delayedFromVersionId: $delayedFromVersionId, ')
          ..write('delayCount: $delayCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deleted,
    versionId,
    title,
    done,
    doneAt,
    priority,
    color,
    colorCustom,
    notes,
    startDate,
    endDate,
    sortKey,
    delayedFromVersionId,
    delayCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Feature &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.versionId == this.versionId &&
          other.title == this.title &&
          other.done == this.done &&
          other.doneAt == this.doneAt &&
          other.priority == this.priority &&
          other.color == this.color &&
          other.colorCustom == this.colorCustom &&
          other.notes == this.notes &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.sortKey == this.sortKey &&
          other.delayedFromVersionId == this.delayedFromVersionId &&
          other.delayCount == this.delayCount);
}

class FeaturesCompanion extends UpdateCompanion<Feature> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> versionId;
  final Value<String> title;
  final Value<bool> done;
  final Value<int?> doneAt;
  final Value<int> priority;
  final Value<int?> color;
  final Value<bool> colorCustom;
  final Value<String?> notes;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String> sortKey;
  final Value<String?> delayedFromVersionId;
  final Value<int> delayCount;
  final Value<int> rowid;
  const FeaturesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.versionId = const Value.absent(),
    this.title = const Value.absent(),
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.priority = const Value.absent(),
    this.color = const Value.absent(),
    this.colorCustom = const Value.absent(),
    this.notes = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.delayedFromVersionId = const Value.absent(),
    this.delayCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeaturesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String versionId,
    required String title,
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.priority = const Value.absent(),
    this.color = const Value.absent(),
    this.colorCustom = const Value.absent(),
    this.notes = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    required String sortKey,
    this.delayedFromVersionId = const Value.absent(),
    this.delayCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionId = Value(versionId),
       title = Value(title),
       sortKey = Value(sortKey);
  static Insertable<Feature> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? versionId,
    Expression<String>? title,
    Expression<bool>? done,
    Expression<int>? doneAt,
    Expression<int>? priority,
    Expression<int>? color,
    Expression<bool>? colorCustom,
    Expression<String>? notes,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? sortKey,
    Expression<String>? delayedFromVersionId,
    Expression<int>? delayCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (versionId != null) 'version_id': versionId,
      if (title != null) 'title': title,
      if (done != null) 'done': done,
      if (doneAt != null) 'done_at': doneAt,
      if (priority != null) 'priority': priority,
      if (color != null) 'color': color,
      if (colorCustom != null) 'color_custom': colorCustom,
      if (notes != null) 'notes': notes,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (sortKey != null) 'sort_key': sortKey,
      if (delayedFromVersionId != null) 'delayed_from_version_id': delayedFromVersionId,
      if (delayCount != null) 'delay_count': delayCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeaturesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? versionId,
    Value<String>? title,
    Value<bool>? done,
    Value<int?>? doneAt,
    Value<int>? priority,
    Value<int?>? color,
    Value<bool>? colorCustom,
    Value<String?>? notes,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<String>? sortKey,
    Value<String?>? delayedFromVersionId,
    Value<int>? delayCount,
    Value<int>? rowid,
  }) {
    return FeaturesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      versionId: versionId ?? this.versionId,
      title: title ?? this.title,
      done: done ?? this.done,
      doneAt: doneAt ?? this.doneAt,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      colorCustom: colorCustom ?? this.colorCustom,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sortKey: sortKey ?? this.sortKey,
      delayedFromVersionId: delayedFromVersionId ?? this.delayedFromVersionId,
      delayCount: delayCount ?? this.delayCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<int>(doneAt.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (colorCustom.present) {
      map['color_custom'] = Variable<bool>(colorCustom.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<String>(sortKey.value);
    }
    if (delayedFromVersionId.present) {
      map['delayed_from_version_id'] = Variable<String>(delayedFromVersionId.value);
    }
    if (delayCount.present) {
      map['delay_count'] = Variable<int>(delayCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeaturesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('versionId: $versionId, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt, ')
          ..write('priority: $priority, ')
          ..write('color: $color, ')
          ..write('colorCustom: $colorCustom, ')
          ..write('notes: $notes, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('sortKey: $sortKey, ')
          ..write('delayedFromVersionId: $delayedFromVersionId, ')
          ..write('delayCount: $delayCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubitemsTable extends Subitems with TableInfo<$SubitemsTable, Subitem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubitemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _featureIdMeta = const VerificationMeta('featureId');
  @override
  late final GeneratedColumn<String> featureId = GeneratedColumn<String>(
    'feature_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("done" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta('sortKey');
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, updatedAt, deleted, featureId, parentId, title, done, sortKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subitems';
  @override
  VerificationContext validateIntegrity(Insertable<Subitem> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('feature_id')) {
      context.handle(_featureIdMeta, featureId.isAcceptableOrUnknown(data['feature_id']!, _featureIdMeta));
    } else if (isInserting) {
      context.missing(_featureIdMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta, parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('done')) {
      context.handle(_doneMeta, done.isAcceptableOrUnknown(data['done']!, _doneMeta));
    }
    if (data.containsKey('sort_key')) {
      context.handle(_sortKeyMeta, sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta));
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subitem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subitem(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      featureId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}feature_id'])!,
      parentId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      done: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}done'])!,
      sortKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sort_key'])!,
    );
  }

  @override
  $SubitemsTable createAlias(String alias) {
    return $SubitemsTable(attachedDatabase, alias);
  }
}

class Subitem extends DataClass implements Insertable<Subitem> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final bool deleted;
  final String featureId;

  /// Parent step for nested steps (null = top level of the feature).
  final String? parentId;
  final String title;
  final bool done;
  final String sortKey;
  const Subitem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.featureId,
    this.parentId,
    required this.title,
    required this.done,
    required this.sortKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['feature_id'] = Variable<String>(featureId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['title'] = Variable<String>(title);
    map['done'] = Variable<bool>(done);
    map['sort_key'] = Variable<String>(sortKey);
    return map;
  }

  SubitemsCompanion toCompanion(bool nullToAbsent) {
    return SubitemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      featureId: Value(featureId),
      parentId: parentId == null && nullToAbsent ? const Value.absent() : Value(parentId),
      title: Value(title),
      done: Value(done),
      sortKey: Value(sortKey),
    );
  }

  factory Subitem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subitem(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      featureId: serializer.fromJson<String>(json['featureId']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      title: serializer.fromJson<String>(json['title']),
      done: serializer.fromJson<bool>(json['done']),
      sortKey: serializer.fromJson<String>(json['sortKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'featureId': serializer.toJson<String>(featureId),
      'parentId': serializer.toJson<String?>(parentId),
      'title': serializer.toJson<String>(title),
      'done': serializer.toJson<bool>(done),
      'sortKey': serializer.toJson<String>(sortKey),
    };
  }

  Subitem copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? deleted,
    String? featureId,
    Value<String?> parentId = const Value.absent(),
    String? title,
    bool? done,
    String? sortKey,
  }) => Subitem(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    featureId: featureId ?? this.featureId,
    parentId: parentId.present ? parentId.value : this.parentId,
    title: title ?? this.title,
    done: done ?? this.done,
    sortKey: sortKey ?? this.sortKey,
  );
  Subitem copyWithCompanion(SubitemsCompanion data) {
    return Subitem(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      featureId: data.featureId.present ? data.featureId.value : this.featureId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      title: data.title.present ? data.title.value : this.title,
      done: data.done.present ? data.done.value : this.done,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subitem(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('featureId: $featureId, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('sortKey: $sortKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, deleted, featureId, parentId, title, done, sortKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subitem &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.featureId == this.featureId &&
          other.parentId == this.parentId &&
          other.title == this.title &&
          other.done == this.done &&
          other.sortKey == this.sortKey);
}

class SubitemsCompanion extends UpdateCompanion<Subitem> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> featureId;
  final Value<String?> parentId;
  final Value<String> title;
  final Value<bool> done;
  final Value<String> sortKey;
  final Value<int> rowid;
  const SubitemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.featureId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.title = const Value.absent(),
    this.done = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubitemsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String featureId,
    this.parentId = const Value.absent(),
    required String title,
    this.done = const Value.absent(),
    required String sortKey,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       featureId = Value(featureId),
       title = Value(title),
       sortKey = Value(sortKey);
  static Insertable<Subitem> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? featureId,
    Expression<String>? parentId,
    Expression<String>? title,
    Expression<bool>? done,
    Expression<String>? sortKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (featureId != null) 'feature_id': featureId,
      if (parentId != null) 'parent_id': parentId,
      if (title != null) 'title': title,
      if (done != null) 'done': done,
      if (sortKey != null) 'sort_key': sortKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubitemsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? featureId,
    Value<String?>? parentId,
    Value<String>? title,
    Value<bool>? done,
    Value<String>? sortKey,
    Value<int>? rowid,
  }) {
    return SubitemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      featureId: featureId ?? this.featureId,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      done: done ?? this.done,
      sortKey: sortKey ?? this.sortKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (featureId.present) {
      map['feature_id'] = Variable<String>(featureId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<String>(sortKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubitemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('featureId: $featureId, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('sortKey: $sortKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MilestonesTable extends Milestones with TableInfo<$MilestonesTable, Milestone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilestonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorCustomMeta = const VerificationMeta('colorCustom');
  @override
  late final GeneratedColumn<bool> colorCustom = GeneratedColumn<bool>(
    'color_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("color_custom" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    projectId,
    title,
    date,
    kind,
    color,
    colorCustom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milestones';
  @override
  VerificationContext validateIntegrity(Insertable<Milestone> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta, projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    }
    if (data.containsKey('color')) {
      context.handle(_colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('color_custom')) {
      context.handle(_colorCustomMeta, colorCustom.isAcceptableOrUnknown(data['color_custom']!, _colorCustomMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Milestone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Milestone(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      projectId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      color: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color']),
      colorCustom: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}color_custom'])!,
    );
  }

  @override
  $MilestonesTable createAlias(String alias) {
    return $MilestonesTable(attachedDatabase, alias);
  }
}

class Milestone extends DataClass implements Insertable<Milestone> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final bool deleted;
  final String projectId;
  final String title;
  final DateTime date;
  final String kind;
  final int? color;
  final bool colorCustom;
  const Milestone({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.projectId,
    required this.title,
    required this.date,
    required this.kind,
    this.color,
    required this.colorCustom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['project_id'] = Variable<String>(projectId);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['color_custom'] = Variable<bool>(colorCustom);
    return map;
  }

  MilestonesCompanion toCompanion(bool nullToAbsent) {
    return MilestonesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      projectId: Value(projectId),
      title: Value(title),
      date: Value(date),
      kind: Value(kind),
      color: color == null && nullToAbsent ? const Value.absent() : Value(color),
      colorCustom: Value(colorCustom),
    );
  }

  factory Milestone.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Milestone(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      projectId: serializer.fromJson<String>(json['projectId']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      kind: serializer.fromJson<String>(json['kind']),
      color: serializer.fromJson<int?>(json['color']),
      colorCustom: serializer.fromJson<bool>(json['colorCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'projectId': serializer.toJson<String>(projectId),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'kind': serializer.toJson<String>(kind),
      'color': serializer.toJson<int?>(color),
      'colorCustom': serializer.toJson<bool>(colorCustom),
    };
  }

  Milestone copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? deleted,
    String? projectId,
    String? title,
    DateTime? date,
    String? kind,
    Value<int?> color = const Value.absent(),
    bool? colorCustom,
  }) => Milestone(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    projectId: projectId ?? this.projectId,
    title: title ?? this.title,
    date: date ?? this.date,
    kind: kind ?? this.kind,
    color: color.present ? color.value : this.color,
    colorCustom: colorCustom ?? this.colorCustom,
  );
  Milestone copyWithCompanion(MilestonesCompanion data) {
    return Milestone(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      kind: data.kind.present ? data.kind.value : this.kind,
      color: data.color.present ? data.color.value : this.color,
      colorCustom: data.colorCustom.present ? data.colorCustom.value : this.colorCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Milestone(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('color: $color, ')
          ..write('colorCustom: $colorCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, deleted, projectId, title, date, kind, color, colorCustom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Milestone &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.projectId == this.projectId &&
          other.title == this.title &&
          other.date == this.date &&
          other.kind == this.kind &&
          other.color == this.color &&
          other.colorCustom == this.colorCustom);
}

class MilestonesCompanion extends UpdateCompanion<Milestone> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> projectId;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<String> kind;
  final Value<int?> color;
  final Value<bool> colorCustom;
  final Value<int> rowid;
  const MilestonesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.kind = const Value.absent(),
    this.color = const Value.absent(),
    this.colorCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MilestonesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String projectId,
    required String title,
    required DateTime date,
    this.kind = const Value.absent(),
    this.color = const Value.absent(),
    this.colorCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       projectId = Value(projectId),
       title = Value(title),
       date = Value(date);
  static Insertable<Milestone> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? projectId,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<String>? kind,
    Expression<int>? color,
    Expression<bool>? colorCustom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (projectId != null) 'project_id': projectId,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (kind != null) 'kind': kind,
      if (color != null) 'color': color,
      if (colorCustom != null) 'color_custom': colorCustom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MilestonesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? projectId,
    Value<String>? title,
    Value<DateTime>? date,
    Value<String>? kind,
    Value<int?>? color,
    Value<bool>? colorCustom,
    Value<int>? rowid,
  }) {
    return MilestonesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      date: date ?? this.date,
      kind: kind ?? this.kind,
      color: color ?? this.color,
      colorCustom: colorCustom ?? this.colorCustom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (colorCustom.present) {
      map['color_custom'] = Variable<bool>(colorCustom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilestonesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('color: $color, ')
          ..write('colorCustom: $colorCustom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorCustomMeta = const VerificationMeta('colorCustom');
  @override
  late final GeneratedColumn<bool> colorCustom = GeneratedColumn<bool>(
    'color_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("color_custom" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta('sortKey');
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    projectId,
    name,
    color,
    colorCustom,
    sortKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta, projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(_colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('color_custom')) {
      context.handle(_colorCustomMeta, colorCustom.isAcceptableOrUnknown(data['color_custom']!, _colorCustomMeta));
    }
    if (data.containsKey('sort_key')) {
      context.handle(_sortKeyMeta, sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta));
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      projectId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      colorCustom: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}color_custom'])!,
      sortKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sort_key'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final bool deleted;
  final String projectId;
  final String name;
  final int color;
  final bool colorCustom;
  final String sortKey;
  const Tag({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.projectId,
    required this.name,
    required this.color,
    required this.colorCustom,
    required this.sortKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['project_id'] = Variable<String>(projectId);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['color_custom'] = Variable<bool>(colorCustom);
    map['sort_key'] = Variable<String>(sortKey);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      projectId: Value(projectId),
      name: Value(name),
      color: Value(color),
      colorCustom: Value(colorCustom),
      sortKey: Value(sortKey),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      projectId: serializer.fromJson<String>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      colorCustom: serializer.fromJson<bool>(json['colorCustom']),
      sortKey: serializer.fromJson<String>(json['sortKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'projectId': serializer.toJson<String>(projectId),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'colorCustom': serializer.toJson<bool>(colorCustom),
      'sortKey': serializer.toJson<String>(sortKey),
    };
  }

  Tag copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? deleted,
    String? projectId,
    String? name,
    int? color,
    bool? colorCustom,
    String? sortKey,
  }) => Tag(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    projectId: projectId ?? this.projectId,
    name: name ?? this.name,
    color: color ?? this.color,
    colorCustom: colorCustom ?? this.colorCustom,
    sortKey: sortKey ?? this.sortKey,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      colorCustom: data.colorCustom.present ? data.colorCustom.value : this.colorCustom,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('colorCustom: $colorCustom, ')
          ..write('sortKey: $sortKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, deleted, projectId, name, color, colorCustom, sortKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.color == this.color &&
          other.colorCustom == this.colorCustom &&
          other.sortKey == this.sortKey);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> projectId;
  final Value<String> name;
  final Value<int> color;
  final Value<bool> colorCustom;
  final Value<String> sortKey;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.colorCustom = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String projectId,
    required String name,
    this.color = const Value.absent(),
    this.colorCustom = const Value.absent(),
    required String sortKey,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       projectId = Value(projectId),
       name = Value(name),
       sortKey = Value(sortKey);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? projectId,
    Expression<String>? name,
    Expression<int>? color,
    Expression<bool>? colorCustom,
    Expression<String>? sortKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (colorCustom != null) 'color_custom': colorCustom,
      if (sortKey != null) 'sort_key': sortKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? projectId,
    Value<String>? name,
    Value<int>? color,
    Value<bool>? colorCustom,
    Value<String>? sortKey,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      color: color ?? this.color,
      colorCustom: colorCustom ?? this.colorCustom,
      sortKey: sortKey ?? this.sortKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (colorCustom.present) {
      map['color_custom'] = Variable<bool>(colorCustom.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<String>(sortKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('colorCustom: $colorCustom, ')
          ..write('sortKey: $sortKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeatureTagsTable extends FeatureTags with TableInfo<$FeatureTagsTable, FeatureTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeatureTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _featureIdMeta = const VerificationMeta('featureId');
  @override
  late final GeneratedColumn<String> featureId = GeneratedColumn<String>(
    'feature_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, updatedAt, deleted, featureId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feature_tags';
  @override
  VerificationContext validateIntegrity(Insertable<FeatureTag> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('feature_id')) {
      context.handle(_featureIdMeta, featureId.isAcceptableOrUnknown(data['feature_id']!, _featureIdMeta));
    } else if (isInserting) {
      context.missing(_featureIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(_tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeatureTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeatureTag(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      featureId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}feature_id'])!,
      tagId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $FeatureTagsTable createAlias(String alias) {
    return $FeatureTagsTable(attachedDatabase, alias);
  }
}

class FeatureTag extends DataClass implements Insertable<FeatureTag> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final bool deleted;
  final String featureId;
  final String tagId;
  const FeatureTag({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.featureId,
    required this.tagId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['feature_id'] = Variable<String>(featureId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  FeatureTagsCompanion toCompanion(bool nullToAbsent) {
    return FeatureTagsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      featureId: Value(featureId),
      tagId: Value(tagId),
    );
  }

  factory FeatureTag.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeatureTag(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      featureId: serializer.fromJson<String>(json['featureId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'featureId': serializer.toJson<String>(featureId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  FeatureTag copyWith({String? id, int? createdAt, int? updatedAt, bool? deleted, String? featureId, String? tagId}) =>
      FeatureTag(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
        featureId: featureId ?? this.featureId,
        tagId: tagId ?? this.tagId,
      );
  FeatureTag copyWithCompanion(FeatureTagsCompanion data) {
    return FeatureTag(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      featureId: data.featureId.present ? data.featureId.value : this.featureId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeatureTag(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('featureId: $featureId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, deleted, featureId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeatureTag &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.featureId == this.featureId &&
          other.tagId == this.tagId);
}

class FeatureTagsCompanion extends UpdateCompanion<FeatureTag> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> featureId;
  final Value<String> tagId;
  final Value<int> rowid;
  const FeatureTagsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.featureId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeatureTagsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String featureId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       featureId = Value(featureId),
       tagId = Value(tagId);
  static Insertable<FeatureTag> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? featureId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (featureId != null) 'feature_id': featureId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeatureTagsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? featureId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return FeatureTagsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      featureId: featureId ?? this.featureId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (featureId.present) {
      map['feature_id'] = Variable<String>(featureId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeatureTagsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('featureId: $featureId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _featureIdMeta = const VerificationMeta('featureId');
  @override
  late final GeneratedColumn<String> featureId = GeneratedColumn<String>(
    'feature_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta('originalName');
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta('sortKey');
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deleted,
    featureId,
    fileName,
    originalName,
    width,
    height,
    sortKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(Insertable<Attachment> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('feature_id')) {
      context.handle(_featureIdMeta, featureId.isAcceptableOrUnknown(data['feature_id']!, _featureIdMeta));
    } else if (isInserting) {
      context.missing(_featureIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta, fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(_originalNameMeta, originalName.isAcceptableOrUnknown(data['original_name']!, _originalNameMeta));
    } else if (isInserting) {
      context.missing(_originalNameMeta);
    }
    if (data.containsKey('width')) {
      context.handle(_widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta, height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('sort_key')) {
      context.handle(_sortKeyMeta, sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta));
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      featureId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}feature_id'])!,
      fileName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      originalName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}original_name'])!,
      width: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}width'])!,
      height: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}height'])!,
      sortKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sort_key'])!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final bool deleted;
  final String featureId;
  final String fileName;
  final String originalName;
  final int width;
  final int height;
  final String sortKey;
  const Attachment({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.featureId,
    required this.fileName,
    required this.originalName,
    required this.width,
    required this.height,
    required this.sortKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['feature_id'] = Variable<String>(featureId);
    map['file_name'] = Variable<String>(fileName);
    map['original_name'] = Variable<String>(originalName);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['sort_key'] = Variable<String>(sortKey);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      featureId: Value(featureId),
      fileName: Value(fileName),
      originalName: Value(originalName),
      width: Value(width),
      height: Value(height),
      sortKey: Value(sortKey),
    );
  }

  factory Attachment.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      featureId: serializer.fromJson<String>(json['featureId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      originalName: serializer.fromJson<String>(json['originalName']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      sortKey: serializer.fromJson<String>(json['sortKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'featureId': serializer.toJson<String>(featureId),
      'fileName': serializer.toJson<String>(fileName),
      'originalName': serializer.toJson<String>(originalName),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'sortKey': serializer.toJson<String>(sortKey),
    };
  }

  Attachment copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? deleted,
    String? featureId,
    String? fileName,
    String? originalName,
    int? width,
    int? height,
    String? sortKey,
  }) => Attachment(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    featureId: featureId ?? this.featureId,
    fileName: fileName ?? this.fileName,
    originalName: originalName ?? this.originalName,
    width: width ?? this.width,
    height: height ?? this.height,
    sortKey: sortKey ?? this.sortKey,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      featureId: data.featureId.present ? data.featureId.value : this.featureId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      originalName: data.originalName.present ? data.originalName.value : this.originalName,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('featureId: $featureId, ')
          ..write('fileName: $fileName, ')
          ..write('originalName: $originalName, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sortKey: $sortKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deleted, featureId, fileName, originalName, width, height, sortKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.featureId == this.featureId &&
          other.fileName == this.fileName &&
          other.originalName == this.originalName &&
          other.width == this.width &&
          other.height == this.height &&
          other.sortKey == this.sortKey);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> featureId;
  final Value<String> fileName;
  final Value<String> originalName;
  final Value<int> width;
  final Value<int> height;
  final Value<String> sortKey;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.featureId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.originalName = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String featureId,
    required String fileName,
    required String originalName,
    required int width,
    required int height,
    required String sortKey,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       featureId = Value(featureId),
       fileName = Value(fileName),
       originalName = Value(originalName),
       width = Value(width),
       height = Value(height),
       sortKey = Value(sortKey);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? featureId,
    Expression<String>? fileName,
    Expression<String>? originalName,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? sortKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (featureId != null) 'feature_id': featureId,
      if (fileName != null) 'file_name': fileName,
      if (originalName != null) 'original_name': originalName,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (sortKey != null) 'sort_key': sortKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? featureId,
    Value<String>? fileName,
    Value<String>? originalName,
    Value<int>? width,
    Value<int>? height,
    Value<String>? sortKey,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      featureId: featureId ?? this.featureId,
      fileName: fileName ?? this.fileName,
      originalName: originalName ?? this.originalName,
      width: width ?? this.width,
      height: height ?? this.height,
      sortKey: sortKey ?? this.sortKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (featureId.present) {
      map['feature_id'] = Variable<String>(featureId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<String>(sortKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('featureId: $featureId, ')
          ..write('fileName: $fileName, ')
          ..write('originalName: $originalName, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sortKey: $sortKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VersoDb extends GeneratedDatabase {
  _$VersoDb(QueryExecutor e) : super(e);
  $VersoDbManager get managers => $VersoDbManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $EnvironmentsTable environments = $EnvironmentsTable(this);
  late final $VersionsTable versions = $VersionsTable(this);
  late final $FeaturesTable features = $FeaturesTable(this);
  late final $SubitemsTable subitems = $SubitemsTable(this);
  late final $MilestonesTable milestones = $MilestonesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $FeatureTagsTable featureTags = $FeatureTagsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    environments,
    versions,
    features,
    subitems,
    milestones,
    tags,
    featureTags,
    attachments,
  ];
}

typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> deleted,
      required String name,
      Value<int> color,
      Value<bool> colorCustom,
      Value<String?> icon,
      required String sortKey,
      Value<bool> archived,
      Value<bool> paused,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> name,
      Value<int> color,
      Value<bool> colorCustom,
      Value<String?> icon,
      Value<String> sortKey,
      Value<bool> archived,
      Value<bool> paused,
      Value<int> rowid,
    });

class $$ProjectsTableFilterComposer extends Composer<_$VersoDb, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get colorCustom =>
      $composableBuilder(column: $table.colorCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get paused =>
      $composableBuilder(column: $table.paused, builder: (column) => ColumnFilters(column));
}

class $$ProjectsTableOrderingComposer extends Composer<_$VersoDb, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get colorCustom =>
      $composableBuilder(column: $table.colorCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get paused =>
      $composableBuilder(column: $table.paused, builder: (column) => ColumnOrderings(column));
}

class $$ProjectsTableAnnotationComposer extends Composer<_$VersoDb, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted => $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color => $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get colorCustom => $composableBuilder(column: $table.colorCustom, builder: (column) => column);

  GeneratedColumn<String> get icon => $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get sortKey => $composableBuilder(column: $table.sortKey, builder: (column) => column);

  GeneratedColumn<bool> get archived => $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<bool> get paused => $composableBuilder(column: $table.paused, builder: (column) => column);
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$VersoDb,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, BaseReferences<_$VersoDb, $ProjectsTable, Project>),
          Project,
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$VersoDb db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> colorCustom = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String> sortKey = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                color: color,
                colorCustom: colorCustom,
                icon: icon,
                sortKey: sortKey,
                archived: archived,
                paused: paused,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                Value<int> color = const Value.absent(),
                Value<bool> colorCustom = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                required String sortKey,
                Value<bool> archived = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                color: color,
                colorCustom: colorCustom,
                icon: icon,
                sortKey: sortKey,
                archived: archived,
                paused: paused,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectsTable, Project>(table),
                  BaseReferences<_$VersoDb, $ProjectsTable, Project>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$VersoDb,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, BaseReferences<_$VersoDb, $ProjectsTable, Project>),
      Project,
      PrefetchHooks Function()
    >;
typedef $$EnvironmentsTableCreateCompanionBuilder =
    EnvironmentsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> deleted,
      required String name,
      Value<String> icon,
      Value<int> color,
      Value<bool> colorCustom,
      required String sortKey,
      Value<int> rowid,
    });
typedef $$EnvironmentsTableUpdateCompanionBuilder =
    EnvironmentsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> name,
      Value<String> icon,
      Value<int> color,
      Value<bool> colorCustom,
      Value<String> sortKey,
      Value<int> rowid,
    });

class $$EnvironmentsTableFilterComposer extends Composer<_$VersoDb, $EnvironmentsTable> {
  $$EnvironmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get colorCustom =>
      $composableBuilder(column: $table.colorCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnFilters(column));
}

class $$EnvironmentsTableOrderingComposer extends Composer<_$VersoDb, $EnvironmentsTable> {
  $$EnvironmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get colorCustom =>
      $composableBuilder(column: $table.colorCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnOrderings(column));
}

class $$EnvironmentsTableAnnotationComposer extends Composer<_$VersoDb, $EnvironmentsTable> {
  $$EnvironmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted => $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon => $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color => $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get colorCustom => $composableBuilder(column: $table.colorCustom, builder: (column) => column);

  GeneratedColumn<String> get sortKey => $composableBuilder(column: $table.sortKey, builder: (column) => column);
}

class $$EnvironmentsTableTableManager
    extends
        RootTableManager<
          _$VersoDb,
          $EnvironmentsTable,
          Environment,
          $$EnvironmentsTableFilterComposer,
          $$EnvironmentsTableOrderingComposer,
          $$EnvironmentsTableAnnotationComposer,
          $$EnvironmentsTableCreateCompanionBuilder,
          $$EnvironmentsTableUpdateCompanionBuilder,
          (Environment, BaseReferences<_$VersoDb, $EnvironmentsTable, Environment>),
          Environment,
          PrefetchHooks Function()
        > {
  $$EnvironmentsTableTableManager(_$VersoDb db, $EnvironmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$EnvironmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$EnvironmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$EnvironmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> colorCustom = const Value.absent(),
                Value<String> sortKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvironmentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                icon: icon,
                color: color,
                colorCustom: colorCustom,
                sortKey: sortKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> colorCustom = const Value.absent(),
                required String sortKey,
                Value<int> rowid = const Value.absent(),
              }) => EnvironmentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                icon: icon,
                color: color,
                colorCustom: colorCustom,
                sortKey: sortKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EnvironmentsTable, Environment>(table),
                  BaseReferences<_$VersoDb, $EnvironmentsTable, Environment>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnvironmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$VersoDb,
      $EnvironmentsTable,
      Environment,
      $$EnvironmentsTableFilterComposer,
      $$EnvironmentsTableOrderingComposer,
      $$EnvironmentsTableAnnotationComposer,
      $$EnvironmentsTableCreateCompanionBuilder,
      $$EnvironmentsTableUpdateCompanionBuilder,
      (Environment, BaseReferences<_$VersoDb, $EnvironmentsTable, Environment>),
      Environment,
      PrefetchHooks Function()
    >;
typedef $$VersionsTableCreateCompanionBuilder =
    VersionsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> deleted,
      required String projectId,
      Value<String?> environmentId,
      Value<String> kind,
      required String name,
      Value<String> status,
      Value<int> color,
      Value<bool> colorCustom,
      Value<DateTime?> startDate,
      Value<DateTime?> targetDate,
      Value<DateTime?> releasedDate,
      Value<String?> description,
      required String sortKey,
      Value<int> rowid,
    });
typedef $$VersionsTableUpdateCompanionBuilder =
    VersionsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> projectId,
      Value<String?> environmentId,
      Value<String> kind,
      Value<String> name,
      Value<String> status,
      Value<int> color,
      Value<bool> colorCustom,
      Value<DateTime?> startDate,
      Value<DateTime?> targetDate,
      Value<DateTime?> releasedDate,
      Value<String?> description,
      Value<String> sortKey,
      Value<int> rowid,
    });

class $$VersionsTableFilterComposer extends Composer<_$VersoDb, $VersionsTable> {
  $$VersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get environmentId =>
      $composableBuilder(column: $table.environmentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get colorCustom =>
      $composableBuilder(column: $table.colorCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get targetDate =>
      $composableBuilder(column: $table.targetDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get releasedDate =>
      $composableBuilder(column: $table.releasedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnFilters(column));
}

class $$VersionsTableOrderingComposer extends Composer<_$VersoDb, $VersionsTable> {
  $$VersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get environmentId =>
      $composableBuilder(column: $table.environmentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get colorCustom =>
      $composableBuilder(column: $table.colorCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get targetDate =>
      $composableBuilder(column: $table.targetDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get releasedDate =>
      $composableBuilder(column: $table.releasedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnOrderings(column));
}

class $$VersionsTableAnnotationComposer extends Composer<_$VersoDb, $VersionsTable> {
  $$VersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted => $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get projectId => $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get environmentId =>
      $composableBuilder(column: $table.environmentId, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get status => $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get color => $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get colorCustom => $composableBuilder(column: $table.colorCustom, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate => $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate =>
      $composableBuilder(column: $table.targetDate, builder: (column) => column);

  GeneratedColumn<DateTime> get releasedDate =>
      $composableBuilder(column: $table.releasedDate, builder: (column) => column);

  GeneratedColumn<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get sortKey => $composableBuilder(column: $table.sortKey, builder: (column) => column);
}

class $$VersionsTableTableManager
    extends
        RootTableManager<
          _$VersoDb,
          $VersionsTable,
          Version,
          $$VersionsTableFilterComposer,
          $$VersionsTableOrderingComposer,
          $$VersionsTableAnnotationComposer,
          $$VersionsTableCreateCompanionBuilder,
          $$VersionsTableUpdateCompanionBuilder,
          (Version, BaseReferences<_$VersoDb, $VersionsTable, Version>),
          Version,
          PrefetchHooks Function()
        > {
  $$VersionsTableTableManager(_$VersoDb db, $VersionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$VersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$VersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$VersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String?> environmentId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> colorCustom = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<DateTime?> releasedDate = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> sortKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VersionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                projectId: projectId,
                environmentId: environmentId,
                kind: kind,
                name: name,
                status: status,
                color: color,
                colorCustom: colorCustom,
                startDate: startDate,
                targetDate: targetDate,
                releasedDate: releasedDate,
                description: description,
                sortKey: sortKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String projectId,
                Value<String?> environmentId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                required String name,
                Value<String> status = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> colorCustom = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<DateTime?> releasedDate = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required String sortKey,
                Value<int> rowid = const Value.absent(),
              }) => VersionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                projectId: projectId,
                environmentId: environmentId,
                kind: kind,
                name: name,
                status: status,
                color: color,
                colorCustom: colorCustom,
                startDate: startDate,
                targetDate: targetDate,
                releasedDate: releasedDate,
                description: description,
                sortKey: sortKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VersionsTable, Version>(table),
                  BaseReferences<_$VersoDb, $VersionsTable, Version>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$VersoDb,
      $VersionsTable,
      Version,
      $$VersionsTableFilterComposer,
      $$VersionsTableOrderingComposer,
      $$VersionsTableAnnotationComposer,
      $$VersionsTableCreateCompanionBuilder,
      $$VersionsTableUpdateCompanionBuilder,
      (Version, BaseReferences<_$VersoDb, $VersionsTable, Version>),
      Version,
      PrefetchHooks Function()
    >;
typedef $$FeaturesTableCreateCompanionBuilder =
    FeaturesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> deleted,
      required String versionId,
      required String title,
      Value<bool> done,
      Value<int?> doneAt,
      Value<int> priority,
      Value<int?> color,
      Value<bool> colorCustom,
      Value<String?> notes,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      required String sortKey,
      Value<String?> delayedFromVersionId,
      Value<int> delayCount,
      Value<int> rowid,
    });
typedef $$FeaturesTableUpdateCompanionBuilder =
    FeaturesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> versionId,
      Value<String> title,
      Value<bool> done,
      Value<int?> doneAt,
      Value<int> priority,
      Value<int?> color,
      Value<bool> colorCustom,
      Value<String?> notes,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String> sortKey,
      Value<String?> delayedFromVersionId,
      Value<int> delayCount,
      Value<int> rowid,
    });

class $$FeaturesTableFilterComposer extends Composer<_$VersoDb, $FeaturesTable> {
  $$FeaturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get versionId =>
      $composableBuilder(column: $table.versionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get done => $composableBuilder(column: $table.done, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get colorCustom =>
      $composableBuilder(column: $table.colorCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get delayedFromVersionId =>
      $composableBuilder(column: $table.delayedFromVersionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get delayCount =>
      $composableBuilder(column: $table.delayCount, builder: (column) => ColumnFilters(column));
}

class $$FeaturesTableOrderingComposer extends Composer<_$VersoDb, $FeaturesTable> {
  $$FeaturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get versionId =>
      $composableBuilder(column: $table.versionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get colorCustom =>
      $composableBuilder(column: $table.colorCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get delayedFromVersionId =>
      $composableBuilder(column: $table.delayedFromVersionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get delayCount =>
      $composableBuilder(column: $table.delayCount, builder: (column) => ColumnOrderings(column));
}

class $$FeaturesTableAnnotationComposer extends Composer<_$VersoDb, $FeaturesTable> {
  $$FeaturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted => $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get versionId => $composableBuilder(column: $table.versionId, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get done => $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<int> get doneAt => $composableBuilder(column: $table.doneAt, builder: (column) => column);

  GeneratedColumn<int> get priority => $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get color => $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get colorCustom => $composableBuilder(column: $table.colorCustom, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate => $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate => $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get sortKey => $composableBuilder(column: $table.sortKey, builder: (column) => column);

  GeneratedColumn<String> get delayedFromVersionId =>
      $composableBuilder(column: $table.delayedFromVersionId, builder: (column) => column);

  GeneratedColumn<int> get delayCount => $composableBuilder(column: $table.delayCount, builder: (column) => column);
}

class $$FeaturesTableTableManager
    extends
        RootTableManager<
          _$VersoDb,
          $FeaturesTable,
          Feature,
          $$FeaturesTableFilterComposer,
          $$FeaturesTableOrderingComposer,
          $$FeaturesTableAnnotationComposer,
          $$FeaturesTableCreateCompanionBuilder,
          $$FeaturesTableUpdateCompanionBuilder,
          (Feature, BaseReferences<_$VersoDb, $FeaturesTable, Feature>),
          Feature,
          PrefetchHooks Function()
        > {
  $$FeaturesTableTableManager(_$VersoDb db, $FeaturesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FeaturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FeaturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$FeaturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> versionId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int?> doneAt = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<bool> colorCustom = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String> sortKey = const Value.absent(),
                Value<String?> delayedFromVersionId = const Value.absent(),
                Value<int> delayCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeaturesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                versionId: versionId,
                title: title,
                done: done,
                doneAt: doneAt,
                priority: priority,
                color: color,
                colorCustom: colorCustom,
                notes: notes,
                startDate: startDate,
                endDate: endDate,
                sortKey: sortKey,
                delayedFromVersionId: delayedFromVersionId,
                delayCount: delayCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String versionId,
                required String title,
                Value<bool> done = const Value.absent(),
                Value<int?> doneAt = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<bool> colorCustom = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                required String sortKey,
                Value<String?> delayedFromVersionId = const Value.absent(),
                Value<int> delayCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeaturesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                versionId: versionId,
                title: title,
                done: done,
                doneAt: doneAt,
                priority: priority,
                color: color,
                colorCustom: colorCustom,
                notes: notes,
                startDate: startDate,
                endDate: endDate,
                sortKey: sortKey,
                delayedFromVersionId: delayedFromVersionId,
                delayCount: delayCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeaturesTable, Feature>(table),
                  BaseReferences<_$VersoDb, $FeaturesTable, Feature>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeaturesTableProcessedTableManager =
    ProcessedTableManager<
      _$VersoDb,
      $FeaturesTable,
      Feature,
      $$FeaturesTableFilterComposer,
      $$FeaturesTableOrderingComposer,
      $$FeaturesTableAnnotationComposer,
      $$FeaturesTableCreateCompanionBuilder,
      $$FeaturesTableUpdateCompanionBuilder,
      (Feature, BaseReferences<_$VersoDb, $FeaturesTable, Feature>),
      Feature,
      PrefetchHooks Function()
    >;
typedef $$SubitemsTableCreateCompanionBuilder =
    SubitemsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> deleted,
      required String featureId,
      Value<String?> parentId,
      required String title,
      Value<bool> done,
      required String sortKey,
      Value<int> rowid,
    });
typedef $$SubitemsTableUpdateCompanionBuilder =
    SubitemsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> featureId,
      Value<String?> parentId,
      Value<String> title,
      Value<bool> done,
      Value<String> sortKey,
      Value<int> rowid,
    });

class $$SubitemsTableFilterComposer extends Composer<_$VersoDb, $SubitemsTable> {
  $$SubitemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get featureId =>
      $composableBuilder(column: $table.featureId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get done => $composableBuilder(column: $table.done, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnFilters(column));
}

class $$SubitemsTableOrderingComposer extends Composer<_$VersoDb, $SubitemsTable> {
  $$SubitemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get featureId =>
      $composableBuilder(column: $table.featureId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnOrderings(column));
}

class $$SubitemsTableAnnotationComposer extends Composer<_$VersoDb, $SubitemsTable> {
  $$SubitemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted => $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get featureId => $composableBuilder(column: $table.featureId, builder: (column) => column);

  GeneratedColumn<String> get parentId => $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get done => $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<String> get sortKey => $composableBuilder(column: $table.sortKey, builder: (column) => column);
}

class $$SubitemsTableTableManager
    extends
        RootTableManager<
          _$VersoDb,
          $SubitemsTable,
          Subitem,
          $$SubitemsTableFilterComposer,
          $$SubitemsTableOrderingComposer,
          $$SubitemsTableAnnotationComposer,
          $$SubitemsTableCreateCompanionBuilder,
          $$SubitemsTableUpdateCompanionBuilder,
          (Subitem, BaseReferences<_$VersoDb, $SubitemsTable, Subitem>),
          Subitem,
          PrefetchHooks Function()
        > {
  $$SubitemsTableTableManager(_$VersoDb db, $SubitemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SubitemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SubitemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SubitemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> featureId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<String> sortKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubitemsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                featureId: featureId,
                parentId: parentId,
                title: title,
                done: done,
                sortKey: sortKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String featureId,
                Value<String?> parentId = const Value.absent(),
                required String title,
                Value<bool> done = const Value.absent(),
                required String sortKey,
                Value<int> rowid = const Value.absent(),
              }) => SubitemsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                featureId: featureId,
                parentId: parentId,
                title: title,
                done: done,
                sortKey: sortKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubitemsTable, Subitem>(table),
                  BaseReferences<_$VersoDb, $SubitemsTable, Subitem>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubitemsTableProcessedTableManager =
    ProcessedTableManager<
      _$VersoDb,
      $SubitemsTable,
      Subitem,
      $$SubitemsTableFilterComposer,
      $$SubitemsTableOrderingComposer,
      $$SubitemsTableAnnotationComposer,
      $$SubitemsTableCreateCompanionBuilder,
      $$SubitemsTableUpdateCompanionBuilder,
      (Subitem, BaseReferences<_$VersoDb, $SubitemsTable, Subitem>),
      Subitem,
      PrefetchHooks Function()
    >;
typedef $$MilestonesTableCreateCompanionBuilder =
    MilestonesCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> deleted,
      required String projectId,
      required String title,
      required DateTime date,
      Value<String> kind,
      Value<int?> color,
      Value<bool> colorCustom,
      Value<int> rowid,
    });
typedef $$MilestonesTableUpdateCompanionBuilder =
    MilestonesCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> projectId,
      Value<String> title,
      Value<DateTime> date,
      Value<String> kind,
      Value<int?> color,
      Value<bool> colorCustom,
      Value<int> rowid,
    });

class $$MilestonesTableFilterComposer extends Composer<_$VersoDb, $MilestonesTable> {
  $$MilestonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get colorCustom =>
      $composableBuilder(column: $table.colorCustom, builder: (column) => ColumnFilters(column));
}

class $$MilestonesTableOrderingComposer extends Composer<_$VersoDb, $MilestonesTable> {
  $$MilestonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get colorCustom =>
      $composableBuilder(column: $table.colorCustom, builder: (column) => ColumnOrderings(column));
}

class $$MilestonesTableAnnotationComposer extends Composer<_$VersoDb, $MilestonesTable> {
  $$MilestonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted => $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get projectId => $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get color => $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get colorCustom => $composableBuilder(column: $table.colorCustom, builder: (column) => column);
}

class $$MilestonesTableTableManager
    extends
        RootTableManager<
          _$VersoDb,
          $MilestonesTable,
          Milestone,
          $$MilestonesTableFilterComposer,
          $$MilestonesTableOrderingComposer,
          $$MilestonesTableAnnotationComposer,
          $$MilestonesTableCreateCompanionBuilder,
          $$MilestonesTableUpdateCompanionBuilder,
          (Milestone, BaseReferences<_$VersoDb, $MilestonesTable, Milestone>),
          Milestone,
          PrefetchHooks Function()
        > {
  $$MilestonesTableTableManager(_$VersoDb db, $MilestonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MilestonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MilestonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MilestonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<bool> colorCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilestonesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                projectId: projectId,
                title: title,
                date: date,
                kind: kind,
                color: color,
                colorCustom: colorCustom,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String projectId,
                required String title,
                required DateTime date,
                Value<String> kind = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<bool> colorCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilestonesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                projectId: projectId,
                title: title,
                date: date,
                kind: kind,
                color: color,
                colorCustom: colorCustom,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MilestonesTable, Milestone>(table),
                  BaseReferences<_$VersoDb, $MilestonesTable, Milestone>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MilestonesTableProcessedTableManager =
    ProcessedTableManager<
      _$VersoDb,
      $MilestonesTable,
      Milestone,
      $$MilestonesTableFilterComposer,
      $$MilestonesTableOrderingComposer,
      $$MilestonesTableAnnotationComposer,
      $$MilestonesTableCreateCompanionBuilder,
      $$MilestonesTableUpdateCompanionBuilder,
      (Milestone, BaseReferences<_$VersoDb, $MilestonesTable, Milestone>),
      Milestone,
      PrefetchHooks Function()
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> deleted,
      required String projectId,
      required String name,
      Value<int> color,
      Value<bool> colorCustom,
      required String sortKey,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> projectId,
      Value<String> name,
      Value<int> color,
      Value<bool> colorCustom,
      Value<String> sortKey,
      Value<int> rowid,
    });

class $$TagsTableFilterComposer extends Composer<_$VersoDb, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get colorCustom =>
      $composableBuilder(column: $table.colorCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnFilters(column));
}

class $$TagsTableOrderingComposer extends Composer<_$VersoDb, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get colorCustom =>
      $composableBuilder(column: $table.colorCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer extends Composer<_$VersoDb, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted => $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get projectId => $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color => $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get colorCustom => $composableBuilder(column: $table.colorCustom, builder: (column) => column);

  GeneratedColumn<String> get sortKey => $composableBuilder(column: $table.sortKey, builder: (column) => column);
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$VersoDb,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, BaseReferences<_$VersoDb, $TagsTable, Tag>),
          Tag,
          PrefetchHooks Function()
        > {
  $$TagsTableTableManager(_$VersoDb db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> colorCustom = const Value.absent(),
                Value<String> sortKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                projectId: projectId,
                name: name,
                color: color,
                colorCustom: colorCustom,
                sortKey: sortKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String projectId,
                required String name,
                Value<int> color = const Value.absent(),
                Value<bool> colorCustom = const Value.absent(),
                required String sortKey,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                projectId: projectId,
                name: name,
                color: color,
                colorCustom: colorCustom,
                sortKey: sortKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable<$TagsTable, Tag>(table), BaseReferences<_$VersoDb, $TagsTable, Tag>(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$VersoDb,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, BaseReferences<_$VersoDb, $TagsTable, Tag>),
      Tag,
      PrefetchHooks Function()
    >;
typedef $$FeatureTagsTableCreateCompanionBuilder =
    FeatureTagsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> deleted,
      required String featureId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$FeatureTagsTableUpdateCompanionBuilder =
    FeatureTagsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> featureId,
      Value<String> tagId,
      Value<int> rowid,
    });

class $$FeatureTagsTableFilterComposer extends Composer<_$VersoDb, $FeatureTagsTable> {
  $$FeatureTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get featureId =>
      $composableBuilder(column: $table.featureId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => ColumnFilters(column));
}

class $$FeatureTagsTableOrderingComposer extends Composer<_$VersoDb, $FeatureTagsTable> {
  $$FeatureTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get featureId =>
      $composableBuilder(column: $table.featureId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => ColumnOrderings(column));
}

class $$FeatureTagsTableAnnotationComposer extends Composer<_$VersoDb, $FeatureTagsTable> {
  $$FeatureTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted => $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get featureId => $composableBuilder(column: $table.featureId, builder: (column) => column);

  GeneratedColumn<String> get tagId => $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$FeatureTagsTableTableManager
    extends
        RootTableManager<
          _$VersoDb,
          $FeatureTagsTable,
          FeatureTag,
          $$FeatureTagsTableFilterComposer,
          $$FeatureTagsTableOrderingComposer,
          $$FeatureTagsTableAnnotationComposer,
          $$FeatureTagsTableCreateCompanionBuilder,
          $$FeatureTagsTableUpdateCompanionBuilder,
          (FeatureTag, BaseReferences<_$VersoDb, $FeatureTagsTable, FeatureTag>),
          FeatureTag,
          PrefetchHooks Function()
        > {
  $$FeatureTagsTableTableManager(_$VersoDb db, $FeatureTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FeatureTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FeatureTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$FeatureTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> featureId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeatureTagsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                featureId: featureId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String featureId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => FeatureTagsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                featureId: featureId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeatureTagsTable, FeatureTag>(table),
                  BaseReferences<_$VersoDb, $FeatureTagsTable, FeatureTag>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeatureTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$VersoDb,
      $FeatureTagsTable,
      FeatureTag,
      $$FeatureTagsTableFilterComposer,
      $$FeatureTagsTableOrderingComposer,
      $$FeatureTagsTableAnnotationComposer,
      $$FeatureTagsTableCreateCompanionBuilder,
      $$FeatureTagsTableUpdateCompanionBuilder,
      (FeatureTag, BaseReferences<_$VersoDb, $FeatureTagsTable, FeatureTag>),
      FeatureTag,
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<bool> deleted,
      required String featureId,
      required String fileName,
      required String originalName,
      required int width,
      required int height,
      required String sortKey,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> featureId,
      Value<String> fileName,
      Value<String> originalName,
      Value<int> width,
      Value<int> height,
      Value<String> sortKey,
      Value<int> rowid,
    });

class $$AttachmentsTableFilterComposer extends Composer<_$VersoDb, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get featureId =>
      $composableBuilder(column: $table.featureId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalName =>
      $composableBuilder(column: $table.originalName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get width => $composableBuilder(column: $table.width, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnFilters(column));
}

class $$AttachmentsTableOrderingComposer extends Composer<_$VersoDb, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get featureId =>
      $composableBuilder(column: $table.featureId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalName =>
      $composableBuilder(column: $table.originalName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnOrderings(column));
}

class $$AttachmentsTableAnnotationComposer extends Composer<_$VersoDb, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted => $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get featureId => $composableBuilder(column: $table.featureId, builder: (column) => column);

  GeneratedColumn<String> get fileName => $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get originalName =>
      $composableBuilder(column: $table.originalName, builder: (column) => column);

  GeneratedColumn<int> get width => $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height => $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get sortKey => $composableBuilder(column: $table.sortKey, builder: (column) => column);
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$VersoDb,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (Attachment, BaseReferences<_$VersoDb, $AttachmentsTable, Attachment>),
          Attachment,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$VersoDb db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> featureId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<String> sortKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                featureId: featureId,
                fileName: fileName,
                originalName: originalName,
                width: width,
                height: height,
                sortKey: sortKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String featureId,
                required String fileName,
                required String originalName,
                required int width,
                required int height,
                required String sortKey,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deleted: deleted,
                featureId: featureId,
                fileName: fileName,
                originalName: originalName,
                width: width,
                height: height,
                sortKey: sortKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttachmentsTable, Attachment>(table),
                  BaseReferences<_$VersoDb, $AttachmentsTable, Attachment>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$VersoDb,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (Attachment, BaseReferences<_$VersoDb, $AttachmentsTable, Attachment>),
      Attachment,
      PrefetchHooks Function()
    >;

class $VersoDbManager {
  final _$VersoDb _db;
  $VersoDbManager(this._db);
  $$ProjectsTableTableManager get projects => $$ProjectsTableTableManager(_db, _db.projects);
  $$EnvironmentsTableTableManager get environments => $$EnvironmentsTableTableManager(_db, _db.environments);
  $$VersionsTableTableManager get versions => $$VersionsTableTableManager(_db, _db.versions);
  $$FeaturesTableTableManager get features => $$FeaturesTableTableManager(_db, _db.features);
  $$SubitemsTableTableManager get subitems => $$SubitemsTableTableManager(_db, _db.subitems);
  $$MilestonesTableTableManager get milestones => $$MilestonesTableTableManager(_db, _db.milestones);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$FeatureTagsTableTableManager get featureTags => $$FeatureTagsTableTableManager(_db, _db.featureTags);
  $$AttachmentsTableTableManager get attachments => $$AttachmentsTableTableManager(_db, _db.attachments);
}
