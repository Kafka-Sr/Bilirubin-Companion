import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bilirubin/database/database.dart';
import 'package:bilirubin/repositories/cloud_sync_repository.dart';
import 'package:bilirubin/models/local_sync_outbox_entry.dart';
import 'package:bilirubin/repositories/local_sync_outbox.dart';

class SyncService {
  SyncService(this._outbox, this._cloud, this._db);

  final LocalSyncOutbox _outbox;
  final CloudSyncRepository _cloud;
  final AppDatabase _db;

  Future<void> drainOutbox() async {
    if (!_cloud.isEnabled) return;

    final entries = await _outbox.readPending();
    if (entries.isEmpty) return;

    final toRemove = <String>{};
    bool hasNetworkError = false;

    Future<void> attempt(
      List<LocalSyncOutboxEntry> batch,
      Future<void> Function() work,
    ) async {
      if (batch.isEmpty) return;
      try {
        await work();
        for (final e in batch) {
          toRemove.add(e.id);
        }
      } on PostgrestException catch (e) {
        if (e.code == '23505') {
          // Unique violation: row is already in cloud — safe to drop.
          debugPrint('drainOutbox: row already in cloud, dropping: $e');
          for (final entry in batch) {
            toRemove.add(entry.id);
          }
        } else {
          // RLS violations, FK errors, etc. are transient — keep for retry.
          debugPrint('drainOutbox: Supabase error (${e.code}), will retry: $e');
          hasNetworkError = true;
        }
      } catch (e) {
        debugPrint('drainOutbox: network error, will retry: $e');
        hasNetworkError = true;
      }
    }

    final babyUpsertEntries = entries
        .where((e) => e.table == 'babies' && e.action == 'upsert')
        .toList();
    for (final entry in babyUpsertEntries) {
      await attempt([entry], () => _cloud.upsertRows(
            table: 'babies',
            rows: [entry.payload],
            onConflict: 'baby_id',
          ));
    }

    final measurementUpsertBatch = entries
        .where((e) => e.table == 'measurements' && e.action == 'upsert')
        .toList();
    await attempt(measurementUpsertBatch, () => _cloud.upsertRows(
          table: 'measurements',
          rows: measurementUpsertBatch.map((e) {
            final p = Map<String, dynamic>.from(e.payload)..remove('received_at');
            return p;
          }).toList(),
          onConflict: 'measurement_id',
        ));

    final babyDeleteBatch = entries
        .where((e) => e.table == 'babies' && e.action == 'delete')
        .toList();
    for (final e in babyDeleteBatch) {
      final id = e.payload['baby_id'];
      if (id == null) {
        toRemove.add(e.id);
        continue;
      }
      await attempt([e], () => _cloud.deleteRow(
            table: 'babies', column: 'baby_id', value: id));
    }

    final measurementDeleteBatch = entries
        .where((e) => e.table == 'measurements' && e.action == 'delete')
        .toList();
    for (final e in measurementDeleteBatch) {
      final id = e.payload['measurement_id'];
      if (id == null) {
        toRemove.add(e.id);
        continue;
      }
      await attempt([e], () => _cloud.deleteRow(
            table: 'measurements',
            column: 'measurement_id',
            value: id));
    }

    final auditUpsertBatch = entries
        .where((e) => e.table == 'audit_events' && e.action == 'upsert')
        .toList();
    await attempt(auditUpsertBatch, () => _cloud.upsertRows(
          table: 'audit_events',
          rows: auditUpsertBatch.map((e) => e.payload).toList(),
          onConflict: 'audit_event_id',
        ));

    await _outbox.removeIds(toRemove);
    if (hasNetworkError) throw Exception('Sync incomplete — some entries kept for retry.');
  }

  Future<void> pullChanges() async {
    if (!_cloud.isEnabled) return;

    try {
      final babyRows =
          await _cloud.fetchRows(table: 'babies', orderBy: 'updated_at');
      for (final row in babyRows) {
        final cloudUpdatedAt = DateTime.parse(row['updated_at'] as String);
        final existing = await _db.babiesDao.getBabyById(row['baby_id'] as String);
        if (existing != null && !cloudUpdatedAt.isAfter(existing.updatedAt)) {
          continue;
        }
        await _db.babiesDao.upsertBaby(BabiesCompanion(
          babyId: Value(row['baby_id'] as String),
          hospitalId: Value(row['hospital_id'] as String),
          babyName: Value(row['baby_name'] as String),
          babyDob: Value(DateTime.parse(row['baby_dob'] as String)),
          babyWeight: Value((row['baby_weight'] as num).toDouble()),
          isArchived: Value(row['is_archived'] as bool? ?? false),
          createdAt: Value(DateTime.parse(row['created_at'] as String)),
          updatedAt: Value(cloudUpdatedAt),
        ));
      }

      final measurementRows = await _cloud.fetchRows(
          table: 'measurements', orderBy: 'captured_at');
      for (final row in measurementRows) {
        final bilirubinRaw = row['bilirubin_mgdl'];
        if (bilirubinRaw == null) continue;
        await _db.measurementsDao.upsertMeasurement(MeasurementsCompanion(
          measurementId: Value(row['measurement_id'] as String),
          babyId: Value(row['baby_id'] as String),
          capturedAt: Value(DateTime.parse(row['captured_at'] as String)),
          ageHours: Value((row['age_hours'] as num).toDouble()),
          bilirubinMgdl: Value((bilirubinRaw as num).toDouble()),
          hasImage: Value(row['has_image'] as bool? ?? false),
          encryptedImageRef: Value(row['encrypted_image_ref'] as String?),
          deviceId: Value(row['device_id'] as String?),
          modelVersion: Value(row['model_version'] as String?),
        ));
      }
    } catch (_) {
      // Offline is acceptable — retry on next pull.
    }
  }

  /// Directly upserts all local babies belonging to [userHospitalId] to
  /// Supabase, bypassing the outbox. Babies with a different hospital_id
  /// (orphans from a deleted hospital) are skipped and counted separately.
  /// Returns {'synced': N, 'skipped': M}.
  Future<Map<String, int>> repairBabySync(String userHospitalId) async {
    if (!_cloud.isEnabled) return {'synced': 0, 'skipped': 0};

    final active = await _db.babiesDao.watchAllActive().first;
    final archived = await _db.babiesDao.watchAllArchived().first;
    final all = [...active, ...archived];

    final toSync =
        all.where((b) => b.hospitalId == userHospitalId).toList();
    final skipped = all.length - toSync.length;

    if (toSync.isNotEmpty) {
      await _cloud.upsertRows(
        table: 'babies',
        rows: toSync
            .map((b) => {
                  'baby_id': b.babyId,
                  'hospital_id': b.hospitalId,
                  'baby_name': b.babyName,
                  'baby_dob': b.babyDob.toUtc().toIso8601String(),
                  'baby_weight': b.babyWeight,
                  'is_archived': b.isArchived,
                  'created_at': b.createdAt.toUtc().toIso8601String(),
                  'updated_at': b.updatedAt.toUtc().toIso8601String(),
                })
            .toList(),
        onConflict: 'baby_id',
      );
    }

    return {'synced': toSync.length, 'skipped': skipped};
  }
}
