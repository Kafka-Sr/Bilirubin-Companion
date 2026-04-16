import 'package:bilirubin/device/device_repository.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';

/// Stub Wi-Fi device repository — to be implemented in v2.
///
/// Will use the `wifi_iot` package (or equivalent) to connect to the device's
/// access point and communicate over a local TCP/UDP socket.
class WifiDeviceRepository implements DeviceRepository {
  @override
  Stream<DeviceConnectionState> get connectionState =>
      throw UnimplementedError('Wi-Fi transport not yet implemented.');

  @override
  Stream<DeviceInfo?> get deviceInfo =>
      throw UnimplementedError('Wi-Fi transport not yet implemented.');

  @override
  Stream<IncomingMeasurement> get measurements =>
      throw UnimplementedError('Wi-Fi transport not yet implemented.');

  @override
  Future<void> connect() =>
      throw UnimplementedError('Wi-Fi transport not yet implemented.');

  @override
  Future<void> disconnect() =>
      throw UnimplementedError('Wi-Fi transport not yet implemented.');

  @override
  void dispose() {}
}
