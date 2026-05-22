import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:bilirubin/core/constants.dart';
import 'package:bilirubin/database/database.dart';
import 'package:bilirubin/repositories/local_sync_outbox.dart';

/// Append-only audit log repository.
///
/// [hospitalId] scopes events to the correct hospital so they can be synced
/// to Supabase and queried by admins via RLS.
class AuditRepository {
  AuditRepository(this._db, {this.hospitalId, LocalSyncOutbox? outbox})
      : _outbox = outbox;

  final AppDatabase _db;
  final String? hospitalId;
  final LocalSyncOutbox? _outbox;
  final _uuid = const Uuid();

  // ── Baby ───────────────────────────────────────────────────────────────────

  Future<void> logBabyCreate(String babyId) =>
      _insert(eventType: kAuditBabyCreate, babyId: babyId);

  Future<void> logBabyEdit(String babyId) =>
      _insert(eventType: kAuditBabyEdit, babyId: babyId);

  Future<void> logBabyDelete(String babyId) =>
      _insert(eventType: kAuditBabyDelete, babyId: babyId);

  // ── Measurement ────────────────────────────────────────────────────────────

  Future<void> logMeasurementCreate(String measurementId, String babyId) =>
      _insert(
          eventType: kAuditMeasurementCreate,
          babyId: babyId,
          measurementId: measurementId);

  Future<void> logMeasurementDelete(String measurementId, String babyId) =>
      _insert(
          eventType: kAuditMeasurementDelete,
          babyId: babyId,
          measurementId: measurementId);

  // ── Export ─────────────────────────────────────────────────────────────────

  Future<void> logExport(String babyId) =>
      _insert(eventType: kAuditExport, babyId: babyId);

  // ── Account ────────────────────────────────────────────────────────────────

  Future<void> logAccountCreate(String targetUserId, String role) =>
      _insert(
          eventType: kAuditAccountCreate,
          detailsJson:
              jsonEncode({'target_user_id': targetUserId, 'role': role}));

  Future<void> logAccountDeactivate(String targetUserId, String role) =>
      _insert(
          eventType: kAuditAccountDeactivate,
          detailsJson:
              jsonEncode({'target_user_id': targetUserId, 'role': role}));

  Future<void> logAccountReactivate(String targetUserId, String role) =>
      _insert(
          eventType: kAuditAccountReactivate,
          detailsJson:
              jsonEncode({'target_user_id': targetUserId, 'role': role}));

  // ── Parent access ──────────────────────────────────────────────────────────

  Future<void> logParentLink(String parentId, String babyId) => _insert(
      eventType: kAuditParentLink,
      babyId: babyId,
      detailsJson: jsonEncode({'parent_id': parentId}));

  Future<void> logParentUnlink(String parentId, String babyId) => _insert(
      eventType: kAuditParentUnlink,
      babyId: babyId,
      detailsJson: jsonEncode({'parent_id': parentId}));

  // ── Device ─────────────────────────────────────────────────────────────────

  Future<void> logDeviceAdd(String deviceId) =>
      _insert(eventType: kAuditDeviceAdd, deviceId: deviceId);

  // ── Transfer ───────────────────────────────────────────────────────────────

  Future<void> logTransferCreate(String babyId, String toHospitalCode) =>
      _insert(
          eventType: kAuditTransferCreate,
          babyId: babyId,
          detailsJson: jsonEncode({'to_hospital_code': toHospitalCode}));

  Future<void> logTransferAccept(String babyId, String fromHospitalCode) =>
      _insert(
          eventType: kAuditTransferAccept,
          babyId: babyId,
          detailsJson: jsonEncode({'from_hospital_code': fromHospitalCode}));

  Future<void> logTransferReject(String babyId, String fromHospitalCode) =>
      _insert(
          eventType: kAuditTransferReject,
          babyId: babyId,
          detailsJson: jsonEncode({'from_hospital_code': fromHospitalCode}));

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _insert({
    required String eventType,
    String? babyId,
    String? measurementId,
    String? deviceId,
    String? detailsJson,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.auditDao.insertEvent(AuditEventsCompanion.insert(
      auditEventId: id,
      createdAt: Value(now),
      eventType: eventType,
      babyId: Value(babyId),
      measurementId: Value(measurementId),
      deviceId: Value(deviceId),
      hospitalId: Value(hospitalId),
      detailsJson: Value(detailsJson),
    ));
    await _enqueue(id, now, eventType,
        babyId: babyId,
        measurementId: measurementId,
        deviceId: deviceId,
        detailsJson: detailsJson);
  }

  Future<void> _enqueue(
    String id,
    DateTime createdAt,
    String eventType, {
    String? babyId,
    String? measurementId,
    String? deviceId,
    String? detailsJson,
  }) async {
    final outbox = _outbox;
    if (outbox == null) return;
    try {
      await outbox.enqueue(
        table: 'audit_events',
        action: 'upsert',
        entityId: id,
        payload: {
          'audit_event_id': id,
          'created_at': createdAt.toIso8601String(),
          'event_type': eventType,
          'hospital_id': hospitalId,
          if (babyId != null) 'baby_id': babyId,
          if (measurementId != null) 'measurement_id': measurementId,
          if (deviceId != null) 'device_id': deviceId,
          if (detailsJson != null) 'details_json': detailsJson,
        },
      );
    } catch (_) {
      // Must not block the original operation.
    }
  }
}
