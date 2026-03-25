import 'package:drift/drift.dart';

/// Append-only audit log for sensitive actions (export, edit, delete).
class AuditEvents extends Table {
  /// UUID for each audit event.
  TextColumn get auditEventId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Event type constant — see core/constants.dart kAudit* values.
  TextColumn get eventType => text()();

  // Optional foreign-key references (nullable — not all events relate to all entities).
  IntColumn get babyId => integer().nullable()();
  TextColumn get measurementId => text().nullable()();
  TextColumn get deviceId => text().nullable()();

  /// Arbitrary JSON payload for additional context.
  TextColumn get detailsJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {auditEventId};
}
