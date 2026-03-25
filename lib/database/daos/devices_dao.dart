import 'package:drift/drift.dart';
import 'package:bilirubin/database/database.dart';
import 'package:bilirubin/database/tables/devices_table.dart';

part 'devices_dao.g.dart';

@DriftAccessor(tables: [Devices])
class DevicesDao extends DatabaseAccessor<AppDatabase>
    with _$DevicesDaoMixin {
  DevicesDao(super.db);

  Stream<List<Device>> watchAll() => select(devices).watch();

  Future<Device?> getById(String deviceId) =>
      (select(devices)..where((d) => d.deviceId.equals(deviceId)))
          .getSingleOrNull();

  Future<void> upsertDevice(DevicesCompanion companion) =>
      into(devices).insertOnConflictUpdate(companion);

  Future<void> updateLastSeen(String deviceId, DateTime ts) =>
      (update(devices)..where((d) => d.deviceId.equals(deviceId)))
          .write(DevicesCompanion(lastSeenAt: Value(ts)));
}
