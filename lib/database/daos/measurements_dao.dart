import 'package:drift/drift.dart';
import 'package:bilirubin/database/database.dart';
import 'package:bilirubin/database/tables/measurements_table.dart';

part 'measurements_dao.g.dart';

@DriftAccessor(tables: [Measurements])
class MeasurementsDao extends DatabaseAccessor<AppDatabase>
    with _$MeasurementsDaoMixin {
  MeasurementsDao(super.db);

  /// Stream of all measurements for [babyId], newest first.
  Stream<List<Measurement>> watchByBaby(int babyId) =>
      (select(measurements)
            ..where((m) => m.babyId.equals(babyId))
            ..orderBy([(m) => OrderingTerm.desc(m.capturedAt)]))
          .watch();

  /// Returns the most recent measurement for [babyId], or null.
  Future<Measurement?> getLatest(int babyId) =>
      (select(measurements)
            ..where((m) => m.babyId.equals(babyId))
            ..orderBy([(m) => OrderingTerm.desc(m.capturedAt)])
            ..limit(1))
          .getSingleOrNull();

  /// Inserts or updates a measurement row, keyed on [measurementId].
  /// This provides deduplication: if the device re-sends the same measurement,
  /// it will be updated rather than duplicated.
  Future<void> upsertMeasurement(MeasurementsCompanion companion) =>
      into(measurements).insertOnConflictUpdate(companion);

  /// Deletes a single measurement by its [measurementId].
  Future<int> deleteMeasurement(String measurementId) =>
      (delete(measurements)
            ..where((m) => m.measurementId.equals(measurementId)))
          .go();
}
