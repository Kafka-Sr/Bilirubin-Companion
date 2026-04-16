// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_dao.dart';

// ignore_for_file: type=lint
mixin _$AuditDaoMixin on DatabaseAccessor<AppDatabase> {
  $AuditEventsTable get auditEvents => attachedDatabase.auditEvents;
  AuditDaoManager get managers => AuditDaoManager(this);
}

class AuditDaoManager {
  final _$AuditDaoMixin _db;
  AuditDaoManager(this._db);
  $$AuditEventsTableTableManager get auditEvents =>
      $$AuditEventsTableTableManager(_db.attachedDatabase, _db.auditEvents);
}
