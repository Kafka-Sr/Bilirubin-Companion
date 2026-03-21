import 'package:bilirubin/models/app_enums.dart';

class DeviceInfo {
  const DeviceInfo({required this.id, required this.transport});

  final String id;
  final DeviceTransport transport;
}

class DeviceState {
  const DeviceState({
    required this.status,
    required this.device,
    required this.busy,
  });

  final DeviceConnectionStatus status;
  final DeviceInfo? device;
  final bool busy;

  bool get isConnected => status == DeviceConnectionStatus.connected;

  DeviceState copyWith({
    DeviceConnectionStatus? status,
    DeviceInfo? device,
    bool? busy,
    bool clearDevice = false,
  }) {
    return DeviceState(
      status: status ?? this.status,
      device: clearDevice ? null : (device ?? this.device),
      busy: busy ?? this.busy,
    );
  }
}
