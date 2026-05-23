class PiBeacon {
  const PiBeacon({
    required this.deviceId,
    required this.displayName,
    required this.host,
    required this.port,
    required this.lastSeenAt,
    this.firmwareVersion,
  });

  final String deviceId;
  final String displayName;
  final String host;
  final int port;
  final DateTime lastSeenAt;
  final String? firmwareVersion;

  String get baseUrl => 'http://$host:$port';

  PiBeacon copyWith({
    String? deviceId,
    String? displayName,
    String? host,
    int? port,
    DateTime? lastSeenAt,
    String? firmwareVersion,
  }) {
    return PiBeacon(
      deviceId: deviceId ?? this.deviceId,
      displayName: displayName ?? this.displayName,
      host: host ?? this.host,
      port: port ?? this.port,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    );
  }
}