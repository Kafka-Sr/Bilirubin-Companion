import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:bilirubin/database/tables/babies_table.dart';
import 'package:bilirubin/database/tables/measurements_table.dart';
import 'package:bilirubin/database/tables/devices_table.dart';
import 'package:bilirubin/database/tables/audit_events_table.dart';
import 'package:bilirubin/database/daos/babies_dao.dart';
import 'package:bilirubin/database/daos/measurements_dao.dart';
import 'package:bilirubin/database/daos/devices_dao.dart';
import 'package:bilirubin/database/daos/audit_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Babies, Measurements, Devices, AuditEvents],
  daos: [BabiesDao, MeasurementsDao, DevicesDao, AuditDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );

  static QueryExecutor _openConnection() =>
      driftDatabase(name: 'bilirubin_db');
}
