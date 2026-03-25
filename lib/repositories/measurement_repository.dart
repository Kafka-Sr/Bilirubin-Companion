import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:bilirubin/core/constants.dart';
import 'package:bilirubin/database/database.dart' hide Baby;
import 'package:bilirubin/device/device_repository.dart';
import 'package:bilirubin/models/measurement.dart' as domain;
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/security/encryption_service.dart';
import 'package:bilirubin/utils/input_validators.dart';

/// Business-logic layer for measurements.
///
/// Responsibilities:
///   • Receive raw [IncomingMeasurement] events from the device layer.
///   • Validate and clamp bilirubin values.
///   • Encrypt and persist image bytes if present.
///   • Upsert into the database (deduplication by [measurementId]).
class MeasurementRepository {
  MeasurementRepository(this._db, this._encryption);

  final AppDatabase _db;
  final EncryptionService _encryption;

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Processes an incoming measurement event for a specific [baby].
  ///
  /// Silently discards the event if [bilirubinMgDl] is outside acceptable
  /// bounds (attacker / malformed device data).
  Future<void> handleIncoming(
    IncomingMeasurement event,
    Baby baby,
  ) async {
    if (!isBilirubinAcceptable(event.bilirubinMgDl)) return;

    final receivedAt = DateTime.now();
    final ageHours = baby.ageHoursAt(event.capturedAt);

    String? imageRef;
    if (event.imageBytes != null && event.imageBytes!.isNotEmpty) {
      imageRef = await _persistImage(event.measurementId, event.imageBytes!);
    }

    await _db.measurementsDao.upsertMeasurement(MeasurementsCompanion.insert(
      measurementId: event.measurementId,
      babyId: baby.id,
      capturedAt: event.capturedAt,
      receivedAt: receivedAt,
      ageHours: ageHours,
      bilirubinMgDl: event.bilirubinMgDl,
      hasImage: Value(imageRef != null),
      encryptedImageRef: Value(imageRef),
      deviceId: Value(event.deviceId),
      modelVersion: Value(event.modelVersion),
    ));
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  Stream<List<domain.Measurement>> watchByBaby(int babyId) =>
      _db.measurementsDao
          .watchByBaby(babyId)
          .map((rows) => rows.map(_toModel).toList());

  Future<domain.Measurement?> getLatest(int babyId) async {
    final row = await _db.measurementsDao.getLatest(babyId);
    return row == null ? null : _toModel(row);
  }

  /// Returns the decrypted image bytes for a measurement, or null.
  Future<Uint8List?> getDecryptedImage(String imageRef) async {
    final file = await _imageFile(imageRef);
    if (!file.existsSync()) return null;
    final blob = await file.readAsBytes();
    return _encryption.decrypt(blob);
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> delete(String measurementId) async {
    // Look up the encrypted image ref before deleting the row.
    final ref = await (_db.select(_db.measurements)
          ..where((m) => m.measurementId.equals(measurementId)))
        .map((r) => r.encryptedImageRef)
        .getSingleOrNull();

    if (ref != null) {
      final file = await _imageFile(ref);
      if (file.existsSync()) await file.delete();
    }
    await _db.measurementsDao.deleteMeasurement(measurementId);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<String> _persistImage(String measurementId, Uint8List raw) async {
    final encrypted = await _encryption.encrypt(raw);
    final filename = '${measurementId.replaceAll('-', '')}.enc';
    final file = await _imageFile(filename);
    await file.writeAsBytes(encrypted);
    return filename;
  }

  Future<File> _imageFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    // Safety: ensure filename contains no path traversal.
    final safe = p.basename(filename);
    if (safe.isEmpty || safe.contains('..')) {
      throw ArgumentError('Invalid image filename: $filename');
    }
    return File(p.join(dir.path, safe));
  }

  // ── Mapper ─────────────────────────────────────────────────────────────────

  static domain.Measurement _toModel(Measurement row) => domain.Measurement(
        measurementId: row.measurementId,
        babyId: row.babyId,
        capturedAt: row.capturedAt,
        receivedAt: row.receivedAt,
        ageHours: row.ageHours,
        bilirubinMgDl: row.bilirubinMgDl,
        hasImage: row.hasImage,
        encryptedImageRef: row.encryptedImageRef,
        deviceId: row.deviceId,
        modelVersion: row.modelVersion,
      );
}

/// Clamps a bilirubin value for safe display without crashing charts.
double clampBilirubin(double v) =>
    v.clamp(kBilirubinMinMgDl, kBilirubinMaxMgDl);
