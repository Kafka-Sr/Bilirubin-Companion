import 'package:bilirubin/device/device_repository.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';

/// Stub BLE device repository — to be implemented in v2.
///
/// Will use `flutter_blue_plus` for scanning, pairing, and receiving
/// measurement notifications from the bilirubin device's GATT service.
class BleDeviceRepository implements DeviceRepository {
  @override
  Stream<DeviceConnectionState> get connectionState =>
      throw UnimplementedError('BLE transport not yet implemented.');

  @override
  Stream<DeviceInfo?> get deviceInfo =>
      throw UnimplementedError('BLE transport not yet implemented.');

  @override
  Stream<IncomingMeasurement> get measurements =>
      throw UnimplementedError('BLE transport not yet implemented.');

  @override
  Future<void> connect() =>
      throw UnimplementedError('BLE transport not yet implemented.');

  @override
  Future<void> disconnect() =>
      throw UnimplementedError('BLE transport not yet implemented.');

  @override
  void dispose() {}
}
