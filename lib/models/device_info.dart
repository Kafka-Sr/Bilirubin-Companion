import 'package:bilirubin/models/device_connection_state.dart';

/// Runtime information about the paired/connected device.
class DeviceInfo {
  const DeviceInfo({
    required this.deviceId,
    required this.displayName,
    required this.connectionState,
    this.lastSeen,
    this.firmwareVersion,
  });

  final String deviceId;
  final String displayName;
  final DeviceConnectionState connectionState;
  final DateTime? lastSeen;
  final String? firmwareVersion;

  bool get isConnected => connectionState == DeviceConnectionState.connected;

  DeviceInfo copyWith({
    String? deviceId,
    String? displayName,
    DeviceConnectionState? connectionState,
    DateTime? lastSeen,
    String? firmwareVersion,
  }) {
    return DeviceInfo(
      deviceId: deviceId ?? this.deviceId,
      displayName: displayName ?? this.displayName,
      connectionState: connectionState ?? this.connectionState,
      lastSeen: lastSeen ?? this.lastSeen,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    );
  }

  @override
  String toString() =>
      'DeviceInfo(id: $deviceId, state: $connectionState)';
}
