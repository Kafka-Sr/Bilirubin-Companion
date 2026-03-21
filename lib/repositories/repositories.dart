import 'dart:math';

import 'package:flutter/material.dart';

import '../models/models.dart';

const String alexisBabyId = 'baby_alexis';
const String tanyaBabyId = 'baby_tanya';
const String emilBabyId = 'baby_emil';

abstract class BabyRepository {
  List<Baby> fetchBabies();
  void saveBaby(Baby baby);
}

abstract class MeasurementRepository {
  Map<String, List<Measurement>> fetchAllMeasurements();
  void addMeasurement(Measurement measurement);
}

abstract class SettingsRepository {
  AppSettings loadSettings();
  void saveSettings(AppSettings settings);
}

abstract class DeviceService {
  DeviceInfo currentDevice();
  Future<DeviceInfo> connect();
  Future<DeviceInfo> disconnect();
  Future<Measurement> simulateScan({
    required Baby baby,
    required List<Measurement> existingMeasurements,
  });
}

final _seedData = _SeedData.create();

class InMemoryBabyRepository implements BabyRepository {
  InMemoryBabyRepository.seeded() : _babies = List<Baby>.from(_seedData.babies);

  final List<Baby> _babies;

  @override
  List<Baby> fetchBabies() => List<Baby>.from(_babies);

  @override
  void saveBaby(Baby baby) {
    final index = _babies.indexWhere((item) => item.id == baby.id);
    if (index == -1) {
      _babies.add(baby);
      return;
    }
    _babies[index] = baby;
  }
}

class InMemoryMeasurementRepository implements MeasurementRepository {
  InMemoryMeasurementRepository.seeded()
    : _measurements = _seedData.measurements.map(
        (key, value) => MapEntry(key, List<Measurement>.from(value)),
      );

  final Map<String, List<Measurement>> _measurements;

  @override
  Map<String, List<Measurement>> fetchAllMeasurements() {
    return _measurements.map(
      (key, value) => MapEntry(key, List<Measurement>.from(value)),
    );
  }

  @override
  void addMeasurement(Measurement measurement) {
    final bucket = _measurements.putIfAbsent(
      measurement.babyId,
      () => <Measurement>[],
    );
    bucket.add(measurement);
    bucket.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}

class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository.seeded() : _settings = _seedData.settings;

  AppSettings _settings;

  @override
  AppSettings loadSettings() => _settings;

  @override
  void saveSettings(AppSettings settings) {
    _settings = settings;
  }
}

class MockDeviceService implements DeviceService {
  MockDeviceService.seeded() : _device = _seedData.device;

  DeviceInfo _device;
  final Random _random = Random();

  @override
  DeviceInfo currentDevice() => _device;

  @override
  Future<DeviceInfo> connect() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _device = _device.copyWith(
      isConnected: true,
      isBusy: false,
      id: _device.id ?? 'BG-204',
      transport: _device.transport ?? DeviceTransport.ble,
    );
    return _device;
  }

  @override
  Future<DeviceInfo> disconnect() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _device = _device.copyWith(isConnected: false, isBusy: false);
    return _device;
  }

  @override
  Future<Measurement> simulateScan({
    required Baby baby,
    required List<Measurement> existingMeasurements,
  }) async {
    if (!_device.isConnected) {
      throw StateError('Connect the device before simulating a scan.');
    }

    await Future<void>.delayed(const Duration(milliseconds: 900));

    final ageHours = max(
      3,
      DateTime.now().difference(baby.dateOfBirth).inMinutes / 60,
    ).toDouble();
    final baseline = existingMeasurements.isEmpty
        ? 8.2 + (_random.nextDouble() * 2.6)
        : existingMeasurements.last.bilirubinMgDl +
              (_random.nextDouble() * 2.0) -
              0.2;
    final bilirubin = baseline.clamp(3.2, 22.8).toDouble();
    final imageLabels = <String>[
      'Device capture',
      'Nursery blanket',
      'Warm crib view',
      'Bedside lamp frame',
      'Incubator sample',
    ];

    return Measurement(
      id: 'measurement_${DateTime.now().millisecondsSinceEpoch}',
      babyId: baby.id,
      timestamp: DateTime.now(),
      bilirubinMgDl: double.parse(bilirubin.toStringAsFixed(1)),
      ageHours: double.parse(ageHours.toStringAsFixed(1)),
      imageLabel: imageLabels[_random.nextInt(imageLabels.length)],
    );
  }
}

class _SeedData {
  const _SeedData({
    required this.babies,
    required this.measurements,
    required this.settings,
    required this.device,
  });

  final List<Baby> babies;
  final Map<String, List<Measurement>> measurements;
  final AppSettings settings;
  final DeviceInfo device;

  factory _SeedData.create() {
    final now = DateTime.now();
    final alexisDob = now.subtract(const Duration(days: 3, hours: 10));
    final tanyaDob = now.subtract(const Duration(days: 1, hours: 14));
    final emilDob = now.subtract(const Duration(hours: 19));

    final babies = <Baby>[
      Baby(
        id: alexisBabyId,
        name: 'Alexis Jones',
        weightKg: 3.1,
        dateOfBirth: alexisDob,
      ),
      Baby(
        id: tanyaBabyId,
        name: 'Tanya Myroniuk',
        weightKg: 2.8,
        dateOfBirth: tanyaDob,
      ),
      Baby(
        id: emilBabyId,
        name: 'Emil Hart',
        weightKg: 3.4,
        dateOfBirth: emilDob,
      ),
    ];

    final measurements = <String, List<Measurement>>{
      alexisBabyId: <Measurement>[
        Measurement(
          id: 'm1',
          babyId: alexisBabyId,
          timestamp: alexisDob.add(const Duration(hours: 11)),
          bilirubinMgDl: 5.6,
          ageHours: 11,
          imageLabel: 'Nursery blanket',
        ),
        Measurement(
          id: 'm2',
          babyId: alexisBabyId,
          timestamp: alexisDob.add(const Duration(hours: 38)),
          bilirubinMgDl: 11.9,
          ageHours: 38,
          imageLabel: 'Warm crib view',
        ),
        Measurement(
          id: 'm3',
          babyId: alexisBabyId,
          timestamp: alexisDob.add(const Duration(hours: 74)),
          bilirubinMgDl: 15.0,
          ageHours: 74,
          imageLabel: 'Device capture',
        ),
      ],
      tanyaBabyId: <Measurement>[
        Measurement(
          id: 'm4',
          babyId: tanyaBabyId,
          timestamp: tanyaDob.add(const Duration(hours: 8)),
          bilirubinMgDl: 6.4,
          ageHours: 8,
          imageLabel: 'Bedside lamp frame',
        ),
        Measurement(
          id: 'm5',
          babyId: tanyaBabyId,
          timestamp: tanyaDob.add(const Duration(hours: 26)),
          bilirubinMgDl: 10.8,
          ageHours: 26,
          imageLabel: 'Incubator sample',
        ),
      ],
      emilBabyId: <Measurement>[],
    };

    final settings = AppSettings(
      themeMode: ThemeMode.system,
      language: AppLanguage.english,
      appLockEnabled: false,
      wifiSsid: 'NICU-Station-2',
      wifiPassword: 'secure-demo-pass',
      bluetoothName: 'Biligun Floor A',
      bluetoothAutoReconnect: true,
    );

    const device = DeviceInfo(
      isConnected: true,
      isBusy: false,
      id: 'BG-204',
      transport: DeviceTransport.ble,
    );

    return _SeedData(
      babies: babies,
      measurements: measurements,
      settings: settings,
      device: device,
    );
  }
}
