import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:bilirubin/core/constants.dart';
import 'package:bilirubin/database/database.dart';

/// Append-only audit log repository.
///
/// Call these methods whenever a sensitive action is performed so that
/// operators can reconstruct what happened without logging PHI directly.
class AuditRepository {
  AuditRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  Future<void> logExport(int babyId) => _insert(
        eventType: kAuditExport,
        babyId: babyId,
      );

  Future<void> logBabyEdit(int babyId) => _insert(
        eventType: kAuditBabyEdit,
        babyId: babyId,
      );

  Future<void> logBabyDelete(int babyId) => _insert(
        eventType: kAuditBabyDelete,
        babyId: babyId,
      );

  Future<void> logMeasurementDelete(String measurementId, int babyId) =>
      _insert(
        eventType: kAuditMeasurementDelete,
        babyId: babyId,
        measurementId: measurementId,
      );

  Future<void> _insert({
    required String eventType,
    int? babyId,
    String? measurementId,
    String? deviceId,
    String? detailsJson,
  }) =>
      _db.auditDao.insertEvent(AuditEventsCompanion.insert(
        auditEventId: _uuid.v4(),
        createdAt: Value(DateTime.now()),
        eventType: eventType,
        babyId: Value(babyId),
        measurementId: Value(measurementId),
        deviceId: Value(deviceId),
        detailsJson: Value(detailsJson),
      ));
}
