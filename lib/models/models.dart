import 'package:flutter/material.dart';

enum BhutaniRiskZone {
  veryHighRiskZone,
  highRiskZone,
  highIntermediateRiskZone,
  intermediateRiskZone,
  lowRiskZone,
}

extension BhutaniRiskZoneX on BhutaniRiskZone {
  String get label {
    switch (this) {
      case BhutaniRiskZone.veryHighRiskZone:
        return 'Very High Risk Zone';
      case BhutaniRiskZone.highRiskZone:
        return 'High Risk Zone';
      case BhutaniRiskZone.highIntermediateRiskZone:
        return 'High Intermediate Risk Zone';
      case BhutaniRiskZone.intermediateRiskZone:
        return 'Intermediate Risk Zone';
      case BhutaniRiskZone.lowRiskZone:
        return 'Low Risk Zone';
    }
  }

  String get uppercaseLabel => label.toUpperCase();

  String get recommendationBody {
    switch (this) {
      case BhutaniRiskZone.veryHighRiskZone:
        return 'Escalate urgently, confirm the measurement, and prepare immediate clinician review for intensive management or phototherapy planning.';
      case BhutaniRiskZone.highRiskZone:
        return 'Arrange prompt reassessment, repeat bilirubin review soon, and consider treatment readiness based on the broader clinical picture.';
      case BhutaniRiskZone.highIntermediateRiskZone:
        return 'Increase follow-up cadence, verify hydration and feeding, and repeat bilirubin assessment within a clinically appropriate short interval.';
      case BhutaniRiskZone.intermediateRiskZone:
        return 'Continue close observation with routine follow-up, reinforce feeding support, and repeat bilirubin checks if symptoms or trend worsen.';
      case BhutaniRiskZone.lowRiskZone:
        return 'Levels are currently reassuring; continue routine observation, support feeding, and maintain planned bilirubin surveillance.';
    }
  }
}

enum DeviceTransport { wifi, ble }

extension DeviceTransportX on DeviceTransport {
  String get label {
    switch (this) {
      case DeviceTransport.wifi:
        return 'Wi-Fi';
      case DeviceTransport.ble:
        return 'BLE';
    }
  }
}

enum AppLanguage { indonesian, english, german }

extension AppLanguageX on AppLanguage {
  String get label {
    switch (this) {
      case AppLanguage.indonesian:
        return 'Indonesian';
      case AppLanguage.english:
        return 'English';
      case AppLanguage.german:
        return 'German';
    }
  }
}

extension ThemeModeX on ThemeMode {
  String get label {
    switch (this) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}

@immutable
class Baby {
  const Baby({
    required this.id,
    required this.name,
    required this.weightKg,
    required this.dateOfBirth,
  });

  final String id;
  final String name;
  final double weightKg;
  final DateTime dateOfBirth;

  Baby copyWith({
    String? id,
    String? name,
    double? weightKg,
    DateTime? dateOfBirth,
  }) {
    return Baby(
      id: id ?? this.id,
      name: name ?? this.name,
      weightKg: weightKg ?? this.weightKg,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}

@immutable
class Measurement {
  const Measurement({
    required this.id,
    required this.babyId,
    required this.timestamp,
    required this.bilirubinMgDl,
    required this.ageHours,
    this.imageLabel,
  });

  final String id;
  final String babyId;
  final DateTime timestamp;
  final double bilirubinMgDl;
  final double ageHours;
  final String? imageLabel;

  bool get hasImage => imageLabel != null && imageLabel!.isNotEmpty;
}

@immutable
class DeviceInfo {
  const DeviceInfo({
    required this.isConnected,
    required this.isBusy,
    this.id,
    this.transport,
  });

  final bool isConnected;
  final bool isBusy;
  final String? id;
  final DeviceTransport? transport;

  DeviceInfo copyWith({
    bool? isConnected,
    bool? isBusy,
    String? id,
    DeviceTransport? transport,
  }) {
    return DeviceInfo(
      isConnected: isConnected ?? this.isConnected,
      isBusy: isBusy ?? this.isBusy,
      id: id ?? this.id,
      transport: transport ?? this.transport,
    );
  }
}

@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.language,
    required this.appLockEnabled,
    required this.wifiSsid,
    required this.wifiPassword,
    required this.bluetoothName,
    required this.bluetoothAutoReconnect,
  });

  final ThemeMode themeMode;
  final AppLanguage language;
  final bool appLockEnabled;
  final String wifiSsid;
  final String wifiPassword;
  final String bluetoothName;
  final bool bluetoothAutoReconnect;

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
    bool? appLockEnabled,
    String? wifiSsid,
    String? wifiPassword,
    String? bluetoothName,
    bool? bluetoothAutoReconnect,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      bluetoothName: bluetoothName ?? this.bluetoothName,
      bluetoothAutoReconnect:
          bluetoothAutoReconnect ?? this.bluetoothAutoReconnect,
    );
  }
}

@immutable
class UiToggles {
  const UiToggles({required this.showPreviousBilirubin});

  final bool showPreviousBilirubin;

  UiToggles copyWith({bool? showPreviousBilirubin}) {
    return UiToggles(
      showPreviousBilirubin:
          showPreviousBilirubin ?? this.showPreviousBilirubin,
    );
  }
}
