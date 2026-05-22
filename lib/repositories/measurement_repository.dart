import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bilirubin/core/constants.dart';
import 'package:bilirubin/database/database.dart' hide Baby;
import 'package:bilirubin/device/device_repository.dart';
import 'package:bilirubin/models/measurement.dart' as domain;
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/repositories/audit_repository.dart';
import 'package:bilirubin/repositories/local_sync_outbox.dart';
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
  MeasurementRepository(
    this._db,
    this._encryption, {
    LocalSyncOutbox? outbox,
    void Function()? onQueued,
    SupabaseClient? supabase,
    AuditRepository? audit,
  }) : _outbox = outbox,
       _onQueued = onQueued,
       _supabase = supabase,
       _audit = audit;

  final AppDatabase _db;
  final EncryptionService _encryption;
  final LocalSyncOutbox? _outbox;
  final void Function()? _onQueued;
  final SupabaseClient? _supabase;
  final AuditRepository? _audit;
  final _imageCache = <String, Uint8List>{};

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Processes an incoming measurement event for a specific [baby].
  ///
  /// Silently discards the event if [bilirubinMgDl] is outside acceptable
  /// bounds (attacker / malformed device data).
  Future<void> handleIncoming(
    IncomingMeasurement event,
    Baby baby,
  ) async {
    if (!isBilirubinAcceptable(event.bilirubinMgdl)) return;

    final receivedAt = DateTime.now();
    final ageHours = baby.ageHoursAt(event.capturedAt);

    String? imageRef;
    if (event.imageBytes != null && event.imageBytes!.isNotEmpty) {
      imageRef = await _persistImage(event.measurementId, event.imageBytes!);
    }

    await _db.measurementsDao.upsertMeasurement(MeasurementsCompanion.insert(
      measurementId: event.measurementId,
      babyId: baby.babyId,
      capturedAt: event.capturedAt,
      receivedAt: receivedAt,
      ageHours: ageHours,
      bilirubinMgdl: event.bilirubinMgdl,
      hasImage: Value(imageRef != null),
      encryptedImageRef: Value(imageRef),
      deviceId: Value(event.deviceId),
      modelVersion: Value(event.modelVersion),
    ));
    _audit?.logMeasurementCreate(event.measurementId, baby.babyId);

    await _queue('upsert', {
      'measurement_id': event.measurementId,
      'baby_id': baby.babyId,
      'captured_at': event.capturedAt.toIso8601String(),
      'received_at': receivedAt.toIso8601String(),
      'age_hours': ageHours,
      'bilirubin_mgdl': event.bilirubinMgdl,
      'has_image': imageRef != null,
      'encrypted_image_ref': imageRef,
      'device_id': event.deviceId,
      'model_version': event.modelVersion,
    });
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  Stream<List<domain.Measurement>> watchByBaby(String babyId) =>
      _db.measurementsDao
          .watchByBaby(babyId)
          .map((rows) => rows.map(_toModel).toList());

  Future<domain.Measurement?> getLatest(String babyId) async {
    final row = await _db.measurementsDao.getLatest(babyId);
    return row == null ? null : _toModel(row);
  }

  /// Returns image bytes for a measurement, or null.
  ///
  /// If [imageRef] is a Supabase Storage path (contains '/'), the file is
  /// downloaded from the bucket and returned as-is (plain JPEG from the Gun).
  /// Otherwise the ref is a local filename encrypted with [EncryptionService].
  Future<Uint8List?> getDecryptedImage(String imageRef) async {
    if (_imageCache.containsKey(imageRef)) return _imageCache[imageRef];
    final Uint8List? result;
    if (imageRef.contains('/')) {
      result = await _fetchCloudImage(imageRef);
    } else {
      final file = await _imageFile(imageRef);
      if (!file.existsSync()) return null;
      final blob = await file.readAsBytes();
      result = await _encryption.decrypt(blob);
    }
    if (result != null) _imageCache[imageRef] = result;
    return result;
  }

  Future<Uint8List?> _fetchCloudImage(String storagePath) async {
    final client = _supabase;
    if (client == null) return null;
    try {
      final slash = storagePath.indexOf('/');
      final bucket = storagePath.substring(0, slash);
      final path = storagePath.substring(slash + 1);
      return await client.storage.from(bucket).download(path);
    } catch (_) {
      return null;
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> delete(String measurementId) async {
    // Look up the row before deleting (need imageRef and babyId).
    final row = await (_db.select(_db.measurements)
          ..where((m) => m.measurementId.equals(measurementId)))
        .getSingleOrNull();

    if (row?.encryptedImageRef != null) {
      final file = await _imageFile(row!.encryptedImageRef!);
      if (file.existsSync()) await file.delete();
    }
    await _db.measurementsDao.deleteMeasurement(measurementId);
    if (row != null) _audit?.logMeasurementDelete(measurementId, row.babyId);
    await _queue('delete', {'measurement_id': measurementId});
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
        bilirubinMgdl: row.bilirubinMgdl,
        hasImage: row.hasImage,
        encryptedImageRef: row.encryptedImageRef,
        deviceId: row.deviceId,
        modelVersion: row.modelVersion,
      );

  Future<void> _queue(String action, Map<String, dynamic> payload) async {
    final outbox = _outbox;
    if (outbox == null) return;
    try {
      await outbox.enqueue(
        table: 'measurements',
        action: action,
        entityId: '${payload['measurement_id'] ?? 'unknown'}',
        payload: payload,
      );
      _onQueued?.call();
    } catch (_) {
      // Temporary staging must not block local capture.
    }
  }
}

/// Clamps a bilirubin value for safe display without crashing charts.
double clampBilirubin(double v) =>
    v.clamp(kBilirubinMinMgDl, kBilirubinMaxMgDl);
