/// Connection lifecycle states for the bilirubin measurement device.
enum DeviceConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  error;

  bool get isActive =>
      this == DeviceConnectionState.connecting ||
      this == DeviceConnectionState.connected;

  bool get isConnected => this == DeviceConnectionState.connected;
}
