import 'dart:async';

import 'package:bilirubin/device/device_repository.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';

/// A no-op [DeviceRepository] used when no device is configured.
///
/// Emits [DeviceConnectionState.disconnected] permanently and never
/// produces measurements. Replaces the old simulator fallback.
class NullDeviceRepository implements DeviceRepository {
  @override
  Stream<DeviceConnectionState> get connectionState =>
      Stream.value(DeviceConnectionState.disconnected);

  @override
  Stream<DeviceInfo?> get deviceInfo => Stream.value(null);

  @override
  Stream<IncomingMeasurement> get measurements => const Stream.empty();

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  void dispose() {}
}
