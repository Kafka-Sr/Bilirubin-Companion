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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from == 1) {
            await m.alterTable(TableMigration(
              babies,
              columnTransformer: <GeneratedColumn<Object>, Expression<Object>>{
                babies.babyId as GeneratedColumn<Object>:
                    const CustomExpression<Object>('id'),
                babies.babyName as GeneratedColumn<Object>:
                    const CustomExpression<Object>('name'),
                babies.babyDob as GeneratedColumn<Object>:
                    const CustomExpression<Object>('date_of_birth'),
                babies.babyWeight as GeneratedColumn<Object>:
                    const CustomExpression<Object>('weight_kg'),
              },
            ));
            await m.alterTable(TableMigration(
              measurements,
              columnTransformer: <GeneratedColumn<Object>, Expression<Object>>{
                measurements.bilirubinMgdl as GeneratedColumn<Object>:
                    const CustomExpression<Object>('bilirubin_mg_dl'),
              },
            ));
          }
        },
      );

  static QueryExecutor _openConnection() =>
      driftDatabase(name: 'bilirubin_db');
}
