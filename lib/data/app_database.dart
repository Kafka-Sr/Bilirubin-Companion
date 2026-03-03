import 'dart:typed_data';

import 'package:bilirubin_companion/data/models.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

class AppDatabase extends DatabaseConnectionUser {
  AppDatabase() : super(DatabaseConnection.fromExecutor(driftDatabase(name: 'bilirubinCompanion.sqlite')));

  bool inited = false;

  Future<void> init() async {
    if (inited) return;
    await customStatement('''
      CREATE TABLE IF NOT EXISTS babies (
        babyId TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        dateOfBirth INTEGER,
        weightKg REAL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        isArchived INTEGER NOT NULL DEFAULT 0
      );
    ''');
    await customStatement('CREATE INDEX IF NOT EXISTS babiesNameIdx ON babies(name);');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS measurements (
        measurementId TEXT PRIMARY KEY,
        babyId TEXT NOT NULL,
        capturedAt INTEGER NOT NULL,
        receivedAt INTEGER NOT NULL,
        ageHours INTEGER NOT NULL,
        bilirubinMgDl REAL NOT NULL,
        hasImage INTEGER NOT NULL,
        imageBytes BLOB,
        deviceId TEXT NOT NULL,
        modelVersion TEXT NOT NULL
      );
    ''');
    await customStatement('CREATE INDEX IF NOT EXISTS measurementsBabyIdx ON measurements(babyId);');
    await customStatement('CREATE INDEX IF NOT EXISTS measurementsCapturedIdx ON measurements(capturedAt);');
    await customStatement('CREATE INDEX IF NOT EXISTS measurementsBabyCapturedIdx ON measurements(babyId, capturedAt);');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS devices (
        deviceId TEXT PRIMARY KEY,
        displayName TEXT NOT NULL,
        transport TEXT NOT NULL,
        isPaired INTEGER NOT NULL,
        pairedAt INTEGER,
        lastSeenAt INTEGER
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS auditEvents (
        auditEventId TEXT PRIMARY KEY,
        createdAt INTEGER NOT NULL,
        eventType TEXT NOT NULL,
        babyId TEXT,
        measurementId TEXT,
        deviceId TEXT,
        detailsJson TEXT
      );
    ''');
    await customStatement('CREATE INDEX IF NOT EXISTS auditEventsCreatedIdx ON auditEvents(createdAt);');
    inited = true;
  }

  Future<List<BabyRecord>> getBabies({String search = ''}) async {
    await init();
    final rows = await customSelect(
      'SELECT * FROM babies WHERE isArchived = 0 AND name LIKE ? ORDER BY updatedAt DESC',
      variables: [Variable.withString('%$search%')],
    ).get();
    return rows
        .map(
          (r) => BabyRecord(
            babyId: r.read<String>('babyId'),
            name: r.read<String>('name'),
            dateOfBirth: r.read<int?>('dateOfBirth') == null ? null : DateTime.fromMillisecondsSinceEpoch(r.read<int>('dateOfBirth')),
            weightKg: r.read<double?>('weightKg'),
            createdAt: DateTime.fromMillisecondsSinceEpoch(r.read<int>('createdAt')),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(r.read<int>('updatedAt')),
            isArchived: r.read<int>('isArchived') == 1,
          ),
        )
        .toList();
  }

  Future<void> upsertBaby(BabyRecord baby) async {
    await init();
    await customStatement(
      'INSERT OR REPLACE INTO babies (babyId, name, dateOfBirth, weightKg, createdAt, updatedAt, isArchived) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        baby.babyId,
        baby.name,
        baby.dateOfBirth?.millisecondsSinceEpoch,
        baby.weightKg,
        baby.createdAt.millisecondsSinceEpoch,
        baby.updatedAt.millisecondsSinceEpoch,
        baby.isArchived ? 1 : 0,
      ],
    );
  }

  Future<List<MeasurementRecord>> getMeasurements(String babyId) async {
    await init();
    final rows = await customSelect(
      'SELECT * FROM measurements WHERE babyId = ? ORDER BY capturedAt DESC',
      variables: [Variable.withString(babyId)],
    ).get();
    return rows
        .map(
          (r) => MeasurementRecord(
            measurementId: r.read<String>('measurementId'),
            babyId: r.read<String>('babyId'),
            capturedAt: DateTime.fromMillisecondsSinceEpoch(r.read<int>('capturedAt')),
            receivedAt: DateTime.fromMillisecondsSinceEpoch(r.read<int>('receivedAt')),
            ageHours: r.read<int>('ageHours'),
            bilirubinMgDl: r.read<double>('bilirubinMgDl'),
            hasImage: r.read<int>('hasImage') == 1,
            imageBytes: r.read<Uint8List?>('imageBytes'),
            deviceId: r.read<String>('deviceId'),
            modelVersion: r.read<String>('modelVersion'),
          ),
        )
        .toList();
  }

  Future<void> insertMeasurement(MeasurementRecord measurement) async {
    await init();
    await customStatement(
      'INSERT INTO measurements (measurementId, babyId, capturedAt, receivedAt, ageHours, bilirubinMgDl, hasImage, imageBytes, deviceId, modelVersion) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        measurement.measurementId,
        measurement.babyId,
        measurement.capturedAt.millisecondsSinceEpoch,
        measurement.receivedAt.millisecondsSinceEpoch,
        measurement.ageHours,
        measurement.bilirubinMgDl,
        measurement.hasImage ? 1 : 0,
        measurement.imageBytes,
        measurement.deviceId,
        measurement.modelVersion,
      ],
    );
  }

  Future<void> addAuditEvent({
    required String auditEventId,
    required String eventType,
    String? babyId,
    String? measurementId,
    String? deviceId,
    String? detailsJson,
  }) async {
    await init();
    await customStatement(
      'INSERT INTO auditEvents (auditEventId, createdAt, eventType, babyId, measurementId, deviceId, detailsJson) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [auditEventId, DateTime.now().millisecondsSinceEpoch, eventType, babyId, measurementId, deviceId, detailsJson],
    );
  }

  Future<void> disposeDatabase() => close();
}
