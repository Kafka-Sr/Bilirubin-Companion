import 'package:drift/drift.dart';

/// Drift table for known/paired bilirubin measurement devices.
class Devices extends Table {
  TextColumn get deviceId => text()();
  TextColumn get displayName => text()();

  /// Transport protocol: 'wifi' | 'ble' | 'fake'
  TextColumn get transport => text()();

  BoolColumn get isPaired =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get pairedAt => dateTime().nullable()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  TextColumn get firmwareVersion => text().nullable()();

  /// Base64-encoded device public key for future challenge-response auth.
  TextColumn get publicKey => text().nullable()();

  @override
  Set<Column> get primaryKey => {deviceId};
}
