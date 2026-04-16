// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurements_dao.dart';

// ignore_for_file: type=lint
mixin _$MeasurementsDaoMixin on DatabaseAccessor<AppDatabase> {
  $BabiesTable get babies => attachedDatabase.babies;
  $MeasurementsTable get measurements => attachedDatabase.measurements;
  MeasurementsDaoManager get managers => MeasurementsDaoManager(this);
}

class MeasurementsDaoManager {
  final _$MeasurementsDaoMixin _db;
  MeasurementsDaoManager(this._db);
  $$BabiesTableTableManager get babies =>
      $$BabiesTableTableManager(_db.attachedDatabase, _db.babies);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db.attachedDatabase, _db.measurements);
}
