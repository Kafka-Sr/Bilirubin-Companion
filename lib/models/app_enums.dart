import 'package:flutter/material.dart';

enum AppLanguage {
  indonesian('Indonesian'),
  english('English'),
  german('German');

  const AppLanguage(this.label);
  final String label;
}

enum DeviceTransport {
  wifi('Wi-Fi'),
  ble('BLE');

  const DeviceTransport(this.label);
  final String label;
}

enum DeviceConnectionStatus { connected, disconnected }

enum BhutaniZone {
  veryHighRiskZone('Very High Risk Zone'),
  highRiskZone('High Risk Zone'),
  highIntermediateRiskZone('High Intermediate Risk Zone'),
  intermediateRiskZone('Intermediate Risk Zone'),
  lowRiskZone('Low Risk Zone');

  const BhutaniZone(this.label);
  final String label;

  String get upper => label.toUpperCase();
}

class AppSettings {
  const AppSettings({
    required this.language,
    required this.themeMode,
    required this.appLockEnabled,
    required this.wifiConfiguration,
    required this.bluetoothConfiguration,
  });

  final AppLanguage language;
  final ThemeMode themeMode;
  final bool appLockEnabled;
  final String wifiConfiguration;
  final String bluetoothConfiguration;

  AppSettings copyWith({
    AppLanguage? language,
    ThemeMode? themeMode,
    bool? appLockEnabled,
    String? wifiConfiguration,
    String? bluetoothConfiguration,
  }) {
    return AppSettings(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      wifiConfiguration: wifiConfiguration ?? this.wifiConfiguration,
      bluetoothConfiguration: bluetoothConfiguration ?? this.bluetoothConfiguration,
    );
  }
}
