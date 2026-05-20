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
        // Permanent schema/data error — drop these entries, retrying won't help.
        debugPrint('drainOutbox: dropping ${batch.length} entries: $e');
        for (final e in batch) {
          toRemove.add(e.id);
        }
      } catch (e) {
        debugPrint('drainOutbox: network error, will retry: $e');
        hasNetworkError = true;
      }
    }

    final babyUpsertBatch = entries
        .where((e) => e.table == 'babies' && e.action == 'upsert')
        .toList();
    await attempt(babyUpsertBatch, () => _cloud.upsertRows(
          table: 'babies',
          rows: babyUpsertBatch.map((e) => e.payload).toList(),
          onConflict: 'baby_id',
        ));

    final measurementUpsertBatch = entries
        .where((e) => e.table == 'measurements' && e.action == 'upsert')
        .toList();
    await attempt(measurementUpsertBatch, () => _cloud.upsertRows(
          table: 'measurements',
          rows: measurementUpsertBatch.map((e) => e.payload).toList(),
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
        final existing = await _db.babiesDao.getBabyById(row['baby_id'] as int);
        if (existing != null && !cloudUpdatedAt.isAfter(existing.updatedAt)) {
          continue;
        }
        await _db.babiesDao.upsertBaby(BabiesCompanion(
          babyId: Value(row['baby_id'] as int),
          babyName: Value(row['baby_name'] as String),
          babyDob: Value(DateTime.parse(row['baby_dob'] as String)),
          babyWeight: Value((row['baby_weight'] as num).toDouble()),
          isArchived: Value(row['is_archived'] as bool? ?? false),
          createdAt: Value(DateTime.parse(row['created_at'] as String)),
          updatedAt: Value(cloudUpdatedAt),
        ));
      }

      final measurementRows = await _cloud.fetchRows(
          table: 'measurements', orderBy: 'received_at');
      for (final row in measurementRows) {
        await _db.measurementsDao.upsertMeasurement(MeasurementsCompanion(
          measurementId: Value(row['measurement_id'] as String),
          babyId: Value(row['baby_id'] as int),
          capturedAt: Value(DateTime.parse(row['captured_at'] as String)),
          receivedAt: Value(DateTime.parse(row['received_at'] as String)),
          ageHours: Value((row['age_hours'] as num).toDouble()),
          bilirubinMgdl: Value((row['bilirubin_mgdl'] as num).toDouble()),
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
}
