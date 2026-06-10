import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:bilirubin/core/constants.dart';
import 'package:bilirubin/database/database.dart' hide Baby;
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/repositories/local_sync_outbox.dart';

/// Append-only audit log repository.
///
/// [hospitalId] scopes events to the correct hospital.
/// [actorName] is the full name of the currently logged-in user — included in
/// details_json for events explicitly triggered by a staff or admin user.
class AuditRepository {
  AuditRepository(
    this._db, {
    this.hospitalId,
    this.actorName,
    LocalSyncOutbox? outbox,
  }) : _outbox = outbox;

  final AppDatabase _db;
  final String? hospitalId;
  final String? actorName;
  final LocalSyncOutbox? _outbox;
  final _uuid = const Uuid();

  // Baby

  Future<void> logBabyCreate(
    String babyId, {
    required String babyName,
    required DateTime dob,
    required double weightKg,
  }) {
    final details = <String, dynamic>{
      'dob': _fmtDob(dob),
      'weight_kg': weightKg.toStringAsFixed(1),
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditBabyCreate,
      babyId: babyId,
      message: "Baby '$babyName' registered",
      detailsJson: jsonEncode(details),
    );
  }

  Future<void> logBabyEdit(Baby oldBaby, Baby newBaby) {
    final details = <String, dynamic>{};
    if (oldBaby.babyName != newBaby.babyName) {
      details['name'] = '${oldBaby.babyName} → ${newBaby.babyName}';
    } else {
      details['name'] = oldBaby.babyName;
    }
    if (oldBaby.babyWeight != newBaby.babyWeight) {
      details['weight_kg'] =
          '${oldBaby.babyWeight.toStringAsFixed(1)} → ${newBaby.babyWeight.toStringAsFixed(1)}';
    } else {
      details['weight_kg'] = '${oldBaby.babyWeight.toStringAsFixed(1)} kg';
    }
    if (oldBaby.babyDob != newBaby.babyDob) {
      details['dob'] = '${_fmtDob(oldBaby.babyDob)} → ${_fmtDob(newBaby.babyDob)}';
    } else {
      details['dob'] = _fmtDob(oldBaby.babyDob);
    }
    if (actorName != null) details['actor_name'] = actorName;

    return _insert(
      eventType: kAuditBabyEdit,
      babyId: newBaby.babyId,
      message: "Baby '${newBaby.babyName}' profile edited",
      detailsJson: jsonEncode(details),
    );
  }

  Future<void> logBabyDelete(
    String babyId, {
    required String babyName,
    required DateTime dob,
    required double weightKg,
  }) {
    final details = <String, dynamic>{
      'dob': _fmtDob(dob),
      'weight_kg': weightKg.toStringAsFixed(1),
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditBabyDelete,
      babyId: babyId,
      message: "Baby '$babyName' removed",
      detailsJson: jsonEncode(details),
    );
  }

  // Measurement

  Future<void> logMeasurementCreate(
    String measurementId,
    String babyId, {
    required String babyName,
    required double bilirubinMgdl,
    required double ageHours,
    required String zone,
    String? deviceId,
  }) {
    final details = <String, dynamic>{
      'zone': zone,
      if (deviceId != null) 'device_id': deviceId,
    };
    return _insert(
      eventType: kAuditMeasurementCreate,
      babyId: babyId,
      measurementId: measurementId,
      deviceId: deviceId,
      message:
          'Measurement ${bilirubinMgdl.toStringAsFixed(1)} mg/dL at '
          '${ageHours.toStringAsFixed(0)}h recorded for \'$babyName\'',
      detailsJson: jsonEncode(details),
    );
  }

  // Export

  Future<void> logExport(
    String babyId, {
    required String babyName,
    required String fileType,
  }) {
    final details = <String, dynamic>{
      'file_type': fileType,
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditExport,
      babyId: babyId,
      message: "Report exported for '$babyName'",
      detailsJson: jsonEncode(details),
    );
  }

  // Account

  Future<void> logAccountCreate(
    String targetUserId, {
    required String email,
    required String name,
    required String role,
  }) {
    final details = <String, dynamic>{
      'name': name,
      'role': role,
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditAccountCreate,
      message: '${_cap(role)} account $email created',
      detailsJson: jsonEncode(details),
    );
  }

  Future<void> logAccountDeactivate(
    String targetUserId, {
    required String name,
    required String role,
  }) {
    final details = <String, dynamic>{
      'name': name,
      'role': role,
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditAccountDeactivate,
      message: "Account '$name' deactivated",
      detailsJson: jsonEncode(details),
    );
  }

  Future<void> logAccountReactivate(
    String targetUserId, {
    required String name,
    required String role,
  }) {
    final details = <String, dynamic>{
      'name': name,
      'role': role,
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditAccountReactivate,
      message: "Account '$name' reactivated",
      detailsJson: jsonEncode(details),
    );
  }

  Future<void> logAccountEdit(
    String targetUserId, {
    required String name,
    required String role,
  }) {
    final details = <String, dynamic>{
      'name': name,
      'role': role,
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditAccountEdit,
      message: "Account '$name' edited",
      detailsJson: jsonEncode(details),
    );
  }

  // Parent access

  Future<void> logParentLink(
    String parentId,
    String babyId, {
    required String parentEmail,
    required String babyName,
  }) {
    final details = <String, dynamic>{
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditParentLink,
      babyId: babyId,
      message: "Parent $parentEmail linked to '$babyName'",
      detailsJson: jsonEncode(details),
    );
  }

  Future<void> logParentUnlink(
    String parentId,
    String babyId, {
    required String parentName,
    required String babyName,
  }) {
    final details = <String, dynamic>{
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditParentUnlink,
      babyId: babyId,
      message: "Parent '$parentName' unlinked from '$babyName'",
      detailsJson: jsonEncode(details),
    );
  }

  // Device

  Future<void> logDeviceAdd(String deviceId, {required String deviceName}) {
    final details = <String, dynamic>{
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditDeviceAdd,
      deviceId: deviceId,
      message: "Device '$deviceName' connected",
      detailsJson: jsonEncode(details),
    );
  }

  // Transfer

  Future<void> logTransferCreate(
    String babyId, {
    required String babyName,
    required String toHospitalCode,
  }) {
    final details = <String, dynamic>{
      'to_hospital_code': toHospitalCode,
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditTransferCreate,
      babyId: babyId,
      message: "Transfer initiated: '$babyName' → $toHospitalCode",
      detailsJson: jsonEncode(details),
    );
  }

  Future<void> logTransferAccept(
    String babyId, {
    required String babyName,
    required String fromHospitalId,
  }) {
    final details = <String, dynamic>{
      'from_hospital_id': fromHospitalId,
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditTransferAccept,
      babyId: babyId,
      message: "Transfer accepted: '$babyName'",
      detailsJson: jsonEncode(details),
    );
  }

  Future<void> logTransferReject(
    String babyId, {
    required String babyName,
    required String fromHospitalId,
  }) {
    final details = <String, dynamic>{
      'from_hospital_id': fromHospitalId,
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditTransferReject,
      babyId: babyId,
      message: "Transfer rejected: '$babyName'",
      detailsJson: jsonEncode(details),
    );
  }

  Future<void> logTransferCancel(
    String babyId, {
    required String babyName,
    required String toHospitalId,
  }) {
    final details = <String, dynamic>{
      'to_hospital_id': toHospitalId,
      if (actorName != null) 'actor_name': actorName,
    };
    return _insert(
      eventType: kAuditTransferCancel,
      babyId: babyId,
      message: "Transfer cancelled: '$babyName'",
      detailsJson: jsonEncode(details),
    );
  }

  // Private

  Future<void> _insert({
    required String eventType,
    String? babyId,
    String? measurementId,
    String? deviceId,
    String? message,
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
      message: Value(message),
      detailsJson: Value(detailsJson),
    ));
    await _enqueue(id, now, eventType,
        babyId: babyId,
        measurementId: measurementId,
        deviceId: deviceId,
        message: message,
        detailsJson: detailsJson);
  }

  Future<void> _enqueue(
    String id,
    DateTime createdAt,
    String eventType, {
    String? babyId,
    String? measurementId,
    String? deviceId,
    String? message,
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
          if (message != null) 'message': message,
          if (detailsJson != null) 'details_json': detailsJson,
        },
      );
    } catch (_) {
      // Must not block the original operation.
    }
  }

  static String _fmtDob(DateTime dob) {
    final d = dob.day.toString().padLeft(2, '0');
    final mo = dob.month.toString().padLeft(2, '0');
    final h = dob.hour.toString().padLeft(2, '0');
    final mi = dob.minute.toString().padLeft(2, '0');
    return '$d/$mo/${dob.year} $h:$mi';
  }

  static String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
