import 'dart:math';

import 'package:flutter/material.dart';

enum BhutaniZone { low, intermediate, highIntermediate, high, veryHigh }

class Baby {
  const Baby({
    required this.babyId,
    required this.name,
    required this.dateOfBirth,
    required this.weightKg,
  });

  final String babyId;
  final String name;
  final DateTime dateOfBirth;
  final double weightKg;

  Baby copyWith({
    String? babyId,
    String? name,
    DateTime? dateOfBirth,
    double? weightKg,
  }) {
    return Baby(
      babyId: babyId ?? this.babyId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}

class Measurement {
  const Measurement({
    required this.measurementId,
    required this.babyId,
    required this.capturedAt,
    required this.ageHours,
    required this.bilirubinMgDl,
    required this.hasImage,
    this.imageProvider,
  });

  final String measurementId;
  final String babyId;
  final DateTime capturedAt;
  final double ageHours;
  final double bilirubinMgDl;
  final bool hasImage;
  final ImageProvider? imageProvider;
}

class DeviceState {
  const DeviceState({
    required this.connected,
    this.deviceId,
    this.transport,
    this.batteryPercent,
  });

  final bool connected;
  final String? deviceId;
  final String? transport;
  final int? batteryPercent;

  DeviceState copyWith({
    bool? connected,
    String? deviceId,
    String? transport,
    int? batteryPercent,
  }) {
    return DeviceState(
      connected: connected ?? this.connected,
      deviceId: deviceId ?? this.deviceId,
      transport: transport ?? this.transport,
      batteryPercent: batteryPercent ?? this.batteryPercent,
    );
  }
}

class LocalizedStrings {
  const LocalizedStrings({required this.languageCode});

  final String languageCode;

  static const Map<String, Map<String, String>> _dict = {
    'en': {
      'dashboard': 'Dashboard',
      'settings': 'Settings',
      'recommendation': 'Recommendation',
      'notConnected': 'Not connected',
      'connected': 'Connected',
      'simulateScan': 'Simulate Scan',
      'addBaby': 'Add Baby',
      'deleteBaby': 'Delete Baby (simulate)',
      'goSettings': 'Go to Settings',
      'showPrevious': 'Show Previous Bilirubin',
      'noMeasurement': 'No recommendation yet (no measurement)',
      'wifi': 'Wi-Fi configurations',
      'bluetooth': 'Bluetooth configurations',
      'language': 'Language options',
      'theme': 'Theme',
      'appLock': 'App lock',
    },
    'id': {
      'dashboard': 'Dasbor',
      'settings': 'Pengaturan',
      'recommendation': 'Rekomendasi',
      'notConnected': 'Tidak terhubung',
      'connected': 'Terhubung',
      'simulateScan': 'Simulasikan Scan',
      'addBaby': 'Tambah Bayi',
      'deleteBaby': 'Hapus Bayi (simulasi)',
      'goSettings': 'Ke Pengaturan',
      'showPrevious': 'Tampilkan Bilirubin Sebelumnya',
      'noMeasurement': 'Belum ada rekomendasi (belum ada pengukuran)',
      'wifi': 'Konfigurasi Wi-Fi',
      'bluetooth': 'Konfigurasi Bluetooth',
      'language': 'Pilihan Bahasa',
      'theme': 'Tema',
      'appLock': 'Kunci aplikasi',
    },
    'de': {
      'dashboard': 'Dashboard',
      'settings': 'Einstellungen',
      'recommendation': 'Empfehlung',
      'notConnected': 'Nicht verbunden',
      'connected': 'Verbunden',
      'simulateScan': 'Scan simulieren',
      'addBaby': 'Baby hinzufügen',
      'deleteBaby': 'Baby löschen (simuliert)',
      'goSettings': 'Zu Einstellungen',
      'showPrevious': 'Frühere Bilirubinwerte anzeigen',
      'noMeasurement': 'Noch keine Empfehlung (keine Messung)',
      'wifi': 'WLAN-Konfigurationen',
      'bluetooth': 'Bluetooth-Konfigurationen',
      'language': 'Sprachoptionen',
      'theme': 'Thema',
      'appLock': 'App-Sperre',
    },
  };

  String t(String key) => _dict[languageCode]?[key] ?? _dict['en']![key] ?? key;
}

String randomId([String prefix = 'id']) {
  final random = Random();
  return '$prefix-${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(9999)}';
}
