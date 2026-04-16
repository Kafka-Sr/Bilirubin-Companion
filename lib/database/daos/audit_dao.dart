import 'package:drift/drift.dart';
import 'package:bilirubin/database/database.dart';
import 'package:bilirubin/database/tables/audit_events_table.dart';

part 'audit_dao.g.dart';

@DriftAccessor(tables: [AuditEvents])
class AuditDao extends DatabaseAccessor<AppDatabase> with _$AuditDaoMixin {
  AuditDao(super.db);

  /// Appends a new audit event. Audit log is append-only from app code.
  Future<void> insertEvent(AuditEventsCompanion companion) =>
      into(auditEvents).insert(companion);
}
