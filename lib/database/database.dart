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
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 7) {
            // Nuclear: schema before v7 is incompatible.
            await customStatement('PRAGMA foreign_keys = OFF');
            for (final table in allTables) {
              await m.deleteTable(table.actualTableName);
            }
            await customStatement('PRAGMA foreign_keys = ON');
            await m.createAll();
          } else {
            if (from < 8) {
              await m.addColumn(auditEvents, auditEvents.message);
            }
          }
        },
      );

  static QueryExecutor _openConnection() =>
      driftDatabase(name: 'bilirubin_db');
}
