import 'package:bilirubin/models/device_connection_state.dart';

/// Transport protocol used to communicate with the device.
enum DeviceTransport { wifi, ble, fake }

/// Runtime information about the paired/connected device.
class DeviceInfo {
  const DeviceInfo({
    required this.deviceId,
    required this.displayName,
    required this.transport,
    required this.connectionState,
    this.lastSeen,
    this.firmwareVersion,
  });

  final String deviceId;
  final String displayName;
  final DeviceTransport transport;
  final DeviceConnectionState connectionState;
  final DateTime? lastSeen;
  final String? firmwareVersion;

  bool get isConnected => connectionState == DeviceConnectionState.connected;

  DeviceInfo copyWith({
    String? deviceId,
    String? displayName,
    DeviceTransport? transport,
    DeviceConnectionState? connectionState,
    DateTime? lastSeen,
    String? firmwareVersion,
  }) {
    return DeviceInfo(
      deviceId: deviceId ?? this.deviceId,
      displayName: displayName ?? this.displayName,
      transport: transport ?? this.transport,
      connectionState: connectionState ?? this.connectionState,
      lastSeen: lastSeen ?? this.lastSeen,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    );
  }

  @override
  String toString() =>
      'DeviceInfo(id: $deviceId, state: $connectionState, transport: $transport)';
}
