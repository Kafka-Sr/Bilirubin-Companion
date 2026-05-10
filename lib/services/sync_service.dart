import 'package:bilirubin/models/local_sync_outbox_entry.dart';
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/repositories/cloud_sync_repository.dart';
import 'package:bilirubin/repositories/local_sync_outbox.dart';
import 'package:bilirubin/repositories/measurement_repository.dart';

enum SyncStatus { disabled, nothingToDo, success, error }

class SyncResult {
  const SyncResult._(this.status, {this.count = 0, this.errorMessage});

  static const disabled = SyncResult._(SyncStatus.disabled);
  static const nothingToDo = SyncResult._(SyncStatus.nothingToDo);

  factory SyncResult.success(int count) =>
      SyncResult._(SyncStatus.success, count: count);
  factory SyncResult.error(String msg) =>
      SyncResult._(SyncStatus.error, errorMessage: msg);

  final SyncStatus status;
  final int count;
  final String? errorMessage;

  bool get ok =>
      status == SyncStatus.success || status == SyncStatus.nothingToDo;
}

/// Drains the local sync outbox and pushes pending changes to Supabase.
///
/// Call [pushPending] after the user has an active session and a known
/// [hospitalId]. On error the outbox is left intact so the next call retries.
class SyncService {
  const SyncService({
    required LocalSyncOutbox outbox,
    required CloudSyncRepository cloudSync,
  })  : _outbox = outbox,
        _cloudSync = cloudSync;

  final LocalSyncOutbox _outbox;
  final CloudSyncRepository _cloudSync;

  /// Pulls measurements from Supabase for each baby and inserts any that are
  /// missing locally. Existing local rows are never overwritten (images safe).
  ///
  /// Pass [capturedAfter] to limit the fetch window; defaults to 30 days.
  Future<void> pullMeasurements({
    required String hospitalId,
    required List<Baby> babies,
    required MeasurementRepository measurementRepo,
    DateTime? capturedAfter,
  }) async {
    if (!_cloudSync.isEnabled || babies.isEmpty) return;
    final after =
        capturedAfter ?? DateTime.now().subtract(const Duration(days: 30));
    for (final baby in babies) {
      final rows = await _cloudSync.fetchMeasurements(
        hospitalId: hospitalId,
        babyLocalId: baby.id,
        capturedAfter: after,
      );
      for (final row in rows) {
        await measurementRepo.upsertFromCloud(row, baby.id);
      }
    }
  }

  /// Upserts every baby in [babies] to the cloud unconditionally.
  /// Call this alongside [pushPending] so pre-outbox babies are never missed.
  Future<void> pushAllBabies({
    required String hospitalId,
    required List<Baby> babies,
  }) async {
    if (!_cloudSync.isEnabled || babies.isEmpty) return;
    final rows = babies
        .map((b) => {
              'hospital_id': hospitalId,
              'local_id': b.id,
              'name': b.name,
              'date_of_birth': b.dateOfBirth.toIso8601String(),
              'weight_kg': b.weightKg,
              'is_archived': b.isArchived,
              'created_at': b.createdAt.toIso8601String(),
              'updated_at': b.updatedAt.toIso8601String(),
            })
        .toList();
    await _cloudSync.upsertRows(
      table: 'babies',
      rows: rows,
      onConflict: 'hospital_id,local_id',
    );
  }

  Future<SyncResult> pushPending({required String hospitalId}) async {
    if (!_cloudSync.isEnabled) return SyncResult.disabled;

    final entries = await _outbox.readPending();
    if (entries.isEmpty) return SyncResult.nothingToDo;

    // Process babies before measurements to satisfy any implicit ordering.
    final babies = entries.where((e) => e.table == 'babies').toList();
    final measurements =
        entries.where((e) => e.table == 'measurements').toList();

    for (final entry in [...babies, ...measurements]) {
      try {
        await _process(entry, hospitalId);
      } catch (e) {
        return SyncResult.error(e.toString());
      }
    }

    await _outbox.clear();
    return SyncResult.success(entries.length);
  }

  Future<void> _process(LocalSyncOutboxEntry entry, String hospitalId) {
    switch (entry.table) {
      case 'babies':
        return _processBaby(entry, hospitalId);
      case 'measurements':
        return _processMeasurement(entry, hospitalId);
      default:
        return Future.value();
    }
  }

  Future<void> _processBaby(
      LocalSyncOutboxEntry entry, String hospitalId) async {
    final p = entry.payload;
    switch (entry.action) {
      case 'upsert':
        await _cloudSync.upsertRows(
          table: 'babies',
          rows: [
            {
              'hospital_id': hospitalId,
              'local_id': p['id'],
              'name': p['name'],
              'date_of_birth': p['dateOfBirth'],
              'weight_kg': p['weightKg'],
              'is_archived': p['isArchived'] ?? false,
              'created_at': p['createdAt'],
              'updated_at': p['updatedAt'],
            }
          ],
          onConflict: 'hospital_id,local_id',
        );
      case 'archive':
        await _cloudSync.upsertRows(
          table: 'babies',
          rows: [
            {
              'hospital_id': hospitalId,
              'local_id': p['id'],
              'is_archived': true,
              'updated_at': DateTime.now().toIso8601String(),
            }
          ],
          onConflict: 'hospital_id,local_id',
        );
      case 'restore':
        await _cloudSync.upsertRows(
          table: 'babies',
          rows: [
            {
              'hospital_id': hospitalId,
              'local_id': p['id'],
              'is_archived': false,
              'updated_at': DateTime.now().toIso8601String(),
            }
          ],
          onConflict: 'hospital_id,local_id',
        );
      case 'delete':
        await _cloudSync.deleteWhere(
          table: 'babies',
          filters: {
            'hospital_id': hospitalId,
            'local_id': p['id'] as Object,
          },
        );
    }
  }

  Future<void> _processMeasurement(
      LocalSyncOutboxEntry entry, String hospitalId) async {
    final p = entry.payload;
    switch (entry.action) {
      case 'upsert':
        await _cloudSync.upsertRows(
          table: 'measurements',
          rows: [
            {
              'measurement_id': p['measurementId'],
              'hospital_id': hospitalId,
              'baby_local_id': p['babyId'],
              'captured_at': p['capturedAt'],
              'received_at': p['receivedAt'],
              'age_hours': p['ageHours'],
              'bilirubin_mg_dl': p['bilirubinMgDl'],
              'has_image': p['hasImage'] ?? false,
              'device_id': p['deviceId'],
              'model_version': p['modelVersion'],
            }
          ],
          onConflict: 'measurement_id',
        );
      case 'delete':
        await _cloudSync.deleteRow(
          table: 'measurements',
          column: 'measurement_id',
          value: p['measurementId'] as Object,
        );
    }
  }
}
