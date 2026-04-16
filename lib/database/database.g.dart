// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BabiesTable extends Babies with TableInfo<$BabiesTable, Baby> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BabiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, dateOfBirth, weightKg, createdAt, updatedAt, isArchived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'babies';
  @override
  VerificationContext validateIntegrity(Insertable<Baby> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    } else if (isInserting) {
      context.missing(_dateOfBirthMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Baby map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Baby(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dateOfBirth: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth'])!,
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
    );
  }

  @override
  $BabiesTable createAlias(String alias) {
    return $BabiesTable(attachedDatabase, alias);
  }
}

class Baby extends DataClass implements Insertable<Baby> {
  final int id;
  final String name;
  final DateTime dateOfBirth;
  final double weightKg;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  const Baby(
      {required this.id,
      required this.name,
      required this.dateOfBirth,
      required this.weightKg,
      required this.createdAt,
      required this.updatedAt,
      required this.isArchived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    map['weight_kg'] = Variable<double>(weightKg);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  BabiesCompanion toCompanion(bool nullToAbsent) {
    return BabiesCompanion(
      id: Value(id),
      name: Value(name),
      dateOfBirth: Value(dateOfBirth),
      weightKg: Value(weightKg),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isArchived: Value(isArchived),
    );
  }

  factory Baby.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Baby(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dateOfBirth: serializer.fromJson<DateTime>(json['dateOfBirth']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'dateOfBirth': serializer.toJson<DateTime>(dateOfBirth),
      'weightKg': serializer.toJson<double>(weightKg),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Baby copyWith(
          {int? id,
          String? name,
          DateTime? dateOfBirth,
          double? weightKg,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isArchived}) =>
      Baby(
        id: id ?? this.id,
        name: name ?? this.name,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        weightKg: weightKg ?? this.weightKg,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isArchived: isArchived ?? this.isArchived,
      );
  Baby copyWithCompanion(BabiesCompanion data) {
    return Baby(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Baby(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('weightKg: $weightKg, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, dateOfBirth, weightKg, createdAt, updatedAt, isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Baby &&
          other.id == this.id &&
          other.name == this.name &&
          other.dateOfBirth == this.dateOfBirth &&
          other.weightKg == this.weightKg &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isArchived == this.isArchived);
}

class BabiesCompanion extends UpdateCompanion<Baby> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> dateOfBirth;
  final Value<double> weightKg;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isArchived;
  const BabiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  BabiesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime dateOfBirth,
    required double weightKg,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
  })  : name = Value(name),
        dateOfBirth = Value(dateOfBirth),
        weightKg = Value(weightKg);
  static Insertable<Baby> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? dateOfBirth,
    Expression<double>? weightKg,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (weightKg != null) 'weight_kg': weightKg,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  BabiesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<DateTime>? dateOfBirth,
      Value<double>? weightKg,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isArchived}) {
    return BabiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weightKg: weightKg ?? this.weightKg,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BabiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('weightKg: $weightKg, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $MeasurementsTable extends Measurements
    with TableInfo<$MeasurementsTable, Measurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _measurementIdMeta =
      const VerificationMeta('measurementId');
  @override
  late final GeneratedColumn<String> measurementId = GeneratedColumn<String>(
      'measurement_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<int> babyId = GeneratedColumn<int>(
      'baby_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES babies (id)'));
  static const VerificationMeta _capturedAtMeta =
      const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
      'captured_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _receivedAtMeta =
      const VerificationMeta('receivedAt');
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
      'received_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _ageHoursMeta =
      const VerificationMeta('ageHours');
  @override
  late final GeneratedColumn<double> ageHours = GeneratedColumn<double>(
      'age_hours', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _bilirubinMgDlMeta =
      const VerificationMeta('bilirubinMgDl');
  @override
  late final GeneratedColumn<double> bilirubinMgDl = GeneratedColumn<double>(
      'bilirubin_mg_dl', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _hasImageMeta =
      const VerificationMeta('hasImage');
  @override
  late final GeneratedColumn<bool> hasImage = GeneratedColumn<bool>(
      'has_image', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("has_image" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _encryptedImageRefMeta =
      const VerificationMeta('encryptedImageRef');
  @override
  late final GeneratedColumn<String> encryptedImageRef =
      GeneratedColumn<String>('encrypted_image_ref', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modelVersionMeta =
      const VerificationMeta('modelVersion');
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
      'model_version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        measurementId,
        babyId,
        capturedAt,
        receivedAt,
        ageHours,
        bilirubinMgDl,
        hasImage,
        encryptedImageRef,
        deviceId,
        modelVersion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurements';
  @override
  VerificationContext validateIntegrity(Insertable<Measurement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('measurement_id')) {
      context.handle(
          _measurementIdMeta,
          measurementId.isAcceptableOrUnknown(
              data['measurement_id']!, _measurementIdMeta));
    } else if (isInserting) {
      context.missing(_measurementIdMeta);
    }
    if (data.containsKey('baby_id')) {
      context.handle(_babyIdMeta,
          babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta));
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
          _capturedAtMeta,
          capturedAt.isAcceptableOrUnknown(
              data['captured_at']!, _capturedAtMeta));
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
          _receivedAtMeta,
          receivedAt.isAcceptableOrUnknown(
              data['received_at']!, _receivedAtMeta));
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('age_hours')) {
      context.handle(_ageHoursMeta,
          ageHours.isAcceptableOrUnknown(data['age_hours']!, _ageHoursMeta));
    } else if (isInserting) {
      context.missing(_ageHoursMeta);
    }
    if (data.containsKey('bilirubin_mg_dl')) {
      context.handle(
          _bilirubinMgDlMeta,
          bilirubinMgDl.isAcceptableOrUnknown(
              data['bilirubin_mg_dl']!, _bilirubinMgDlMeta));
    } else if (isInserting) {
      context.missing(_bilirubinMgDlMeta);
    }
    if (data.containsKey('has_image')) {
      context.handle(_hasImageMeta,
          hasImage.isAcceptableOrUnknown(data['has_image']!, _hasImageMeta));
    }
    if (data.containsKey('encrypted_image_ref')) {
      context.handle(
          _encryptedImageRefMeta,
          encryptedImageRef.isAcceptableOrUnknown(
              data['encrypted_image_ref']!, _encryptedImageRefMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('model_version')) {
      context.handle(
          _modelVersionMeta,
          modelVersion.isAcceptableOrUnknown(
              data['model_version']!, _modelVersionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {measurementId};
  @override
  Measurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Measurement(
      measurementId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}measurement_id'])!,
      babyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}baby_id'])!,
      capturedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}captured_at'])!,
      receivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}received_at'])!,
      ageHours: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}age_hours'])!,
      bilirubinMgDl: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}bilirubin_mg_dl'])!,
      hasImage: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_image'])!,
      encryptedImageRef: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}encrypted_image_ref']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      modelVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_version']),
    );
  }

  @override
  $MeasurementsTable createAlias(String alias) {
    return $MeasurementsTable(attachedDatabase, alias);
  }
}

class Measurement extends DataClass implements Insertable<Measurement> {
  /// UUID from the device — globally unique.
  final String measurementId;

  /// FK → babies.id
  final int babyId;

  /// Timestamp from the device clock (may drift).
  final DateTime capturedAt;

  /// Timestamp when the app received the data.
  final DateTime receivedAt;

  /// Baby's postnatal age in hours at time of measurement.
  final double ageHours;

  /// Measured bilirubin concentration in mg/dL.
  final double bilirubinMgDl;

  /// True if an encrypted image file exists for this measurement.
  final bool hasImage;

  /// Filename (basename only) of the AES-GCM encrypted image on disk.
  final String? encryptedImageRef;

  /// ID of the device that produced this measurement.
  final String? deviceId;

  /// On-device model version used for inference.
  final String? modelVersion;
  const Measurement(
      {required this.measurementId,
      required this.babyId,
      required this.capturedAt,
      required this.receivedAt,
      required this.ageHours,
      required this.bilirubinMgDl,
      required this.hasImage,
      this.encryptedImageRef,
      this.deviceId,
      this.modelVersion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['measurement_id'] = Variable<String>(measurementId);
    map['baby_id'] = Variable<int>(babyId);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['age_hours'] = Variable<double>(ageHours);
    map['bilirubin_mg_dl'] = Variable<double>(bilirubinMgDl);
    map['has_image'] = Variable<bool>(hasImage);
    if (!nullToAbsent || encryptedImageRef != null) {
      map['encrypted_image_ref'] = Variable<String>(encryptedImageRef);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || modelVersion != null) {
      map['model_version'] = Variable<String>(modelVersion);
    }
    return map;
  }

  MeasurementsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementsCompanion(
      measurementId: Value(measurementId),
      babyId: Value(babyId),
      capturedAt: Value(capturedAt),
      receivedAt: Value(receivedAt),
      ageHours: Value(ageHours),
      bilirubinMgDl: Value(bilirubinMgDl),
      hasImage: Value(hasImage),
      encryptedImageRef: encryptedImageRef == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedImageRef),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      modelVersion: modelVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(modelVersion),
    );
  }

  factory Measurement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Measurement(
      measurementId: serializer.fromJson<String>(json['measurementId']),
      babyId: serializer.fromJson<int>(json['babyId']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      ageHours: serializer.fromJson<double>(json['ageHours']),
      bilirubinMgDl: serializer.fromJson<double>(json['bilirubinMgDl']),
      hasImage: serializer.fromJson<bool>(json['hasImage']),
      encryptedImageRef:
          serializer.fromJson<String?>(json['encryptedImageRef']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      modelVersion: serializer.fromJson<String?>(json['modelVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'measurementId': serializer.toJson<String>(measurementId),
      'babyId': serializer.toJson<int>(babyId),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'ageHours': serializer.toJson<double>(ageHours),
      'bilirubinMgDl': serializer.toJson<double>(bilirubinMgDl),
      'hasImage': serializer.toJson<bool>(hasImage),
      'encryptedImageRef': serializer.toJson<String?>(encryptedImageRef),
      'deviceId': serializer.toJson<String?>(deviceId),
      'modelVersion': serializer.toJson<String?>(modelVersion),
    };
  }

  Measurement copyWith(
          {String? measurementId,
          int? babyId,
          DateTime? capturedAt,
          DateTime? receivedAt,
          double? ageHours,
          double? bilirubinMgDl,
          bool? hasImage,
          Value<String?> encryptedImageRef = const Value.absent(),
          Value<String?> deviceId = const Value.absent(),
          Value<String?> modelVersion = const Value.absent()}) =>
      Measurement(
        measurementId: measurementId ?? this.measurementId,
        babyId: babyId ?? this.babyId,
        capturedAt: capturedAt ?? this.capturedAt,
        receivedAt: receivedAt ?? this.receivedAt,
        ageHours: ageHours ?? this.ageHours,
        bilirubinMgDl: bilirubinMgDl ?? this.bilirubinMgDl,
        hasImage: hasImage ?? this.hasImage,
        encryptedImageRef: encryptedImageRef.present
            ? encryptedImageRef.value
            : this.encryptedImageRef,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        modelVersion:
            modelVersion.present ? modelVersion.value : this.modelVersion,
      );
  Measurement copyWithCompanion(MeasurementsCompanion data) {
    return Measurement(
      measurementId: data.measurementId.present
          ? data.measurementId.value
          : this.measurementId,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      receivedAt:
          data.receivedAt.present ? data.receivedAt.value : this.receivedAt,
      ageHours: data.ageHours.present ? data.ageHours.value : this.ageHours,
      bilirubinMgDl: data.bilirubinMgDl.present
          ? data.bilirubinMgDl.value
          : this.bilirubinMgDl,
      hasImage: data.hasImage.present ? data.hasImage.value : this.hasImage,
      encryptedImageRef: data.encryptedImageRef.present
          ? data.encryptedImageRef.value
          : this.encryptedImageRef,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Measurement(')
          ..write('measurementId: $measurementId, ')
          ..write('babyId: $babyId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('ageHours: $ageHours, ')
          ..write('bilirubinMgDl: $bilirubinMgDl, ')
          ..write('hasImage: $hasImage, ')
          ..write('encryptedImageRef: $encryptedImageRef, ')
          ..write('deviceId: $deviceId, ')
          ..write('modelVersion: $modelVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      measurementId,
      babyId,
      capturedAt,
      receivedAt,
      ageHours,
      bilirubinMgDl,
      hasImage,
      encryptedImageRef,
      deviceId,
      modelVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Measurement &&
          other.measurementId == this.measurementId &&
          other.babyId == this.babyId &&
          other.capturedAt == this.capturedAt &&
          other.receivedAt == this.receivedAt &&
          other.ageHours == this.ageHours &&
          other.bilirubinMgDl == this.bilirubinMgDl &&
          other.hasImage == this.hasImage &&
          other.encryptedImageRef == this.encryptedImageRef &&
          other.deviceId == this.deviceId &&
          other.modelVersion == this.modelVersion);
}

class MeasurementsCompanion extends UpdateCompanion<Measurement> {
  final Value<String> measurementId;
  final Value<int> babyId;
  final Value<DateTime> capturedAt;
  final Value<DateTime> receivedAt;
  final Value<double> ageHours;
  final Value<double> bilirubinMgDl;
  final Value<bool> hasImage;
  final Value<String?> encryptedImageRef;
  final Value<String?> deviceId;
  final Value<String?> modelVersion;
  final Value<int> rowid;
  const MeasurementsCompanion({
    this.measurementId = const Value.absent(),
    this.babyId = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.ageHours = const Value.absent(),
    this.bilirubinMgDl = const Value.absent(),
    this.hasImage = const Value.absent(),
    this.encryptedImageRef = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementsCompanion.insert({
    required String measurementId,
    required int babyId,
    required DateTime capturedAt,
    required DateTime receivedAt,
    required double ageHours,
    required double bilirubinMgDl,
    this.hasImage = const Value.absent(),
    this.encryptedImageRef = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : measurementId = Value(measurementId),
        babyId = Value(babyId),
        capturedAt = Value(capturedAt),
        receivedAt = Value(receivedAt),
        ageHours = Value(ageHours),
        bilirubinMgDl = Value(bilirubinMgDl);
  static Insertable<Measurement> custom({
    Expression<String>? measurementId,
    Expression<int>? babyId,
    Expression<DateTime>? capturedAt,
    Expression<DateTime>? receivedAt,
    Expression<double>? ageHours,
    Expression<double>? bilirubinMgDl,
    Expression<bool>? hasImage,
    Expression<String>? encryptedImageRef,
    Expression<String>? deviceId,
    Expression<String>? modelVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (measurementId != null) 'measurement_id': measurementId,
      if (babyId != null) 'baby_id': babyId,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (receivedAt != null) 'received_at': receivedAt,
      if (ageHours != null) 'age_hours': ageHours,
      if (bilirubinMgDl != null) 'bilirubin_mg_dl': bilirubinMgDl,
      if (hasImage != null) 'has_image': hasImage,
      if (encryptedImageRef != null) 'encrypted_image_ref': encryptedImageRef,
      if (deviceId != null) 'device_id': deviceId,
      if (modelVersion != null) 'model_version': modelVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementsCompanion copyWith(
      {Value<String>? measurementId,
      Value<int>? babyId,
      Value<DateTime>? capturedAt,
      Value<DateTime>? receivedAt,
      Value<double>? ageHours,
      Value<double>? bilirubinMgDl,
      Value<bool>? hasImage,
      Value<String?>? encryptedImageRef,
      Value<String?>? deviceId,
      Value<String?>? modelVersion,
      Value<int>? rowid}) {
    return MeasurementsCompanion(
      measurementId: measurementId ?? this.measurementId,
      babyId: babyId ?? this.babyId,
      capturedAt: capturedAt ?? this.capturedAt,
      receivedAt: receivedAt ?? this.receivedAt,
      ageHours: ageHours ?? this.ageHours,
      bilirubinMgDl: bilirubinMgDl ?? this.bilirubinMgDl,
      hasImage: hasImage ?? this.hasImage,
      encryptedImageRef: encryptedImageRef ?? this.encryptedImageRef,
      deviceId: deviceId ?? this.deviceId,
      modelVersion: modelVersion ?? this.modelVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (measurementId.present) {
      map['measurement_id'] = Variable<String>(measurementId.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<int>(babyId.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (ageHours.present) {
      map['age_hours'] = Variable<double>(ageHours.value);
    }
    if (bilirubinMgDl.present) {
      map['bilirubin_mg_dl'] = Variable<double>(bilirubinMgDl.value);
    }
    if (hasImage.present) {
      map['has_image'] = Variable<bool>(hasImage.value);
    }
    if (encryptedImageRef.present) {
      map['encrypted_image_ref'] = Variable<String>(encryptedImageRef.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementsCompanion(')
          ..write('measurementId: $measurementId, ')
          ..write('babyId: $babyId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('ageHours: $ageHours, ')
          ..write('bilirubinMgDl: $bilirubinMgDl, ')
          ..write('hasImage: $hasImage, ')
          ..write('encryptedImageRef: $encryptedImageRef, ')
          ..write('deviceId: $deviceId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transportMeta =
      const VerificationMeta('transport');
  @override
  late final GeneratedColumn<String> transport = GeneratedColumn<String>(
      'transport', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isPairedMeta =
      const VerificationMeta('isPaired');
  @override
  late final GeneratedColumn<bool> isPaired = GeneratedColumn<bool>(
      'is_paired', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_paired" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _pairedAtMeta =
      const VerificationMeta('pairedAt');
  @override
  late final GeneratedColumn<DateTime> pairedAt = GeneratedColumn<DateTime>(
      'paired_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSeenAtMeta =
      const VerificationMeta('lastSeenAt');
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
      'last_seen_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _firmwareVersionMeta =
      const VerificationMeta('firmwareVersion');
  @override
  late final GeneratedColumn<String> firmwareVersion = GeneratedColumn<String>(
      'firmware_version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _publicKeyMeta =
      const VerificationMeta('publicKey');
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
      'public_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        deviceId,
        displayName,
        transport,
        isPaired,
        pairedAt,
        lastSeenAt,
        firmwareVersion,
        publicKey
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(Insertable<Device> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('transport')) {
      context.handle(_transportMeta,
          transport.isAcceptableOrUnknown(data['transport']!, _transportMeta));
    } else if (isInserting) {
      context.missing(_transportMeta);
    }
    if (data.containsKey('is_paired')) {
      context.handle(_isPairedMeta,
          isPaired.isAcceptableOrUnknown(data['is_paired']!, _isPairedMeta));
    }
    if (data.containsKey('paired_at')) {
      context.handle(_pairedAtMeta,
          pairedAt.isAcceptableOrUnknown(data['paired_at']!, _pairedAtMeta));
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
          _lastSeenAtMeta,
          lastSeenAt.isAcceptableOrUnknown(
              data['last_seen_at']!, _lastSeenAtMeta));
    }
    if (data.containsKey('firmware_version')) {
      context.handle(
          _firmwareVersionMeta,
          firmwareVersion.isAcceptableOrUnknown(
              data['firmware_version']!, _firmwareVersionMeta));
    }
    if (data.containsKey('public_key')) {
      context.handle(_publicKeyMeta,
          publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      transport: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transport'])!,
      isPaired: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_paired'])!,
      pairedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}paired_at']),
      lastSeenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_seen_at']),
      firmwareVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}firmware_version']),
      publicKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}public_key']),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String deviceId;
  final String displayName;

  /// Transport protocol: 'wifi' | 'ble' | 'fake'
  final String transport;
  final bool isPaired;
  final DateTime? pairedAt;
  final DateTime? lastSeenAt;
  final String? firmwareVersion;

  /// Base64-encoded device public key for future challenge-response auth.
  final String? publicKey;
  const Device(
      {required this.deviceId,
      required this.displayName,
      required this.transport,
      required this.isPaired,
      this.pairedAt,
      this.lastSeenAt,
      this.firmwareVersion,
      this.publicKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['display_name'] = Variable<String>(displayName);
    map['transport'] = Variable<String>(transport);
    map['is_paired'] = Variable<bool>(isPaired);
    if (!nullToAbsent || pairedAt != null) {
      map['paired_at'] = Variable<DateTime>(pairedAt);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    if (!nullToAbsent || firmwareVersion != null) {
      map['firmware_version'] = Variable<String>(firmwareVersion);
    }
    if (!nullToAbsent || publicKey != null) {
      map['public_key'] = Variable<String>(publicKey);
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      deviceId: Value(deviceId),
      displayName: Value(displayName),
      transport: Value(transport),
      isPaired: Value(isPaired),
      pairedAt: pairedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pairedAt),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      firmwareVersion: firmwareVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(firmwareVersion),
      publicKey: publicKey == null && nullToAbsent
          ? const Value.absent()
          : Value(publicKey),
    );
  }

  factory Device.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      transport: serializer.fromJson<String>(json['transport']),
      isPaired: serializer.fromJson<bool>(json['isPaired']),
      pairedAt: serializer.fromJson<DateTime?>(json['pairedAt']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      firmwareVersion: serializer.fromJson<String?>(json['firmwareVersion']),
      publicKey: serializer.fromJson<String?>(json['publicKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'displayName': serializer.toJson<String>(displayName),
      'transport': serializer.toJson<String>(transport),
      'isPaired': serializer.toJson<bool>(isPaired),
      'pairedAt': serializer.toJson<DateTime?>(pairedAt),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'firmwareVersion': serializer.toJson<String?>(firmwareVersion),
      'publicKey': serializer.toJson<String?>(publicKey),
    };
  }

  Device copyWith(
          {String? deviceId,
          String? displayName,
          String? transport,
          bool? isPaired,
          Value<DateTime?> pairedAt = const Value.absent(),
          Value<DateTime?> lastSeenAt = const Value.absent(),
          Value<String?> firmwareVersion = const Value.absent(),
          Value<String?> publicKey = const Value.absent()}) =>
      Device(
        deviceId: deviceId ?? this.deviceId,
        displayName: displayName ?? this.displayName,
        transport: transport ?? this.transport,
        isPaired: isPaired ?? this.isPaired,
        pairedAt: pairedAt.present ? pairedAt.value : this.pairedAt,
        lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
        firmwareVersion: firmwareVersion.present
            ? firmwareVersion.value
            : this.firmwareVersion,
        publicKey: publicKey.present ? publicKey.value : this.publicKey,
      );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      transport: data.transport.present ? data.transport.value : this.transport,
      isPaired: data.isPaired.present ? data.isPaired.value : this.isPaired,
      pairedAt: data.pairedAt.present ? data.pairedAt.value : this.pairedAt,
      lastSeenAt:
          data.lastSeenAt.present ? data.lastSeenAt.value : this.lastSeenAt,
      firmwareVersion: data.firmwareVersion.present
          ? data.firmwareVersion.value
          : this.firmwareVersion,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('deviceId: $deviceId, ')
          ..write('displayName: $displayName, ')
          ..write('transport: $transport, ')
          ..write('isPaired: $isPaired, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('publicKey: $publicKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, displayName, transport, isPaired,
      pairedAt, lastSeenAt, firmwareVersion, publicKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.deviceId == this.deviceId &&
          other.displayName == this.displayName &&
          other.transport == this.transport &&
          other.isPaired == this.isPaired &&
          other.pairedAt == this.pairedAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.firmwareVersion == this.firmwareVersion &&
          other.publicKey == this.publicKey);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> deviceId;
  final Value<String> displayName;
  final Value<String> transport;
  final Value<bool> isPaired;
  final Value<DateTime?> pairedAt;
  final Value<DateTime?> lastSeenAt;
  final Value<String?> firmwareVersion;
  final Value<String?> publicKey;
  final Value<int> rowid;
  const DevicesCompanion({
    this.deviceId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.transport = const Value.absent(),
    this.isPaired = const Value.absent(),
    this.pairedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String deviceId,
    required String displayName,
    required String transport,
    this.isPaired = const Value.absent(),
    this.pairedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : deviceId = Value(deviceId),
        displayName = Value(displayName),
        transport = Value(transport);
  static Insertable<Device> custom({
    Expression<String>? deviceId,
    Expression<String>? displayName,
    Expression<String>? transport,
    Expression<bool>? isPaired,
    Expression<DateTime>? pairedAt,
    Expression<DateTime>? lastSeenAt,
    Expression<String>? firmwareVersion,
    Expression<String>? publicKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (displayName != null) 'display_name': displayName,
      if (transport != null) 'transport': transport,
      if (isPaired != null) 'is_paired': isPaired,
      if (pairedAt != null) 'paired_at': pairedAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (firmwareVersion != null) 'firmware_version': firmwareVersion,
      if (publicKey != null) 'public_key': publicKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith(
      {Value<String>? deviceId,
      Value<String>? displayName,
      Value<String>? transport,
      Value<bool>? isPaired,
      Value<DateTime?>? pairedAt,
      Value<DateTime?>? lastSeenAt,
      Value<String?>? firmwareVersion,
      Value<String?>? publicKey,
      Value<int>? rowid}) {
    return DevicesCompanion(
      deviceId: deviceId ?? this.deviceId,
      displayName: displayName ?? this.displayName,
      transport: transport ?? this.transport,
      isPaired: isPaired ?? this.isPaired,
      pairedAt: pairedAt ?? this.pairedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      publicKey: publicKey ?? this.publicKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (transport.present) {
      map['transport'] = Variable<String>(transport.value);
    }
    if (isPaired.present) {
      map['is_paired'] = Variable<bool>(isPaired.value);
    }
    if (pairedAt.present) {
      map['paired_at'] = Variable<DateTime>(pairedAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (firmwareVersion.present) {
      map['firmware_version'] = Variable<String>(firmwareVersion.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('displayName: $displayName, ')
          ..write('transport: $transport, ')
          ..write('isPaired: $isPaired, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('publicKey: $publicKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditEventsTable extends AuditEvents
    with TableInfo<$AuditEventsTable, AuditEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _auditEventIdMeta =
      const VerificationMeta('auditEventId');
  @override
  late final GeneratedColumn<String> auditEventId = GeneratedColumn<String>(
      'audit_event_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<int> babyId = GeneratedColumn<int>(
      'baby_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _measurementIdMeta =
      const VerificationMeta('measurementId');
  @override
  late final GeneratedColumn<String> measurementId = GeneratedColumn<String>(
      'measurement_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _detailsJsonMeta =
      const VerificationMeta('detailsJson');
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
      'details_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        auditEventId,
        createdAt,
        eventType,
        babyId,
        measurementId,
        deviceId,
        detailsJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_events';
  @override
  VerificationContext validateIntegrity(Insertable<AuditEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('audit_event_id')) {
      context.handle(
          _auditEventIdMeta,
          auditEventId.isAcceptableOrUnknown(
              data['audit_event_id']!, _auditEventIdMeta));
    } else if (isInserting) {
      context.missing(_auditEventIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('baby_id')) {
      context.handle(_babyIdMeta,
          babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta));
    }
    if (data.containsKey('measurement_id')) {
      context.handle(
          _measurementIdMeta,
          measurementId.isAcceptableOrUnknown(
              data['measurement_id']!, _measurementIdMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('details_json')) {
      context.handle(
          _detailsJsonMeta,
          detailsJson.isAcceptableOrUnknown(
              data['details_json']!, _detailsJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {auditEventId};
  @override
  AuditEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditEvent(
      auditEventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audit_event_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      babyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}baby_id']),
      measurementId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}measurement_id']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      detailsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details_json']),
    );
  }

  @override
  $AuditEventsTable createAlias(String alias) {
    return $AuditEventsTable(attachedDatabase, alias);
  }
}

class AuditEvent extends DataClass implements Insertable<AuditEvent> {
  /// UUID for each audit event.
  final String auditEventId;
  final DateTime createdAt;

  /// Event type constant — see core/constants.dart kAudit* values.
  final String eventType;
  final int? babyId;
  final String? measurementId;
  final String? deviceId;

  /// Arbitrary JSON payload for additional context.
  final String? detailsJson;
  const AuditEvent(
      {required this.auditEventId,
      required this.createdAt,
      required this.eventType,
      this.babyId,
      this.measurementId,
      this.deviceId,
      this.detailsJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['audit_event_id'] = Variable<String>(auditEventId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || babyId != null) {
      map['baby_id'] = Variable<int>(babyId);
    }
    if (!nullToAbsent || measurementId != null) {
      map['measurement_id'] = Variable<String>(measurementId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || detailsJson != null) {
      map['details_json'] = Variable<String>(detailsJson);
    }
    return map;
  }

  AuditEventsCompanion toCompanion(bool nullToAbsent) {
    return AuditEventsCompanion(
      auditEventId: Value(auditEventId),
      createdAt: Value(createdAt),
      eventType: Value(eventType),
      babyId:
          babyId == null && nullToAbsent ? const Value.absent() : Value(babyId),
      measurementId: measurementId == null && nullToAbsent
          ? const Value.absent()
          : Value(measurementId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      detailsJson: detailsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detailsJson),
    );
  }

  factory AuditEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditEvent(
      auditEventId: serializer.fromJson<String>(json['auditEventId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      eventType: serializer.fromJson<String>(json['eventType']),
      babyId: serializer.fromJson<int?>(json['babyId']),
      measurementId: serializer.fromJson<String?>(json['measurementId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      detailsJson: serializer.fromJson<String?>(json['detailsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'auditEventId': serializer.toJson<String>(auditEventId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'eventType': serializer.toJson<String>(eventType),
      'babyId': serializer.toJson<int?>(babyId),
      'measurementId': serializer.toJson<String?>(measurementId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'detailsJson': serializer.toJson<String?>(detailsJson),
    };
  }

  AuditEvent copyWith(
          {String? auditEventId,
          DateTime? createdAt,
          String? eventType,
          Value<int?> babyId = const Value.absent(),
          Value<String?> measurementId = const Value.absent(),
          Value<String?> deviceId = const Value.absent(),
          Value<String?> detailsJson = const Value.absent()}) =>
      AuditEvent(
        auditEventId: auditEventId ?? this.auditEventId,
        createdAt: createdAt ?? this.createdAt,
        eventType: eventType ?? this.eventType,
        babyId: babyId.present ? babyId.value : this.babyId,
        measurementId:
            measurementId.present ? measurementId.value : this.measurementId,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        detailsJson: detailsJson.present ? detailsJson.value : this.detailsJson,
      );
  AuditEvent copyWithCompanion(AuditEventsCompanion data) {
    return AuditEvent(
      auditEventId: data.auditEventId.present
          ? data.auditEventId.value
          : this.auditEventId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      measurementId: data.measurementId.present
          ? data.measurementId.value
          : this.measurementId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      detailsJson:
          data.detailsJson.present ? data.detailsJson.value : this.detailsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditEvent(')
          ..write('auditEventId: $auditEventId, ')
          ..write('createdAt: $createdAt, ')
          ..write('eventType: $eventType, ')
          ..write('babyId: $babyId, ')
          ..write('measurementId: $measurementId, ')
          ..write('deviceId: $deviceId, ')
          ..write('detailsJson: $detailsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(auditEventId, createdAt, eventType, babyId,
      measurementId, deviceId, detailsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditEvent &&
          other.auditEventId == this.auditEventId &&
          other.createdAt == this.createdAt &&
          other.eventType == this.eventType &&
          other.babyId == this.babyId &&
          other.measurementId == this.measurementId &&
          other.deviceId == this.deviceId &&
          other.detailsJson == this.detailsJson);
}

class AuditEventsCompanion extends UpdateCompanion<AuditEvent> {
  final Value<String> auditEventId;
  final Value<DateTime> createdAt;
  final Value<String> eventType;
  final Value<int?> babyId;
  final Value<String?> measurementId;
  final Value<String?> deviceId;
  final Value<String?> detailsJson;
  final Value<int> rowid;
  const AuditEventsCompanion({
    this.auditEventId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.eventType = const Value.absent(),
    this.babyId = const Value.absent(),
    this.measurementId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditEventsCompanion.insert({
    required String auditEventId,
    this.createdAt = const Value.absent(),
    required String eventType,
    this.babyId = const Value.absent(),
    this.measurementId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : auditEventId = Value(auditEventId),
        eventType = Value(eventType);
  static Insertable<AuditEvent> custom({
    Expression<String>? auditEventId,
    Expression<DateTime>? createdAt,
    Expression<String>? eventType,
    Expression<int>? babyId,
    Expression<String>? measurementId,
    Expression<String>? deviceId,
    Expression<String>? detailsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (auditEventId != null) 'audit_event_id': auditEventId,
      if (createdAt != null) 'created_at': createdAt,
      if (eventType != null) 'event_type': eventType,
      if (babyId != null) 'baby_id': babyId,
      if (measurementId != null) 'measurement_id': measurementId,
      if (deviceId != null) 'device_id': deviceId,
      if (detailsJson != null) 'details_json': detailsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditEventsCompanion copyWith(
      {Value<String>? auditEventId,
      Value<DateTime>? createdAt,
      Value<String>? eventType,
      Value<int?>? babyId,
      Value<String?>? measurementId,
      Value<String?>? deviceId,
      Value<String?>? detailsJson,
      Value<int>? rowid}) {
    return AuditEventsCompanion(
      auditEventId: auditEventId ?? this.auditEventId,
      createdAt: createdAt ?? this.createdAt,
      eventType: eventType ?? this.eventType,
      babyId: babyId ?? this.babyId,
      measurementId: measurementId ?? this.measurementId,
      deviceId: deviceId ?? this.deviceId,
      detailsJson: detailsJson ?? this.detailsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (auditEventId.present) {
      map['audit_event_id'] = Variable<String>(auditEventId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<int>(babyId.value);
    }
    if (measurementId.present) {
      map['measurement_id'] = Variable<String>(measurementId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditEventsCompanion(')
          ..write('auditEventId: $auditEventId, ')
          ..write('createdAt: $createdAt, ')
          ..write('eventType: $eventType, ')
          ..write('babyId: $babyId, ')
          ..write('measurementId: $measurementId, ')
          ..write('deviceId: $deviceId, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BabiesTable babies = $BabiesTable(this);
  late final $MeasurementsTable measurements = $MeasurementsTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $AuditEventsTable auditEvents = $AuditEventsTable(this);
  late final BabiesDao babiesDao = BabiesDao(this as AppDatabase);
  late final MeasurementsDao measurementsDao =
      MeasurementsDao(this as AppDatabase);
  late final DevicesDao devicesDao = DevicesDao(this as AppDatabase);
  late final AuditDao auditDao = AuditDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [babies, measurements, devices, auditEvents];
}

typedef $$BabiesTableCreateCompanionBuilder = BabiesCompanion Function({
  Value<int> id,
  required String name,
  required DateTime dateOfBirth,
  required double weightKg,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isArchived,
});
typedef $$BabiesTableUpdateCompanionBuilder = BabiesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> dateOfBirth,
  Value<double> weightKg,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isArchived,
});

final class $$BabiesTableReferences
    extends BaseReferences<_$AppDatabase, $BabiesTable, Baby> {
  $$BabiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MeasurementsTable, List<Measurement>>
      _measurementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.measurements,
              aliasName:
                  $_aliasNameGenerator(db.babies.id, db.measurements.babyId));

  $$MeasurementsTableProcessedTableManager get measurementsRefs {
    final manager = $$MeasurementsTableTableManager($_db, $_db.measurements)
        .filter((f) => f.babyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_measurementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BabiesTableFilterComposer
    extends Composer<_$AppDatabase, $BabiesTable> {
  $$BabiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  Expression<bool> measurementsRefs(
      Expression<bool> Function($$MeasurementsTableFilterComposer f) f) {
    final $$MeasurementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurements,
        getReferencedColumn: (t) => t.babyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementsTableFilterComposer(
              $db: $db,
              $table: $db.measurements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BabiesTableOrderingComposer
    extends Composer<_$AppDatabase, $BabiesTable> {
  $$BabiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));
}

class $$BabiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BabiesTable> {
  $$BabiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  Expression<T> measurementsRefs<T extends Object>(
      Expression<T> Function($$MeasurementsTableAnnotationComposer a) f) {
    final $$MeasurementsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurements,
        getReferencedColumn: (t) => t.babyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementsTableAnnotationComposer(
              $db: $db,
              $table: $db.measurements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BabiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BabiesTable,
    Baby,
    $$BabiesTableFilterComposer,
    $$BabiesTableOrderingComposer,
    $$BabiesTableAnnotationComposer,
    $$BabiesTableCreateCompanionBuilder,
    $$BabiesTableUpdateCompanionBuilder,
    (Baby, $$BabiesTableReferences),
    Baby,
    PrefetchHooks Function({bool measurementsRefs})> {
  $$BabiesTableTableManager(_$AppDatabase db, $BabiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BabiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BabiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BabiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> dateOfBirth = const Value.absent(),
            Value<double> weightKg = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
          }) =>
              BabiesCompanion(
            id: id,
            name: name,
            dateOfBirth: dateOfBirth,
            weightKg: weightKg,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isArchived: isArchived,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required DateTime dateOfBirth,
            required double weightKg,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
          }) =>
              BabiesCompanion.insert(
            id: id,
            name: name,
            dateOfBirth: dateOfBirth,
            weightKg: weightKg,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isArchived: isArchived,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BabiesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({measurementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (measurementsRefs) db.measurements],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (measurementsRefs)
                    await $_getPrefetchedData<Baby, $BabiesTable, Measurement>(
                        currentTable: table,
                        referencedTable:
                            $$BabiesTableReferences._measurementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BabiesTableReferences(db, table, p0)
                                .measurementsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.babyId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BabiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BabiesTable,
    Baby,
    $$BabiesTableFilterComposer,
    $$BabiesTableOrderingComposer,
    $$BabiesTableAnnotationComposer,
    $$BabiesTableCreateCompanionBuilder,
    $$BabiesTableUpdateCompanionBuilder,
    (Baby, $$BabiesTableReferences),
    Baby,
    PrefetchHooks Function({bool measurementsRefs})>;
typedef $$MeasurementsTableCreateCompanionBuilder = MeasurementsCompanion
    Function({
  required String measurementId,
  required int babyId,
  required DateTime capturedAt,
  required DateTime receivedAt,
  required double ageHours,
  required double bilirubinMgDl,
  Value<bool> hasImage,
  Value<String?> encryptedImageRef,
  Value<String?> deviceId,
  Value<String?> modelVersion,
  Value<int> rowid,
});
typedef $$MeasurementsTableUpdateCompanionBuilder = MeasurementsCompanion
    Function({
  Value<String> measurementId,
  Value<int> babyId,
  Value<DateTime> capturedAt,
  Value<DateTime> receivedAt,
  Value<double> ageHours,
  Value<double> bilirubinMgDl,
  Value<bool> hasImage,
  Value<String?> encryptedImageRef,
  Value<String?> deviceId,
  Value<String?> modelVersion,
  Value<int> rowid,
});

final class $$MeasurementsTableReferences
    extends BaseReferences<_$AppDatabase, $MeasurementsTable, Measurement> {
  $$MeasurementsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BabiesTable _babyIdTable(_$AppDatabase db) => db.babies
      .createAlias($_aliasNameGenerator(db.measurements.babyId, db.babies.id));

  $$BabiesTableProcessedTableManager get babyId {
    final $_column = $_itemColumn<int>('baby_id')!;

    final manager = $$BabiesTableTableManager($_db, $_db.babies)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_babyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get measurementId => $composableBuilder(
      column: $table.measurementId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get ageHours => $composableBuilder(
      column: $table.ageHours, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bilirubinMgDl => $composableBuilder(
      column: $table.bilirubinMgDl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasImage => $composableBuilder(
      column: $table.hasImage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encryptedImageRef => $composableBuilder(
      column: $table.encryptedImageRef,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => ColumnFilters(column));

  $$BabiesTableFilterComposer get babyId {
    final $$BabiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.babyId,
        referencedTable: $db.babies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BabiesTableFilterComposer(
              $db: $db,
              $table: $db.babies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get measurementId => $composableBuilder(
      column: $table.measurementId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get ageHours => $composableBuilder(
      column: $table.ageHours, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bilirubinMgDl => $composableBuilder(
      column: $table.bilirubinMgDl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasImage => $composableBuilder(
      column: $table.hasImage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encryptedImageRef => $composableBuilder(
      column: $table.encryptedImageRef,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion,
      builder: (column) => ColumnOrderings(column));

  $$BabiesTableOrderingComposer get babyId {
    final $$BabiesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.babyId,
        referencedTable: $db.babies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BabiesTableOrderingComposer(
              $db: $db,
              $table: $db.babies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get measurementId => $composableBuilder(
      column: $table.measurementId, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => column);

  GeneratedColumn<double> get ageHours =>
      $composableBuilder(column: $table.ageHours, builder: (column) => column);

  GeneratedColumn<double> get bilirubinMgDl => $composableBuilder(
      column: $table.bilirubinMgDl, builder: (column) => column);

  GeneratedColumn<bool> get hasImage =>
      $composableBuilder(column: $table.hasImage, builder: (column) => column);

  GeneratedColumn<String> get encryptedImageRef => $composableBuilder(
      column: $table.encryptedImageRef, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => column);

  $$BabiesTableAnnotationComposer get babyId {
    final $$BabiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.babyId,
        referencedTable: $db.babies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BabiesTableAnnotationComposer(
              $db: $db,
              $table: $db.babies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MeasurementsTable,
    Measurement,
    $$MeasurementsTableFilterComposer,
    $$MeasurementsTableOrderingComposer,
    $$MeasurementsTableAnnotationComposer,
    $$MeasurementsTableCreateCompanionBuilder,
    $$MeasurementsTableUpdateCompanionBuilder,
    (Measurement, $$MeasurementsTableReferences),
    Measurement,
    PrefetchHooks Function({bool babyId})> {
  $$MeasurementsTableTableManager(_$AppDatabase db, $MeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> measurementId = const Value.absent(),
            Value<int> babyId = const Value.absent(),
            Value<DateTime> capturedAt = const Value.absent(),
            Value<DateTime> receivedAt = const Value.absent(),
            Value<double> ageHours = const Value.absent(),
            Value<double> bilirubinMgDl = const Value.absent(),
            Value<bool> hasImage = const Value.absent(),
            Value<String?> encryptedImageRef = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String?> modelVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MeasurementsCompanion(
            measurementId: measurementId,
            babyId: babyId,
            capturedAt: capturedAt,
            receivedAt: receivedAt,
            ageHours: ageHours,
            bilirubinMgDl: bilirubinMgDl,
            hasImage: hasImage,
            encryptedImageRef: encryptedImageRef,
            deviceId: deviceId,
            modelVersion: modelVersion,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String measurementId,
            required int babyId,
            required DateTime capturedAt,
            required DateTime receivedAt,
            required double ageHours,
            required double bilirubinMgDl,
            Value<bool> hasImage = const Value.absent(),
            Value<String?> encryptedImageRef = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String?> modelVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MeasurementsCompanion.insert(
            measurementId: measurementId,
            babyId: babyId,
            capturedAt: capturedAt,
            receivedAt: receivedAt,
            ageHours: ageHours,
            bilirubinMgDl: bilirubinMgDl,
            hasImage: hasImage,
            encryptedImageRef: encryptedImageRef,
            deviceId: deviceId,
            modelVersion: modelVersion,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MeasurementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({babyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (babyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.babyId,
                    referencedTable:
                        $$MeasurementsTableReferences._babyIdTable(db),
                    referencedColumn:
                        $$MeasurementsTableReferences._babyIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MeasurementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MeasurementsTable,
    Measurement,
    $$MeasurementsTableFilterComposer,
    $$MeasurementsTableOrderingComposer,
    $$MeasurementsTableAnnotationComposer,
    $$MeasurementsTableCreateCompanionBuilder,
    $$MeasurementsTableUpdateCompanionBuilder,
    (Measurement, $$MeasurementsTableReferences),
    Measurement,
    PrefetchHooks Function({bool babyId})>;
typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required String deviceId,
  required String displayName,
  required String transport,
  Value<bool> isPaired,
  Value<DateTime?> pairedAt,
  Value<DateTime?> lastSeenAt,
  Value<String?> firmwareVersion,
  Value<String?> publicKey,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> deviceId,
  Value<String> displayName,
  Value<String> transport,
  Value<bool> isPaired,
  Value<DateTime?> pairedAt,
  Value<DateTime?> lastSeenAt,
  Value<String?> firmwareVersion,
  Value<String?> publicKey,
  Value<int> rowid,
});

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transport => $composableBuilder(
      column: $table.transport, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPaired => $composableBuilder(
      column: $table.isPaired, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get pairedAt => $composableBuilder(
      column: $table.pairedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
      column: $table.lastSeenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firmwareVersion => $composableBuilder(
      column: $table.firmwareVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get publicKey => $composableBuilder(
      column: $table.publicKey, builder: (column) => ColumnFilters(column));
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transport => $composableBuilder(
      column: $table.transport, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPaired => $composableBuilder(
      column: $table.isPaired, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get pairedAt => $composableBuilder(
      column: $table.pairedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
      column: $table.lastSeenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firmwareVersion => $composableBuilder(
      column: $table.firmwareVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get publicKey => $composableBuilder(
      column: $table.publicKey, builder: (column) => ColumnOrderings(column));
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get transport =>
      $composableBuilder(column: $table.transport, builder: (column) => column);

  GeneratedColumn<bool> get isPaired =>
      $composableBuilder(column: $table.isPaired, builder: (column) => column);

  GeneratedColumn<DateTime> get pairedAt =>
      $composableBuilder(column: $table.pairedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
      column: $table.lastSeenAt, builder: (column) => column);

  GeneratedColumn<String> get firmwareVersion => $composableBuilder(
      column: $table.firmwareVersion, builder: (column) => column);

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);
}

class $$DevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
    Device,
    PrefetchHooks Function()> {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> deviceId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> transport = const Value.absent(),
            Value<bool> isPaired = const Value.absent(),
            Value<DateTime?> pairedAt = const Value.absent(),
            Value<DateTime?> lastSeenAt = const Value.absent(),
            Value<String?> firmwareVersion = const Value.absent(),
            Value<String?> publicKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion(
            deviceId: deviceId,
            displayName: displayName,
            transport: transport,
            isPaired: isPaired,
            pairedAt: pairedAt,
            lastSeenAt: lastSeenAt,
            firmwareVersion: firmwareVersion,
            publicKey: publicKey,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String deviceId,
            required String displayName,
            required String transport,
            Value<bool> isPaired = const Value.absent(),
            Value<DateTime?> pairedAt = const Value.absent(),
            Value<DateTime?> lastSeenAt = const Value.absent(),
            Value<String?> firmwareVersion = const Value.absent(),
            Value<String?> publicKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion.insert(
            deviceId: deviceId,
            displayName: displayName,
            transport: transport,
            isPaired: isPaired,
            pairedAt: pairedAt,
            lastSeenAt: lastSeenAt,
            firmwareVersion: firmwareVersion,
            publicKey: publicKey,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DevicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
    Device,
    PrefetchHooks Function()>;
typedef $$AuditEventsTableCreateCompanionBuilder = AuditEventsCompanion
    Function({
  required String auditEventId,
  Value<DateTime> createdAt,
  required String eventType,
  Value<int?> babyId,
  Value<String?> measurementId,
  Value<String?> deviceId,
  Value<String?> detailsJson,
  Value<int> rowid,
});
typedef $$AuditEventsTableUpdateCompanionBuilder = AuditEventsCompanion
    Function({
  Value<String> auditEventId,
  Value<DateTime> createdAt,
  Value<String> eventType,
  Value<int?> babyId,
  Value<String?> measurementId,
  Value<String?> deviceId,
  Value<String?> detailsJson,
  Value<int> rowid,
});

class $$AuditEventsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditEventsTable> {
  $$AuditEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get auditEventId => $composableBuilder(
      column: $table.auditEventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get babyId => $composableBuilder(
      column: $table.babyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get measurementId => $composableBuilder(
      column: $table.measurementId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detailsJson => $composableBuilder(
      column: $table.detailsJson, builder: (column) => ColumnFilters(column));
}

class $$AuditEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditEventsTable> {
  $$AuditEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get auditEventId => $composableBuilder(
      column: $table.auditEventId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get babyId => $composableBuilder(
      column: $table.babyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get measurementId => $composableBuilder(
      column: $table.measurementId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detailsJson => $composableBuilder(
      column: $table.detailsJson, builder: (column) => ColumnOrderings(column));
}

class $$AuditEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditEventsTable> {
  $$AuditEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get auditEventId => $composableBuilder(
      column: $table.auditEventId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<String> get measurementId => $composableBuilder(
      column: $table.measurementId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get detailsJson => $composableBuilder(
      column: $table.detailsJson, builder: (column) => column);
}

class $$AuditEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditEventsTable,
    AuditEvent,
    $$AuditEventsTableFilterComposer,
    $$AuditEventsTableOrderingComposer,
    $$AuditEventsTableAnnotationComposer,
    $$AuditEventsTableCreateCompanionBuilder,
    $$AuditEventsTableUpdateCompanionBuilder,
    (AuditEvent, BaseReferences<_$AppDatabase, $AuditEventsTable, AuditEvent>),
    AuditEvent,
    PrefetchHooks Function()> {
  $$AuditEventsTableTableManager(_$AppDatabase db, $AuditEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> auditEventId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<int?> babyId = const Value.absent(),
            Value<String?> measurementId = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String?> detailsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditEventsCompanion(
            auditEventId: auditEventId,
            createdAt: createdAt,
            eventType: eventType,
            babyId: babyId,
            measurementId: measurementId,
            deviceId: deviceId,
            detailsJson: detailsJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String auditEventId,
            Value<DateTime> createdAt = const Value.absent(),
            required String eventType,
            Value<int?> babyId = const Value.absent(),
            Value<String?> measurementId = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String?> detailsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditEventsCompanion.insert(
            auditEventId: auditEventId,
            createdAt: createdAt,
            eventType: eventType,
            babyId: babyId,
            measurementId: measurementId,
            deviceId: deviceId,
            detailsJson: detailsJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AuditEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuditEventsTable,
    AuditEvent,
    $$AuditEventsTableFilterComposer,
    $$AuditEventsTableOrderingComposer,
    $$AuditEventsTableAnnotationComposer,
    $$AuditEventsTableCreateCompanionBuilder,
    $$AuditEventsTableUpdateCompanionBuilder,
    (AuditEvent, BaseReferences<_$AppDatabase, $AuditEventsTable, AuditEvent>),
    AuditEvent,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BabiesTableTableManager get babies =>
      $$BabiesTableTableManager(_db, _db.babies);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db, _db.measurements);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$AuditEventsTableTableManager get auditEvents =>
      $$AuditEventsTableTableManager(_db, _db.auditEvents);
}
