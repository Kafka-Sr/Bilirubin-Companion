import 'package:drift/drift.dart';

/// Drift table for known/paired bilirubin measurement devices.
class Devices extends Table {
  TextColumn get deviceId => text()();
  TextColumn get hospitalId => text()();
  TextColumn get displayName => text()();
  DateTimeColumn get pairedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get ssid => text().nullable()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {deviceId};
}
