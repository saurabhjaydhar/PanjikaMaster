// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class Packs extends Table with TableInfo<Packs, PackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Packs(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _traditionMeta = const VerificationMeta(
    'tradition',
  );
  late final GeneratedColumn<String> tradition = GeneratedColumn<String>(
    'tradition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (kind IN (\'global\', \'cities\', \'observances\'))',
  );
  static const VerificationMeta _isSampleMeta = const VerificationMeta(
    'isSample',
  );
  late final GeneratedColumn<int> isSample = GeneratedColumn<int>(
    'is_sample',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_sample IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _coversFromMeta = const VerificationMeta(
    'coversFrom',
  );
  late final GeneratedColumn<String> coversFrom = GeneratedColumn<String>(
    'covers_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _coversToMeta = const VerificationMeta(
    'coversTo',
  );
  late final GeneratedColumn<String> coversTo = GeneratedColumn<String>(
    'covers_to',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (version >= 1)',
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  late final GeneratedColumn<String> generatedAt = GeneratedColumn<String>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _engineVersionMeta = const VerificationMeta(
    'engineVersion',
  );
  late final GeneratedColumn<String> engineVersion = GeneratedColumn<String>(
    'engine_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _ephemerisSha256Meta = const VerificationMeta(
    'ephemerisSha256',
  );
  late final GeneratedColumn<String> ephemerisSha256 = GeneratedColumn<String>(
    'ephemeris_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _validationSummaryMeta = const VerificationMeta(
    'validationSummary',
  );
  late final GeneratedColumn<String> validationSummary =
      GeneratedColumn<String>(
        'validation_summary',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  late final GeneratedColumn<String> installedAt = GeneratedColumn<String>(
    'installed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tradition,
    kind,
    isSample,
    coversFrom,
    coversTo,
    version,
    generatedAt,
    engineVersion,
    ephemerisSha256,
    validationSummary,
    installedAt,
    sha256,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PackRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tradition')) {
      context.handle(
        _traditionMeta,
        tradition.isAcceptableOrUnknown(data['tradition']!, _traditionMeta),
      );
    } else if (isInserting) {
      context.missing(_traditionMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('is_sample')) {
      context.handle(
        _isSampleMeta,
        isSample.isAcceptableOrUnknown(data['is_sample']!, _isSampleMeta),
      );
    }
    if (data.containsKey('covers_from')) {
      context.handle(
        _coversFromMeta,
        coversFrom.isAcceptableOrUnknown(data['covers_from']!, _coversFromMeta),
      );
    } else if (isInserting) {
      context.missing(_coversFromMeta);
    }
    if (data.containsKey('covers_to')) {
      context.handle(
        _coversToMeta,
        coversTo.isAcceptableOrUnknown(data['covers_to']!, _coversToMeta),
      );
    } else if (isInserting) {
      context.missing(_coversToMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    if (data.containsKey('engine_version')) {
      context.handle(
        _engineVersionMeta,
        engineVersion.isAcceptableOrUnknown(
          data['engine_version']!,
          _engineVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_engineVersionMeta);
    }
    if (data.containsKey('ephemeris_sha256')) {
      context.handle(
        _ephemerisSha256Meta,
        ephemerisSha256.isAcceptableOrUnknown(
          data['ephemeris_sha256']!,
          _ephemerisSha256Meta,
        ),
      );
    }
    if (data.containsKey('validation_summary')) {
      context.handle(
        _validationSummaryMeta,
        validationSummary.isAcceptableOrUnknown(
          data['validation_summary']!,
          _validationSummaryMeta,
        ),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PackRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PackRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tradition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tradition'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      isSample: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_sample'],
      )!,
      coversFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}covers_from'],
      )!,
      coversTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}covers_to'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}generated_at'],
      )!,
      engineVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine_version'],
      )!,
      ephemerisSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ephemeris_sha256'],
      ),
      validationSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}validation_summary'],
      ),
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installed_at'],
      ),
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      ),
    );
  }

  @override
  Packs createAlias(String alias) {
    return Packs(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'CHECK(covers_from <= covers_to)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class PackRow extends DataClass implements Insertable<PackRow> {
  final String id;
  final String tradition;

  /// e.g. 'drik_bishuddha'
  final String kind;
  final int isSample;
  final String coversFrom;
  final String coversTo;
  final int version;
  final String generatedAt;
  final String engineVersion;
  final String? ephemerisSha256;

  /// NULL for sample packs
  final String? validationSummary;
  final String? installedAt;

  /// set by the app's importer; NULL inside a pack file
  final String? sha256;
  const PackRow({
    required this.id,
    required this.tradition,
    required this.kind,
    required this.isSample,
    required this.coversFrom,
    required this.coversTo,
    required this.version,
    required this.generatedAt,
    required this.engineVersion,
    this.ephemerisSha256,
    this.validationSummary,
    this.installedAt,
    this.sha256,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tradition'] = Variable<String>(tradition);
    map['kind'] = Variable<String>(kind);
    map['is_sample'] = Variable<int>(isSample);
    map['covers_from'] = Variable<String>(coversFrom);
    map['covers_to'] = Variable<String>(coversTo);
    map['version'] = Variable<int>(version);
    map['generated_at'] = Variable<String>(generatedAt);
    map['engine_version'] = Variable<String>(engineVersion);
    if (!nullToAbsent || ephemerisSha256 != null) {
      map['ephemeris_sha256'] = Variable<String>(ephemerisSha256);
    }
    if (!nullToAbsent || validationSummary != null) {
      map['validation_summary'] = Variable<String>(validationSummary);
    }
    if (!nullToAbsent || installedAt != null) {
      map['installed_at'] = Variable<String>(installedAt);
    }
    if (!nullToAbsent || sha256 != null) {
      map['sha256'] = Variable<String>(sha256);
    }
    return map;
  }

  PacksCompanion toCompanion(bool nullToAbsent) {
    return PacksCompanion(
      id: Value(id),
      tradition: Value(tradition),
      kind: Value(kind),
      isSample: Value(isSample),
      coversFrom: Value(coversFrom),
      coversTo: Value(coversTo),
      version: Value(version),
      generatedAt: Value(generatedAt),
      engineVersion: Value(engineVersion),
      ephemerisSha256: ephemerisSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(ephemerisSha256),
      validationSummary: validationSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(validationSummary),
      installedAt: installedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(installedAt),
      sha256: sha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256),
    );
  }

  factory PackRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PackRow(
      id: serializer.fromJson<String>(json['id']),
      tradition: serializer.fromJson<String>(json['tradition']),
      kind: serializer.fromJson<String>(json['kind']),
      isSample: serializer.fromJson<int>(json['is_sample']),
      coversFrom: serializer.fromJson<String>(json['covers_from']),
      coversTo: serializer.fromJson<String>(json['covers_to']),
      version: serializer.fromJson<int>(json['version']),
      generatedAt: serializer.fromJson<String>(json['generated_at']),
      engineVersion: serializer.fromJson<String>(json['engine_version']),
      ephemerisSha256: serializer.fromJson<String?>(json['ephemeris_sha256']),
      validationSummary: serializer.fromJson<String?>(
        json['validation_summary'],
      ),
      installedAt: serializer.fromJson<String?>(json['installed_at']),
      sha256: serializer.fromJson<String?>(json['sha256']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tradition': serializer.toJson<String>(tradition),
      'kind': serializer.toJson<String>(kind),
      'is_sample': serializer.toJson<int>(isSample),
      'covers_from': serializer.toJson<String>(coversFrom),
      'covers_to': serializer.toJson<String>(coversTo),
      'version': serializer.toJson<int>(version),
      'generated_at': serializer.toJson<String>(generatedAt),
      'engine_version': serializer.toJson<String>(engineVersion),
      'ephemeris_sha256': serializer.toJson<String?>(ephemerisSha256),
      'validation_summary': serializer.toJson<String?>(validationSummary),
      'installed_at': serializer.toJson<String?>(installedAt),
      'sha256': serializer.toJson<String?>(sha256),
    };
  }

  PackRow copyWith({
    String? id,
    String? tradition,
    String? kind,
    int? isSample,
    String? coversFrom,
    String? coversTo,
    int? version,
    String? generatedAt,
    String? engineVersion,
    Value<String?> ephemerisSha256 = const Value.absent(),
    Value<String?> validationSummary = const Value.absent(),
    Value<String?> installedAt = const Value.absent(),
    Value<String?> sha256 = const Value.absent(),
  }) => PackRow(
    id: id ?? this.id,
    tradition: tradition ?? this.tradition,
    kind: kind ?? this.kind,
    isSample: isSample ?? this.isSample,
    coversFrom: coversFrom ?? this.coversFrom,
    coversTo: coversTo ?? this.coversTo,
    version: version ?? this.version,
    generatedAt: generatedAt ?? this.generatedAt,
    engineVersion: engineVersion ?? this.engineVersion,
    ephemerisSha256: ephemerisSha256.present
        ? ephemerisSha256.value
        : this.ephemerisSha256,
    validationSummary: validationSummary.present
        ? validationSummary.value
        : this.validationSummary,
    installedAt: installedAt.present ? installedAt.value : this.installedAt,
    sha256: sha256.present ? sha256.value : this.sha256,
  );
  PackRow copyWithCompanion(PacksCompanion data) {
    return PackRow(
      id: data.id.present ? data.id.value : this.id,
      tradition: data.tradition.present ? data.tradition.value : this.tradition,
      kind: data.kind.present ? data.kind.value : this.kind,
      isSample: data.isSample.present ? data.isSample.value : this.isSample,
      coversFrom: data.coversFrom.present
          ? data.coversFrom.value
          : this.coversFrom,
      coversTo: data.coversTo.present ? data.coversTo.value : this.coversTo,
      version: data.version.present ? data.version.value : this.version,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      engineVersion: data.engineVersion.present
          ? data.engineVersion.value
          : this.engineVersion,
      ephemerisSha256: data.ephemerisSha256.present
          ? data.ephemerisSha256.value
          : this.ephemerisSha256,
      validationSummary: data.validationSummary.present
          ? data.validationSummary.value
          : this.validationSummary,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PackRow(')
          ..write('id: $id, ')
          ..write('tradition: $tradition, ')
          ..write('kind: $kind, ')
          ..write('isSample: $isSample, ')
          ..write('coversFrom: $coversFrom, ')
          ..write('coversTo: $coversTo, ')
          ..write('version: $version, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('engineVersion: $engineVersion, ')
          ..write('ephemerisSha256: $ephemerisSha256, ')
          ..write('validationSummary: $validationSummary, ')
          ..write('installedAt: $installedAt, ')
          ..write('sha256: $sha256')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tradition,
    kind,
    isSample,
    coversFrom,
    coversTo,
    version,
    generatedAt,
    engineVersion,
    ephemerisSha256,
    validationSummary,
    installedAt,
    sha256,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackRow &&
          other.id == this.id &&
          other.tradition == this.tradition &&
          other.kind == this.kind &&
          other.isSample == this.isSample &&
          other.coversFrom == this.coversFrom &&
          other.coversTo == this.coversTo &&
          other.version == this.version &&
          other.generatedAt == this.generatedAt &&
          other.engineVersion == this.engineVersion &&
          other.ephemerisSha256 == this.ephemerisSha256 &&
          other.validationSummary == this.validationSummary &&
          other.installedAt == this.installedAt &&
          other.sha256 == this.sha256);
}

class PacksCompanion extends UpdateCompanion<PackRow> {
  final Value<String> id;
  final Value<String> tradition;
  final Value<String> kind;
  final Value<int> isSample;
  final Value<String> coversFrom;
  final Value<String> coversTo;
  final Value<int> version;
  final Value<String> generatedAt;
  final Value<String> engineVersion;
  final Value<String?> ephemerisSha256;
  final Value<String?> validationSummary;
  final Value<String?> installedAt;
  final Value<String?> sha256;
  final Value<int> rowid;
  const PacksCompanion({
    this.id = const Value.absent(),
    this.tradition = const Value.absent(),
    this.kind = const Value.absent(),
    this.isSample = const Value.absent(),
    this.coversFrom = const Value.absent(),
    this.coversTo = const Value.absent(),
    this.version = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.engineVersion = const Value.absent(),
    this.ephemerisSha256 = const Value.absent(),
    this.validationSummary = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PacksCompanion.insert({
    required String id,
    required String tradition,
    required String kind,
    this.isSample = const Value.absent(),
    required String coversFrom,
    required String coversTo,
    required int version,
    required String generatedAt,
    required String engineVersion,
    this.ephemerisSha256 = const Value.absent(),
    this.validationSummary = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tradition = Value(tradition),
       kind = Value(kind),
       coversFrom = Value(coversFrom),
       coversTo = Value(coversTo),
       version = Value(version),
       generatedAt = Value(generatedAt),
       engineVersion = Value(engineVersion);
  static Insertable<PackRow> custom({
    Expression<String>? id,
    Expression<String>? tradition,
    Expression<String>? kind,
    Expression<int>? isSample,
    Expression<String>? coversFrom,
    Expression<String>? coversTo,
    Expression<int>? version,
    Expression<String>? generatedAt,
    Expression<String>? engineVersion,
    Expression<String>? ephemerisSha256,
    Expression<String>? validationSummary,
    Expression<String>? installedAt,
    Expression<String>? sha256,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tradition != null) 'tradition': tradition,
      if (kind != null) 'kind': kind,
      if (isSample != null) 'is_sample': isSample,
      if (coversFrom != null) 'covers_from': coversFrom,
      if (coversTo != null) 'covers_to': coversTo,
      if (version != null) 'version': version,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (engineVersion != null) 'engine_version': engineVersion,
      if (ephemerisSha256 != null) 'ephemeris_sha256': ephemerisSha256,
      if (validationSummary != null) 'validation_summary': validationSummary,
      if (installedAt != null) 'installed_at': installedAt,
      if (sha256 != null) 'sha256': sha256,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PacksCompanion copyWith({
    Value<String>? id,
    Value<String>? tradition,
    Value<String>? kind,
    Value<int>? isSample,
    Value<String>? coversFrom,
    Value<String>? coversTo,
    Value<int>? version,
    Value<String>? generatedAt,
    Value<String>? engineVersion,
    Value<String?>? ephemerisSha256,
    Value<String?>? validationSummary,
    Value<String?>? installedAt,
    Value<String?>? sha256,
    Value<int>? rowid,
  }) {
    return PacksCompanion(
      id: id ?? this.id,
      tradition: tradition ?? this.tradition,
      kind: kind ?? this.kind,
      isSample: isSample ?? this.isSample,
      coversFrom: coversFrom ?? this.coversFrom,
      coversTo: coversTo ?? this.coversTo,
      version: version ?? this.version,
      generatedAt: generatedAt ?? this.generatedAt,
      engineVersion: engineVersion ?? this.engineVersion,
      ephemerisSha256: ephemerisSha256 ?? this.ephemerisSha256,
      validationSummary: validationSummary ?? this.validationSummary,
      installedAt: installedAt ?? this.installedAt,
      sha256: sha256 ?? this.sha256,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tradition.present) {
      map['tradition'] = Variable<String>(tradition.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (isSample.present) {
      map['is_sample'] = Variable<int>(isSample.value);
    }
    if (coversFrom.present) {
      map['covers_from'] = Variable<String>(coversFrom.value);
    }
    if (coversTo.present) {
      map['covers_to'] = Variable<String>(coversTo.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<String>(generatedAt.value);
    }
    if (engineVersion.present) {
      map['engine_version'] = Variable<String>(engineVersion.value);
    }
    if (ephemerisSha256.present) {
      map['ephemeris_sha256'] = Variable<String>(ephemerisSha256.value);
    }
    if (validationSummary.present) {
      map['validation_summary'] = Variable<String>(validationSummary.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<String>(installedAt.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PacksCompanion(')
          ..write('id: $id, ')
          ..write('tradition: $tradition, ')
          ..write('kind: $kind, ')
          ..write('isSample: $isSample, ')
          ..write('coversFrom: $coversFrom, ')
          ..write('coversTo: $coversTo, ')
          ..write('version: $version, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('engineVersion: $engineVersion, ')
          ..write('ephemerisSha256: $ephemerisSha256, ')
          ..write('validationSummary: $validationSummary, ')
          ..write('installedAt: $installedAt, ')
          ..write('sha256: $sha256, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Transitions extends Table with TableInfo<Transitions, TransitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Transitions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES packs(id)',
  );
  static const VerificationMeta _traditionMeta = const VerificationMeta(
    'tradition',
  );
  late final GeneratedColumn<String> tradition = GeneratedColumn<String>(
    'tradition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (kind IN (\'tithi\', \'nakshatra\', \'yoga\', \'karana\', \'sankranti\'))',
  );
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
    'idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _startsUtcMeta = const VerificationMeta(
    'startsUtc',
  );
  late final GeneratedColumn<int> startsUtc = GeneratedColumn<int>(
    'starts_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _endsUtcMeta = const VerificationMeta(
    'endsUtc',
  );
  late final GeneratedColumn<int> endsUtc = GeneratedColumn<int>(
    'ends_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packId,
    tradition,
    kind,
    idx,
    startsUtc,
    endsUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('tradition')) {
      context.handle(
        _traditionMeta,
        tradition.isAcceptableOrUnknown(data['tradition']!, _traditionMeta),
      );
    } else if (isInserting) {
      context.missing(_traditionMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('idx')) {
      context.handle(
        _idxMeta,
        idx.isAcceptableOrUnknown(data['idx']!, _idxMeta),
      );
    } else if (isInserting) {
      context.missing(_idxMeta);
    }
    if (data.containsKey('starts_utc')) {
      context.handle(
        _startsUtcMeta,
        startsUtc.isAcceptableOrUnknown(data['starts_utc']!, _startsUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_startsUtcMeta);
    }
    if (data.containsKey('ends_utc')) {
      context.handle(
        _endsUtcMeta,
        endsUtc.isAcceptableOrUnknown(data['ends_utc']!, _endsUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_endsUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransitionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransitionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
      tradition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tradition'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      idx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}idx'],
      )!,
      startsUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}starts_utc'],
      )!,
      endsUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ends_utc'],
      )!,
    );
  }

  @override
  Transitions createAlias(String alias) {
    return Transitions(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'CHECK(starts_utc < ends_utc)',
    'CHECK(idx >= 0 AND idx <= CASE kind WHEN \'tithi\' THEN 29 WHEN \'nakshatra\' THEN 26 WHEN \'yoga\' THEN 26 WHEN \'karana\' THEN 59 WHEN \'sankranti\' THEN 11 END)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class TransitionRow extends DataClass implements Insertable<TransitionRow> {
  final int id;
  final String packId;
  final String tradition;
  final String kind;
  final int idx;
  final int startsUtc;
  final int endsUtc;
  const TransitionRow({
    required this.id,
    required this.packId,
    required this.tradition,
    required this.kind,
    required this.idx,
    required this.startsUtc,
    required this.endsUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pack_id'] = Variable<String>(packId);
    map['tradition'] = Variable<String>(tradition);
    map['kind'] = Variable<String>(kind);
    map['idx'] = Variable<int>(idx);
    map['starts_utc'] = Variable<int>(startsUtc);
    map['ends_utc'] = Variable<int>(endsUtc);
    return map;
  }

  TransitionsCompanion toCompanion(bool nullToAbsent) {
    return TransitionsCompanion(
      id: Value(id),
      packId: Value(packId),
      tradition: Value(tradition),
      kind: Value(kind),
      idx: Value(idx),
      startsUtc: Value(startsUtc),
      endsUtc: Value(endsUtc),
    );
  }

  factory TransitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransitionRow(
      id: serializer.fromJson<int>(json['id']),
      packId: serializer.fromJson<String>(json['pack_id']),
      tradition: serializer.fromJson<String>(json['tradition']),
      kind: serializer.fromJson<String>(json['kind']),
      idx: serializer.fromJson<int>(json['idx']),
      startsUtc: serializer.fromJson<int>(json['starts_utc']),
      endsUtc: serializer.fromJson<int>(json['ends_utc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pack_id': serializer.toJson<String>(packId),
      'tradition': serializer.toJson<String>(tradition),
      'kind': serializer.toJson<String>(kind),
      'idx': serializer.toJson<int>(idx),
      'starts_utc': serializer.toJson<int>(startsUtc),
      'ends_utc': serializer.toJson<int>(endsUtc),
    };
  }

  TransitionRow copyWith({
    int? id,
    String? packId,
    String? tradition,
    String? kind,
    int? idx,
    int? startsUtc,
    int? endsUtc,
  }) => TransitionRow(
    id: id ?? this.id,
    packId: packId ?? this.packId,
    tradition: tradition ?? this.tradition,
    kind: kind ?? this.kind,
    idx: idx ?? this.idx,
    startsUtc: startsUtc ?? this.startsUtc,
    endsUtc: endsUtc ?? this.endsUtc,
  );
  TransitionRow copyWithCompanion(TransitionsCompanion data) {
    return TransitionRow(
      id: data.id.present ? data.id.value : this.id,
      packId: data.packId.present ? data.packId.value : this.packId,
      tradition: data.tradition.present ? data.tradition.value : this.tradition,
      kind: data.kind.present ? data.kind.value : this.kind,
      idx: data.idx.present ? data.idx.value : this.idx,
      startsUtc: data.startsUtc.present ? data.startsUtc.value : this.startsUtc,
      endsUtc: data.endsUtc.present ? data.endsUtc.value : this.endsUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransitionRow(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('tradition: $tradition, ')
          ..write('kind: $kind, ')
          ..write('idx: $idx, ')
          ..write('startsUtc: $startsUtc, ')
          ..write('endsUtc: $endsUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, packId, tradition, kind, idx, startsUtc, endsUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransitionRow &&
          other.id == this.id &&
          other.packId == this.packId &&
          other.tradition == this.tradition &&
          other.kind == this.kind &&
          other.idx == this.idx &&
          other.startsUtc == this.startsUtc &&
          other.endsUtc == this.endsUtc);
}

class TransitionsCompanion extends UpdateCompanion<TransitionRow> {
  final Value<int> id;
  final Value<String> packId;
  final Value<String> tradition;
  final Value<String> kind;
  final Value<int> idx;
  final Value<int> startsUtc;
  final Value<int> endsUtc;
  const TransitionsCompanion({
    this.id = const Value.absent(),
    this.packId = const Value.absent(),
    this.tradition = const Value.absent(),
    this.kind = const Value.absent(),
    this.idx = const Value.absent(),
    this.startsUtc = const Value.absent(),
    this.endsUtc = const Value.absent(),
  });
  TransitionsCompanion.insert({
    this.id = const Value.absent(),
    required String packId,
    required String tradition,
    required String kind,
    required int idx,
    required int startsUtc,
    required int endsUtc,
  }) : packId = Value(packId),
       tradition = Value(tradition),
       kind = Value(kind),
       idx = Value(idx),
       startsUtc = Value(startsUtc),
       endsUtc = Value(endsUtc);
  static Insertable<TransitionRow> custom({
    Expression<int>? id,
    Expression<String>? packId,
    Expression<String>? tradition,
    Expression<String>? kind,
    Expression<int>? idx,
    Expression<int>? startsUtc,
    Expression<int>? endsUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packId != null) 'pack_id': packId,
      if (tradition != null) 'tradition': tradition,
      if (kind != null) 'kind': kind,
      if (idx != null) 'idx': idx,
      if (startsUtc != null) 'starts_utc': startsUtc,
      if (endsUtc != null) 'ends_utc': endsUtc,
    });
  }

  TransitionsCompanion copyWith({
    Value<int>? id,
    Value<String>? packId,
    Value<String>? tradition,
    Value<String>? kind,
    Value<int>? idx,
    Value<int>? startsUtc,
    Value<int>? endsUtc,
  }) {
    return TransitionsCompanion(
      id: id ?? this.id,
      packId: packId ?? this.packId,
      tradition: tradition ?? this.tradition,
      kind: kind ?? this.kind,
      idx: idx ?? this.idx,
      startsUtc: startsUtc ?? this.startsUtc,
      endsUtc: endsUtc ?? this.endsUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (tradition.present) {
      map['tradition'] = Variable<String>(tradition.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (startsUtc.present) {
      map['starts_utc'] = Variable<int>(startsUtc.value);
    }
    if (endsUtc.present) {
      map['ends_utc'] = Variable<int>(endsUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransitionsCompanion(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('tradition: $tradition, ')
          ..write('kind: $kind, ')
          ..write('idx: $idx, ')
          ..write('startsUtc: $startsUtc, ')
          ..write('endsUtc: $endsUtc')
          ..write(')'))
        .toString();
  }
}

class Cities extends Table with TableInfo<Cities, CityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Cities(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _nameBnMeta = const VerificationMeta('nameBn');
  late final GeneratedColumn<String> nameBn = GeneratedColumn<String>(
    'name_bn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(name_bn) > 0)',
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(name_en) > 0)',
  );
  static const VerificationMeta _aliasesMeta = const VerificationMeta(
    'aliases',
  );
  late final GeneratedColumn<String> aliases = GeneratedColumn<String>(
    'aliases',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _districtBnMeta = const VerificationMeta(
    'districtBn',
  );
  late final GeneratedColumn<String> districtBn = GeneratedColumn<String>(
    'district_bn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _districtEnMeta = const VerificationMeta(
    'districtEn',
  );
  late final GeneratedColumn<String> districtEn = GeneratedColumn<String>(
    'district_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (lat BETWEEN -90 AND 90)',
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (lon BETWEEN -180 AND 180)',
  );
  static const VerificationMeta _elevationMMeta = const VerificationMeta(
    'elevationM',
  );
  late final GeneratedColumn<int> elevationM = GeneratedColumn<int>(
    'elevation_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _tzMeta = const VerificationMeta('tz');
  late final GeneratedColumn<String> tz = GeneratedColumn<String>(
    'tz',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _popularMeta = const VerificationMeta(
    'popular',
  );
  late final GeneratedColumn<int> popular = GeneratedColumn<int>(
    'popular',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (popular IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES packs(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameBn,
    nameEn,
    aliases,
    districtBn,
    districtEn,
    state,
    lat,
    lon,
    elevationM,
    tz,
    popular,
    packId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cities';
  @override
  VerificationContext validateIntegrity(
    Insertable<CityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_bn')) {
      context.handle(
        _nameBnMeta,
        nameBn.isAcceptableOrUnknown(data['name_bn']!, _nameBnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameBnMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('aliases')) {
      context.handle(
        _aliasesMeta,
        aliases.isAcceptableOrUnknown(data['aliases']!, _aliasesMeta),
      );
    }
    if (data.containsKey('district_bn')) {
      context.handle(
        _districtBnMeta,
        districtBn.isAcceptableOrUnknown(data['district_bn']!, _districtBnMeta),
      );
    } else if (isInserting) {
      context.missing(_districtBnMeta);
    }
    if (data.containsKey('district_en')) {
      context.handle(
        _districtEnMeta,
        districtEn.isAcceptableOrUnknown(data['district_en']!, _districtEnMeta),
      );
    } else if (isInserting) {
      context.missing(_districtEnMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('elevation_m')) {
      context.handle(
        _elevationMMeta,
        elevationM.isAcceptableOrUnknown(data['elevation_m']!, _elevationMMeta),
      );
    }
    if (data.containsKey('tz')) {
      context.handle(_tzMeta, tz.isAcceptableOrUnknown(data['tz']!, _tzMeta));
    } else if (isInserting) {
      context.missing(_tzMeta);
    }
    if (data.containsKey('popular')) {
      context.handle(
        _popularMeta,
        popular.isAcceptableOrUnknown(data['popular']!, _popularMeta),
      );
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nameBn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_bn'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      aliases: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aliases'],
      )!,
      districtBn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district_bn'],
      )!,
      districtEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district_en'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      )!,
      elevationM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elevation_m'],
      )!,
      tz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tz'],
      )!,
      popular: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}popular'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
    );
  }

  @override
  Cities createAlias(String alias) {
    return Cities(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class CityRow extends DataClass implements Insertable<CityRow> {
  final String id;
  final String nameBn;
  final String nameEn;
  final String aliases;

  /// both scripts + romanisations, '|' separated
  final String districtBn;
  final String districtEn;
  final String state;
  final double lat;
  final double lon;
  final int elevationM;
  final String tz;
  final int popular;
  final String packId;
  const CityRow({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.aliases,
    required this.districtBn,
    required this.districtEn,
    required this.state,
    required this.lat,
    required this.lon,
    required this.elevationM,
    required this.tz,
    required this.popular,
    required this.packId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name_bn'] = Variable<String>(nameBn);
    map['name_en'] = Variable<String>(nameEn);
    map['aliases'] = Variable<String>(aliases);
    map['district_bn'] = Variable<String>(districtBn);
    map['district_en'] = Variable<String>(districtEn);
    map['state'] = Variable<String>(state);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['elevation_m'] = Variable<int>(elevationM);
    map['tz'] = Variable<String>(tz);
    map['popular'] = Variable<int>(popular);
    map['pack_id'] = Variable<String>(packId);
    return map;
  }

  CitiesCompanion toCompanion(bool nullToAbsent) {
    return CitiesCompanion(
      id: Value(id),
      nameBn: Value(nameBn),
      nameEn: Value(nameEn),
      aliases: Value(aliases),
      districtBn: Value(districtBn),
      districtEn: Value(districtEn),
      state: Value(state),
      lat: Value(lat),
      lon: Value(lon),
      elevationM: Value(elevationM),
      tz: Value(tz),
      popular: Value(popular),
      packId: Value(packId),
    );
  }

  factory CityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CityRow(
      id: serializer.fromJson<String>(json['id']),
      nameBn: serializer.fromJson<String>(json['name_bn']),
      nameEn: serializer.fromJson<String>(json['name_en']),
      aliases: serializer.fromJson<String>(json['aliases']),
      districtBn: serializer.fromJson<String>(json['district_bn']),
      districtEn: serializer.fromJson<String>(json['district_en']),
      state: serializer.fromJson<String>(json['state']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      elevationM: serializer.fromJson<int>(json['elevation_m']),
      tz: serializer.fromJson<String>(json['tz']),
      popular: serializer.fromJson<int>(json['popular']),
      packId: serializer.fromJson<String>(json['pack_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name_bn': serializer.toJson<String>(nameBn),
      'name_en': serializer.toJson<String>(nameEn),
      'aliases': serializer.toJson<String>(aliases),
      'district_bn': serializer.toJson<String>(districtBn),
      'district_en': serializer.toJson<String>(districtEn),
      'state': serializer.toJson<String>(state),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'elevation_m': serializer.toJson<int>(elevationM),
      'tz': serializer.toJson<String>(tz),
      'popular': serializer.toJson<int>(popular),
      'pack_id': serializer.toJson<String>(packId),
    };
  }

  CityRow copyWith({
    String? id,
    String? nameBn,
    String? nameEn,
    String? aliases,
    String? districtBn,
    String? districtEn,
    String? state,
    double? lat,
    double? lon,
    int? elevationM,
    String? tz,
    int? popular,
    String? packId,
  }) => CityRow(
    id: id ?? this.id,
    nameBn: nameBn ?? this.nameBn,
    nameEn: nameEn ?? this.nameEn,
    aliases: aliases ?? this.aliases,
    districtBn: districtBn ?? this.districtBn,
    districtEn: districtEn ?? this.districtEn,
    state: state ?? this.state,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    elevationM: elevationM ?? this.elevationM,
    tz: tz ?? this.tz,
    popular: popular ?? this.popular,
    packId: packId ?? this.packId,
  );
  CityRow copyWithCompanion(CitiesCompanion data) {
    return CityRow(
      id: data.id.present ? data.id.value : this.id,
      nameBn: data.nameBn.present ? data.nameBn.value : this.nameBn,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
      districtBn: data.districtBn.present
          ? data.districtBn.value
          : this.districtBn,
      districtEn: data.districtEn.present
          ? data.districtEn.value
          : this.districtEn,
      state: data.state.present ? data.state.value : this.state,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      elevationM: data.elevationM.present
          ? data.elevationM.value
          : this.elevationM,
      tz: data.tz.present ? data.tz.value : this.tz,
      popular: data.popular.present ? data.popular.value : this.popular,
      packId: data.packId.present ? data.packId.value : this.packId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CityRow(')
          ..write('id: $id, ')
          ..write('nameBn: $nameBn, ')
          ..write('nameEn: $nameEn, ')
          ..write('aliases: $aliases, ')
          ..write('districtBn: $districtBn, ')
          ..write('districtEn: $districtEn, ')
          ..write('state: $state, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('elevationM: $elevationM, ')
          ..write('tz: $tz, ')
          ..write('popular: $popular, ')
          ..write('packId: $packId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nameBn,
    nameEn,
    aliases,
    districtBn,
    districtEn,
    state,
    lat,
    lon,
    elevationM,
    tz,
    popular,
    packId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CityRow &&
          other.id == this.id &&
          other.nameBn == this.nameBn &&
          other.nameEn == this.nameEn &&
          other.aliases == this.aliases &&
          other.districtBn == this.districtBn &&
          other.districtEn == this.districtEn &&
          other.state == this.state &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.elevationM == this.elevationM &&
          other.tz == this.tz &&
          other.popular == this.popular &&
          other.packId == this.packId);
}

class CitiesCompanion extends UpdateCompanion<CityRow> {
  final Value<String> id;
  final Value<String> nameBn;
  final Value<String> nameEn;
  final Value<String> aliases;
  final Value<String> districtBn;
  final Value<String> districtEn;
  final Value<String> state;
  final Value<double> lat;
  final Value<double> lon;
  final Value<int> elevationM;
  final Value<String> tz;
  final Value<int> popular;
  final Value<String> packId;
  final Value<int> rowid;
  const CitiesCompanion({
    this.id = const Value.absent(),
    this.nameBn = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.aliases = const Value.absent(),
    this.districtBn = const Value.absent(),
    this.districtEn = const Value.absent(),
    this.state = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.elevationM = const Value.absent(),
    this.tz = const Value.absent(),
    this.popular = const Value.absent(),
    this.packId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CitiesCompanion.insert({
    required String id,
    required String nameBn,
    required String nameEn,
    this.aliases = const Value.absent(),
    required String districtBn,
    required String districtEn,
    required String state,
    required double lat,
    required double lon,
    this.elevationM = const Value.absent(),
    required String tz,
    this.popular = const Value.absent(),
    required String packId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nameBn = Value(nameBn),
       nameEn = Value(nameEn),
       districtBn = Value(districtBn),
       districtEn = Value(districtEn),
       state = Value(state),
       lat = Value(lat),
       lon = Value(lon),
       tz = Value(tz),
       packId = Value(packId);
  static Insertable<CityRow> custom({
    Expression<String>? id,
    Expression<String>? nameBn,
    Expression<String>? nameEn,
    Expression<String>? aliases,
    Expression<String>? districtBn,
    Expression<String>? districtEn,
    Expression<String>? state,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<int>? elevationM,
    Expression<String>? tz,
    Expression<int>? popular,
    Expression<String>? packId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameBn != null) 'name_bn': nameBn,
      if (nameEn != null) 'name_en': nameEn,
      if (aliases != null) 'aliases': aliases,
      if (districtBn != null) 'district_bn': districtBn,
      if (districtEn != null) 'district_en': districtEn,
      if (state != null) 'state': state,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (elevationM != null) 'elevation_m': elevationM,
      if (tz != null) 'tz': tz,
      if (popular != null) 'popular': popular,
      if (packId != null) 'pack_id': packId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? nameBn,
    Value<String>? nameEn,
    Value<String>? aliases,
    Value<String>? districtBn,
    Value<String>? districtEn,
    Value<String>? state,
    Value<double>? lat,
    Value<double>? lon,
    Value<int>? elevationM,
    Value<String>? tz,
    Value<int>? popular,
    Value<String>? packId,
    Value<int>? rowid,
  }) {
    return CitiesCompanion(
      id: id ?? this.id,
      nameBn: nameBn ?? this.nameBn,
      nameEn: nameEn ?? this.nameEn,
      aliases: aliases ?? this.aliases,
      districtBn: districtBn ?? this.districtBn,
      districtEn: districtEn ?? this.districtEn,
      state: state ?? this.state,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      elevationM: elevationM ?? this.elevationM,
      tz: tz ?? this.tz,
      popular: popular ?? this.popular,
      packId: packId ?? this.packId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nameBn.present) {
      map['name_bn'] = Variable<String>(nameBn.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(aliases.value);
    }
    if (districtBn.present) {
      map['district_bn'] = Variable<String>(districtBn.value);
    }
    if (districtEn.present) {
      map['district_en'] = Variable<String>(districtEn.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (elevationM.present) {
      map['elevation_m'] = Variable<int>(elevationM.value);
    }
    if (tz.present) {
      map['tz'] = Variable<String>(tz.value);
    }
    if (popular.present) {
      map['popular'] = Variable<int>(popular.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CitiesCompanion(')
          ..write('id: $id, ')
          ..write('nameBn: $nameBn, ')
          ..write('nameEn: $nameEn, ')
          ..write('aliases: $aliases, ')
          ..write('districtBn: $districtBn, ')
          ..write('districtEn: $districtEn, ')
          ..write('state: $state, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('elevationM: $elevationM, ')
          ..write('tz: $tz, ')
          ..write('popular: $popular, ')
          ..write('packId: $packId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class CityDays extends Table with TableInfo<CityDays, CityDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CityDays(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cityIdMeta = const VerificationMeta('cityId');
  late final GeneratedColumn<String> cityId = GeneratedColumn<String>(
    'city_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES cities(id)',
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sunriseUtcMeta = const VerificationMeta(
    'sunriseUtc',
  );
  late final GeneratedColumn<int> sunriseUtc = GeneratedColumn<int>(
    'sunrise_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sunsetUtcMeta = const VerificationMeta(
    'sunsetUtc',
  );
  late final GeneratedColumn<int> sunsetUtc = GeneratedColumn<int>(
    'sunset_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _moonriseUtcMeta = const VerificationMeta(
    'moonriseUtc',
  );
  late final GeneratedColumn<int> moonriseUtc = GeneratedColumn<int>(
    'moonrise_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _moonsetUtcMeta = const VerificationMeta(
    'moonsetUtc',
  );
  late final GeneratedColumn<int> moonsetUtc = GeneratedColumn<int>(
    'moonset_utc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES packs(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    cityId,
    date,
    sunriseUtc,
    sunsetUtc,
    moonriseUtc,
    moonsetUtc,
    packId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'city_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<CityDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_id')) {
      context.handle(
        _cityIdMeta,
        cityId.isAcceptableOrUnknown(data['city_id']!, _cityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cityIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('sunrise_utc')) {
      context.handle(
        _sunriseUtcMeta,
        sunriseUtc.isAcceptableOrUnknown(data['sunrise_utc']!, _sunriseUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_sunriseUtcMeta);
    }
    if (data.containsKey('sunset_utc')) {
      context.handle(
        _sunsetUtcMeta,
        sunsetUtc.isAcceptableOrUnknown(data['sunset_utc']!, _sunsetUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_sunsetUtcMeta);
    }
    if (data.containsKey('moonrise_utc')) {
      context.handle(
        _moonriseUtcMeta,
        moonriseUtc.isAcceptableOrUnknown(
          data['moonrise_utc']!,
          _moonriseUtcMeta,
        ),
      );
    }
    if (data.containsKey('moonset_utc')) {
      context.handle(
        _moonsetUtcMeta,
        moonsetUtc.isAcceptableOrUnknown(data['moonset_utc']!, _moonsetUtcMeta),
      );
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cityId, date};
  @override
  CityDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CityDayRow(
      cityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      sunriseUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sunrise_utc'],
      )!,
      sunsetUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sunset_utc'],
      )!,
      moonriseUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}moonrise_utc'],
      ),
      moonsetUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}moonset_utc'],
      ),
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
    );
  }

  @override
  CityDays createAlias(String alias) {
    return CityDays(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(city_id, date)',
    'CHECK(sunrise_utc < sunset_utc)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class CityDayRow extends DataClass implements Insertable<CityDayRow> {
  final String cityId;
  final String date;
  final int sunriseUtc;
  final int sunsetUtc;
  final int? moonriseUtc;

  /// NULL = no moonrise that day
  final int? moonsetUtc;
  final String packId;
  const CityDayRow({
    required this.cityId,
    required this.date,
    required this.sunriseUtc,
    required this.sunsetUtc,
    this.moonriseUtc,
    this.moonsetUtc,
    required this.packId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_id'] = Variable<String>(cityId);
    map['date'] = Variable<String>(date);
    map['sunrise_utc'] = Variable<int>(sunriseUtc);
    map['sunset_utc'] = Variable<int>(sunsetUtc);
    if (!nullToAbsent || moonriseUtc != null) {
      map['moonrise_utc'] = Variable<int>(moonriseUtc);
    }
    if (!nullToAbsent || moonsetUtc != null) {
      map['moonset_utc'] = Variable<int>(moonsetUtc);
    }
    map['pack_id'] = Variable<String>(packId);
    return map;
  }

  CityDaysCompanion toCompanion(bool nullToAbsent) {
    return CityDaysCompanion(
      cityId: Value(cityId),
      date: Value(date),
      sunriseUtc: Value(sunriseUtc),
      sunsetUtc: Value(sunsetUtc),
      moonriseUtc: moonriseUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(moonriseUtc),
      moonsetUtc: moonsetUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(moonsetUtc),
      packId: Value(packId),
    );
  }

  factory CityDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CityDayRow(
      cityId: serializer.fromJson<String>(json['city_id']),
      date: serializer.fromJson<String>(json['date']),
      sunriseUtc: serializer.fromJson<int>(json['sunrise_utc']),
      sunsetUtc: serializer.fromJson<int>(json['sunset_utc']),
      moonriseUtc: serializer.fromJson<int?>(json['moonrise_utc']),
      moonsetUtc: serializer.fromJson<int?>(json['moonset_utc']),
      packId: serializer.fromJson<String>(json['pack_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'city_id': serializer.toJson<String>(cityId),
      'date': serializer.toJson<String>(date),
      'sunrise_utc': serializer.toJson<int>(sunriseUtc),
      'sunset_utc': serializer.toJson<int>(sunsetUtc),
      'moonrise_utc': serializer.toJson<int?>(moonriseUtc),
      'moonset_utc': serializer.toJson<int?>(moonsetUtc),
      'pack_id': serializer.toJson<String>(packId),
    };
  }

  CityDayRow copyWith({
    String? cityId,
    String? date,
    int? sunriseUtc,
    int? sunsetUtc,
    Value<int?> moonriseUtc = const Value.absent(),
    Value<int?> moonsetUtc = const Value.absent(),
    String? packId,
  }) => CityDayRow(
    cityId: cityId ?? this.cityId,
    date: date ?? this.date,
    sunriseUtc: sunriseUtc ?? this.sunriseUtc,
    sunsetUtc: sunsetUtc ?? this.sunsetUtc,
    moonriseUtc: moonriseUtc.present ? moonriseUtc.value : this.moonriseUtc,
    moonsetUtc: moonsetUtc.present ? moonsetUtc.value : this.moonsetUtc,
    packId: packId ?? this.packId,
  );
  CityDayRow copyWithCompanion(CityDaysCompanion data) {
    return CityDayRow(
      cityId: data.cityId.present ? data.cityId.value : this.cityId,
      date: data.date.present ? data.date.value : this.date,
      sunriseUtc: data.sunriseUtc.present
          ? data.sunriseUtc.value
          : this.sunriseUtc,
      sunsetUtc: data.sunsetUtc.present ? data.sunsetUtc.value : this.sunsetUtc,
      moonriseUtc: data.moonriseUtc.present
          ? data.moonriseUtc.value
          : this.moonriseUtc,
      moonsetUtc: data.moonsetUtc.present
          ? data.moonsetUtc.value
          : this.moonsetUtc,
      packId: data.packId.present ? data.packId.value : this.packId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CityDayRow(')
          ..write('cityId: $cityId, ')
          ..write('date: $date, ')
          ..write('sunriseUtc: $sunriseUtc, ')
          ..write('sunsetUtc: $sunsetUtc, ')
          ..write('moonriseUtc: $moonriseUtc, ')
          ..write('moonsetUtc: $moonsetUtc, ')
          ..write('packId: $packId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    cityId,
    date,
    sunriseUtc,
    sunsetUtc,
    moonriseUtc,
    moonsetUtc,
    packId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CityDayRow &&
          other.cityId == this.cityId &&
          other.date == this.date &&
          other.sunriseUtc == this.sunriseUtc &&
          other.sunsetUtc == this.sunsetUtc &&
          other.moonriseUtc == this.moonriseUtc &&
          other.moonsetUtc == this.moonsetUtc &&
          other.packId == this.packId);
}

class CityDaysCompanion extends UpdateCompanion<CityDayRow> {
  final Value<String> cityId;
  final Value<String> date;
  final Value<int> sunriseUtc;
  final Value<int> sunsetUtc;
  final Value<int?> moonriseUtc;
  final Value<int?> moonsetUtc;
  final Value<String> packId;
  final Value<int> rowid;
  const CityDaysCompanion({
    this.cityId = const Value.absent(),
    this.date = const Value.absent(),
    this.sunriseUtc = const Value.absent(),
    this.sunsetUtc = const Value.absent(),
    this.moonriseUtc = const Value.absent(),
    this.moonsetUtc = const Value.absent(),
    this.packId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CityDaysCompanion.insert({
    required String cityId,
    required String date,
    required int sunriseUtc,
    required int sunsetUtc,
    this.moonriseUtc = const Value.absent(),
    this.moonsetUtc = const Value.absent(),
    required String packId,
    this.rowid = const Value.absent(),
  }) : cityId = Value(cityId),
       date = Value(date),
       sunriseUtc = Value(sunriseUtc),
       sunsetUtc = Value(sunsetUtc),
       packId = Value(packId);
  static Insertable<CityDayRow> custom({
    Expression<String>? cityId,
    Expression<String>? date,
    Expression<int>? sunriseUtc,
    Expression<int>? sunsetUtc,
    Expression<int>? moonriseUtc,
    Expression<int>? moonsetUtc,
    Expression<String>? packId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cityId != null) 'city_id': cityId,
      if (date != null) 'date': date,
      if (sunriseUtc != null) 'sunrise_utc': sunriseUtc,
      if (sunsetUtc != null) 'sunset_utc': sunsetUtc,
      if (moonriseUtc != null) 'moonrise_utc': moonriseUtc,
      if (moonsetUtc != null) 'moonset_utc': moonsetUtc,
      if (packId != null) 'pack_id': packId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CityDaysCompanion copyWith({
    Value<String>? cityId,
    Value<String>? date,
    Value<int>? sunriseUtc,
    Value<int>? sunsetUtc,
    Value<int?>? moonriseUtc,
    Value<int?>? moonsetUtc,
    Value<String>? packId,
    Value<int>? rowid,
  }) {
    return CityDaysCompanion(
      cityId: cityId ?? this.cityId,
      date: date ?? this.date,
      sunriseUtc: sunriseUtc ?? this.sunriseUtc,
      sunsetUtc: sunsetUtc ?? this.sunsetUtc,
      moonriseUtc: moonriseUtc ?? this.moonriseUtc,
      moonsetUtc: moonsetUtc ?? this.moonsetUtc,
      packId: packId ?? this.packId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cityId.present) {
      map['city_id'] = Variable<String>(cityId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (sunriseUtc.present) {
      map['sunrise_utc'] = Variable<int>(sunriseUtc.value);
    }
    if (sunsetUtc.present) {
      map['sunset_utc'] = Variable<int>(sunsetUtc.value);
    }
    if (moonriseUtc.present) {
      map['moonrise_utc'] = Variable<int>(moonriseUtc.value);
    }
    if (moonsetUtc.present) {
      map['moonset_utc'] = Variable<int>(moonsetUtc.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CityDaysCompanion(')
          ..write('cityId: $cityId, ')
          ..write('date: $date, ')
          ..write('sunriseUtc: $sunriseUtc, ')
          ..write('sunsetUtc: $sunsetUtc, ')
          ..write('moonriseUtc: $moonriseUtc, ')
          ..write('moonsetUtc: $moonsetUtc, ')
          ..write('packId: $packId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BengaliDates extends Table with TableInfo<BengaliDates, BengaliDateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BengaliDates(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _traditionMeta = const VerificationMeta(
    'tradition',
  );
  late final GeneratedColumn<String> tradition = GeneratedColumn<String>(
    'tradition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _bnDayMeta = const VerificationMeta('bnDay');
  late final GeneratedColumn<int> bnDay = GeneratedColumn<int>(
    'bn_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (bn_day BETWEEN 1 AND 32)',
  );
  static const VerificationMeta _bnMonthIdxMeta = const VerificationMeta(
    'bnMonthIdx',
  );
  late final GeneratedColumn<int> bnMonthIdx = GeneratedColumn<int>(
    'bn_month_idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (bn_month_idx BETWEEN 0 AND 11)',
  );
  static const VerificationMeta _bnYearMeta = const VerificationMeta('bnYear');
  late final GeneratedColumn<int> bnYear = GeneratedColumn<int>(
    'bn_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES packs(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    tradition,
    date,
    bnDay,
    bnMonthIdx,
    bnYear,
    packId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bengali_dates';
  @override
  VerificationContext validateIntegrity(
    Insertable<BengaliDateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tradition')) {
      context.handle(
        _traditionMeta,
        tradition.isAcceptableOrUnknown(data['tradition']!, _traditionMeta),
      );
    } else if (isInserting) {
      context.missing(_traditionMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('bn_day')) {
      context.handle(
        _bnDayMeta,
        bnDay.isAcceptableOrUnknown(data['bn_day']!, _bnDayMeta),
      );
    } else if (isInserting) {
      context.missing(_bnDayMeta);
    }
    if (data.containsKey('bn_month_idx')) {
      context.handle(
        _bnMonthIdxMeta,
        bnMonthIdx.isAcceptableOrUnknown(
          data['bn_month_idx']!,
          _bnMonthIdxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bnMonthIdxMeta);
    }
    if (data.containsKey('bn_year')) {
      context.handle(
        _bnYearMeta,
        bnYear.isAcceptableOrUnknown(data['bn_year']!, _bnYearMeta),
      );
    } else if (isInserting) {
      context.missing(_bnYearMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tradition, date};
  @override
  BengaliDateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BengaliDateRow(
      tradition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tradition'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      bnDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bn_day'],
      )!,
      bnMonthIdx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bn_month_idx'],
      )!,
      bnYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bn_year'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
    );
  }

  @override
  BengaliDates createAlias(String alias) {
    return BengaliDates(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const ['PRIMARY KEY(tradition, date)'];
  @override
  bool get dontWriteConstraints => true;
}

class BengaliDateRow extends DataClass implements Insertable<BengaliDateRow> {
  final String tradition;
  final String date;
  final int bnDay;
  final int bnMonthIdx;
  final int bnYear;
  final String packId;
  const BengaliDateRow({
    required this.tradition,
    required this.date,
    required this.bnDay,
    required this.bnMonthIdx,
    required this.bnYear,
    required this.packId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tradition'] = Variable<String>(tradition);
    map['date'] = Variable<String>(date);
    map['bn_day'] = Variable<int>(bnDay);
    map['bn_month_idx'] = Variable<int>(bnMonthIdx);
    map['bn_year'] = Variable<int>(bnYear);
    map['pack_id'] = Variable<String>(packId);
    return map;
  }

  BengaliDatesCompanion toCompanion(bool nullToAbsent) {
    return BengaliDatesCompanion(
      tradition: Value(tradition),
      date: Value(date),
      bnDay: Value(bnDay),
      bnMonthIdx: Value(bnMonthIdx),
      bnYear: Value(bnYear),
      packId: Value(packId),
    );
  }

  factory BengaliDateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BengaliDateRow(
      tradition: serializer.fromJson<String>(json['tradition']),
      date: serializer.fromJson<String>(json['date']),
      bnDay: serializer.fromJson<int>(json['bn_day']),
      bnMonthIdx: serializer.fromJson<int>(json['bn_month_idx']),
      bnYear: serializer.fromJson<int>(json['bn_year']),
      packId: serializer.fromJson<String>(json['pack_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tradition': serializer.toJson<String>(tradition),
      'date': serializer.toJson<String>(date),
      'bn_day': serializer.toJson<int>(bnDay),
      'bn_month_idx': serializer.toJson<int>(bnMonthIdx),
      'bn_year': serializer.toJson<int>(bnYear),
      'pack_id': serializer.toJson<String>(packId),
    };
  }

  BengaliDateRow copyWith({
    String? tradition,
    String? date,
    int? bnDay,
    int? bnMonthIdx,
    int? bnYear,
    String? packId,
  }) => BengaliDateRow(
    tradition: tradition ?? this.tradition,
    date: date ?? this.date,
    bnDay: bnDay ?? this.bnDay,
    bnMonthIdx: bnMonthIdx ?? this.bnMonthIdx,
    bnYear: bnYear ?? this.bnYear,
    packId: packId ?? this.packId,
  );
  BengaliDateRow copyWithCompanion(BengaliDatesCompanion data) {
    return BengaliDateRow(
      tradition: data.tradition.present ? data.tradition.value : this.tradition,
      date: data.date.present ? data.date.value : this.date,
      bnDay: data.bnDay.present ? data.bnDay.value : this.bnDay,
      bnMonthIdx: data.bnMonthIdx.present
          ? data.bnMonthIdx.value
          : this.bnMonthIdx,
      bnYear: data.bnYear.present ? data.bnYear.value : this.bnYear,
      packId: data.packId.present ? data.packId.value : this.packId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BengaliDateRow(')
          ..write('tradition: $tradition, ')
          ..write('date: $date, ')
          ..write('bnDay: $bnDay, ')
          ..write('bnMonthIdx: $bnMonthIdx, ')
          ..write('bnYear: $bnYear, ')
          ..write('packId: $packId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(tradition, date, bnDay, bnMonthIdx, bnYear, packId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BengaliDateRow &&
          other.tradition == this.tradition &&
          other.date == this.date &&
          other.bnDay == this.bnDay &&
          other.bnMonthIdx == this.bnMonthIdx &&
          other.bnYear == this.bnYear &&
          other.packId == this.packId);
}

class BengaliDatesCompanion extends UpdateCompanion<BengaliDateRow> {
  final Value<String> tradition;
  final Value<String> date;
  final Value<int> bnDay;
  final Value<int> bnMonthIdx;
  final Value<int> bnYear;
  final Value<String> packId;
  final Value<int> rowid;
  const BengaliDatesCompanion({
    this.tradition = const Value.absent(),
    this.date = const Value.absent(),
    this.bnDay = const Value.absent(),
    this.bnMonthIdx = const Value.absent(),
    this.bnYear = const Value.absent(),
    this.packId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BengaliDatesCompanion.insert({
    required String tradition,
    required String date,
    required int bnDay,
    required int bnMonthIdx,
    required int bnYear,
    required String packId,
    this.rowid = const Value.absent(),
  }) : tradition = Value(tradition),
       date = Value(date),
       bnDay = Value(bnDay),
       bnMonthIdx = Value(bnMonthIdx),
       bnYear = Value(bnYear),
       packId = Value(packId);
  static Insertable<BengaliDateRow> custom({
    Expression<String>? tradition,
    Expression<String>? date,
    Expression<int>? bnDay,
    Expression<int>? bnMonthIdx,
    Expression<int>? bnYear,
    Expression<String>? packId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tradition != null) 'tradition': tradition,
      if (date != null) 'date': date,
      if (bnDay != null) 'bn_day': bnDay,
      if (bnMonthIdx != null) 'bn_month_idx': bnMonthIdx,
      if (bnYear != null) 'bn_year': bnYear,
      if (packId != null) 'pack_id': packId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BengaliDatesCompanion copyWith({
    Value<String>? tradition,
    Value<String>? date,
    Value<int>? bnDay,
    Value<int>? bnMonthIdx,
    Value<int>? bnYear,
    Value<String>? packId,
    Value<int>? rowid,
  }) {
    return BengaliDatesCompanion(
      tradition: tradition ?? this.tradition,
      date: date ?? this.date,
      bnDay: bnDay ?? this.bnDay,
      bnMonthIdx: bnMonthIdx ?? this.bnMonthIdx,
      bnYear: bnYear ?? this.bnYear,
      packId: packId ?? this.packId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tradition.present) {
      map['tradition'] = Variable<String>(tradition.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (bnDay.present) {
      map['bn_day'] = Variable<int>(bnDay.value);
    }
    if (bnMonthIdx.present) {
      map['bn_month_idx'] = Variable<int>(bnMonthIdx.value);
    }
    if (bnYear.present) {
      map['bn_year'] = Variable<int>(bnYear.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BengaliDatesCompanion(')
          ..write('tradition: $tradition, ')
          ..write('date: $date, ')
          ..write('bnDay: $bnDay, ')
          ..write('bnMonthIdx: $bnMonthIdx, ')
          ..write('bnYear: $bnYear, ')
          ..write('packId: $packId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Names extends Table with TableInfo<Names, NameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Names(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (kind IN (\'tithi\', \'paksha\', \'nakshatra\', \'yoga\', \'karana\', \'solar_month\', \'lunar_month\', \'weekday\', \'gregorian_month\', \'period\', \'tradition\', \'category\', \'term\'))',
  );
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
    'idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (idx >= 0)',
  );
  static const VerificationMeta _nameBnMeta = const VerificationMeta('nameBn');
  late final GeneratedColumn<String> nameBn = GeneratedColumn<String>(
    'name_bn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(name_bn) > 0)',
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(name_en) > 0)',
  );
  static const VerificationMeta _translitMeta = const VerificationMeta(
    'translit',
  );
  late final GeneratedColumn<String> translit = GeneratedColumn<String>(
    'translit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _glossBnMeta = const VerificationMeta(
    'glossBn',
  );
  late final GeneratedColumn<String> glossBn = GeneratedColumn<String>(
    'gloss_bn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _glossEnMeta = const VerificationMeta(
    'glossEn',
  );
  late final GeneratedColumn<String> glossEn = GeneratedColumn<String>(
    'gloss_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES packs(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    kind,
    idx,
    nameBn,
    nameEn,
    translit,
    glossBn,
    glossEn,
    packId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'names';
  @override
  VerificationContext validateIntegrity(
    Insertable<NameRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('idx')) {
      context.handle(
        _idxMeta,
        idx.isAcceptableOrUnknown(data['idx']!, _idxMeta),
      );
    } else if (isInserting) {
      context.missing(_idxMeta);
    }
    if (data.containsKey('name_bn')) {
      context.handle(
        _nameBnMeta,
        nameBn.isAcceptableOrUnknown(data['name_bn']!, _nameBnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameBnMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('translit')) {
      context.handle(
        _translitMeta,
        translit.isAcceptableOrUnknown(data['translit']!, _translitMeta),
      );
    } else if (isInserting) {
      context.missing(_translitMeta);
    }
    if (data.containsKey('gloss_bn')) {
      context.handle(
        _glossBnMeta,
        glossBn.isAcceptableOrUnknown(data['gloss_bn']!, _glossBnMeta),
      );
    }
    if (data.containsKey('gloss_en')) {
      context.handle(
        _glossEnMeta,
        glossEn.isAcceptableOrUnknown(data['gloss_en']!, _glossEnMeta),
      );
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {kind, idx};
  @override
  NameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NameRow(
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      idx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}idx'],
      )!,
      nameBn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_bn'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      translit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translit'],
      )!,
      glossBn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gloss_bn'],
      ),
      glossEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gloss_en'],
      ),
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
    );
  }

  @override
  Names createAlias(String alias) {
    return Names(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(kind, idx)',
    'CHECK((gloss_bn IS NULL)=(gloss_en IS NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class NameRow extends DataClass implements Insertable<NameRow> {
  final String kind;

  /// term = glossary entries (FR-SET-07)
  final int idx;
  final String nameBn;
  final String nameEn;
  final String translit;
  final String? glossBn;
  final String? glossEn;
  final String packId;
  const NameRow({
    required this.kind,
    required this.idx,
    required this.nameBn,
    required this.nameEn,
    required this.translit,
    this.glossBn,
    this.glossEn,
    required this.packId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['kind'] = Variable<String>(kind);
    map['idx'] = Variable<int>(idx);
    map['name_bn'] = Variable<String>(nameBn);
    map['name_en'] = Variable<String>(nameEn);
    map['translit'] = Variable<String>(translit);
    if (!nullToAbsent || glossBn != null) {
      map['gloss_bn'] = Variable<String>(glossBn);
    }
    if (!nullToAbsent || glossEn != null) {
      map['gloss_en'] = Variable<String>(glossEn);
    }
    map['pack_id'] = Variable<String>(packId);
    return map;
  }

  NamesCompanion toCompanion(bool nullToAbsent) {
    return NamesCompanion(
      kind: Value(kind),
      idx: Value(idx),
      nameBn: Value(nameBn),
      nameEn: Value(nameEn),
      translit: Value(translit),
      glossBn: glossBn == null && nullToAbsent
          ? const Value.absent()
          : Value(glossBn),
      glossEn: glossEn == null && nullToAbsent
          ? const Value.absent()
          : Value(glossEn),
      packId: Value(packId),
    );
  }

  factory NameRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NameRow(
      kind: serializer.fromJson<String>(json['kind']),
      idx: serializer.fromJson<int>(json['idx']),
      nameBn: serializer.fromJson<String>(json['name_bn']),
      nameEn: serializer.fromJson<String>(json['name_en']),
      translit: serializer.fromJson<String>(json['translit']),
      glossBn: serializer.fromJson<String?>(json['gloss_bn']),
      glossEn: serializer.fromJson<String?>(json['gloss_en']),
      packId: serializer.fromJson<String>(json['pack_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'kind': serializer.toJson<String>(kind),
      'idx': serializer.toJson<int>(idx),
      'name_bn': serializer.toJson<String>(nameBn),
      'name_en': serializer.toJson<String>(nameEn),
      'translit': serializer.toJson<String>(translit),
      'gloss_bn': serializer.toJson<String?>(glossBn),
      'gloss_en': serializer.toJson<String?>(glossEn),
      'pack_id': serializer.toJson<String>(packId),
    };
  }

  NameRow copyWith({
    String? kind,
    int? idx,
    String? nameBn,
    String? nameEn,
    String? translit,
    Value<String?> glossBn = const Value.absent(),
    Value<String?> glossEn = const Value.absent(),
    String? packId,
  }) => NameRow(
    kind: kind ?? this.kind,
    idx: idx ?? this.idx,
    nameBn: nameBn ?? this.nameBn,
    nameEn: nameEn ?? this.nameEn,
    translit: translit ?? this.translit,
    glossBn: glossBn.present ? glossBn.value : this.glossBn,
    glossEn: glossEn.present ? glossEn.value : this.glossEn,
    packId: packId ?? this.packId,
  );
  NameRow copyWithCompanion(NamesCompanion data) {
    return NameRow(
      kind: data.kind.present ? data.kind.value : this.kind,
      idx: data.idx.present ? data.idx.value : this.idx,
      nameBn: data.nameBn.present ? data.nameBn.value : this.nameBn,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      translit: data.translit.present ? data.translit.value : this.translit,
      glossBn: data.glossBn.present ? data.glossBn.value : this.glossBn,
      glossEn: data.glossEn.present ? data.glossEn.value : this.glossEn,
      packId: data.packId.present ? data.packId.value : this.packId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NameRow(')
          ..write('kind: $kind, ')
          ..write('idx: $idx, ')
          ..write('nameBn: $nameBn, ')
          ..write('nameEn: $nameEn, ')
          ..write('translit: $translit, ')
          ..write('glossBn: $glossBn, ')
          ..write('glossEn: $glossEn, ')
          ..write('packId: $packId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    kind,
    idx,
    nameBn,
    nameEn,
    translit,
    glossBn,
    glossEn,
    packId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NameRow &&
          other.kind == this.kind &&
          other.idx == this.idx &&
          other.nameBn == this.nameBn &&
          other.nameEn == this.nameEn &&
          other.translit == this.translit &&
          other.glossBn == this.glossBn &&
          other.glossEn == this.glossEn &&
          other.packId == this.packId);
}

class NamesCompanion extends UpdateCompanion<NameRow> {
  final Value<String> kind;
  final Value<int> idx;
  final Value<String> nameBn;
  final Value<String> nameEn;
  final Value<String> translit;
  final Value<String?> glossBn;
  final Value<String?> glossEn;
  final Value<String> packId;
  final Value<int> rowid;
  const NamesCompanion({
    this.kind = const Value.absent(),
    this.idx = const Value.absent(),
    this.nameBn = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.translit = const Value.absent(),
    this.glossBn = const Value.absent(),
    this.glossEn = const Value.absent(),
    this.packId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NamesCompanion.insert({
    required String kind,
    required int idx,
    required String nameBn,
    required String nameEn,
    required String translit,
    this.glossBn = const Value.absent(),
    this.glossEn = const Value.absent(),
    required String packId,
    this.rowid = const Value.absent(),
  }) : kind = Value(kind),
       idx = Value(idx),
       nameBn = Value(nameBn),
       nameEn = Value(nameEn),
       translit = Value(translit),
       packId = Value(packId);
  static Insertable<NameRow> custom({
    Expression<String>? kind,
    Expression<int>? idx,
    Expression<String>? nameBn,
    Expression<String>? nameEn,
    Expression<String>? translit,
    Expression<String>? glossBn,
    Expression<String>? glossEn,
    Expression<String>? packId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (kind != null) 'kind': kind,
      if (idx != null) 'idx': idx,
      if (nameBn != null) 'name_bn': nameBn,
      if (nameEn != null) 'name_en': nameEn,
      if (translit != null) 'translit': translit,
      if (glossBn != null) 'gloss_bn': glossBn,
      if (glossEn != null) 'gloss_en': glossEn,
      if (packId != null) 'pack_id': packId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NamesCompanion copyWith({
    Value<String>? kind,
    Value<int>? idx,
    Value<String>? nameBn,
    Value<String>? nameEn,
    Value<String>? translit,
    Value<String?>? glossBn,
    Value<String?>? glossEn,
    Value<String>? packId,
    Value<int>? rowid,
  }) {
    return NamesCompanion(
      kind: kind ?? this.kind,
      idx: idx ?? this.idx,
      nameBn: nameBn ?? this.nameBn,
      nameEn: nameEn ?? this.nameEn,
      translit: translit ?? this.translit,
      glossBn: glossBn ?? this.glossBn,
      glossEn: glossEn ?? this.glossEn,
      packId: packId ?? this.packId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (nameBn.present) {
      map['name_bn'] = Variable<String>(nameBn.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (translit.present) {
      map['translit'] = Variable<String>(translit.value);
    }
    if (glossBn.present) {
      map['gloss_bn'] = Variable<String>(glossBn.value);
    }
    if (glossEn.present) {
      map['gloss_en'] = Variable<String>(glossEn.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NamesCompanion(')
          ..write('kind: $kind, ')
          ..write('idx: $idx, ')
          ..write('nameBn: $nameBn, ')
          ..write('nameEn: $nameEn, ')
          ..write('translit: $translit, ')
          ..write('glossBn: $glossBn, ')
          ..write('glossEn: $glossEn, ')
          ..write('packId: $packId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Observances extends Table with TableInfo<Observances, ObservanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Observances(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _nameBnMeta = const VerificationMeta('nameBn');
  late final GeneratedColumn<String> nameBn = GeneratedColumn<String>(
    'name_bn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(name_bn) > 0)',
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(name_en) > 0)',
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (category IN (\'puja\', \'vrata\', \'tithi\', \'utsav\', \'jayanti\'))',
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  late final GeneratedColumn<int> tier = GeneratedColumn<int>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (tier IN (1, 2, 3))',
  );
  static const VerificationMeta _descriptionBnMeta = const VerificationMeta(
    'descriptionBn',
  );
  late final GeneratedColumn<String> descriptionBn = GeneratedColumn<String>(
    'description_bn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(description_bn) > 0)',
  );
  static const VerificationMeta _descriptionEnMeta = const VerificationMeta(
    'descriptionEn',
  );
  late final GeneratedColumn<String> descriptionEn = GeneratedColumn<String>(
    'description_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(description_en) > 0)',
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES packs(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameBn,
    nameEn,
    category,
    tier,
    descriptionBn,
    descriptionEn,
    packId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observances';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObservanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_bn')) {
      context.handle(
        _nameBnMeta,
        nameBn.isAcceptableOrUnknown(data['name_bn']!, _nameBnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameBnMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('description_bn')) {
      context.handle(
        _descriptionBnMeta,
        descriptionBn.isAcceptableOrUnknown(
          data['description_bn']!,
          _descriptionBnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionBnMeta);
    }
    if (data.containsKey('description_en')) {
      context.handle(
        _descriptionEnMeta,
        descriptionEn.isAcceptableOrUnknown(
          data['description_en']!,
          _descriptionEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionEnMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ObservanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObservanceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nameBn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_bn'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tier'],
      )!,
      descriptionBn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_bn'],
      )!,
      descriptionEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_en'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
    );
  }

  @override
  Observances createAlias(String alias) {
    return Observances(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class ObservanceRow extends DataClass implements Insertable<ObservanceRow> {
  final String id;
  final String nameBn;
  final String nameEn;
  final String category;
  final int tier;
  final String descriptionBn;
  final String descriptionEn;
  final String packId;
  const ObservanceRow({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.category,
    required this.tier,
    required this.descriptionBn,
    required this.descriptionEn,
    required this.packId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name_bn'] = Variable<String>(nameBn);
    map['name_en'] = Variable<String>(nameEn);
    map['category'] = Variable<String>(category);
    map['tier'] = Variable<int>(tier);
    map['description_bn'] = Variable<String>(descriptionBn);
    map['description_en'] = Variable<String>(descriptionEn);
    map['pack_id'] = Variable<String>(packId);
    return map;
  }

  ObservancesCompanion toCompanion(bool nullToAbsent) {
    return ObservancesCompanion(
      id: Value(id),
      nameBn: Value(nameBn),
      nameEn: Value(nameEn),
      category: Value(category),
      tier: Value(tier),
      descriptionBn: Value(descriptionBn),
      descriptionEn: Value(descriptionEn),
      packId: Value(packId),
    );
  }

  factory ObservanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObservanceRow(
      id: serializer.fromJson<String>(json['id']),
      nameBn: serializer.fromJson<String>(json['name_bn']),
      nameEn: serializer.fromJson<String>(json['name_en']),
      category: serializer.fromJson<String>(json['category']),
      tier: serializer.fromJson<int>(json['tier']),
      descriptionBn: serializer.fromJson<String>(json['description_bn']),
      descriptionEn: serializer.fromJson<String>(json['description_en']),
      packId: serializer.fromJson<String>(json['pack_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name_bn': serializer.toJson<String>(nameBn),
      'name_en': serializer.toJson<String>(nameEn),
      'category': serializer.toJson<String>(category),
      'tier': serializer.toJson<int>(tier),
      'description_bn': serializer.toJson<String>(descriptionBn),
      'description_en': serializer.toJson<String>(descriptionEn),
      'pack_id': serializer.toJson<String>(packId),
    };
  }

  ObservanceRow copyWith({
    String? id,
    String? nameBn,
    String? nameEn,
    String? category,
    int? tier,
    String? descriptionBn,
    String? descriptionEn,
    String? packId,
  }) => ObservanceRow(
    id: id ?? this.id,
    nameBn: nameBn ?? this.nameBn,
    nameEn: nameEn ?? this.nameEn,
    category: category ?? this.category,
    tier: tier ?? this.tier,
    descriptionBn: descriptionBn ?? this.descriptionBn,
    descriptionEn: descriptionEn ?? this.descriptionEn,
    packId: packId ?? this.packId,
  );
  ObservanceRow copyWithCompanion(ObservancesCompanion data) {
    return ObservanceRow(
      id: data.id.present ? data.id.value : this.id,
      nameBn: data.nameBn.present ? data.nameBn.value : this.nameBn,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      category: data.category.present ? data.category.value : this.category,
      tier: data.tier.present ? data.tier.value : this.tier,
      descriptionBn: data.descriptionBn.present
          ? data.descriptionBn.value
          : this.descriptionBn,
      descriptionEn: data.descriptionEn.present
          ? data.descriptionEn.value
          : this.descriptionEn,
      packId: data.packId.present ? data.packId.value : this.packId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObservanceRow(')
          ..write('id: $id, ')
          ..write('nameBn: $nameBn, ')
          ..write('nameEn: $nameEn, ')
          ..write('category: $category, ')
          ..write('tier: $tier, ')
          ..write('descriptionBn: $descriptionBn, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('packId: $packId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nameBn,
    nameEn,
    category,
    tier,
    descriptionBn,
    descriptionEn,
    packId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObservanceRow &&
          other.id == this.id &&
          other.nameBn == this.nameBn &&
          other.nameEn == this.nameEn &&
          other.category == this.category &&
          other.tier == this.tier &&
          other.descriptionBn == this.descriptionBn &&
          other.descriptionEn == this.descriptionEn &&
          other.packId == this.packId);
}

class ObservancesCompanion extends UpdateCompanion<ObservanceRow> {
  final Value<String> id;
  final Value<String> nameBn;
  final Value<String> nameEn;
  final Value<String> category;
  final Value<int> tier;
  final Value<String> descriptionBn;
  final Value<String> descriptionEn;
  final Value<String> packId;
  final Value<int> rowid;
  const ObservancesCompanion({
    this.id = const Value.absent(),
    this.nameBn = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.category = const Value.absent(),
    this.tier = const Value.absent(),
    this.descriptionBn = const Value.absent(),
    this.descriptionEn = const Value.absent(),
    this.packId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObservancesCompanion.insert({
    required String id,
    required String nameBn,
    required String nameEn,
    required String category,
    required int tier,
    required String descriptionBn,
    required String descriptionEn,
    required String packId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nameBn = Value(nameBn),
       nameEn = Value(nameEn),
       category = Value(category),
       tier = Value(tier),
       descriptionBn = Value(descriptionBn),
       descriptionEn = Value(descriptionEn),
       packId = Value(packId);
  static Insertable<ObservanceRow> custom({
    Expression<String>? id,
    Expression<String>? nameBn,
    Expression<String>? nameEn,
    Expression<String>? category,
    Expression<int>? tier,
    Expression<String>? descriptionBn,
    Expression<String>? descriptionEn,
    Expression<String>? packId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameBn != null) 'name_bn': nameBn,
      if (nameEn != null) 'name_en': nameEn,
      if (category != null) 'category': category,
      if (tier != null) 'tier': tier,
      if (descriptionBn != null) 'description_bn': descriptionBn,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (packId != null) 'pack_id': packId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObservancesCompanion copyWith({
    Value<String>? id,
    Value<String>? nameBn,
    Value<String>? nameEn,
    Value<String>? category,
    Value<int>? tier,
    Value<String>? descriptionBn,
    Value<String>? descriptionEn,
    Value<String>? packId,
    Value<int>? rowid,
  }) {
    return ObservancesCompanion(
      id: id ?? this.id,
      nameBn: nameBn ?? this.nameBn,
      nameEn: nameEn ?? this.nameEn,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      packId: packId ?? this.packId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nameBn.present) {
      map['name_bn'] = Variable<String>(nameBn.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (tier.present) {
      map['tier'] = Variable<int>(tier.value);
    }
    if (descriptionBn.present) {
      map['description_bn'] = Variable<String>(descriptionBn.value);
    }
    if (descriptionEn.present) {
      map['description_en'] = Variable<String>(descriptionEn.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservancesCompanion(')
          ..write('id: $id, ')
          ..write('nameBn: $nameBn, ')
          ..write('nameEn: $nameEn, ')
          ..write('category: $category, ')
          ..write('tier: $tier, ')
          ..write('descriptionBn: $descriptionBn, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('packId: $packId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ObservanceDates extends Table
    with TableInfo<ObservanceDates, ObservanceDateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ObservanceDates(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _observanceIdMeta = const VerificationMeta(
    'observanceId',
  );
  late final GeneratedColumn<String> observanceId = GeneratedColumn<String>(
    'observance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES observances(id)',
  );
  static const VerificationMeta _traditionMeta = const VerificationMeta(
    'tradition',
  );
  late final GeneratedColumn<String> tradition = GeneratedColumn<String>(
    'tradition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta(
    'dayIndex',
  );
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
    'day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (day_index >= 0)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (status IN (\'computed\', \'reference_matched\', \'expert_reviewed\', \'sample\'))',
  );
  static const VerificationMeta _reviewedByMeta = const VerificationMeta(
    'reviewedBy',
  );
  late final GeneratedColumn<String> reviewedBy = GeneratedColumn<String>(
    'reviewed_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _reviewedOnMeta = const VerificationMeta(
    'reviewedOn',
  );
  late final GeneratedColumn<String> reviewedOn = GeneratedColumn<String>(
    'reviewed_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _noteBnMeta = const VerificationMeta('noteBn');
  late final GeneratedColumn<String> noteBn = GeneratedColumn<String>(
    'note_bn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _noteEnMeta = const VerificationMeta('noteEn');
  late final GeneratedColumn<String> noteEn = GeneratedColumn<String>(
    'note_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES packs(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    observanceId,
    tradition,
    date,
    dayIndex,
    status,
    reviewedBy,
    reviewedOn,
    noteBn,
    noteEn,
    packId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observance_dates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObservanceDateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('observance_id')) {
      context.handle(
        _observanceIdMeta,
        observanceId.isAcceptableOrUnknown(
          data['observance_id']!,
          _observanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observanceIdMeta);
    }
    if (data.containsKey('tradition')) {
      context.handle(
        _traditionMeta,
        tradition.isAcceptableOrUnknown(data['tradition']!, _traditionMeta),
      );
    } else if (isInserting) {
      context.missing(_traditionMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('day_index')) {
      context.handle(
        _dayIndexMeta,
        dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('reviewed_by')) {
      context.handle(
        _reviewedByMeta,
        reviewedBy.isAcceptableOrUnknown(data['reviewed_by']!, _reviewedByMeta),
      );
    }
    if (data.containsKey('reviewed_on')) {
      context.handle(
        _reviewedOnMeta,
        reviewedOn.isAcceptableOrUnknown(data['reviewed_on']!, _reviewedOnMeta),
      );
    }
    if (data.containsKey('note_bn')) {
      context.handle(
        _noteBnMeta,
        noteBn.isAcceptableOrUnknown(data['note_bn']!, _noteBnMeta),
      );
    }
    if (data.containsKey('note_en')) {
      context.handle(
        _noteEnMeta,
        noteEn.isAcceptableOrUnknown(data['note_en']!, _noteEnMeta),
      );
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {observanceId, tradition, date};
  @override
  ObservanceDateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObservanceDateRow(
      observanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observance_id'],
      )!,
      tradition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tradition'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      dayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_index'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      reviewedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewed_by'],
      ),
      reviewedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewed_on'],
      ),
      noteBn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_bn'],
      ),
      noteEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_en'],
      ),
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
    );
  }

  @override
  ObservanceDates createAlias(String alias) {
    return ObservanceDates(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(observance_id, tradition, date)',
    'CHECK((note_bn IS NULL)=(note_en IS NULL))',
    'CHECK(status <> \'expert_reviewed\' OR(reviewed_by IS NOT NULL AND reviewed_on IS NOT NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ObservanceDateRow extends DataClass
    implements Insertable<ObservanceDateRow> {
  final String observanceId;
  final String tradition;
  final String date;
  final int dayIndex;

  /// multi-day festivals
  final String status;
  final String? reviewedBy;
  final String? reviewedOn;
  final String? noteBn;
  final String? noteEn;
  final String packId;
  const ObservanceDateRow({
    required this.observanceId,
    required this.tradition,
    required this.date,
    required this.dayIndex,
    required this.status,
    this.reviewedBy,
    this.reviewedOn,
    this.noteBn,
    this.noteEn,
    required this.packId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['observance_id'] = Variable<String>(observanceId);
    map['tradition'] = Variable<String>(tradition);
    map['date'] = Variable<String>(date);
    map['day_index'] = Variable<int>(dayIndex);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || reviewedBy != null) {
      map['reviewed_by'] = Variable<String>(reviewedBy);
    }
    if (!nullToAbsent || reviewedOn != null) {
      map['reviewed_on'] = Variable<String>(reviewedOn);
    }
    if (!nullToAbsent || noteBn != null) {
      map['note_bn'] = Variable<String>(noteBn);
    }
    if (!nullToAbsent || noteEn != null) {
      map['note_en'] = Variable<String>(noteEn);
    }
    map['pack_id'] = Variable<String>(packId);
    return map;
  }

  ObservanceDatesCompanion toCompanion(bool nullToAbsent) {
    return ObservanceDatesCompanion(
      observanceId: Value(observanceId),
      tradition: Value(tradition),
      date: Value(date),
      dayIndex: Value(dayIndex),
      status: Value(status),
      reviewedBy: reviewedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedBy),
      reviewedOn: reviewedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedOn),
      noteBn: noteBn == null && nullToAbsent
          ? const Value.absent()
          : Value(noteBn),
      noteEn: noteEn == null && nullToAbsent
          ? const Value.absent()
          : Value(noteEn),
      packId: Value(packId),
    );
  }

  factory ObservanceDateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObservanceDateRow(
      observanceId: serializer.fromJson<String>(json['observance_id']),
      tradition: serializer.fromJson<String>(json['tradition']),
      date: serializer.fromJson<String>(json['date']),
      dayIndex: serializer.fromJson<int>(json['day_index']),
      status: serializer.fromJson<String>(json['status']),
      reviewedBy: serializer.fromJson<String?>(json['reviewed_by']),
      reviewedOn: serializer.fromJson<String?>(json['reviewed_on']),
      noteBn: serializer.fromJson<String?>(json['note_bn']),
      noteEn: serializer.fromJson<String?>(json['note_en']),
      packId: serializer.fromJson<String>(json['pack_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'observance_id': serializer.toJson<String>(observanceId),
      'tradition': serializer.toJson<String>(tradition),
      'date': serializer.toJson<String>(date),
      'day_index': serializer.toJson<int>(dayIndex),
      'status': serializer.toJson<String>(status),
      'reviewed_by': serializer.toJson<String?>(reviewedBy),
      'reviewed_on': serializer.toJson<String?>(reviewedOn),
      'note_bn': serializer.toJson<String?>(noteBn),
      'note_en': serializer.toJson<String?>(noteEn),
      'pack_id': serializer.toJson<String>(packId),
    };
  }

  ObservanceDateRow copyWith({
    String? observanceId,
    String? tradition,
    String? date,
    int? dayIndex,
    String? status,
    Value<String?> reviewedBy = const Value.absent(),
    Value<String?> reviewedOn = const Value.absent(),
    Value<String?> noteBn = const Value.absent(),
    Value<String?> noteEn = const Value.absent(),
    String? packId,
  }) => ObservanceDateRow(
    observanceId: observanceId ?? this.observanceId,
    tradition: tradition ?? this.tradition,
    date: date ?? this.date,
    dayIndex: dayIndex ?? this.dayIndex,
    status: status ?? this.status,
    reviewedBy: reviewedBy.present ? reviewedBy.value : this.reviewedBy,
    reviewedOn: reviewedOn.present ? reviewedOn.value : this.reviewedOn,
    noteBn: noteBn.present ? noteBn.value : this.noteBn,
    noteEn: noteEn.present ? noteEn.value : this.noteEn,
    packId: packId ?? this.packId,
  );
  ObservanceDateRow copyWithCompanion(ObservanceDatesCompanion data) {
    return ObservanceDateRow(
      observanceId: data.observanceId.present
          ? data.observanceId.value
          : this.observanceId,
      tradition: data.tradition.present ? data.tradition.value : this.tradition,
      date: data.date.present ? data.date.value : this.date,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      status: data.status.present ? data.status.value : this.status,
      reviewedBy: data.reviewedBy.present
          ? data.reviewedBy.value
          : this.reviewedBy,
      reviewedOn: data.reviewedOn.present
          ? data.reviewedOn.value
          : this.reviewedOn,
      noteBn: data.noteBn.present ? data.noteBn.value : this.noteBn,
      noteEn: data.noteEn.present ? data.noteEn.value : this.noteEn,
      packId: data.packId.present ? data.packId.value : this.packId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObservanceDateRow(')
          ..write('observanceId: $observanceId, ')
          ..write('tradition: $tradition, ')
          ..write('date: $date, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('status: $status, ')
          ..write('reviewedBy: $reviewedBy, ')
          ..write('reviewedOn: $reviewedOn, ')
          ..write('noteBn: $noteBn, ')
          ..write('noteEn: $noteEn, ')
          ..write('packId: $packId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    observanceId,
    tradition,
    date,
    dayIndex,
    status,
    reviewedBy,
    reviewedOn,
    noteBn,
    noteEn,
    packId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObservanceDateRow &&
          other.observanceId == this.observanceId &&
          other.tradition == this.tradition &&
          other.date == this.date &&
          other.dayIndex == this.dayIndex &&
          other.status == this.status &&
          other.reviewedBy == this.reviewedBy &&
          other.reviewedOn == this.reviewedOn &&
          other.noteBn == this.noteBn &&
          other.noteEn == this.noteEn &&
          other.packId == this.packId);
}

class ObservanceDatesCompanion extends UpdateCompanion<ObservanceDateRow> {
  final Value<String> observanceId;
  final Value<String> tradition;
  final Value<String> date;
  final Value<int> dayIndex;
  final Value<String> status;
  final Value<String?> reviewedBy;
  final Value<String?> reviewedOn;
  final Value<String?> noteBn;
  final Value<String?> noteEn;
  final Value<String> packId;
  final Value<int> rowid;
  const ObservanceDatesCompanion({
    this.observanceId = const Value.absent(),
    this.tradition = const Value.absent(),
    this.date = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.status = const Value.absent(),
    this.reviewedBy = const Value.absent(),
    this.reviewedOn = const Value.absent(),
    this.noteBn = const Value.absent(),
    this.noteEn = const Value.absent(),
    this.packId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObservanceDatesCompanion.insert({
    required String observanceId,
    required String tradition,
    required String date,
    this.dayIndex = const Value.absent(),
    required String status,
    this.reviewedBy = const Value.absent(),
    this.reviewedOn = const Value.absent(),
    this.noteBn = const Value.absent(),
    this.noteEn = const Value.absent(),
    required String packId,
    this.rowid = const Value.absent(),
  }) : observanceId = Value(observanceId),
       tradition = Value(tradition),
       date = Value(date),
       status = Value(status),
       packId = Value(packId);
  static Insertable<ObservanceDateRow> custom({
    Expression<String>? observanceId,
    Expression<String>? tradition,
    Expression<String>? date,
    Expression<int>? dayIndex,
    Expression<String>? status,
    Expression<String>? reviewedBy,
    Expression<String>? reviewedOn,
    Expression<String>? noteBn,
    Expression<String>? noteEn,
    Expression<String>? packId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (observanceId != null) 'observance_id': observanceId,
      if (tradition != null) 'tradition': tradition,
      if (date != null) 'date': date,
      if (dayIndex != null) 'day_index': dayIndex,
      if (status != null) 'status': status,
      if (reviewedBy != null) 'reviewed_by': reviewedBy,
      if (reviewedOn != null) 'reviewed_on': reviewedOn,
      if (noteBn != null) 'note_bn': noteBn,
      if (noteEn != null) 'note_en': noteEn,
      if (packId != null) 'pack_id': packId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObservanceDatesCompanion copyWith({
    Value<String>? observanceId,
    Value<String>? tradition,
    Value<String>? date,
    Value<int>? dayIndex,
    Value<String>? status,
    Value<String?>? reviewedBy,
    Value<String?>? reviewedOn,
    Value<String?>? noteBn,
    Value<String?>? noteEn,
    Value<String>? packId,
    Value<int>? rowid,
  }) {
    return ObservanceDatesCompanion(
      observanceId: observanceId ?? this.observanceId,
      tradition: tradition ?? this.tradition,
      date: date ?? this.date,
      dayIndex: dayIndex ?? this.dayIndex,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedOn: reviewedOn ?? this.reviewedOn,
      noteBn: noteBn ?? this.noteBn,
      noteEn: noteEn ?? this.noteEn,
      packId: packId ?? this.packId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (observanceId.present) {
      map['observance_id'] = Variable<String>(observanceId.value);
    }
    if (tradition.present) {
      map['tradition'] = Variable<String>(tradition.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reviewedBy.present) {
      map['reviewed_by'] = Variable<String>(reviewedBy.value);
    }
    if (reviewedOn.present) {
      map['reviewed_on'] = Variable<String>(reviewedOn.value);
    }
    if (noteBn.present) {
      map['note_bn'] = Variable<String>(noteBn.value);
    }
    if (noteEn.present) {
      map['note_en'] = Variable<String>(noteEn.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservanceDatesCompanion(')
          ..write('observanceId: $observanceId, ')
          ..write('tradition: $tradition, ')
          ..write('date: $date, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('status: $status, ')
          ..write('reviewedBy: $reviewedBy, ')
          ..write('reviewedOn: $reviewedOn, ')
          ..write('noteBn: $noteBn, ')
          ..write('noteEn: $noteEn, ')
          ..write('packId: $packId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ObservanceWindows extends Table
    with TableInfo<ObservanceWindows, ObservanceWindowRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ObservanceWindows(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _observanceIdMeta = const VerificationMeta(
    'observanceId',
  );
  late final GeneratedColumn<String> observanceId = GeneratedColumn<String>(
    'observance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _traditionMeta = const VerificationMeta(
    'tradition',
  );
  late final GeneratedColumn<String> tradition = GeneratedColumn<String>(
    'tradition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _windowKindMeta = const VerificationMeta(
    'windowKind',
  );
  late final GeneratedColumn<String> windowKind = GeneratedColumn<String>(
    'window_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _startUtcMeta = const VerificationMeta(
    'startUtc',
  );
  late final GeneratedColumn<int> startUtc = GeneratedColumn<int>(
    'start_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _endUtcMeta = const VerificationMeta('endUtc');
  late final GeneratedColumn<int> endUtc = GeneratedColumn<int>(
    'end_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES packs(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    observanceId,
    tradition,
    date,
    windowKind,
    startUtc,
    endUtc,
    packId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observance_windows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObservanceWindowRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('observance_id')) {
      context.handle(
        _observanceIdMeta,
        observanceId.isAcceptableOrUnknown(
          data['observance_id']!,
          _observanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observanceIdMeta);
    }
    if (data.containsKey('tradition')) {
      context.handle(
        _traditionMeta,
        tradition.isAcceptableOrUnknown(data['tradition']!, _traditionMeta),
      );
    } else if (isInserting) {
      context.missing(_traditionMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('window_kind')) {
      context.handle(
        _windowKindMeta,
        windowKind.isAcceptableOrUnknown(data['window_kind']!, _windowKindMeta),
      );
    } else if (isInserting) {
      context.missing(_windowKindMeta);
    }
    if (data.containsKey('start_utc')) {
      context.handle(
        _startUtcMeta,
        startUtc.isAcceptableOrUnknown(data['start_utc']!, _startUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_startUtcMeta);
    }
    if (data.containsKey('end_utc')) {
      context.handle(
        _endUtcMeta,
        endUtc.isAcceptableOrUnknown(data['end_utc']!, _endUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_endUtcMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    observanceId,
    tradition,
    date,
    windowKind,
  };
  @override
  ObservanceWindowRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObservanceWindowRow(
      observanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observance_id'],
      )!,
      tradition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tradition'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      windowKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}window_kind'],
      )!,
      startUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_utc'],
      )!,
      endUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_utc'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
    );
  }

  @override
  ObservanceWindows createAlias(String alias) {
    return ObservanceWindows(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(observance_id, tradition, date, window_kind)',
    'FOREIGN KEY(observance_id, tradition, date)REFERENCES observance_dates(observance_id, tradition, date)',
    'CHECK(start_utc < end_utc)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ObservanceWindowRow extends DataClass
    implements Insertable<ObservanceWindowRow> {
  final String observanceId;
  final String tradition;
  final String date;
  final String windowKind;

  /// sandhi_puja | nishita | purnima_span …
  final int startUtc;
  final int endUtc;
  final String packId;
  const ObservanceWindowRow({
    required this.observanceId,
    required this.tradition,
    required this.date,
    required this.windowKind,
    required this.startUtc,
    required this.endUtc,
    required this.packId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['observance_id'] = Variable<String>(observanceId);
    map['tradition'] = Variable<String>(tradition);
    map['date'] = Variable<String>(date);
    map['window_kind'] = Variable<String>(windowKind);
    map['start_utc'] = Variable<int>(startUtc);
    map['end_utc'] = Variable<int>(endUtc);
    map['pack_id'] = Variable<String>(packId);
    return map;
  }

  ObservanceWindowsCompanion toCompanion(bool nullToAbsent) {
    return ObservanceWindowsCompanion(
      observanceId: Value(observanceId),
      tradition: Value(tradition),
      date: Value(date),
      windowKind: Value(windowKind),
      startUtc: Value(startUtc),
      endUtc: Value(endUtc),
      packId: Value(packId),
    );
  }

  factory ObservanceWindowRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObservanceWindowRow(
      observanceId: serializer.fromJson<String>(json['observance_id']),
      tradition: serializer.fromJson<String>(json['tradition']),
      date: serializer.fromJson<String>(json['date']),
      windowKind: serializer.fromJson<String>(json['window_kind']),
      startUtc: serializer.fromJson<int>(json['start_utc']),
      endUtc: serializer.fromJson<int>(json['end_utc']),
      packId: serializer.fromJson<String>(json['pack_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'observance_id': serializer.toJson<String>(observanceId),
      'tradition': serializer.toJson<String>(tradition),
      'date': serializer.toJson<String>(date),
      'window_kind': serializer.toJson<String>(windowKind),
      'start_utc': serializer.toJson<int>(startUtc),
      'end_utc': serializer.toJson<int>(endUtc),
      'pack_id': serializer.toJson<String>(packId),
    };
  }

  ObservanceWindowRow copyWith({
    String? observanceId,
    String? tradition,
    String? date,
    String? windowKind,
    int? startUtc,
    int? endUtc,
    String? packId,
  }) => ObservanceWindowRow(
    observanceId: observanceId ?? this.observanceId,
    tradition: tradition ?? this.tradition,
    date: date ?? this.date,
    windowKind: windowKind ?? this.windowKind,
    startUtc: startUtc ?? this.startUtc,
    endUtc: endUtc ?? this.endUtc,
    packId: packId ?? this.packId,
  );
  ObservanceWindowRow copyWithCompanion(ObservanceWindowsCompanion data) {
    return ObservanceWindowRow(
      observanceId: data.observanceId.present
          ? data.observanceId.value
          : this.observanceId,
      tradition: data.tradition.present ? data.tradition.value : this.tradition,
      date: data.date.present ? data.date.value : this.date,
      windowKind: data.windowKind.present
          ? data.windowKind.value
          : this.windowKind,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      endUtc: data.endUtc.present ? data.endUtc.value : this.endUtc,
      packId: data.packId.present ? data.packId.value : this.packId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObservanceWindowRow(')
          ..write('observanceId: $observanceId, ')
          ..write('tradition: $tradition, ')
          ..write('date: $date, ')
          ..write('windowKind: $windowKind, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('packId: $packId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    observanceId,
    tradition,
    date,
    windowKind,
    startUtc,
    endUtc,
    packId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObservanceWindowRow &&
          other.observanceId == this.observanceId &&
          other.tradition == this.tradition &&
          other.date == this.date &&
          other.windowKind == this.windowKind &&
          other.startUtc == this.startUtc &&
          other.endUtc == this.endUtc &&
          other.packId == this.packId);
}

class ObservanceWindowsCompanion extends UpdateCompanion<ObservanceWindowRow> {
  final Value<String> observanceId;
  final Value<String> tradition;
  final Value<String> date;
  final Value<String> windowKind;
  final Value<int> startUtc;
  final Value<int> endUtc;
  final Value<String> packId;
  final Value<int> rowid;
  const ObservanceWindowsCompanion({
    this.observanceId = const Value.absent(),
    this.tradition = const Value.absent(),
    this.date = const Value.absent(),
    this.windowKind = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.endUtc = const Value.absent(),
    this.packId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObservanceWindowsCompanion.insert({
    required String observanceId,
    required String tradition,
    required String date,
    required String windowKind,
    required int startUtc,
    required int endUtc,
    required String packId,
    this.rowid = const Value.absent(),
  }) : observanceId = Value(observanceId),
       tradition = Value(tradition),
       date = Value(date),
       windowKind = Value(windowKind),
       startUtc = Value(startUtc),
       endUtc = Value(endUtc),
       packId = Value(packId);
  static Insertable<ObservanceWindowRow> custom({
    Expression<String>? observanceId,
    Expression<String>? tradition,
    Expression<String>? date,
    Expression<String>? windowKind,
    Expression<int>? startUtc,
    Expression<int>? endUtc,
    Expression<String>? packId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (observanceId != null) 'observance_id': observanceId,
      if (tradition != null) 'tradition': tradition,
      if (date != null) 'date': date,
      if (windowKind != null) 'window_kind': windowKind,
      if (startUtc != null) 'start_utc': startUtc,
      if (endUtc != null) 'end_utc': endUtc,
      if (packId != null) 'pack_id': packId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObservanceWindowsCompanion copyWith({
    Value<String>? observanceId,
    Value<String>? tradition,
    Value<String>? date,
    Value<String>? windowKind,
    Value<int>? startUtc,
    Value<int>? endUtc,
    Value<String>? packId,
    Value<int>? rowid,
  }) {
    return ObservanceWindowsCompanion(
      observanceId: observanceId ?? this.observanceId,
      tradition: tradition ?? this.tradition,
      date: date ?? this.date,
      windowKind: windowKind ?? this.windowKind,
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
      packId: packId ?? this.packId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (observanceId.present) {
      map['observance_id'] = Variable<String>(observanceId.value);
    }
    if (tradition.present) {
      map['tradition'] = Variable<String>(tradition.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (windowKind.present) {
      map['window_kind'] = Variable<String>(windowKind.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<int>(startUtc.value);
    }
    if (endUtc.present) {
      map['end_utc'] = Variable<int>(endUtc.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservanceWindowsCompanion(')
          ..write('observanceId: $observanceId, ')
          ..write('tradition: $tradition, ')
          ..write('date: $date, ')
          ..write('windowKind: $windowKind, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('packId: $packId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class LunarMonths extends Table with TableInfo<LunarMonths, LunarMonthRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LunarMonths(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _traditionMeta = const VerificationMeta(
    'tradition',
  );
  late final GeneratedColumn<String> tradition = GeneratedColumn<String>(
    'tradition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _monthIdxMeta = const VerificationMeta(
    'monthIdx',
  );
  late final GeneratedColumn<int> monthIdx = GeneratedColumn<int>(
    'month_idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (month_idx BETWEEN 0 AND 11)',
  );
  static const VerificationMeta _isAdhikMeta = const VerificationMeta(
    'isAdhik',
  );
  late final GeneratedColumn<int> isAdhik = GeneratedColumn<int>(
    'is_adhik',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (is_adhik IN (0, 1))',
  );
  static const VerificationMeta _startsUtcMeta = const VerificationMeta(
    'startsUtc',
  );
  late final GeneratedColumn<int> startsUtc = GeneratedColumn<int>(
    'starts_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _endsUtcMeta = const VerificationMeta(
    'endsUtc',
  );
  late final GeneratedColumn<int> endsUtc = GeneratedColumn<int>(
    'ends_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES packs(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    tradition,
    monthIdx,
    isAdhik,
    startsUtc,
    endsUtc,
    packId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lunar_months';
  @override
  VerificationContext validateIntegrity(
    Insertable<LunarMonthRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tradition')) {
      context.handle(
        _traditionMeta,
        tradition.isAcceptableOrUnknown(data['tradition']!, _traditionMeta),
      );
    } else if (isInserting) {
      context.missing(_traditionMeta);
    }
    if (data.containsKey('month_idx')) {
      context.handle(
        _monthIdxMeta,
        monthIdx.isAcceptableOrUnknown(data['month_idx']!, _monthIdxMeta),
      );
    } else if (isInserting) {
      context.missing(_monthIdxMeta);
    }
    if (data.containsKey('is_adhik')) {
      context.handle(
        _isAdhikMeta,
        isAdhik.isAcceptableOrUnknown(data['is_adhik']!, _isAdhikMeta),
      );
    } else if (isInserting) {
      context.missing(_isAdhikMeta);
    }
    if (data.containsKey('starts_utc')) {
      context.handle(
        _startsUtcMeta,
        startsUtc.isAcceptableOrUnknown(data['starts_utc']!, _startsUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_startsUtcMeta);
    }
    if (data.containsKey('ends_utc')) {
      context.handle(
        _endsUtcMeta,
        endsUtc.isAcceptableOrUnknown(data['ends_utc']!, _endsUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_endsUtcMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tradition, startsUtc};
  @override
  LunarMonthRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LunarMonthRow(
      tradition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tradition'],
      )!,
      monthIdx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_idx'],
      )!,
      isAdhik: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_adhik'],
      )!,
      startsUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}starts_utc'],
      )!,
      endsUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ends_utc'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
    );
  }

  @override
  LunarMonths createAlias(String alias) {
    return LunarMonths(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(tradition, starts_utc)',
    'CHECK(starts_utc < ends_utc)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class LunarMonthRow extends DataClass implements Insertable<LunarMonthRow> {
  final String tradition;
  final int monthIdx;

  /// naming per Q2
  final int isAdhik;

  /// 1 = মলমাস
  final int startsUtc;
  final int endsUtc;
  final String packId;
  const LunarMonthRow({
    required this.tradition,
    required this.monthIdx,
    required this.isAdhik,
    required this.startsUtc,
    required this.endsUtc,
    required this.packId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tradition'] = Variable<String>(tradition);
    map['month_idx'] = Variable<int>(monthIdx);
    map['is_adhik'] = Variable<int>(isAdhik);
    map['starts_utc'] = Variable<int>(startsUtc);
    map['ends_utc'] = Variable<int>(endsUtc);
    map['pack_id'] = Variable<String>(packId);
    return map;
  }

  LunarMonthsCompanion toCompanion(bool nullToAbsent) {
    return LunarMonthsCompanion(
      tradition: Value(tradition),
      monthIdx: Value(monthIdx),
      isAdhik: Value(isAdhik),
      startsUtc: Value(startsUtc),
      endsUtc: Value(endsUtc),
      packId: Value(packId),
    );
  }

  factory LunarMonthRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LunarMonthRow(
      tradition: serializer.fromJson<String>(json['tradition']),
      monthIdx: serializer.fromJson<int>(json['month_idx']),
      isAdhik: serializer.fromJson<int>(json['is_adhik']),
      startsUtc: serializer.fromJson<int>(json['starts_utc']),
      endsUtc: serializer.fromJson<int>(json['ends_utc']),
      packId: serializer.fromJson<String>(json['pack_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tradition': serializer.toJson<String>(tradition),
      'month_idx': serializer.toJson<int>(monthIdx),
      'is_adhik': serializer.toJson<int>(isAdhik),
      'starts_utc': serializer.toJson<int>(startsUtc),
      'ends_utc': serializer.toJson<int>(endsUtc),
      'pack_id': serializer.toJson<String>(packId),
    };
  }

  LunarMonthRow copyWith({
    String? tradition,
    int? monthIdx,
    int? isAdhik,
    int? startsUtc,
    int? endsUtc,
    String? packId,
  }) => LunarMonthRow(
    tradition: tradition ?? this.tradition,
    monthIdx: monthIdx ?? this.monthIdx,
    isAdhik: isAdhik ?? this.isAdhik,
    startsUtc: startsUtc ?? this.startsUtc,
    endsUtc: endsUtc ?? this.endsUtc,
    packId: packId ?? this.packId,
  );
  LunarMonthRow copyWithCompanion(LunarMonthsCompanion data) {
    return LunarMonthRow(
      tradition: data.tradition.present ? data.tradition.value : this.tradition,
      monthIdx: data.monthIdx.present ? data.monthIdx.value : this.monthIdx,
      isAdhik: data.isAdhik.present ? data.isAdhik.value : this.isAdhik,
      startsUtc: data.startsUtc.present ? data.startsUtc.value : this.startsUtc,
      endsUtc: data.endsUtc.present ? data.endsUtc.value : this.endsUtc,
      packId: data.packId.present ? data.packId.value : this.packId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LunarMonthRow(')
          ..write('tradition: $tradition, ')
          ..write('monthIdx: $monthIdx, ')
          ..write('isAdhik: $isAdhik, ')
          ..write('startsUtc: $startsUtc, ')
          ..write('endsUtc: $endsUtc, ')
          ..write('packId: $packId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(tradition, monthIdx, isAdhik, startsUtc, endsUtc, packId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LunarMonthRow &&
          other.tradition == this.tradition &&
          other.monthIdx == this.monthIdx &&
          other.isAdhik == this.isAdhik &&
          other.startsUtc == this.startsUtc &&
          other.endsUtc == this.endsUtc &&
          other.packId == this.packId);
}

class LunarMonthsCompanion extends UpdateCompanion<LunarMonthRow> {
  final Value<String> tradition;
  final Value<int> monthIdx;
  final Value<int> isAdhik;
  final Value<int> startsUtc;
  final Value<int> endsUtc;
  final Value<String> packId;
  final Value<int> rowid;
  const LunarMonthsCompanion({
    this.tradition = const Value.absent(),
    this.monthIdx = const Value.absent(),
    this.isAdhik = const Value.absent(),
    this.startsUtc = const Value.absent(),
    this.endsUtc = const Value.absent(),
    this.packId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LunarMonthsCompanion.insert({
    required String tradition,
    required int monthIdx,
    required int isAdhik,
    required int startsUtc,
    required int endsUtc,
    required String packId,
    this.rowid = const Value.absent(),
  }) : tradition = Value(tradition),
       monthIdx = Value(monthIdx),
       isAdhik = Value(isAdhik),
       startsUtc = Value(startsUtc),
       endsUtc = Value(endsUtc),
       packId = Value(packId);
  static Insertable<LunarMonthRow> custom({
    Expression<String>? tradition,
    Expression<int>? monthIdx,
    Expression<int>? isAdhik,
    Expression<int>? startsUtc,
    Expression<int>? endsUtc,
    Expression<String>? packId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tradition != null) 'tradition': tradition,
      if (monthIdx != null) 'month_idx': monthIdx,
      if (isAdhik != null) 'is_adhik': isAdhik,
      if (startsUtc != null) 'starts_utc': startsUtc,
      if (endsUtc != null) 'ends_utc': endsUtc,
      if (packId != null) 'pack_id': packId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LunarMonthsCompanion copyWith({
    Value<String>? tradition,
    Value<int>? monthIdx,
    Value<int>? isAdhik,
    Value<int>? startsUtc,
    Value<int>? endsUtc,
    Value<String>? packId,
    Value<int>? rowid,
  }) {
    return LunarMonthsCompanion(
      tradition: tradition ?? this.tradition,
      monthIdx: monthIdx ?? this.monthIdx,
      isAdhik: isAdhik ?? this.isAdhik,
      startsUtc: startsUtc ?? this.startsUtc,
      endsUtc: endsUtc ?? this.endsUtc,
      packId: packId ?? this.packId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tradition.present) {
      map['tradition'] = Variable<String>(tradition.value);
    }
    if (monthIdx.present) {
      map['month_idx'] = Variable<int>(monthIdx.value);
    }
    if (isAdhik.present) {
      map['is_adhik'] = Variable<int>(isAdhik.value);
    }
    if (startsUtc.present) {
      map['starts_utc'] = Variable<int>(startsUtc.value);
    }
    if (endsUtc.present) {
      map['ends_utc'] = Variable<int>(endsUtc.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LunarMonthsCompanion(')
          ..write('tradition: $tradition, ')
          ..write('monthIdx: $monthIdx, ')
          ..write('isAdhik: $isAdhik, ')
          ..write('startsUtc: $startsUtc, ')
          ..write('endsUtc: $endsUtc, ')
          ..write('packId: $packId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PeriodRules extends Table with TableInfo<PeriodRules, PeriodRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PeriodRules(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _traditionMeta = const VerificationMeta(
    'tradition',
  );
  late final GeneratedColumn<String> tradition = GeneratedColumn<String>(
    'tradition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nameIdxMeta = const VerificationMeta(
    'nameIdx',
  );
  late final GeneratedColumn<int> nameIdx = GeneratedColumn<int>(
    'name_idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (kind IN (\'shubh\', \'ashubh\'))',
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (weekday BETWEEN 0 AND 6)',
  );
  static const VerificationMeta _basisMeta = const VerificationMeta('basis');
  late final GeneratedColumn<String> basis = GeneratedColumn<String>(
    'basis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (basis IN (\'day\', \'night\'))',
  );
  static const VerificationMeta _divisionsMeta = const VerificationMeta(
    'divisions',
  );
  late final GeneratedColumn<int> divisions = GeneratedColumn<int>(
    'divisions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (divisions >= 1)',
  );
  static const VerificationMeta _partMeta = const VerificationMeta('part');
  late final GeneratedColumn<int> part = GeneratedColumn<int>(
    'part',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  late final GeneratedColumn<int> enabled = GeneratedColumn<int>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (enabled IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES packs(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    tradition,
    nameIdx,
    kind,
    weekday,
    basis,
    divisions,
    part,
    enabled,
    packId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'period_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeriodRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tradition')) {
      context.handle(
        _traditionMeta,
        tradition.isAcceptableOrUnknown(data['tradition']!, _traditionMeta),
      );
    } else if (isInserting) {
      context.missing(_traditionMeta);
    }
    if (data.containsKey('name_idx')) {
      context.handle(
        _nameIdxMeta,
        nameIdx.isAcceptableOrUnknown(data['name_idx']!, _nameIdxMeta),
      );
    } else if (isInserting) {
      context.missing(_nameIdxMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('basis')) {
      context.handle(
        _basisMeta,
        basis.isAcceptableOrUnknown(data['basis']!, _basisMeta),
      );
    } else if (isInserting) {
      context.missing(_basisMeta);
    }
    if (data.containsKey('divisions')) {
      context.handle(
        _divisionsMeta,
        divisions.isAcceptableOrUnknown(data['divisions']!, _divisionsMeta),
      );
    } else if (isInserting) {
      context.missing(_divisionsMeta);
    }
    if (data.containsKey('part')) {
      context.handle(
        _partMeta,
        part.isAcceptableOrUnknown(data['part']!, _partMeta),
      );
    } else if (isInserting) {
      context.missing(_partMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tradition, nameIdx, weekday, basis};
  @override
  PeriodRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodRuleRow(
      tradition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tradition'],
      )!,
      nameIdx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}name_idx'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      basis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}basis'],
      )!,
      divisions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}divisions'],
      )!,
      part: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}part'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}enabled'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
    );
  }

  @override
  PeriodRules createAlias(String alias) {
    return PeriodRules(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(tradition, name_idx, weekday, basis)',
    'CHECK(part BETWEEN 1 AND divisions)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class PeriodRuleRow extends DataClass implements Insertable<PeriodRuleRow> {
  final String tradition;
  final int nameIdx;

  /// names(kind = 'period')
  final String kind;
  final int weekday;

  /// 0 = Sunday
  final String basis;
  final int divisions;
  final int part;

  /// 1-based part number, as in spec §6.5.8
  final int enabled;
  final String packId;
  const PeriodRuleRow({
    required this.tradition,
    required this.nameIdx,
    required this.kind,
    required this.weekday,
    required this.basis,
    required this.divisions,
    required this.part,
    required this.enabled,
    required this.packId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tradition'] = Variable<String>(tradition);
    map['name_idx'] = Variable<int>(nameIdx);
    map['kind'] = Variable<String>(kind);
    map['weekday'] = Variable<int>(weekday);
    map['basis'] = Variable<String>(basis);
    map['divisions'] = Variable<int>(divisions);
    map['part'] = Variable<int>(part);
    map['enabled'] = Variable<int>(enabled);
    map['pack_id'] = Variable<String>(packId);
    return map;
  }

  PeriodRulesCompanion toCompanion(bool nullToAbsent) {
    return PeriodRulesCompanion(
      tradition: Value(tradition),
      nameIdx: Value(nameIdx),
      kind: Value(kind),
      weekday: Value(weekday),
      basis: Value(basis),
      divisions: Value(divisions),
      part: Value(part),
      enabled: Value(enabled),
      packId: Value(packId),
    );
  }

  factory PeriodRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodRuleRow(
      tradition: serializer.fromJson<String>(json['tradition']),
      nameIdx: serializer.fromJson<int>(json['name_idx']),
      kind: serializer.fromJson<String>(json['kind']),
      weekday: serializer.fromJson<int>(json['weekday']),
      basis: serializer.fromJson<String>(json['basis']),
      divisions: serializer.fromJson<int>(json['divisions']),
      part: serializer.fromJson<int>(json['part']),
      enabled: serializer.fromJson<int>(json['enabled']),
      packId: serializer.fromJson<String>(json['pack_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tradition': serializer.toJson<String>(tradition),
      'name_idx': serializer.toJson<int>(nameIdx),
      'kind': serializer.toJson<String>(kind),
      'weekday': serializer.toJson<int>(weekday),
      'basis': serializer.toJson<String>(basis),
      'divisions': serializer.toJson<int>(divisions),
      'part': serializer.toJson<int>(part),
      'enabled': serializer.toJson<int>(enabled),
      'pack_id': serializer.toJson<String>(packId),
    };
  }

  PeriodRuleRow copyWith({
    String? tradition,
    int? nameIdx,
    String? kind,
    int? weekday,
    String? basis,
    int? divisions,
    int? part,
    int? enabled,
    String? packId,
  }) => PeriodRuleRow(
    tradition: tradition ?? this.tradition,
    nameIdx: nameIdx ?? this.nameIdx,
    kind: kind ?? this.kind,
    weekday: weekday ?? this.weekday,
    basis: basis ?? this.basis,
    divisions: divisions ?? this.divisions,
    part: part ?? this.part,
    enabled: enabled ?? this.enabled,
    packId: packId ?? this.packId,
  );
  PeriodRuleRow copyWithCompanion(PeriodRulesCompanion data) {
    return PeriodRuleRow(
      tradition: data.tradition.present ? data.tradition.value : this.tradition,
      nameIdx: data.nameIdx.present ? data.nameIdx.value : this.nameIdx,
      kind: data.kind.present ? data.kind.value : this.kind,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      basis: data.basis.present ? data.basis.value : this.basis,
      divisions: data.divisions.present ? data.divisions.value : this.divisions,
      part: data.part.present ? data.part.value : this.part,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      packId: data.packId.present ? data.packId.value : this.packId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodRuleRow(')
          ..write('tradition: $tradition, ')
          ..write('nameIdx: $nameIdx, ')
          ..write('kind: $kind, ')
          ..write('weekday: $weekday, ')
          ..write('basis: $basis, ')
          ..write('divisions: $divisions, ')
          ..write('part: $part, ')
          ..write('enabled: $enabled, ')
          ..write('packId: $packId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    tradition,
    nameIdx,
    kind,
    weekday,
    basis,
    divisions,
    part,
    enabled,
    packId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodRuleRow &&
          other.tradition == this.tradition &&
          other.nameIdx == this.nameIdx &&
          other.kind == this.kind &&
          other.weekday == this.weekday &&
          other.basis == this.basis &&
          other.divisions == this.divisions &&
          other.part == this.part &&
          other.enabled == this.enabled &&
          other.packId == this.packId);
}

class PeriodRulesCompanion extends UpdateCompanion<PeriodRuleRow> {
  final Value<String> tradition;
  final Value<int> nameIdx;
  final Value<String> kind;
  final Value<int> weekday;
  final Value<String> basis;
  final Value<int> divisions;
  final Value<int> part;
  final Value<int> enabled;
  final Value<String> packId;
  final Value<int> rowid;
  const PeriodRulesCompanion({
    this.tradition = const Value.absent(),
    this.nameIdx = const Value.absent(),
    this.kind = const Value.absent(),
    this.weekday = const Value.absent(),
    this.basis = const Value.absent(),
    this.divisions = const Value.absent(),
    this.part = const Value.absent(),
    this.enabled = const Value.absent(),
    this.packId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeriodRulesCompanion.insert({
    required String tradition,
    required int nameIdx,
    required String kind,
    required int weekday,
    required String basis,
    required int divisions,
    required int part,
    this.enabled = const Value.absent(),
    required String packId,
    this.rowid = const Value.absent(),
  }) : tradition = Value(tradition),
       nameIdx = Value(nameIdx),
       kind = Value(kind),
       weekday = Value(weekday),
       basis = Value(basis),
       divisions = Value(divisions),
       part = Value(part),
       packId = Value(packId);
  static Insertable<PeriodRuleRow> custom({
    Expression<String>? tradition,
    Expression<int>? nameIdx,
    Expression<String>? kind,
    Expression<int>? weekday,
    Expression<String>? basis,
    Expression<int>? divisions,
    Expression<int>? part,
    Expression<int>? enabled,
    Expression<String>? packId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tradition != null) 'tradition': tradition,
      if (nameIdx != null) 'name_idx': nameIdx,
      if (kind != null) 'kind': kind,
      if (weekday != null) 'weekday': weekday,
      if (basis != null) 'basis': basis,
      if (divisions != null) 'divisions': divisions,
      if (part != null) 'part': part,
      if (enabled != null) 'enabled': enabled,
      if (packId != null) 'pack_id': packId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeriodRulesCompanion copyWith({
    Value<String>? tradition,
    Value<int>? nameIdx,
    Value<String>? kind,
    Value<int>? weekday,
    Value<String>? basis,
    Value<int>? divisions,
    Value<int>? part,
    Value<int>? enabled,
    Value<String>? packId,
    Value<int>? rowid,
  }) {
    return PeriodRulesCompanion(
      tradition: tradition ?? this.tradition,
      nameIdx: nameIdx ?? this.nameIdx,
      kind: kind ?? this.kind,
      weekday: weekday ?? this.weekday,
      basis: basis ?? this.basis,
      divisions: divisions ?? this.divisions,
      part: part ?? this.part,
      enabled: enabled ?? this.enabled,
      packId: packId ?? this.packId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tradition.present) {
      map['tradition'] = Variable<String>(tradition.value);
    }
    if (nameIdx.present) {
      map['name_idx'] = Variable<int>(nameIdx.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (basis.present) {
      map['basis'] = Variable<String>(basis.value);
    }
    if (divisions.present) {
      map['divisions'] = Variable<int>(divisions.value);
    }
    if (part.present) {
      map['part'] = Variable<int>(part.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<int>(enabled.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodRulesCompanion(')
          ..write('tradition: $tradition, ')
          ..write('nameIdx: $nameIdx, ')
          ..write('kind: $kind, ')
          ..write('weekday: $weekday, ')
          ..write('basis: $basis, ')
          ..write('divisions: $divisions, ')
          ..write('part: $part, ')
          ..write('enabled: $enabled, ')
          ..write('packId: $packId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Reminders extends Table with TableInfo<Reminders, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Reminders(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _targetKindMeta = const VerificationMeta(
    'targetKind',
  );
  late final GeneratedColumn<String> targetKind = GeneratedColumn<String>(
    'target_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (target_kind IN (\'observance\', \'tithi\'))',
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _offsetMinutesMeta = const VerificationMeta(
    'offsetMinutes',
  );
  late final GeneratedColumn<int> offsetMinutes = GeneratedColumn<int>(
    'offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _timeOfDayMeta = const VerificationMeta(
    'timeOfDay',
  );
  late final GeneratedColumn<String> timeOfDay = GeneratedColumn<String>(
    'time_of_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  late final GeneratedColumn<int> enabled = GeneratedColumn<int>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (enabled IN (0, 1))',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetKind,
    targetId,
    offsetMinutes,
    timeOfDay,
    enabled,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_kind')) {
      context.handle(
        _targetKindMeta,
        targetKind.isAcceptableOrUnknown(data['target_kind']!, _targetKindMeta),
      );
    } else if (isInserting) {
      context.missing(_targetKindMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('offset_minutes')) {
      context.handle(
        _offsetMinutesMeta,
        offsetMinutes.isAcceptableOrUnknown(
          data['offset_minutes']!,
          _offsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('time_of_day')) {
      context.handle(
        _timeOfDayMeta,
        timeOfDay.isAcceptableOrUnknown(data['time_of_day']!, _timeOfDayMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_kind'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      offsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offset_minutes'],
      )!,
      timeOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_of_day'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  Reminders createAlias(String alias) {
    return Reminders(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final int id;
  final String targetKind;
  final String targetId;
  final int offsetMinutes;
  final String? timeOfDay;

  /// 'HH:MM' local, NULL = relative to the event
  final int enabled;
  final String createdAt;
  const ReminderRow({
    required this.id,
    required this.targetKind,
    required this.targetId,
    required this.offsetMinutes,
    this.timeOfDay,
    required this.enabled,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_kind'] = Variable<String>(targetKind);
    map['target_id'] = Variable<String>(targetId);
    map['offset_minutes'] = Variable<int>(offsetMinutes);
    if (!nullToAbsent || timeOfDay != null) {
      map['time_of_day'] = Variable<String>(timeOfDay);
    }
    map['enabled'] = Variable<int>(enabled);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      targetKind: Value(targetKind),
      targetId: Value(targetId),
      offsetMinutes: Value(offsetMinutes),
      timeOfDay: timeOfDay == null && nullToAbsent
          ? const Value.absent()
          : Value(timeOfDay),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<int>(json['id']),
      targetKind: serializer.fromJson<String>(json['target_kind']),
      targetId: serializer.fromJson<String>(json['target_id']),
      offsetMinutes: serializer.fromJson<int>(json['offset_minutes']),
      timeOfDay: serializer.fromJson<String?>(json['time_of_day']),
      enabled: serializer.fromJson<int>(json['enabled']),
      createdAt: serializer.fromJson<String>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'target_kind': serializer.toJson<String>(targetKind),
      'target_id': serializer.toJson<String>(targetId),
      'offset_minutes': serializer.toJson<int>(offsetMinutes),
      'time_of_day': serializer.toJson<String?>(timeOfDay),
      'enabled': serializer.toJson<int>(enabled),
      'created_at': serializer.toJson<String>(createdAt),
    };
  }

  ReminderRow copyWith({
    int? id,
    String? targetKind,
    String? targetId,
    int? offsetMinutes,
    Value<String?> timeOfDay = const Value.absent(),
    int? enabled,
    String? createdAt,
  }) => ReminderRow(
    id: id ?? this.id,
    targetKind: targetKind ?? this.targetKind,
    targetId: targetId ?? this.targetId,
    offsetMinutes: offsetMinutes ?? this.offsetMinutes,
    timeOfDay: timeOfDay.present ? timeOfDay.value : this.timeOfDay,
    enabled: enabled ?? this.enabled,
    createdAt: createdAt ?? this.createdAt,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      targetKind: data.targetKind.present
          ? data.targetKind.value
          : this.targetKind,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      offsetMinutes: data.offsetMinutes.present
          ? data.offsetMinutes.value
          : this.offsetMinutes,
      timeOfDay: data.timeOfDay.present ? data.timeOfDay.value : this.timeOfDay,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('targetKind: $targetKind, ')
          ..write('targetId: $targetId, ')
          ..write('offsetMinutes: $offsetMinutes, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetKind,
    targetId,
    offsetMinutes,
    timeOfDay,
    enabled,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.targetKind == this.targetKind &&
          other.targetId == this.targetId &&
          other.offsetMinutes == this.offsetMinutes &&
          other.timeOfDay == this.timeOfDay &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<int> id;
  final Value<String> targetKind;
  final Value<String> targetId;
  final Value<int> offsetMinutes;
  final Value<String?> timeOfDay;
  final Value<int> enabled;
  final Value<String> createdAt;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.targetKind = const Value.absent(),
    this.targetId = const Value.absent(),
    this.offsetMinutes = const Value.absent(),
    this.timeOfDay = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required String targetKind,
    required String targetId,
    this.offsetMinutes = const Value.absent(),
    this.timeOfDay = const Value.absent(),
    this.enabled = const Value.absent(),
    required String createdAt,
  }) : targetKind = Value(targetKind),
       targetId = Value(targetId),
       createdAt = Value(createdAt);
  static Insertable<ReminderRow> custom({
    Expression<int>? id,
    Expression<String>? targetKind,
    Expression<String>? targetId,
    Expression<int>? offsetMinutes,
    Expression<String>? timeOfDay,
    Expression<int>? enabled,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetKind != null) 'target_kind': targetKind,
      if (targetId != null) 'target_id': targetId,
      if (offsetMinutes != null) 'offset_minutes': offsetMinutes,
      if (timeOfDay != null) 'time_of_day': timeOfDay,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<String>? targetKind,
    Value<String>? targetId,
    Value<int>? offsetMinutes,
    Value<String?>? timeOfDay,
    Value<int>? enabled,
    Value<String>? createdAt,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      targetKind: targetKind ?? this.targetKind,
      targetId: targetId ?? this.targetId,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetKind.present) {
      map['target_kind'] = Variable<String>(targetKind.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (offsetMinutes.present) {
      map['offset_minutes'] = Variable<int>(offsetMinutes.value);
    }
    if (timeOfDay.present) {
      map['time_of_day'] = Variable<String>(timeOfDay.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<int>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('targetKind: $targetKind, ')
          ..write('targetId: $targetId, ')
          ..write('offsetMinutes: $offsetMinutes, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class Settings extends Table with TableInfo<Settings, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Settings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  Settings createAlias(String alias) {
    return Settings(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;

  /// keys listed in spec §15.1
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ErrorReportsQueue extends Table
    with TableInfo<ErrorReportsQueue, QueuedErrorReportRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ErrorReportsQueue(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'error_reports_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueuedErrorReportRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueuedErrorReportRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueuedErrorReportRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  ErrorReportsQueue createAlias(String alias) {
    return ErrorReportsQueue(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class QueuedErrorReportRow extends DataClass
    implements Insertable<QueuedErrorReportRow> {
  final int id;
  final String payload;

  /// JSON with only the fields in spec §15.3
  final String createdAt;
  const QueuedErrorReportRow({
    required this.id,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ErrorReportsQueueCompanion toCompanion(bool nullToAbsent) {
    return ErrorReportsQueueCompanion(
      id: Value(id),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory QueuedErrorReportRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueuedErrorReportRow(
      id: serializer.fromJson<int>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<String>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'payload': serializer.toJson<String>(payload),
      'created_at': serializer.toJson<String>(createdAt),
    };
  }

  QueuedErrorReportRow copyWith({
    int? id,
    String? payload,
    String? createdAt,
  }) => QueuedErrorReportRow(
    id: id ?? this.id,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  QueuedErrorReportRow copyWithCompanion(ErrorReportsQueueCompanion data) {
    return QueuedErrorReportRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueuedErrorReportRow(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueuedErrorReportRow &&
          other.id == this.id &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class ErrorReportsQueueCompanion extends UpdateCompanion<QueuedErrorReportRow> {
  final Value<int> id;
  final Value<String> payload;
  final Value<String> createdAt;
  const ErrorReportsQueueCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ErrorReportsQueueCompanion.insert({
    this.id = const Value.absent(),
    required String payload,
    required String createdAt,
  }) : payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<QueuedErrorReportRow> custom({
    Expression<int>? id,
    Expression<String>? payload,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ErrorReportsQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? payload,
    Value<String>? createdAt,
  }) {
    return ErrorReportsQueueCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ErrorReportsQueueCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class ObservanceCorrections extends Table
    with TableInfo<ObservanceCorrections, ObservanceCorrectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ObservanceCorrections(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _traditionMeta = const VerificationMeta(
    'tradition',
  );
  late final GeneratedColumn<String> tradition = GeneratedColumn<String>(
    'tradition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _observanceIdMeta = const VerificationMeta(
    'observanceId',
  );
  late final GeneratedColumn<String> observanceId = GeneratedColumn<String>(
    'observance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _correctedAtMeta = const VerificationMeta(
    'correctedAt',
  );
  late final GeneratedColumn<String> correctedAt = GeneratedColumn<String>(
    'corrected_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [tradition, observanceId, correctedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observance_corrections';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObservanceCorrectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tradition')) {
      context.handle(
        _traditionMeta,
        tradition.isAcceptableOrUnknown(data['tradition']!, _traditionMeta),
      );
    } else if (isInserting) {
      context.missing(_traditionMeta);
    }
    if (data.containsKey('observance_id')) {
      context.handle(
        _observanceIdMeta,
        observanceId.isAcceptableOrUnknown(
          data['observance_id']!,
          _observanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observanceIdMeta);
    }
    if (data.containsKey('corrected_at')) {
      context.handle(
        _correctedAtMeta,
        correctedAt.isAcceptableOrUnknown(
          data['corrected_at']!,
          _correctedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tradition, observanceId};
  @override
  ObservanceCorrectionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObservanceCorrectionRow(
      tradition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tradition'],
      )!,
      observanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observance_id'],
      )!,
      correctedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corrected_at'],
      )!,
    );
  }

  @override
  ObservanceCorrections createAlias(String alias) {
    return ObservanceCorrections(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(tradition, observance_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ObservanceCorrectionRow extends DataClass
    implements Insertable<ObservanceCorrectionRow> {
  final String tradition;
  final String observanceId;
  final String correctedAt;
  const ObservanceCorrectionRow({
    required this.tradition,
    required this.observanceId,
    required this.correctedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tradition'] = Variable<String>(tradition);
    map['observance_id'] = Variable<String>(observanceId);
    map['corrected_at'] = Variable<String>(correctedAt);
    return map;
  }

  ObservanceCorrectionsCompanion toCompanion(bool nullToAbsent) {
    return ObservanceCorrectionsCompanion(
      tradition: Value(tradition),
      observanceId: Value(observanceId),
      correctedAt: Value(correctedAt),
    );
  }

  factory ObservanceCorrectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObservanceCorrectionRow(
      tradition: serializer.fromJson<String>(json['tradition']),
      observanceId: serializer.fromJson<String>(json['observance_id']),
      correctedAt: serializer.fromJson<String>(json['corrected_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tradition': serializer.toJson<String>(tradition),
      'observance_id': serializer.toJson<String>(observanceId),
      'corrected_at': serializer.toJson<String>(correctedAt),
    };
  }

  ObservanceCorrectionRow copyWith({
    String? tradition,
    String? observanceId,
    String? correctedAt,
  }) => ObservanceCorrectionRow(
    tradition: tradition ?? this.tradition,
    observanceId: observanceId ?? this.observanceId,
    correctedAt: correctedAt ?? this.correctedAt,
  );
  ObservanceCorrectionRow copyWithCompanion(
    ObservanceCorrectionsCompanion data,
  ) {
    return ObservanceCorrectionRow(
      tradition: data.tradition.present ? data.tradition.value : this.tradition,
      observanceId: data.observanceId.present
          ? data.observanceId.value
          : this.observanceId,
      correctedAt: data.correctedAt.present
          ? data.correctedAt.value
          : this.correctedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObservanceCorrectionRow(')
          ..write('tradition: $tradition, ')
          ..write('observanceId: $observanceId, ')
          ..write('correctedAt: $correctedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tradition, observanceId, correctedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObservanceCorrectionRow &&
          other.tradition == this.tradition &&
          other.observanceId == this.observanceId &&
          other.correctedAt == this.correctedAt);
}

class ObservanceCorrectionsCompanion
    extends UpdateCompanion<ObservanceCorrectionRow> {
  final Value<String> tradition;
  final Value<String> observanceId;
  final Value<String> correctedAt;
  final Value<int> rowid;
  const ObservanceCorrectionsCompanion({
    this.tradition = const Value.absent(),
    this.observanceId = const Value.absent(),
    this.correctedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObservanceCorrectionsCompanion.insert({
    required String tradition,
    required String observanceId,
    required String correctedAt,
    this.rowid = const Value.absent(),
  }) : tradition = Value(tradition),
       observanceId = Value(observanceId),
       correctedAt = Value(correctedAt);
  static Insertable<ObservanceCorrectionRow> custom({
    Expression<String>? tradition,
    Expression<String>? observanceId,
    Expression<String>? correctedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tradition != null) 'tradition': tradition,
      if (observanceId != null) 'observance_id': observanceId,
      if (correctedAt != null) 'corrected_at': correctedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObservanceCorrectionsCompanion copyWith({
    Value<String>? tradition,
    Value<String>? observanceId,
    Value<String>? correctedAt,
    Value<int>? rowid,
  }) {
    return ObservanceCorrectionsCompanion(
      tradition: tradition ?? this.tradition,
      observanceId: observanceId ?? this.observanceId,
      correctedAt: correctedAt ?? this.correctedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tradition.present) {
      map['tradition'] = Variable<String>(tradition.value);
    }
    if (observanceId.present) {
      map['observance_id'] = Variable<String>(observanceId.value);
    }
    if (correctedAt.present) {
      map['corrected_at'] = Variable<String>(correctedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservanceCorrectionsCompanion(')
          ..write('tradition: $tradition, ')
          ..write('observanceId: $observanceId, ')
          ..write('correctedAt: $correctedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final Packs packs = Packs(this);
  late final Transitions transitions = Transitions(this);
  late final Cities cities = Cities(this);
  late final CityDays cityDays = CityDays(this);
  late final BengaliDates bengaliDates = BengaliDates(this);
  late final Names names = Names(this);
  late final Observances observances = Observances(this);
  late final ObservanceDates observanceDates = ObservanceDates(this);
  late final ObservanceWindows observanceWindows = ObservanceWindows(this);
  late final LunarMonths lunarMonths = LunarMonths(this);
  late final PeriodRules periodRules = PeriodRules(this);
  late final Reminders reminders = Reminders(this);
  late final Settings settings = Settings(this);
  late final ErrorReportsQueue errorReportsQueue = ErrorReportsQueue(this);
  late final ObservanceCorrections observanceCorrections =
      ObservanceCorrections(this);
  late final Index transitionsByStart = Index(
    'transitions_by_start',
    'CREATE INDEX transitions_by_start ON transitions (tradition, kind, starts_utc)',
  );
  late final Index transitionsByEnd = Index(
    'transitions_by_end',
    'CREATE INDEX transitions_by_end ON transitions (tradition, kind, ends_utc)',
  );
  Selectable<TransitionRow> transitionsOverlapping(
    String tradition,
    String kind,
    int fromUtc,
    int toUtc,
  ) {
    return customSelect(
      'SELECT * FROM transitions WHERE tradition = ?1 AND kind = ?2 AND ends_utc > ?3 AND starts_utc < ?4 ORDER BY starts_utc',
      variables: [
        Variable<String>(tradition),
        Variable<String>(kind),
        Variable<int>(fromUtc),
        Variable<int>(toUtc),
      ],
      readsFrom: {this.transitions},
    ).asyncMap(this.transitions.mapFromRow);
  }

  Selectable<CityDayRow> cityDay(String cityId, String date) {
    return customSelect(
      'SELECT * FROM city_days WHERE city_id = ?1 AND date = ?2',
      variables: [Variable<String>(cityId), Variable<String>(date)],
      readsFrom: {this.cityDays},
    ).asyncMap(this.cityDays.mapFromRow);
  }

  Selectable<BengaliDateRow> bengaliDateOn(String tradition, String date) {
    return customSelect(
      'SELECT * FROM bengali_dates WHERE tradition = ?1 AND date = ?2',
      variables: [Variable<String>(tradition), Variable<String>(date)],
      readsFrom: {this.bengaliDates},
    ).asyncMap(this.bengaliDates.mapFromRow);
  }

  Selectable<NameRow> namesOfKind(String kind) {
    return customSelect(
      'SELECT * FROM names WHERE kind = ?1 ORDER BY idx',
      variables: [Variable<String>(kind)],
      readsFrom: {this.names},
    ).asyncMap(this.names.mapFromRow);
  }

  Selectable<ObservancesBetweenResult> observancesBetween(
    String tradition,
    String fromDate,
    String toDate,
  ) {
    return customSelect(
      'SELECT"o"."id" AS "nested_0.id", "o"."name_bn" AS "nested_0.name_bn", "o"."name_en" AS "nested_0.name_en", "o"."category" AS "nested_0.category", "o"."tier" AS "nested_0.tier", "o"."description_bn" AS "nested_0.description_bn", "o"."description_en" AS "nested_0.description_en", "o"."pack_id" AS "nested_0.pack_id","d"."observance_id" AS "nested_1.observance_id", "d"."tradition" AS "nested_1.tradition", "d"."date" AS "nested_1.date", "d"."day_index" AS "nested_1.day_index", "d"."status" AS "nested_1.status", "d"."reviewed_by" AS "nested_1.reviewed_by", "d"."reviewed_on" AS "nested_1.reviewed_on", "d"."note_bn" AS "nested_1.note_bn", "d"."note_en" AS "nested_1.note_en", "d"."pack_id" AS "nested_1.pack_id" FROM observance_dates AS d JOIN observances AS o ON o.id = d.observance_id WHERE d.tradition = ?1 AND d.date BETWEEN ?2 AND ?3 ORDER BY d.date, o.tier, o.id',
      variables: [
        Variable<String>(tradition),
        Variable<String>(fromDate),
        Variable<String>(toDate),
      ],
      readsFrom: {this.observanceDates, this.observances},
    ).asyncMap(
      (QueryRow row) async => ObservancesBetweenResult(
        o: await this.observances.mapFromRow(row, tablePrefix: 'nested_0'),
        d: await this.observanceDates.mapFromRow(row, tablePrefix: 'nested_1'),
      ),
    );
  }

  Selectable<ObservanceDatesOfResult> observanceDatesOf(
    String tradition,
    String id,
  ) {
    return customSelect(
      'SELECT"o"."id" AS "nested_0.id", "o"."name_bn" AS "nested_0.name_bn", "o"."name_en" AS "nested_0.name_en", "o"."category" AS "nested_0.category", "o"."tier" AS "nested_0.tier", "o"."description_bn" AS "nested_0.description_bn", "o"."description_en" AS "nested_0.description_en", "o"."pack_id" AS "nested_0.pack_id","d"."observance_id" AS "nested_1.observance_id", "d"."tradition" AS "nested_1.tradition", "d"."date" AS "nested_1.date", "d"."day_index" AS "nested_1.day_index", "d"."status" AS "nested_1.status", "d"."reviewed_by" AS "nested_1.reviewed_by", "d"."reviewed_on" AS "nested_1.reviewed_on", "d"."note_bn" AS "nested_1.note_bn", "d"."note_en" AS "nested_1.note_en", "d"."pack_id" AS "nested_1.pack_id" FROM observance_dates AS d JOIN observances AS o ON o.id = d.observance_id WHERE d.tradition = ?1 AND d.observance_id = ?2 ORDER BY d.date',
      variables: [Variable<String>(tradition), Variable<String>(id)],
      readsFrom: {this.observanceDates, this.observances},
    ).asyncMap(
      (QueryRow row) async => ObservanceDatesOfResult(
        o: await this.observances.mapFromRow(row, tablePrefix: 'nested_0'),
        d: await this.observanceDates.mapFromRow(row, tablePrefix: 'nested_1'),
      ),
    );
  }

  Selectable<ObservanceWindowRow> windowsOf(String tradition, String id) {
    return customSelect(
      'SELECT * FROM observance_windows WHERE tradition = ?1 AND observance_id = ?2 ORDER BY date, start_utc',
      variables: [Variable<String>(tradition), Variable<String>(id)],
      readsFrom: {this.observanceWindows},
    ).asyncMap(this.observanceWindows.mapFromRow);
  }

  Selectable<ObservanceStartsResult> observanceStarts(String tradition) {
    return customSelect(
      'SELECT"o"."id" AS "nested_0.id", "o"."name_bn" AS "nested_0.name_bn", "o"."name_en" AS "nested_0.name_en", "o"."category" AS "nested_0.category", "o"."tier" AS "nested_0.tier", "o"."description_bn" AS "nested_0.description_bn", "o"."description_en" AS "nested_0.description_en", "o"."pack_id" AS "nested_0.pack_id","d"."observance_id" AS "nested_1.observance_id", "d"."tradition" AS "nested_1.tradition", "d"."date" AS "nested_1.date", "d"."day_index" AS "nested_1.day_index", "d"."status" AS "nested_1.status", "d"."reviewed_by" AS "nested_1.reviewed_by", "d"."reviewed_on" AS "nested_1.reviewed_on", "d"."note_bn" AS "nested_1.note_bn", "d"."note_en" AS "nested_1.note_en", "d"."pack_id" AS "nested_1.pack_id" FROM observance_dates AS d JOIN observances AS o ON o.id = d.observance_id WHERE d.tradition = ?1 AND d.day_index = 0 ORDER BY d.date',
      variables: [Variable<String>(tradition)],
      readsFrom: {this.observanceDates, this.observances},
    ).asyncMap(
      (QueryRow row) async => ObservanceStartsResult(
        o: await this.observances.mapFromRow(row, tablePrefix: 'nested_0'),
        d: await this.observanceDates.mapFromRow(row, tablePrefix: 'nested_1'),
      ),
    );
  }

  Selectable<BengaliDateRow> bengaliDatesOf(
    String tradition,
    int monthIdx,
    int day,
  ) {
    return customSelect(
      'SELECT * FROM bengali_dates WHERE tradition = ?1 AND bn_month_idx = ?2 AND bn_day = ?3 ORDER BY date',
      variables: [
        Variable<String>(tradition),
        Variable<int>(monthIdx),
        Variable<int>(day),
      ],
      readsFrom: {this.bengaliDates},
    ).asyncMap(this.bengaliDates.mapFromRow);
  }

  Selectable<ObservanceRow> observanceById(String id) {
    return customSelect(
      'SELECT * FROM observances WHERE id = ?1',
      variables: [Variable<String>(id)],
      readsFrom: {this.observances},
    ).asyncMap(this.observances.mapFromRow);
  }

  Selectable<ObservanceWindowRow> windowsOn(String tradition, String date) {
    return customSelect(
      'SELECT * FROM observance_windows WHERE tradition = ?1 AND date = ?2 ORDER BY start_utc',
      variables: [Variable<String>(tradition), Variable<String>(date)],
      readsFrom: {this.observanceWindows},
    ).asyncMap(this.observanceWindows.mapFromRow);
  }

  Selectable<PackRow> packById(String id) {
    return customSelect(
      'SELECT * FROM packs WHERE id = ?1',
      variables: [Variable<String>(id)],
      readsFrom: {this.packs},
    ).asyncMap(this.packs.mapFromRow);
  }

  Selectable<CityDayRow> cityDaysBetween(
    String cityId,
    String fromDate,
    String toDate,
  ) {
    return customSelect(
      'SELECT * FROM city_days WHERE city_id = ?1 AND date BETWEEN ?2 AND ?3 ORDER BY date',
      variables: [
        Variable<String>(cityId),
        Variable<String>(fromDate),
        Variable<String>(toDate),
      ],
      readsFrom: {this.cityDays},
    ).asyncMap(this.cityDays.mapFromRow);
  }

  Selectable<BengaliDateRow> bengaliDatesBetween(
    String tradition,
    String fromDate,
    String toDate,
  ) {
    return customSelect(
      'SELECT * FROM bengali_dates WHERE tradition = ?1 AND date BETWEEN ?2 AND ?3 ORDER BY date',
      variables: [
        Variable<String>(tradition),
        Variable<String>(fromDate),
        Variable<String>(toDate),
      ],
      readsFrom: {this.bengaliDates},
    ).asyncMap(this.bengaliDates.mapFromRow);
  }

  Selectable<BengaliDateRow> bengaliMonthDates(
    String tradition,
    int bnYear,
    int bnMonthIdx,
  ) {
    return customSelect(
      'SELECT * FROM bengali_dates WHERE tradition = ?1 AND bn_year = ?2 AND bn_month_idx = ?3 ORDER BY date',
      variables: [
        Variable<String>(tradition),
        Variable<int>(bnYear),
        Variable<int>(bnMonthIdx),
      ],
      readsFrom: {this.bengaliDates},
    ).asyncMap(this.bengaliDates.mapFromRow);
  }

  Selectable<LunarMonthRow> lunarMonthsOverlapping(
    String tradition,
    int fromUtc,
    int toUtc,
  ) {
    return customSelect(
      'SELECT * FROM lunar_months WHERE tradition = ?1 AND ends_utc > ?2 AND starts_utc < ?3 ORDER BY starts_utc',
      variables: [
        Variable<String>(tradition),
        Variable<int>(fromUtc),
        Variable<int>(toUtc),
      ],
      readsFrom: {this.lunarMonths},
    ).asyncMap(this.lunarMonths.mapFromRow);
  }

  Selectable<PeriodRuleRow> enabledPeriodRules(String tradition) {
    return customSelect(
      'SELECT * FROM period_rules WHERE tradition = ?1 AND enabled = 1',
      variables: [Variable<String>(tradition)],
      readsFrom: {this.periodRules},
    ).asyncMap(this.periodRules.mapFromRow);
  }

  Selectable<CityRow> cityById(String id) {
    return customSelect(
      'SELECT * FROM cities WHERE id = ?1',
      variables: [Variable<String>(id)],
      readsFrom: {this.cities},
    ).asyncMap(this.cities.mapFromRow);
  }

  Selectable<NameRow> allNames() {
    return customSelect(
      'SELECT * FROM names ORDER BY kind, idx',
      variables: [],
      readsFrom: {this.names},
    ).asyncMap(this.names.mapFromRow);
  }

  Selectable<PackRow> packsOfTradition(String tradition, String kind) {
    return customSelect(
      'SELECT * FROM packs WHERE tradition = ?1 AND kind = ?2',
      variables: [Variable<String>(tradition), Variable<String>(kind)],
      readsFrom: {this.packs},
    ).asyncMap(this.packs.mapFromRow);
  }

  Selectable<CityRow> allCities() {
    return customSelect(
      'SELECT * FROM cities ORDER BY name_en',
      variables: [],
      readsFrom: {this.cities},
    ).asyncMap(this.cities.mapFromRow);
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    packs,
    transitions,
    cities,
    cityDays,
    bengaliDates,
    names,
    observances,
    observanceDates,
    observanceWindows,
    lunarMonths,
    periodRules,
    reminders,
    settings,
    errorReportsQueue,
    observanceCorrections,
    transitionsByStart,
    transitionsByEnd,
  ];
}

typedef $PacksCreateCompanionBuilder = PacksCompanion Function({
  required String id,
  required String tradition,
  required String kind,
  Value<int> isSample,
  required String coversFrom,
  required String coversTo,
  required int version,
  required String generatedAt,
  required String engineVersion,
  Value<String?> ephemerisSha256,
  Value<String?> validationSummary,
  Value<String?> installedAt,
  Value<String?> sha256,
  Value<int> rowid,
});
typedef $PacksUpdateCompanionBuilder = PacksCompanion Function({
  Value<String> id,
  Value<String> tradition,
  Value<String> kind,
  Value<int> isSample,
  Value<String> coversFrom,
  Value<String> coversTo,
  Value<int> version,
  Value<String> generatedAt,
  Value<String> engineVersion,
  Value<String?> ephemerisSha256,
  Value<String?> validationSummary,
  Value<String?> installedAt,
  Value<String?> sha256,
  Value<int> rowid,
});

final class $PacksReferences
    extends BaseReferences<_$AppDatabase, Packs, PackRow> {
  $PacksReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Transitions, List<TransitionRow>>
  _transitionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transitions,
    aliasName: 'packs__id__transitions__pack_id',
  );

  $TransitionsProcessedTableManager get transitionsRefs {
    final manager = $TransitionsTableManager(
      $_db,
      $_db.transitions,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transitionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Cities, List<CityRow>> _citiesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cities,
    aliasName: 'packs__id__cities__pack_id',
  );

  $CitiesProcessedTableManager get citiesRefs {
    final manager = $CitiesTableManager(
      $_db,
      $_db.cities,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_citiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<CityDays, List<CityDayRow>> _cityDaysRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cityDays,
    aliasName: 'packs__id__city_days__pack_id',
  );

  $CityDaysProcessedTableManager get cityDaysRefs {
    final manager = $CityDaysTableManager(
      $_db,
      $_db.cityDays,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cityDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<BengaliDates, List<BengaliDateRow>>
  _bengaliDatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bengaliDates,
    aliasName: 'packs__id__bengali_dates__pack_id',
  );

  $BengaliDatesProcessedTableManager get bengaliDatesRefs {
    final manager = $BengaliDatesTableManager(
      $_db,
      $_db.bengaliDates,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bengaliDatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Names, List<NameRow>> _namesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.names,
    aliasName: 'packs__id__names__pack_id',
  );

  $NamesProcessedTableManager get namesRefs {
    final manager = $NamesTableManager(
      $_db,
      $_db.names,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_namesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Observances, List<ObservanceRow>>
  _observancesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.observances,
    aliasName: 'packs__id__observances__pack_id',
  );

  $ObservancesProcessedTableManager get observancesRefs {
    final manager = $ObservancesTableManager(
      $_db,
      $_db.observances,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_observancesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<ObservanceDates, List<ObservanceDateRow>>
  _observanceDatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.observanceDates,
    aliasName: 'packs__id__observance_dates__pack_id',
  );

  $ObservanceDatesProcessedTableManager get observanceDatesRefs {
    final manager = $ObservanceDatesTableManager(
      $_db,
      $_db.observanceDates,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _observanceDatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<ObservanceWindows, List<ObservanceWindowRow>>
  _observanceWindowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.observanceWindows,
        aliasName: 'packs__id__observance_windows__pack_id',
      );

  $ObservanceWindowsProcessedTableManager get observanceWindowsRefs {
    final manager = $ObservanceWindowsTableManager(
      $_db,
      $_db.observanceWindows,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _observanceWindowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<LunarMonths, List<LunarMonthRow>>
  _lunarMonthsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lunarMonths,
    aliasName: 'packs__id__lunar_months__pack_id',
  );

  $LunarMonthsProcessedTableManager get lunarMonthsRefs {
    final manager = $LunarMonthsTableManager(
      $_db,
      $_db.lunarMonths,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lunarMonthsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<PeriodRules, List<PeriodRuleRow>>
  _periodRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.periodRules,
    aliasName: 'packs__id__period_rules__pack_id',
  );

  $PeriodRulesProcessedTableManager get periodRulesRefs {
    final manager = $PeriodRulesTableManager(
      $_db,
      $_db.periodRules,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_periodRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $PacksFilterComposer extends Composer<_$AppDatabase, Packs> {
  $PacksFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSample => $composableBuilder(
    column: $table.isSample,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coversFrom => $composableBuilder(
    column: $table.coversFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coversTo => $composableBuilder(
    column: $table.coversTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engineVersion => $composableBuilder(
    column: $table.engineVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ephemerisSha256 => $composableBuilder(
    column: $table.ephemerisSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validationSummary => $composableBuilder(
    column: $table.validationSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transitionsRefs(
    Expression<bool> Function($TransitionsFilterComposer f) f,
  ) {
    final $TransitionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transitions,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TransitionsFilterComposer(
            $db: $db,
            $table: $db.transitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> citiesRefs(
    Expression<bool> Function($CitiesFilterComposer f) f,
  ) {
    final $CitiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cities,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CitiesFilterComposer(
            $db: $db,
            $table: $db.cities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cityDaysRefs(
    Expression<bool> Function($CityDaysFilterComposer f) f,
  ) {
    final $CityDaysFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cityDays,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CityDaysFilterComposer(
            $db: $db,
            $table: $db.cityDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bengaliDatesRefs(
    Expression<bool> Function($BengaliDatesFilterComposer f) f,
  ) {
    final $BengaliDatesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bengaliDates,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BengaliDatesFilterComposer(
            $db: $db,
            $table: $db.bengaliDates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> namesRefs(
    Expression<bool> Function($NamesFilterComposer f) f,
  ) {
    final $NamesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.names,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $NamesFilterComposer(
            $db: $db,
            $table: $db.names,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> observancesRefs(
    Expression<bool> Function($ObservancesFilterComposer f) f,
  ) {
    final $ObservancesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observances,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ObservancesFilterComposer(
            $db: $db,
            $table: $db.observances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> observanceDatesRefs(
    Expression<bool> Function($ObservanceDatesFilterComposer f) f,
  ) {
    final $ObservanceDatesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observanceDates,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ObservanceDatesFilterComposer(
            $db: $db,
            $table: $db.observanceDates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> observanceWindowsRefs(
    Expression<bool> Function($ObservanceWindowsFilterComposer f) f,
  ) {
    final $ObservanceWindowsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observanceWindows,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ObservanceWindowsFilterComposer(
            $db: $db,
            $table: $db.observanceWindows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lunarMonthsRefs(
    Expression<bool> Function($LunarMonthsFilterComposer f) f,
  ) {
    final $LunarMonthsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lunarMonths,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LunarMonthsFilterComposer(
            $db: $db,
            $table: $db.lunarMonths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> periodRulesRefs(
    Expression<bool> Function($PeriodRulesFilterComposer f) f,
  ) {
    final $PeriodRulesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.periodRules,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PeriodRulesFilterComposer(
            $db: $db,
            $table: $db.periodRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PacksOrderingComposer extends Composer<_$AppDatabase, Packs> {
  $PacksOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSample => $composableBuilder(
    column: $table.isSample,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coversFrom => $composableBuilder(
    column: $table.coversFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coversTo => $composableBuilder(
    column: $table.coversTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engineVersion => $composableBuilder(
    column: $table.engineVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ephemerisSha256 => $composableBuilder(
    column: $table.ephemerisSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validationSummary => $composableBuilder(
    column: $table.validationSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );
}

class $PacksAnnotationComposer extends Composer<_$AppDatabase, Packs> {
  $PacksAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tradition =>
      $composableBuilder(column: $table.tradition, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get isSample =>
      $composableBuilder(column: $table.isSample, builder: (column) => column);

  GeneratedColumn<String> get coversFrom => $composableBuilder(
    column: $table.coversFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coversTo =>
      $composableBuilder(column: $table.coversTo, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get engineVersion => $composableBuilder(
    column: $table.engineVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ephemerisSha256 => $composableBuilder(
    column: $table.ephemerisSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get validationSummary => $composableBuilder(
    column: $table.validationSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  Expression<T> transitionsRefs<T extends Object>(
    Expression<T> Function($TransitionsAnnotationComposer a) f,
  ) {
    final $TransitionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transitions,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TransitionsAnnotationComposer(
            $db: $db,
            $table: $db.transitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> citiesRefs<T extends Object>(
    Expression<T> Function($CitiesAnnotationComposer a) f,
  ) {
    final $CitiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cities,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CitiesAnnotationComposer(
            $db: $db,
            $table: $db.cities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cityDaysRefs<T extends Object>(
    Expression<T> Function($CityDaysAnnotationComposer a) f,
  ) {
    final $CityDaysAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cityDays,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CityDaysAnnotationComposer(
            $db: $db,
            $table: $db.cityDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bengaliDatesRefs<T extends Object>(
    Expression<T> Function($BengaliDatesAnnotationComposer a) f,
  ) {
    final $BengaliDatesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bengaliDates,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BengaliDatesAnnotationComposer(
            $db: $db,
            $table: $db.bengaliDates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> namesRefs<T extends Object>(
    Expression<T> Function($NamesAnnotationComposer a) f,
  ) {
    final $NamesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.names,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $NamesAnnotationComposer(
            $db: $db,
            $table: $db.names,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> observancesRefs<T extends Object>(
    Expression<T> Function($ObservancesAnnotationComposer a) f,
  ) {
    final $ObservancesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observances,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ObservancesAnnotationComposer(
            $db: $db,
            $table: $db.observances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> observanceDatesRefs<T extends Object>(
    Expression<T> Function($ObservanceDatesAnnotationComposer a) f,
  ) {
    final $ObservanceDatesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observanceDates,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ObservanceDatesAnnotationComposer(
            $db: $db,
            $table: $db.observanceDates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> observanceWindowsRefs<T extends Object>(
    Expression<T> Function($ObservanceWindowsAnnotationComposer a) f,
  ) {
    final $ObservanceWindowsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observanceWindows,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ObservanceWindowsAnnotationComposer(
            $db: $db,
            $table: $db.observanceWindows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lunarMonthsRefs<T extends Object>(
    Expression<T> Function($LunarMonthsAnnotationComposer a) f,
  ) {
    final $LunarMonthsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lunarMonths,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LunarMonthsAnnotationComposer(
            $db: $db,
            $table: $db.lunarMonths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> periodRulesRefs<T extends Object>(
    Expression<T> Function($PeriodRulesAnnotationComposer a) f,
  ) {
    final $PeriodRulesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.periodRules,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PeriodRulesAnnotationComposer(
            $db: $db,
            $table: $db.periodRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PacksTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Packs,
          PackRow,
          $PacksFilterComposer,
          $PacksOrderingComposer,
          $PacksAnnotationComposer,
          $PacksCreateCompanionBuilder,
          $PacksUpdateCompanionBuilder,
          (PackRow, $PacksReferences),
          PackRow,
          PrefetchHooks Function({
            bool transitionsRefs,
            bool citiesRefs,
            bool cityDaysRefs,
            bool bengaliDatesRefs,
            bool namesRefs,
            bool observancesRefs,
            bool observanceDatesRefs,
            bool observanceWindowsRefs,
            bool lunarMonthsRefs,
            bool periodRulesRefs,
          })
        > {
  $PacksTableManager(_$AppDatabase db, Packs table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PacksFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PacksOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PacksAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tradition = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> isSample = const Value.absent(),
                Value<String> coversFrom = const Value.absent(),
                Value<String> coversTo = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> generatedAt = const Value.absent(),
                Value<String> engineVersion = const Value.absent(),
                Value<String?> ephemerisSha256 = const Value.absent(),
                Value<String?> validationSummary = const Value.absent(),
                Value<String?> installedAt = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PacksCompanion(
                id: id,
                tradition: tradition,
                kind: kind,
                isSample: isSample,
                coversFrom: coversFrom,
                coversTo: coversTo,
                version: version,
                generatedAt: generatedAt,
                engineVersion: engineVersion,
                ephemerisSha256: ephemerisSha256,
                validationSummary: validationSummary,
                installedAt: installedAt,
                sha256: sha256,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tradition,
                required String kind,
                Value<int> isSample = const Value.absent(),
                required String coversFrom,
                required String coversTo,
                required int version,
                required String generatedAt,
                required String engineVersion,
                Value<String?> ephemerisSha256 = const Value.absent(),
                Value<String?> validationSummary = const Value.absent(),
                Value<String?> installedAt = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PacksCompanion.insert(
                id: id,
                tradition: tradition,
                kind: kind,
                isSample: isSample,
                coversFrom: coversFrom,
                coversTo: coversTo,
                version: version,
                generatedAt: generatedAt,
                engineVersion: engineVersion,
                ephemerisSha256: ephemerisSha256,
                validationSummary: validationSummary,
                installedAt: installedAt,
                sha256: sha256,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Packs, PackRow>(table),
                  $PacksReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                transitionsRefs = false,
                citiesRefs = false,
                cityDaysRefs = false,
                bengaliDatesRefs = false,
                namesRefs = false,
                observancesRefs = false,
                observanceDatesRefs = false,
                observanceWindowsRefs = false,
                lunarMonthsRefs = false,
                periodRulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transitionsRefs) db.transitions,
                    if (citiesRefs) db.cities,
                    if (cityDaysRefs) db.cityDays,
                    if (bengaliDatesRefs) db.bengaliDates,
                    if (namesRefs) db.names,
                    if (observancesRefs) db.observances,
                    if (observanceDatesRefs) db.observanceDates,
                    if (observanceWindowsRefs) db.observanceWindows,
                    if (lunarMonthsRefs) db.lunarMonths,
                    if (periodRulesRefs) db.periodRules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transitionsRefs)
                        await $_getPrefetchedData<
                          PackRow,
                          Packs,
                          TransitionRow
                        >(
                          currentTable: table,
                          referencedTable: $PacksReferences
                              ._transitionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $PacksReferences(db, table, p0).transitionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (citiesRefs)
                        await $_getPrefetchedData<PackRow, Packs, CityRow>(
                          currentTable: table,
                          referencedTable: $PacksReferences._citiesRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $PacksReferences(db, table, p0).citiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cityDaysRefs)
                        await $_getPrefetchedData<PackRow, Packs, CityDayRow>(
                          currentTable: table,
                          referencedTable: $PacksReferences._cityDaysRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $PacksReferences(db, table, p0).cityDaysRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bengaliDatesRefs)
                        await $_getPrefetchedData<
                          PackRow,
                          Packs,
                          BengaliDateRow
                        >(
                          currentTable: table,
                          referencedTable: $PacksReferences
                              ._bengaliDatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $PacksReferences(db, table, p0).bengaliDatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (namesRefs)
                        await $_getPrefetchedData<PackRow, Packs, NameRow>(
                          currentTable: table,
                          referencedTable: $PacksReferences._namesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $PacksReferences(db, table, p0).namesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (observancesRefs)
                        await $_getPrefetchedData<
                          PackRow,
                          Packs,
                          ObservanceRow
                        >(
                          currentTable: table,
                          referencedTable: $PacksReferences
                              ._observancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $PacksReferences(db, table, p0).observancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (observanceDatesRefs)
                        await $_getPrefetchedData<
                          PackRow,
                          Packs,
                          ObservanceDateRow
                        >(
                          currentTable: table,
                          referencedTable: $PacksReferences
                              ._observanceDatesRefsTable(db),
                          managerFromTypedResult: (p0) => $PacksReferences(
                            db,
                            table,
                            p0,
                          ).observanceDatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (observanceWindowsRefs)
                        await $_getPrefetchedData<
                          PackRow,
                          Packs,
                          ObservanceWindowRow
                        >(
                          currentTable: table,
                          referencedTable: $PacksReferences
                              ._observanceWindowsRefsTable(db),
                          managerFromTypedResult: (p0) => $PacksReferences(
                            db,
                            table,
                            p0,
                          ).observanceWindowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lunarMonthsRefs)
                        await $_getPrefetchedData<
                          PackRow,
                          Packs,
                          LunarMonthRow
                        >(
                          currentTable: table,
                          referencedTable: $PacksReferences
                              ._lunarMonthsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $PacksReferences(db, table, p0).lunarMonthsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (periodRulesRefs)
                        await $_getPrefetchedData<
                          PackRow,
                          Packs,
                          PeriodRuleRow
                        >(
                          currentTable: table,
                          referencedTable: $PacksReferences
                              ._periodRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $PacksReferences(db, table, p0).periodRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $PacksProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Packs,
      PackRow,
      $PacksFilterComposer,
      $PacksOrderingComposer,
      $PacksAnnotationComposer,
      $PacksCreateCompanionBuilder,
      $PacksUpdateCompanionBuilder,
      (PackRow, $PacksReferences),
      PackRow,
      PrefetchHooks Function({
        bool transitionsRefs,
        bool citiesRefs,
        bool cityDaysRefs,
        bool bengaliDatesRefs,
        bool namesRefs,
        bool observancesRefs,
        bool observanceDatesRefs,
        bool observanceWindowsRefs,
        bool lunarMonthsRefs,
        bool periodRulesRefs,
      })
    >;
typedef $TransitionsCreateCompanionBuilder = TransitionsCompanion Function({
  Value<int> id,
  required String packId,
  required String tradition,
  required String kind,
  required int idx,
  required int startsUtc,
  required int endsUtc,
});
typedef $TransitionsUpdateCompanionBuilder = TransitionsCompanion Function({
  Value<int> id,
  Value<String> packId,
  Value<String> tradition,
  Value<String> kind,
  Value<int> idx,
  Value<int> startsUtc,
  Value<int> endsUtc,
});

final class $TransitionsReferences
    extends BaseReferences<_$AppDatabase, Transitions, TransitionRow> {
  $TransitionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Packs _packIdTable(_$AppDatabase db) =>
      db.packs.createAlias('transitions__pack_id__packs__id');

  $PacksProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $PacksTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $TransitionsFilterComposer extends Composer<_$AppDatabase, Transitions> {
  $TransitionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startsUtc => $composableBuilder(
    column: $table.startsUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endsUtc => $composableBuilder(
    column: $table.endsUtc,
    builder: (column) => ColumnFilters(column),
  );

  $PacksFilterComposer get packId {
    final $PacksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransitionsOrderingComposer
    extends Composer<_$AppDatabase, Transitions> {
  $TransitionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startsUtc => $composableBuilder(
    column: $table.startsUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endsUtc => $composableBuilder(
    column: $table.endsUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $PacksOrderingComposer get packId {
    final $PacksOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransitionsAnnotationComposer
    extends Composer<_$AppDatabase, Transitions> {
  $TransitionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tradition =>
      $composableBuilder(column: $table.tradition, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumn<int> get startsUtc =>
      $composableBuilder(column: $table.startsUtc, builder: (column) => column);

  GeneratedColumn<int> get endsUtc =>
      $composableBuilder(column: $table.endsUtc, builder: (column) => column);

  $PacksAnnotationComposer get packId {
    final $PacksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransitionsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Transitions,
          TransitionRow,
          $TransitionsFilterComposer,
          $TransitionsOrderingComposer,
          $TransitionsAnnotationComposer,
          $TransitionsCreateCompanionBuilder,
          $TransitionsUpdateCompanionBuilder,
          (TransitionRow, $TransitionsReferences),
          TransitionRow,
          PrefetchHooks Function({bool packId})
        > {
  $TransitionsTableManager(_$AppDatabase db, Transitions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TransitionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TransitionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TransitionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<String> tradition = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> idx = const Value.absent(),
                Value<int> startsUtc = const Value.absent(),
                Value<int> endsUtc = const Value.absent(),
              }) => TransitionsCompanion(
                id: id,
                packId: packId,
                tradition: tradition,
                kind: kind,
                idx: idx,
                startsUtc: startsUtc,
                endsUtc: endsUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packId,
                required String tradition,
                required String kind,
                required int idx,
                required int startsUtc,
                required int endsUtc,
              }) => TransitionsCompanion.insert(
                id: id,
                packId: packId,
                tradition: tradition,
                kind: kind,
                idx: idx,
                startsUtc: startsUtc,
                endsUtc: endsUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Transitions, TransitionRow>(table),
                  $TransitionsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $TransitionsReferences._packIdTable(
                          db,
                        ),
                        referencedColumn: $TransitionsReferences
                            ._packIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $TransitionsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Transitions,
      TransitionRow,
      $TransitionsFilterComposer,
      $TransitionsOrderingComposer,
      $TransitionsAnnotationComposer,
      $TransitionsCreateCompanionBuilder,
      $TransitionsUpdateCompanionBuilder,
      (TransitionRow, $TransitionsReferences),
      TransitionRow,
      PrefetchHooks Function({bool packId})
    >;
typedef $CitiesCreateCompanionBuilder = CitiesCompanion Function({
  required String id,
  required String nameBn,
  required String nameEn,
  Value<String> aliases,
  required String districtBn,
  required String districtEn,
  required String state,
  required double lat,
  required double lon,
  Value<int> elevationM,
  required String tz,
  Value<int> popular,
  required String packId,
  Value<int> rowid,
});
typedef $CitiesUpdateCompanionBuilder = CitiesCompanion Function({
  Value<String> id,
  Value<String> nameBn,
  Value<String> nameEn,
  Value<String> aliases,
  Value<String> districtBn,
  Value<String> districtEn,
  Value<String> state,
  Value<double> lat,
  Value<double> lon,
  Value<int> elevationM,
  Value<String> tz,
  Value<int> popular,
  Value<String> packId,
  Value<int> rowid,
});

final class $CitiesReferences
    extends BaseReferences<_$AppDatabase, Cities, CityRow> {
  $CitiesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Packs _packIdTable(_$AppDatabase db) =>
      db.packs.createAlias('cities__pack_id__packs__id');

  $PacksProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $PacksTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<CityDays, List<CityDayRow>> _cityDaysRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cityDays,
    aliasName: 'cities__id__city_days__city_id',
  );

  $CityDaysProcessedTableManager get cityDaysRefs {
    final manager = $CityDaysTableManager(
      $_db,
      $_db.cityDays,
    ).filter((f) => f.cityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cityDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $CitiesFilterComposer extends Composer<_$AppDatabase, Cities> {
  $CitiesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameBn => $composableBuilder(
    column: $table.nameBn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get districtBn => $composableBuilder(
    column: $table.districtBn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get districtEn => $composableBuilder(
    column: $table.districtEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elevationM => $composableBuilder(
    column: $table.elevationM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tz => $composableBuilder(
    column: $table.tz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get popular => $composableBuilder(
    column: $table.popular,
    builder: (column) => ColumnFilters(column),
  );

  $PacksFilterComposer get packId {
    final $PacksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cityDaysRefs(
    Expression<bool> Function($CityDaysFilterComposer f) f,
  ) {
    final $CityDaysFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cityDays,
      getReferencedColumn: (t) => t.cityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CityDaysFilterComposer(
            $db: $db,
            $table: $db.cityDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CitiesOrderingComposer extends Composer<_$AppDatabase, Cities> {
  $CitiesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameBn => $composableBuilder(
    column: $table.nameBn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get districtBn => $composableBuilder(
    column: $table.districtBn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get districtEn => $composableBuilder(
    column: $table.districtEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elevationM => $composableBuilder(
    column: $table.elevationM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tz => $composableBuilder(
    column: $table.tz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get popular => $composableBuilder(
    column: $table.popular,
    builder: (column) => ColumnOrderings(column),
  );

  $PacksOrderingComposer get packId {
    final $PacksOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CitiesAnnotationComposer extends Composer<_$AppDatabase, Cities> {
  $CitiesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameBn =>
      $composableBuilder(column: $table.nameBn, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);

  GeneratedColumn<String> get districtBn => $composableBuilder(
    column: $table.districtBn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get districtEn => $composableBuilder(
    column: $table.districtEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<int> get elevationM => $composableBuilder(
    column: $table.elevationM,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tz =>
      $composableBuilder(column: $table.tz, builder: (column) => column);

  GeneratedColumn<int> get popular =>
      $composableBuilder(column: $table.popular, builder: (column) => column);

  $PacksAnnotationComposer get packId {
    final $PacksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cityDaysRefs<T extends Object>(
    Expression<T> Function($CityDaysAnnotationComposer a) f,
  ) {
    final $CityDaysAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cityDays,
      getReferencedColumn: (t) => t.cityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CityDaysAnnotationComposer(
            $db: $db,
            $table: $db.cityDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CitiesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Cities,
          CityRow,
          $CitiesFilterComposer,
          $CitiesOrderingComposer,
          $CitiesAnnotationComposer,
          $CitiesCreateCompanionBuilder,
          $CitiesUpdateCompanionBuilder,
          (CityRow, $CitiesReferences),
          CityRow,
          PrefetchHooks Function({bool packId, bool cityDaysRefs})
        > {
  $CitiesTableManager(_$AppDatabase db, Cities table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CitiesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CitiesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CitiesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nameBn = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> aliases = const Value.absent(),
                Value<String> districtBn = const Value.absent(),
                Value<String> districtEn = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<int> elevationM = const Value.absent(),
                Value<String> tz = const Value.absent(),
                Value<int> popular = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CitiesCompanion(
                id: id,
                nameBn: nameBn,
                nameEn: nameEn,
                aliases: aliases,
                districtBn: districtBn,
                districtEn: districtEn,
                state: state,
                lat: lat,
                lon: lon,
                elevationM: elevationM,
                tz: tz,
                popular: popular,
                packId: packId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nameBn,
                required String nameEn,
                Value<String> aliases = const Value.absent(),
                required String districtBn,
                required String districtEn,
                required String state,
                required double lat,
                required double lon,
                Value<int> elevationM = const Value.absent(),
                required String tz,
                Value<int> popular = const Value.absent(),
                required String packId,
                Value<int> rowid = const Value.absent(),
              }) => CitiesCompanion.insert(
                id: id,
                nameBn: nameBn,
                nameEn: nameEn,
                aliases: aliases,
                districtBn: districtBn,
                districtEn: districtEn,
                state: state,
                lat: lat,
                lon: lon,
                elevationM: elevationM,
                tz: tz,
                popular: popular,
                packId: packId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Cities, CityRow>(table),
                  $CitiesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packId = false, cityDaysRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cityDaysRefs) db.cityDays],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $CitiesReferences._packIdTable(db),
                        referencedColumn: $CitiesReferences._packIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cityDaysRefs)
                    await $_getPrefetchedData<CityRow, Cities, CityDayRow>(
                      currentTable: table,
                      referencedTable: $CitiesReferences._cityDaysRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $CitiesReferences(db, table, p0).cityDaysRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.cityId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $CitiesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Cities,
      CityRow,
      $CitiesFilterComposer,
      $CitiesOrderingComposer,
      $CitiesAnnotationComposer,
      $CitiesCreateCompanionBuilder,
      $CitiesUpdateCompanionBuilder,
      (CityRow, $CitiesReferences),
      CityRow,
      PrefetchHooks Function({bool packId, bool cityDaysRefs})
    >;
typedef $CityDaysCreateCompanionBuilder = CityDaysCompanion Function({
  required String cityId,
  required String date,
  required int sunriseUtc,
  required int sunsetUtc,
  Value<int?> moonriseUtc,
  Value<int?> moonsetUtc,
  required String packId,
  Value<int> rowid,
});
typedef $CityDaysUpdateCompanionBuilder = CityDaysCompanion Function({
  Value<String> cityId,
  Value<String> date,
  Value<int> sunriseUtc,
  Value<int> sunsetUtc,
  Value<int?> moonriseUtc,
  Value<int?> moonsetUtc,
  Value<String> packId,
  Value<int> rowid,
});

final class $CityDaysReferences
    extends BaseReferences<_$AppDatabase, CityDays, CityDayRow> {
  $CityDaysReferences(super.$_db, super.$_table, super.$_typedResult);

  static Cities _cityIdTable(_$AppDatabase db) =>
      db.cities.createAlias('city_days__city_id__cities__id');

  $CitiesProcessedTableManager get cityId {
    final $_column = $_itemColumn<String>('city_id')!;

    final manager = $CitiesTableManager(
      $_db,
      $_db.cities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Packs _packIdTable(_$AppDatabase db) =>
      db.packs.createAlias('city_days__pack_id__packs__id');

  $PacksProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $PacksTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $CityDaysFilterComposer extends Composer<_$AppDatabase, CityDays> {
  $CityDaysFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sunriseUtc => $composableBuilder(
    column: $table.sunriseUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sunsetUtc => $composableBuilder(
    column: $table.sunsetUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get moonriseUtc => $composableBuilder(
    column: $table.moonriseUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get moonsetUtc => $composableBuilder(
    column: $table.moonsetUtc,
    builder: (column) => ColumnFilters(column),
  );

  $CitiesFilterComposer get cityId {
    final $CitiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cityId,
      referencedTable: $db.cities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CitiesFilterComposer(
            $db: $db,
            $table: $db.cities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PacksFilterComposer get packId {
    final $PacksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CityDaysOrderingComposer extends Composer<_$AppDatabase, CityDays> {
  $CityDaysOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sunriseUtc => $composableBuilder(
    column: $table.sunriseUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sunsetUtc => $composableBuilder(
    column: $table.sunsetUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get moonriseUtc => $composableBuilder(
    column: $table.moonriseUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get moonsetUtc => $composableBuilder(
    column: $table.moonsetUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $CitiesOrderingComposer get cityId {
    final $CitiesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cityId,
      referencedTable: $db.cities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CitiesOrderingComposer(
            $db: $db,
            $table: $db.cities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PacksOrderingComposer get packId {
    final $PacksOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CityDaysAnnotationComposer extends Composer<_$AppDatabase, CityDays> {
  $CityDaysAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get sunriseUtc => $composableBuilder(
    column: $table.sunriseUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sunsetUtc =>
      $composableBuilder(column: $table.sunsetUtc, builder: (column) => column);

  GeneratedColumn<int> get moonriseUtc => $composableBuilder(
    column: $table.moonriseUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get moonsetUtc => $composableBuilder(
    column: $table.moonsetUtc,
    builder: (column) => column,
  );

  $CitiesAnnotationComposer get cityId {
    final $CitiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cityId,
      referencedTable: $db.cities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CitiesAnnotationComposer(
            $db: $db,
            $table: $db.cities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PacksAnnotationComposer get packId {
    final $PacksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CityDaysTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          CityDays,
          CityDayRow,
          $CityDaysFilterComposer,
          $CityDaysOrderingComposer,
          $CityDaysAnnotationComposer,
          $CityDaysCreateCompanionBuilder,
          $CityDaysUpdateCompanionBuilder,
          (CityDayRow, $CityDaysReferences),
          CityDayRow,
          PrefetchHooks Function({bool cityId, bool packId})
        > {
  $CityDaysTableManager(_$AppDatabase db, CityDays table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CityDaysFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CityDaysOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CityDaysAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cityId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> sunriseUtc = const Value.absent(),
                Value<int> sunsetUtc = const Value.absent(),
                Value<int?> moonriseUtc = const Value.absent(),
                Value<int?> moonsetUtc = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CityDaysCompanion(
                cityId: cityId,
                date: date,
                sunriseUtc: sunriseUtc,
                sunsetUtc: sunsetUtc,
                moonriseUtc: moonriseUtc,
                moonsetUtc: moonsetUtc,
                packId: packId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cityId,
                required String date,
                required int sunriseUtc,
                required int sunsetUtc,
                Value<int?> moonriseUtc = const Value.absent(),
                Value<int?> moonsetUtc = const Value.absent(),
                required String packId,
                Value<int> rowid = const Value.absent(),
              }) => CityDaysCompanion.insert(
                cityId: cityId,
                date: date,
                sunriseUtc: sunriseUtc,
                sunsetUtc: sunsetUtc,
                moonriseUtc: moonriseUtc,
                moonsetUtc: moonsetUtc,
                packId: packId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<CityDays, CityDayRow>(table),
                  $CityDaysReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cityId = false, packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cityId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cityId,
                        referencedTable: $CityDaysReferences._cityIdTable(db),
                        referencedColumn: $CityDaysReferences
                            ._cityIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $CityDaysReferences._packIdTable(db),
                        referencedColumn: $CityDaysReferences
                            ._packIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $CityDaysProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      CityDays,
      CityDayRow,
      $CityDaysFilterComposer,
      $CityDaysOrderingComposer,
      $CityDaysAnnotationComposer,
      $CityDaysCreateCompanionBuilder,
      $CityDaysUpdateCompanionBuilder,
      (CityDayRow, $CityDaysReferences),
      CityDayRow,
      PrefetchHooks Function({bool cityId, bool packId})
    >;
typedef $BengaliDatesCreateCompanionBuilder = BengaliDatesCompanion Function({
  required String tradition,
  required String date,
  required int bnDay,
  required int bnMonthIdx,
  required int bnYear,
  required String packId,
  Value<int> rowid,
});
typedef $BengaliDatesUpdateCompanionBuilder = BengaliDatesCompanion Function({
  Value<String> tradition,
  Value<String> date,
  Value<int> bnDay,
  Value<int> bnMonthIdx,
  Value<int> bnYear,
  Value<String> packId,
  Value<int> rowid,
});

final class $BengaliDatesReferences
    extends BaseReferences<_$AppDatabase, BengaliDates, BengaliDateRow> {
  $BengaliDatesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Packs _packIdTable(_$AppDatabase db) =>
      db.packs.createAlias('bengali_dates__pack_id__packs__id');

  $PacksProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $PacksTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $BengaliDatesFilterComposer
    extends Composer<_$AppDatabase, BengaliDates> {
  $BengaliDatesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bnDay => $composableBuilder(
    column: $table.bnDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bnMonthIdx => $composableBuilder(
    column: $table.bnMonthIdx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bnYear => $composableBuilder(
    column: $table.bnYear,
    builder: (column) => ColumnFilters(column),
  );

  $PacksFilterComposer get packId {
    final $PacksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $BengaliDatesOrderingComposer
    extends Composer<_$AppDatabase, BengaliDates> {
  $BengaliDatesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bnDay => $composableBuilder(
    column: $table.bnDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bnMonthIdx => $composableBuilder(
    column: $table.bnMonthIdx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bnYear => $composableBuilder(
    column: $table.bnYear,
    builder: (column) => ColumnOrderings(column),
  );

  $PacksOrderingComposer get packId {
    final $PacksOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $BengaliDatesAnnotationComposer
    extends Composer<_$AppDatabase, BengaliDates> {
  $BengaliDatesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tradition =>
      $composableBuilder(column: $table.tradition, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get bnDay =>
      $composableBuilder(column: $table.bnDay, builder: (column) => column);

  GeneratedColumn<int> get bnMonthIdx => $composableBuilder(
    column: $table.bnMonthIdx,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bnYear =>
      $composableBuilder(column: $table.bnYear, builder: (column) => column);

  $PacksAnnotationComposer get packId {
    final $PacksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $BengaliDatesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          BengaliDates,
          BengaliDateRow,
          $BengaliDatesFilterComposer,
          $BengaliDatesOrderingComposer,
          $BengaliDatesAnnotationComposer,
          $BengaliDatesCreateCompanionBuilder,
          $BengaliDatesUpdateCompanionBuilder,
          (BengaliDateRow, $BengaliDatesReferences),
          BengaliDateRow,
          PrefetchHooks Function({bool packId})
        > {
  $BengaliDatesTableManager(_$AppDatabase db, BengaliDates table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BengaliDatesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BengaliDatesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BengaliDatesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tradition = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> bnDay = const Value.absent(),
                Value<int> bnMonthIdx = const Value.absent(),
                Value<int> bnYear = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BengaliDatesCompanion(
                tradition: tradition,
                date: date,
                bnDay: bnDay,
                bnMonthIdx: bnMonthIdx,
                bnYear: bnYear,
                packId: packId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tradition,
                required String date,
                required int bnDay,
                required int bnMonthIdx,
                required int bnYear,
                required String packId,
                Value<int> rowid = const Value.absent(),
              }) => BengaliDatesCompanion.insert(
                tradition: tradition,
                date: date,
                bnDay: bnDay,
                bnMonthIdx: bnMonthIdx,
                bnYear: bnYear,
                packId: packId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<BengaliDates, BengaliDateRow>(table),
                  $BengaliDatesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $BengaliDatesReferences._packIdTable(
                          db,
                        ),
                        referencedColumn: $BengaliDatesReferences
                            ._packIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $BengaliDatesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      BengaliDates,
      BengaliDateRow,
      $BengaliDatesFilterComposer,
      $BengaliDatesOrderingComposer,
      $BengaliDatesAnnotationComposer,
      $BengaliDatesCreateCompanionBuilder,
      $BengaliDatesUpdateCompanionBuilder,
      (BengaliDateRow, $BengaliDatesReferences),
      BengaliDateRow,
      PrefetchHooks Function({bool packId})
    >;
typedef $NamesCreateCompanionBuilder = NamesCompanion Function({
  required String kind,
  required int idx,
  required String nameBn,
  required String nameEn,
  required String translit,
  Value<String?> glossBn,
  Value<String?> glossEn,
  required String packId,
  Value<int> rowid,
});
typedef $NamesUpdateCompanionBuilder = NamesCompanion Function({
  Value<String> kind,
  Value<int> idx,
  Value<String> nameBn,
  Value<String> nameEn,
  Value<String> translit,
  Value<String?> glossBn,
  Value<String?> glossEn,
  Value<String> packId,
  Value<int> rowid,
});

final class $NamesReferences
    extends BaseReferences<_$AppDatabase, Names, NameRow> {
  $NamesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Packs _packIdTable(_$AppDatabase db) =>
      db.packs.createAlias('names__pack_id__packs__id');

  $PacksProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $PacksTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $NamesFilterComposer extends Composer<_$AppDatabase, Names> {
  $NamesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameBn => $composableBuilder(
    column: $table.nameBn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translit => $composableBuilder(
    column: $table.translit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get glossBn => $composableBuilder(
    column: $table.glossBn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get glossEn => $composableBuilder(
    column: $table.glossEn,
    builder: (column) => ColumnFilters(column),
  );

  $PacksFilterComposer get packId {
    final $PacksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $NamesOrderingComposer extends Composer<_$AppDatabase, Names> {
  $NamesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameBn => $composableBuilder(
    column: $table.nameBn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translit => $composableBuilder(
    column: $table.translit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get glossBn => $composableBuilder(
    column: $table.glossBn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get glossEn => $composableBuilder(
    column: $table.glossEn,
    builder: (column) => ColumnOrderings(column),
  );

  $PacksOrderingComposer get packId {
    final $PacksOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $NamesAnnotationComposer extends Composer<_$AppDatabase, Names> {
  $NamesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumn<String> get nameBn =>
      $composableBuilder(column: $table.nameBn, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get translit =>
      $composableBuilder(column: $table.translit, builder: (column) => column);

  GeneratedColumn<String> get glossBn =>
      $composableBuilder(column: $table.glossBn, builder: (column) => column);

  GeneratedColumn<String> get glossEn =>
      $composableBuilder(column: $table.glossEn, builder: (column) => column);

  $PacksAnnotationComposer get packId {
    final $PacksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $NamesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Names,
          NameRow,
          $NamesFilterComposer,
          $NamesOrderingComposer,
          $NamesAnnotationComposer,
          $NamesCreateCompanionBuilder,
          $NamesUpdateCompanionBuilder,
          (NameRow, $NamesReferences),
          NameRow,
          PrefetchHooks Function({bool packId})
        > {
  $NamesTableManager(_$AppDatabase db, Names table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $NamesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $NamesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $NamesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> kind = const Value.absent(),
                Value<int> idx = const Value.absent(),
                Value<String> nameBn = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> translit = const Value.absent(),
                Value<String?> glossBn = const Value.absent(),
                Value<String?> glossEn = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NamesCompanion(
                kind: kind,
                idx: idx,
                nameBn: nameBn,
                nameEn: nameEn,
                translit: translit,
                glossBn: glossBn,
                glossEn: glossEn,
                packId: packId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String kind,
                required int idx,
                required String nameBn,
                required String nameEn,
                required String translit,
                Value<String?> glossBn = const Value.absent(),
                Value<String?> glossEn = const Value.absent(),
                required String packId,
                Value<int> rowid = const Value.absent(),
              }) => NamesCompanion.insert(
                kind: kind,
                idx: idx,
                nameBn: nameBn,
                nameEn: nameEn,
                translit: translit,
                glossBn: glossBn,
                glossEn: glossEn,
                packId: packId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Names, NameRow>(table),
                  $NamesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $NamesReferences._packIdTable(db),
                        referencedColumn: $NamesReferences._packIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $NamesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Names,
      NameRow,
      $NamesFilterComposer,
      $NamesOrderingComposer,
      $NamesAnnotationComposer,
      $NamesCreateCompanionBuilder,
      $NamesUpdateCompanionBuilder,
      (NameRow, $NamesReferences),
      NameRow,
      PrefetchHooks Function({bool packId})
    >;
typedef $ObservancesCreateCompanionBuilder = ObservancesCompanion Function({
  required String id,
  required String nameBn,
  required String nameEn,
  required String category,
  required int tier,
  required String descriptionBn,
  required String descriptionEn,
  required String packId,
  Value<int> rowid,
});
typedef $ObservancesUpdateCompanionBuilder = ObservancesCompanion Function({
  Value<String> id,
  Value<String> nameBn,
  Value<String> nameEn,
  Value<String> category,
  Value<int> tier,
  Value<String> descriptionBn,
  Value<String> descriptionEn,
  Value<String> packId,
  Value<int> rowid,
});

final class $ObservancesReferences
    extends BaseReferences<_$AppDatabase, Observances, ObservanceRow> {
  $ObservancesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Packs _packIdTable(_$AppDatabase db) =>
      db.packs.createAlias('observances__pack_id__packs__id');

  $PacksProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $PacksTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<ObservanceDates, List<ObservanceDateRow>>
  _observanceDatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.observanceDates,
    aliasName: 'observances__id__observance_dates__observance_id',
  );

  $ObservanceDatesProcessedTableManager get observanceDatesRefs {
    final manager = $ObservanceDatesTableManager(
      $_db,
      $_db.observanceDates,
    ).filter((f) => f.observanceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _observanceDatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ObservancesFilterComposer extends Composer<_$AppDatabase, Observances> {
  $ObservancesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameBn => $composableBuilder(
    column: $table.nameBn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionBn => $composableBuilder(
    column: $table.descriptionBn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnFilters(column),
  );

  $PacksFilterComposer get packId {
    final $PacksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> observanceDatesRefs(
    Expression<bool> Function($ObservanceDatesFilterComposer f) f,
  ) {
    final $ObservanceDatesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observanceDates,
      getReferencedColumn: (t) => t.observanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ObservanceDatesFilterComposer(
            $db: $db,
            $table: $db.observanceDates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ObservancesOrderingComposer
    extends Composer<_$AppDatabase, Observances> {
  $ObservancesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameBn => $composableBuilder(
    column: $table.nameBn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionBn => $composableBuilder(
    column: $table.descriptionBn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => ColumnOrderings(column),
  );

  $PacksOrderingComposer get packId {
    final $PacksOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ObservancesAnnotationComposer
    extends Composer<_$AppDatabase, Observances> {
  $ObservancesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameBn =>
      $composableBuilder(column: $table.nameBn, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<String> get descriptionBn => $composableBuilder(
    column: $table.descriptionBn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionEn => $composableBuilder(
    column: $table.descriptionEn,
    builder: (column) => column,
  );

  $PacksAnnotationComposer get packId {
    final $PacksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> observanceDatesRefs<T extends Object>(
    Expression<T> Function($ObservanceDatesAnnotationComposer a) f,
  ) {
    final $ObservanceDatesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observanceDates,
      getReferencedColumn: (t) => t.observanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ObservanceDatesAnnotationComposer(
            $db: $db,
            $table: $db.observanceDates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ObservancesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Observances,
          ObservanceRow,
          $ObservancesFilterComposer,
          $ObservancesOrderingComposer,
          $ObservancesAnnotationComposer,
          $ObservancesCreateCompanionBuilder,
          $ObservancesUpdateCompanionBuilder,
          (ObservanceRow, $ObservancesReferences),
          ObservanceRow,
          PrefetchHooks Function({bool packId, bool observanceDatesRefs})
        > {
  $ObservancesTableManager(_$AppDatabase db, Observances table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ObservancesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ObservancesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ObservancesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nameBn = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> tier = const Value.absent(),
                Value<String> descriptionBn = const Value.absent(),
                Value<String> descriptionEn = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservancesCompanion(
                id: id,
                nameBn: nameBn,
                nameEn: nameEn,
                category: category,
                tier: tier,
                descriptionBn: descriptionBn,
                descriptionEn: descriptionEn,
                packId: packId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nameBn,
                required String nameEn,
                required String category,
                required int tier,
                required String descriptionBn,
                required String descriptionEn,
                required String packId,
                Value<int> rowid = const Value.absent(),
              }) => ObservancesCompanion.insert(
                id: id,
                nameBn: nameBn,
                nameEn: nameEn,
                category: category,
                tier: tier,
                descriptionBn: descriptionBn,
                descriptionEn: descriptionEn,
                packId: packId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Observances, ObservanceRow>(table),
                  $ObservancesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({packId = false, observanceDatesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (observanceDatesRefs) db.observanceDates,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (packId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.packId,
                            referencedTable: $ObservancesReferences
                                ._packIdTable(db),
                            referencedColumn: $ObservancesReferences
                                ._packIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (observanceDatesRefs)
                        await $_getPrefetchedData<
                          ObservanceRow,
                          Observances,
                          ObservanceDateRow
                        >(
                          currentTable: table,
                          referencedTable: $ObservancesReferences
                              ._observanceDatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ObservancesReferences(
                                db,
                                table,
                                p0,
                              ).observanceDatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.observanceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $ObservancesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Observances,
      ObservanceRow,
      $ObservancesFilterComposer,
      $ObservancesOrderingComposer,
      $ObservancesAnnotationComposer,
      $ObservancesCreateCompanionBuilder,
      $ObservancesUpdateCompanionBuilder,
      (ObservanceRow, $ObservancesReferences),
      ObservanceRow,
      PrefetchHooks Function({bool packId, bool observanceDatesRefs})
    >;
typedef $ObservanceDatesCreateCompanionBuilder =
    ObservanceDatesCompanion Function({
      required String observanceId,
      required String tradition,
      required String date,
      Value<int> dayIndex,
      required String status,
      Value<String?> reviewedBy,
      Value<String?> reviewedOn,
      Value<String?> noteBn,
      Value<String?> noteEn,
      required String packId,
      Value<int> rowid,
    });
typedef $ObservanceDatesUpdateCompanionBuilder =
    ObservanceDatesCompanion Function({
      Value<String> observanceId,
      Value<String> tradition,
      Value<String> date,
      Value<int> dayIndex,
      Value<String> status,
      Value<String?> reviewedBy,
      Value<String?> reviewedOn,
      Value<String?> noteBn,
      Value<String?> noteEn,
      Value<String> packId,
      Value<int> rowid,
    });

final class $ObservanceDatesReferences
    extends BaseReferences<_$AppDatabase, ObservanceDates, ObservanceDateRow> {
  $ObservanceDatesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Observances _observanceIdTable(_$AppDatabase db) => db.observances
      .createAlias('observance_dates__observance_id__observances__id');

  $ObservancesProcessedTableManager get observanceId {
    final $_column = $_itemColumn<String>('observance_id')!;

    final manager = $ObservancesTableManager(
      $_db,
      $_db.observances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_observanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Packs _packIdTable(_$AppDatabase db) =>
      db.packs.createAlias('observance_dates__pack_id__packs__id');

  $PacksProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $PacksTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ObservanceDatesFilterComposer
    extends Composer<_$AppDatabase, ObservanceDates> {
  $ObservanceDatesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewedBy => $composableBuilder(
    column: $table.reviewedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewedOn => $composableBuilder(
    column: $table.reviewedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteBn => $composableBuilder(
    column: $table.noteBn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteEn => $composableBuilder(
    column: $table.noteEn,
    builder: (column) => ColumnFilters(column),
  );

  $ObservancesFilterComposer get observanceId {
    final $ObservancesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observanceId,
      referencedTable: $db.observances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ObservancesFilterComposer(
            $db: $db,
            $table: $db.observances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PacksFilterComposer get packId {
    final $PacksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ObservanceDatesOrderingComposer
    extends Composer<_$AppDatabase, ObservanceDates> {
  $ObservanceDatesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewedBy => $composableBuilder(
    column: $table.reviewedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewedOn => $composableBuilder(
    column: $table.reviewedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteBn => $composableBuilder(
    column: $table.noteBn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteEn => $composableBuilder(
    column: $table.noteEn,
    builder: (column) => ColumnOrderings(column),
  );

  $ObservancesOrderingComposer get observanceId {
    final $ObservancesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observanceId,
      referencedTable: $db.observances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ObservancesOrderingComposer(
            $db: $db,
            $table: $db.observances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PacksOrderingComposer get packId {
    final $PacksOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ObservanceDatesAnnotationComposer
    extends Composer<_$AppDatabase, ObservanceDates> {
  $ObservanceDatesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tradition =>
      $composableBuilder(column: $table.tradition, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reviewedBy => $composableBuilder(
    column: $table.reviewedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewedOn => $composableBuilder(
    column: $table.reviewedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noteBn =>
      $composableBuilder(column: $table.noteBn, builder: (column) => column);

  GeneratedColumn<String> get noteEn =>
      $composableBuilder(column: $table.noteEn, builder: (column) => column);

  $ObservancesAnnotationComposer get observanceId {
    final $ObservancesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observanceId,
      referencedTable: $db.observances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ObservancesAnnotationComposer(
            $db: $db,
            $table: $db.observances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PacksAnnotationComposer get packId {
    final $PacksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ObservanceDatesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ObservanceDates,
          ObservanceDateRow,
          $ObservanceDatesFilterComposer,
          $ObservanceDatesOrderingComposer,
          $ObservanceDatesAnnotationComposer,
          $ObservanceDatesCreateCompanionBuilder,
          $ObservanceDatesUpdateCompanionBuilder,
          (ObservanceDateRow, $ObservanceDatesReferences),
          ObservanceDateRow,
          PrefetchHooks Function({bool observanceId, bool packId})
        > {
  $ObservanceDatesTableManager(_$AppDatabase db, ObservanceDates table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ObservanceDatesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ObservanceDatesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ObservanceDatesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> observanceId = const Value.absent(),
                Value<String> tradition = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> reviewedBy = const Value.absent(),
                Value<String?> reviewedOn = const Value.absent(),
                Value<String?> noteBn = const Value.absent(),
                Value<String?> noteEn = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservanceDatesCompanion(
                observanceId: observanceId,
                tradition: tradition,
                date: date,
                dayIndex: dayIndex,
                status: status,
                reviewedBy: reviewedBy,
                reviewedOn: reviewedOn,
                noteBn: noteBn,
                noteEn: noteEn,
                packId: packId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String observanceId,
                required String tradition,
                required String date,
                Value<int> dayIndex = const Value.absent(),
                required String status,
                Value<String?> reviewedBy = const Value.absent(),
                Value<String?> reviewedOn = const Value.absent(),
                Value<String?> noteBn = const Value.absent(),
                Value<String?> noteEn = const Value.absent(),
                required String packId,
                Value<int> rowid = const Value.absent(),
              }) => ObservanceDatesCompanion.insert(
                observanceId: observanceId,
                tradition: tradition,
                date: date,
                dayIndex: dayIndex,
                status: status,
                reviewedBy: reviewedBy,
                reviewedOn: reviewedOn,
                noteBn: noteBn,
                noteEn: noteEn,
                packId: packId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ObservanceDates, ObservanceDateRow>(table),
                  $ObservanceDatesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({observanceId = false, packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (observanceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.observanceId,
                        referencedTable: $ObservanceDatesReferences
                            ._observanceIdTable(db),
                        referencedColumn: $ObservanceDatesReferences
                            ._observanceIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $ObservanceDatesReferences
                            ._packIdTable(db),
                        referencedColumn: $ObservanceDatesReferences
                            ._packIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $ObservanceDatesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ObservanceDates,
      ObservanceDateRow,
      $ObservanceDatesFilterComposer,
      $ObservanceDatesOrderingComposer,
      $ObservanceDatesAnnotationComposer,
      $ObservanceDatesCreateCompanionBuilder,
      $ObservanceDatesUpdateCompanionBuilder,
      (ObservanceDateRow, $ObservanceDatesReferences),
      ObservanceDateRow,
      PrefetchHooks Function({bool observanceId, bool packId})
    >;
typedef $ObservanceWindowsCreateCompanionBuilder =
    ObservanceWindowsCompanion Function({
      required String observanceId,
      required String tradition,
      required String date,
      required String windowKind,
      required int startUtc,
      required int endUtc,
      required String packId,
      Value<int> rowid,
    });
typedef $ObservanceWindowsUpdateCompanionBuilder =
    ObservanceWindowsCompanion Function({
      Value<String> observanceId,
      Value<String> tradition,
      Value<String> date,
      Value<String> windowKind,
      Value<int> startUtc,
      Value<int> endUtc,
      Value<String> packId,
      Value<int> rowid,
    });

final class $ObservanceWindowsReferences
    extends
        BaseReferences<_$AppDatabase, ObservanceWindows, ObservanceWindowRow> {
  $ObservanceWindowsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Packs _packIdTable(_$AppDatabase db) =>
      db.packs.createAlias('observance_windows__pack_id__packs__id');

  $PacksProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $PacksTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ObservanceWindowsFilterComposer
    extends Composer<_$AppDatabase, ObservanceWindows> {
  $ObservanceWindowsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get observanceId => $composableBuilder(
    column: $table.observanceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get windowKind => $composableBuilder(
    column: $table.windowKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startUtc => $composableBuilder(
    column: $table.startUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endUtc => $composableBuilder(
    column: $table.endUtc,
    builder: (column) => ColumnFilters(column),
  );

  $PacksFilterComposer get packId {
    final $PacksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ObservanceWindowsOrderingComposer
    extends Composer<_$AppDatabase, ObservanceWindows> {
  $ObservanceWindowsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get observanceId => $composableBuilder(
    column: $table.observanceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get windowKind => $composableBuilder(
    column: $table.windowKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startUtc => $composableBuilder(
    column: $table.startUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endUtc => $composableBuilder(
    column: $table.endUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $PacksOrderingComposer get packId {
    final $PacksOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ObservanceWindowsAnnotationComposer
    extends Composer<_$AppDatabase, ObservanceWindows> {
  $ObservanceWindowsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get observanceId => $composableBuilder(
    column: $table.observanceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tradition =>
      $composableBuilder(column: $table.tradition, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get windowKind => $composableBuilder(
    column: $table.windowKind,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumn<int> get endUtc =>
      $composableBuilder(column: $table.endUtc, builder: (column) => column);

  $PacksAnnotationComposer get packId {
    final $PacksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ObservanceWindowsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ObservanceWindows,
          ObservanceWindowRow,
          $ObservanceWindowsFilterComposer,
          $ObservanceWindowsOrderingComposer,
          $ObservanceWindowsAnnotationComposer,
          $ObservanceWindowsCreateCompanionBuilder,
          $ObservanceWindowsUpdateCompanionBuilder,
          (ObservanceWindowRow, $ObservanceWindowsReferences),
          ObservanceWindowRow,
          PrefetchHooks Function({bool packId})
        > {
  $ObservanceWindowsTableManager(_$AppDatabase db, ObservanceWindows table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ObservanceWindowsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ObservanceWindowsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ObservanceWindowsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> observanceId = const Value.absent(),
                Value<String> tradition = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> windowKind = const Value.absent(),
                Value<int> startUtc = const Value.absent(),
                Value<int> endUtc = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservanceWindowsCompanion(
                observanceId: observanceId,
                tradition: tradition,
                date: date,
                windowKind: windowKind,
                startUtc: startUtc,
                endUtc: endUtc,
                packId: packId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String observanceId,
                required String tradition,
                required String date,
                required String windowKind,
                required int startUtc,
                required int endUtc,
                required String packId,
                Value<int> rowid = const Value.absent(),
              }) => ObservanceWindowsCompanion.insert(
                observanceId: observanceId,
                tradition: tradition,
                date: date,
                windowKind: windowKind,
                startUtc: startUtc,
                endUtc: endUtc,
                packId: packId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ObservanceWindows, ObservanceWindowRow>(table),
                  $ObservanceWindowsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $ObservanceWindowsReferences
                            ._packIdTable(db),
                        referencedColumn: $ObservanceWindowsReferences
                            ._packIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $ObservanceWindowsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ObservanceWindows,
      ObservanceWindowRow,
      $ObservanceWindowsFilterComposer,
      $ObservanceWindowsOrderingComposer,
      $ObservanceWindowsAnnotationComposer,
      $ObservanceWindowsCreateCompanionBuilder,
      $ObservanceWindowsUpdateCompanionBuilder,
      (ObservanceWindowRow, $ObservanceWindowsReferences),
      ObservanceWindowRow,
      PrefetchHooks Function({bool packId})
    >;
typedef $LunarMonthsCreateCompanionBuilder = LunarMonthsCompanion Function({
  required String tradition,
  required int monthIdx,
  required int isAdhik,
  required int startsUtc,
  required int endsUtc,
  required String packId,
  Value<int> rowid,
});
typedef $LunarMonthsUpdateCompanionBuilder = LunarMonthsCompanion Function({
  Value<String> tradition,
  Value<int> monthIdx,
  Value<int> isAdhik,
  Value<int> startsUtc,
  Value<int> endsUtc,
  Value<String> packId,
  Value<int> rowid,
});

final class $LunarMonthsReferences
    extends BaseReferences<_$AppDatabase, LunarMonths, LunarMonthRow> {
  $LunarMonthsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Packs _packIdTable(_$AppDatabase db) =>
      db.packs.createAlias('lunar_months__pack_id__packs__id');

  $PacksProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $PacksTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $LunarMonthsFilterComposer extends Composer<_$AppDatabase, LunarMonths> {
  $LunarMonthsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthIdx => $composableBuilder(
    column: $table.monthIdx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isAdhik => $composableBuilder(
    column: $table.isAdhik,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startsUtc => $composableBuilder(
    column: $table.startsUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endsUtc => $composableBuilder(
    column: $table.endsUtc,
    builder: (column) => ColumnFilters(column),
  );

  $PacksFilterComposer get packId {
    final $PacksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LunarMonthsOrderingComposer
    extends Composer<_$AppDatabase, LunarMonths> {
  $LunarMonthsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthIdx => $composableBuilder(
    column: $table.monthIdx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isAdhik => $composableBuilder(
    column: $table.isAdhik,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startsUtc => $composableBuilder(
    column: $table.startsUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endsUtc => $composableBuilder(
    column: $table.endsUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $PacksOrderingComposer get packId {
    final $PacksOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LunarMonthsAnnotationComposer
    extends Composer<_$AppDatabase, LunarMonths> {
  $LunarMonthsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tradition =>
      $composableBuilder(column: $table.tradition, builder: (column) => column);

  GeneratedColumn<int> get monthIdx =>
      $composableBuilder(column: $table.monthIdx, builder: (column) => column);

  GeneratedColumn<int> get isAdhik =>
      $composableBuilder(column: $table.isAdhik, builder: (column) => column);

  GeneratedColumn<int> get startsUtc =>
      $composableBuilder(column: $table.startsUtc, builder: (column) => column);

  GeneratedColumn<int> get endsUtc =>
      $composableBuilder(column: $table.endsUtc, builder: (column) => column);

  $PacksAnnotationComposer get packId {
    final $PacksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LunarMonthsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          LunarMonths,
          LunarMonthRow,
          $LunarMonthsFilterComposer,
          $LunarMonthsOrderingComposer,
          $LunarMonthsAnnotationComposer,
          $LunarMonthsCreateCompanionBuilder,
          $LunarMonthsUpdateCompanionBuilder,
          (LunarMonthRow, $LunarMonthsReferences),
          LunarMonthRow,
          PrefetchHooks Function({bool packId})
        > {
  $LunarMonthsTableManager(_$AppDatabase db, LunarMonths table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LunarMonthsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LunarMonthsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LunarMonthsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tradition = const Value.absent(),
                Value<int> monthIdx = const Value.absent(),
                Value<int> isAdhik = const Value.absent(),
                Value<int> startsUtc = const Value.absent(),
                Value<int> endsUtc = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LunarMonthsCompanion(
                tradition: tradition,
                monthIdx: monthIdx,
                isAdhik: isAdhik,
                startsUtc: startsUtc,
                endsUtc: endsUtc,
                packId: packId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tradition,
                required int monthIdx,
                required int isAdhik,
                required int startsUtc,
                required int endsUtc,
                required String packId,
                Value<int> rowid = const Value.absent(),
              }) => LunarMonthsCompanion.insert(
                tradition: tradition,
                monthIdx: monthIdx,
                isAdhik: isAdhik,
                startsUtc: startsUtc,
                endsUtc: endsUtc,
                packId: packId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<LunarMonths, LunarMonthRow>(table),
                  $LunarMonthsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $LunarMonthsReferences._packIdTable(
                          db,
                        ),
                        referencedColumn: $LunarMonthsReferences
                            ._packIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $LunarMonthsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      LunarMonths,
      LunarMonthRow,
      $LunarMonthsFilterComposer,
      $LunarMonthsOrderingComposer,
      $LunarMonthsAnnotationComposer,
      $LunarMonthsCreateCompanionBuilder,
      $LunarMonthsUpdateCompanionBuilder,
      (LunarMonthRow, $LunarMonthsReferences),
      LunarMonthRow,
      PrefetchHooks Function({bool packId})
    >;
typedef $PeriodRulesCreateCompanionBuilder = PeriodRulesCompanion Function({
  required String tradition,
  required int nameIdx,
  required String kind,
  required int weekday,
  required String basis,
  required int divisions,
  required int part,
  Value<int> enabled,
  required String packId,
  Value<int> rowid,
});
typedef $PeriodRulesUpdateCompanionBuilder = PeriodRulesCompanion Function({
  Value<String> tradition,
  Value<int> nameIdx,
  Value<String> kind,
  Value<int> weekday,
  Value<String> basis,
  Value<int> divisions,
  Value<int> part,
  Value<int> enabled,
  Value<String> packId,
  Value<int> rowid,
});

final class $PeriodRulesReferences
    extends BaseReferences<_$AppDatabase, PeriodRules, PeriodRuleRow> {
  $PeriodRulesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Packs _packIdTable(_$AppDatabase db) =>
      db.packs.createAlias('period_rules__pack_id__packs__id');

  $PacksProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $PacksTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $PeriodRulesFilterComposer extends Composer<_$AppDatabase, PeriodRules> {
  $PeriodRulesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nameIdx => $composableBuilder(
    column: $table.nameIdx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get basis => $composableBuilder(
    column: $table.basis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get divisions => $composableBuilder(
    column: $table.divisions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get part => $composableBuilder(
    column: $table.part,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  $PacksFilterComposer get packId {
    final $PacksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PeriodRulesOrderingComposer
    extends Composer<_$AppDatabase, PeriodRules> {
  $PeriodRulesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nameIdx => $composableBuilder(
    column: $table.nameIdx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basis => $composableBuilder(
    column: $table.basis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get divisions => $composableBuilder(
    column: $table.divisions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get part => $composableBuilder(
    column: $table.part,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  $PacksOrderingComposer get packId {
    final $PacksOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PeriodRulesAnnotationComposer
    extends Composer<_$AppDatabase, PeriodRules> {
  $PeriodRulesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tradition =>
      $composableBuilder(column: $table.tradition, builder: (column) => column);

  GeneratedColumn<int> get nameIdx =>
      $composableBuilder(column: $table.nameIdx, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<String> get basis =>
      $composableBuilder(column: $table.basis, builder: (column) => column);

  GeneratedColumn<int> get divisions =>
      $composableBuilder(column: $table.divisions, builder: (column) => column);

  GeneratedColumn<int> get part =>
      $composableBuilder(column: $table.part, builder: (column) => column);

  GeneratedColumn<int> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  $PacksAnnotationComposer get packId {
    final $PacksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PacksAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PeriodRulesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          PeriodRules,
          PeriodRuleRow,
          $PeriodRulesFilterComposer,
          $PeriodRulesOrderingComposer,
          $PeriodRulesAnnotationComposer,
          $PeriodRulesCreateCompanionBuilder,
          $PeriodRulesUpdateCompanionBuilder,
          (PeriodRuleRow, $PeriodRulesReferences),
          PeriodRuleRow,
          PrefetchHooks Function({bool packId})
        > {
  $PeriodRulesTableManager(_$AppDatabase db, PeriodRules table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PeriodRulesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PeriodRulesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PeriodRulesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tradition = const Value.absent(),
                Value<int> nameIdx = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<String> basis = const Value.absent(),
                Value<int> divisions = const Value.absent(),
                Value<int> part = const Value.absent(),
                Value<int> enabled = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeriodRulesCompanion(
                tradition: tradition,
                nameIdx: nameIdx,
                kind: kind,
                weekday: weekday,
                basis: basis,
                divisions: divisions,
                part: part,
                enabled: enabled,
                packId: packId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tradition,
                required int nameIdx,
                required String kind,
                required int weekday,
                required String basis,
                required int divisions,
                required int part,
                Value<int> enabled = const Value.absent(),
                required String packId,
                Value<int> rowid = const Value.absent(),
              }) => PeriodRulesCompanion.insert(
                tradition: tradition,
                nameIdx: nameIdx,
                kind: kind,
                weekday: weekday,
                basis: basis,
                divisions: divisions,
                part: part,
                enabled: enabled,
                packId: packId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PeriodRules, PeriodRuleRow>(table),
                  $PeriodRulesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $PeriodRulesReferences._packIdTable(
                          db,
                        ),
                        referencedColumn: $PeriodRulesReferences
                            ._packIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $PeriodRulesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      PeriodRules,
      PeriodRuleRow,
      $PeriodRulesFilterComposer,
      $PeriodRulesOrderingComposer,
      $PeriodRulesAnnotationComposer,
      $PeriodRulesCreateCompanionBuilder,
      $PeriodRulesUpdateCompanionBuilder,
      (PeriodRuleRow, $PeriodRulesReferences),
      PeriodRuleRow,
      PrefetchHooks Function({bool packId})
    >;
typedef $RemindersCreateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  required String targetKind,
  required String targetId,
  Value<int> offsetMinutes,
  Value<String?> timeOfDay,
  Value<int> enabled,
  required String createdAt,
});
typedef $RemindersUpdateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<String> targetKind,
  Value<String> targetId,
  Value<int> offsetMinutes,
  Value<String?> timeOfDay,
  Value<int> enabled,
  Value<String> createdAt,
});

class $RemindersFilterComposer extends Composer<_$AppDatabase, Reminders> {
  $RemindersFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetKind => $composableBuilder(
    column: $table.targetKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeOfDay => $composableBuilder(
    column: $table.timeOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $RemindersOrderingComposer extends Composer<_$AppDatabase, Reminders> {
  $RemindersOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetKind => $composableBuilder(
    column: $table.targetKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeOfDay => $composableBuilder(
    column: $table.timeOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $RemindersAnnotationComposer extends Composer<_$AppDatabase, Reminders> {
  $RemindersAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetKind => $composableBuilder(
    column: $table.targetKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeOfDay =>
      $composableBuilder(column: $table.timeOfDay, builder: (column) => column);

  GeneratedColumn<int> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $RemindersTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Reminders,
          ReminderRow,
          $RemindersFilterComposer,
          $RemindersOrderingComposer,
          $RemindersAnnotationComposer,
          $RemindersCreateCompanionBuilder,
          $RemindersUpdateCompanionBuilder,
          (ReminderRow, BaseReferences<_$AppDatabase, Reminders, ReminderRow>),
          ReminderRow,
          PrefetchHooks Function()
        > {
  $RemindersTableManager(_$AppDatabase db, Reminders table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $RemindersFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $RemindersOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $RemindersAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> targetKind = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<int> offsetMinutes = const Value.absent(),
                Value<String?> timeOfDay = const Value.absent(),
                Value<int> enabled = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                targetKind: targetKind,
                targetId: targetId,
                offsetMinutes: offsetMinutes,
                timeOfDay: timeOfDay,
                enabled: enabled,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String targetKind,
                required String targetId,
                Value<int> offsetMinutes = const Value.absent(),
                Value<String?> timeOfDay = const Value.absent(),
                Value<int> enabled = const Value.absent(),
                required String createdAt,
              }) => RemindersCompanion.insert(
                id: id,
                targetKind: targetKind,
                targetId: targetId,
                offsetMinutes: offsetMinutes,
                timeOfDay: timeOfDay,
                enabled: enabled,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Reminders, ReminderRow>(table),
                  BaseReferences<_$AppDatabase, Reminders, ReminderRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $RemindersProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Reminders,
      ReminderRow,
      $RemindersFilterComposer,
      $RemindersOrderingComposer,
      $RemindersAnnotationComposer,
      $RemindersCreateCompanionBuilder,
      $RemindersUpdateCompanionBuilder,
      (ReminderRow, BaseReferences<_$AppDatabase, Reminders, ReminderRow>),
      ReminderRow,
      PrefetchHooks Function()
    >;
typedef $SettingsCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $SettingsUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $SettingsFilterComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $SettingsOrderingComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SettingsAnnotationComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $SettingsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Settings,
          SettingRow,
          $SettingsFilterComposer,
          $SettingsOrderingComposer,
          $SettingsAnnotationComposer,
          $SettingsCreateCompanionBuilder,
          $SettingsUpdateCompanionBuilder,
          (SettingRow, BaseReferences<_$AppDatabase, Settings, SettingRow>),
          SettingRow,
          PrefetchHooks Function()
        > {
  $SettingsTableManager(_$AppDatabase db, Settings table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SettingsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SettingsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SettingsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Settings, SettingRow>(table),
                  BaseReferences<_$AppDatabase, Settings, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SettingsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Settings,
      SettingRow,
      $SettingsFilterComposer,
      $SettingsOrderingComposer,
      $SettingsAnnotationComposer,
      $SettingsCreateCompanionBuilder,
      $SettingsUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, Settings, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $ErrorReportsQueueCreateCompanionBuilder =
    ErrorReportsQueueCompanion Function({
      Value<int> id,
      required String payload,
      required String createdAt,
    });
typedef $ErrorReportsQueueUpdateCompanionBuilder =
    ErrorReportsQueueCompanion Function({
      Value<int> id,
      Value<String> payload,
      Value<String> createdAt,
    });

class $ErrorReportsQueueFilterComposer
    extends Composer<_$AppDatabase, ErrorReportsQueue> {
  $ErrorReportsQueueFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $ErrorReportsQueueOrderingComposer
    extends Composer<_$AppDatabase, ErrorReportsQueue> {
  $ErrorReportsQueueOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ErrorReportsQueueAnnotationComposer
    extends Composer<_$AppDatabase, ErrorReportsQueue> {
  $ErrorReportsQueueAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $ErrorReportsQueueTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ErrorReportsQueue,
          QueuedErrorReportRow,
          $ErrorReportsQueueFilterComposer,
          $ErrorReportsQueueOrderingComposer,
          $ErrorReportsQueueAnnotationComposer,
          $ErrorReportsQueueCreateCompanionBuilder,
          $ErrorReportsQueueUpdateCompanionBuilder,
          (
            QueuedErrorReportRow,
            BaseReferences<
              _$AppDatabase,
              ErrorReportsQueue,
              QueuedErrorReportRow
            >,
          ),
          QueuedErrorReportRow,
          PrefetchHooks Function()
        > {
  $ErrorReportsQueueTableManager(_$AppDatabase db, ErrorReportsQueue table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ErrorReportsQueueFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ErrorReportsQueueOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ErrorReportsQueueAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => ErrorReportsQueueCompanion(
                id: id,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String payload,
                required String createdAt,
              }) => ErrorReportsQueueCompanion.insert(
                id: id,
                payload: payload,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ErrorReportsQueue, QueuedErrorReportRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    ErrorReportsQueue,
                    QueuedErrorReportRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ErrorReportsQueueProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ErrorReportsQueue,
      QueuedErrorReportRow,
      $ErrorReportsQueueFilterComposer,
      $ErrorReportsQueueOrderingComposer,
      $ErrorReportsQueueAnnotationComposer,
      $ErrorReportsQueueCreateCompanionBuilder,
      $ErrorReportsQueueUpdateCompanionBuilder,
      (
        QueuedErrorReportRow,
        BaseReferences<_$AppDatabase, ErrorReportsQueue, QueuedErrorReportRow>,
      ),
      QueuedErrorReportRow,
      PrefetchHooks Function()
    >;
typedef $ObservanceCorrectionsCreateCompanionBuilder =
    ObservanceCorrectionsCompanion Function({
      required String tradition,
      required String observanceId,
      required String correctedAt,
      Value<int> rowid,
    });
typedef $ObservanceCorrectionsUpdateCompanionBuilder =
    ObservanceCorrectionsCompanion Function({
      Value<String> tradition,
      Value<String> observanceId,
      Value<String> correctedAt,
      Value<int> rowid,
    });

class $ObservanceCorrectionsFilterComposer
    extends Composer<_$AppDatabase, ObservanceCorrections> {
  $ObservanceCorrectionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observanceId => $composableBuilder(
    column: $table.observanceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctedAt => $composableBuilder(
    column: $table.correctedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $ObservanceCorrectionsOrderingComposer
    extends Composer<_$AppDatabase, ObservanceCorrections> {
  $ObservanceCorrectionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observanceId => $composableBuilder(
    column: $table.observanceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctedAt => $composableBuilder(
    column: $table.correctedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ObservanceCorrectionsAnnotationComposer
    extends Composer<_$AppDatabase, ObservanceCorrections> {
  $ObservanceCorrectionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tradition =>
      $composableBuilder(column: $table.tradition, builder: (column) => column);

  GeneratedColumn<String> get observanceId => $composableBuilder(
    column: $table.observanceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctedAt => $composableBuilder(
    column: $table.correctedAt,
    builder: (column) => column,
  );
}

class $ObservanceCorrectionsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ObservanceCorrections,
          ObservanceCorrectionRow,
          $ObservanceCorrectionsFilterComposer,
          $ObservanceCorrectionsOrderingComposer,
          $ObservanceCorrectionsAnnotationComposer,
          $ObservanceCorrectionsCreateCompanionBuilder,
          $ObservanceCorrectionsUpdateCompanionBuilder,
          (
            ObservanceCorrectionRow,
            BaseReferences<
              _$AppDatabase,
              ObservanceCorrections,
              ObservanceCorrectionRow
            >,
          ),
          ObservanceCorrectionRow,
          PrefetchHooks Function()
        > {
  $ObservanceCorrectionsTableManager(
    _$AppDatabase db,
    ObservanceCorrections table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ObservanceCorrectionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ObservanceCorrectionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ObservanceCorrectionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tradition = const Value.absent(),
                Value<String> observanceId = const Value.absent(),
                Value<String> correctedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservanceCorrectionsCompanion(
                tradition: tradition,
                observanceId: observanceId,
                correctedAt: correctedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tradition,
                required String observanceId,
                required String correctedAt,
                Value<int> rowid = const Value.absent(),
              }) => ObservanceCorrectionsCompanion.insert(
                tradition: tradition,
                observanceId: observanceId,
                correctedAt: correctedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ObservanceCorrections, ObservanceCorrectionRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    ObservanceCorrections,
                    ObservanceCorrectionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ObservanceCorrectionsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ObservanceCorrections,
      ObservanceCorrectionRow,
      $ObservanceCorrectionsFilterComposer,
      $ObservanceCorrectionsOrderingComposer,
      $ObservanceCorrectionsAnnotationComposer,
      $ObservanceCorrectionsCreateCompanionBuilder,
      $ObservanceCorrectionsUpdateCompanionBuilder,
      (
        ObservanceCorrectionRow,
        BaseReferences<
          _$AppDatabase,
          ObservanceCorrections,
          ObservanceCorrectionRow
        >,
      ),
      ObservanceCorrectionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $PacksTableManager get packs => $PacksTableManager(_db, _db.packs);
  $TransitionsTableManager get transitions =>
      $TransitionsTableManager(_db, _db.transitions);
  $CitiesTableManager get cities => $CitiesTableManager(_db, _db.cities);
  $CityDaysTableManager get cityDays =>
      $CityDaysTableManager(_db, _db.cityDays);
  $BengaliDatesTableManager get bengaliDates =>
      $BengaliDatesTableManager(_db, _db.bengaliDates);
  $NamesTableManager get names => $NamesTableManager(_db, _db.names);
  $ObservancesTableManager get observances =>
      $ObservancesTableManager(_db, _db.observances);
  $ObservanceDatesTableManager get observanceDates =>
      $ObservanceDatesTableManager(_db, _db.observanceDates);
  $ObservanceWindowsTableManager get observanceWindows =>
      $ObservanceWindowsTableManager(_db, _db.observanceWindows);
  $LunarMonthsTableManager get lunarMonths =>
      $LunarMonthsTableManager(_db, _db.lunarMonths);
  $PeriodRulesTableManager get periodRules =>
      $PeriodRulesTableManager(_db, _db.periodRules);
  $RemindersTableManager get reminders =>
      $RemindersTableManager(_db, _db.reminders);
  $SettingsTableManager get settings =>
      $SettingsTableManager(_db, _db.settings);
  $ErrorReportsQueueTableManager get errorReportsQueue =>
      $ErrorReportsQueueTableManager(_db, _db.errorReportsQueue);
  $ObservanceCorrectionsTableManager get observanceCorrections =>
      $ObservanceCorrectionsTableManager(_db, _db.observanceCorrections);
}

class ObservancesBetweenResult {
  final ObservanceRow o;
  final ObservanceDateRow d;
  ObservancesBetweenResult({required this.o, required this.d});
}

class ObservanceDatesOfResult {
  final ObservanceRow o;
  final ObservanceDateRow d;
  ObservanceDatesOfResult({required this.o, required this.d});
}

class ObservanceStartsResult {
  final ObservanceRow o;
  final ObservanceDateRow d;
  ObservanceStartsResult({required this.o, required this.d});
}
