import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bilirubin/models/app_enums.dart';
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/models/device_info.dart';
import 'package:bilirubin/models/measurement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final babiesRepositoryProvider = Provider<BabiesRepository>((ref) {
  return BabiesRepository.seeded();
});

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

final babiesProvider = NotifierProvider<BabiesNotifier, List<Baby>>(
  BabiesNotifier.new,
);

final selectedBabyIdProvider = StateProvider<String?>((ref) {
  final babies = ref.read(babiesProvider);
  return babies.isNotEmpty ? babies.first.id : null;
});

final selectedBabyProvider = Provider<Baby?>((ref) {
  final selectedId = ref.watch(selectedBabyIdProvider);
  final babies = ref.watch(babiesProvider);
  if (selectedId == null) {
    return babies.isNotEmpty ? babies.first : null;
  }
  return babies.where((baby) => baby.id == selectedId).firstOrNull;
});

final showPreviousBilirubinProvider = StateProvider<bool>((ref) => true);

final deviceControllerProvider =
    NotifierProvider<DeviceController, DeviceState>(DeviceController.new);

class BabiesRepository {
  BabiesRepository(this._babies);

  final List<Baby> _babies;

  factory BabiesRepository.seeded() {
    final now = DateTime.now();
    return BabiesRepository([
      Baby(
        id: 'baby_1',
        name: 'Alexis Jones',
        weightKg: 3.2,
        dateOfBirth: now.subtract(const Duration(days: 3, hours: 12)),
        measurements: [
          Measurement(
            id: 'm1',
            takenAt: now.subtract(const Duration(days: 2, hours: 21)),
            ageHours: 15,
            bilirubinMgDl: 6.8,
            imageLabel: 'Heel-warmup reference',
          ),
          Measurement(
            id: 'm2',
            takenAt: now.subtract(const Duration(days: 2, hours: 5)),
            ageHours: 31,
            bilirubinMgDl: 10.4,
            imageLabel: 'Forehead capture #1',
          ),
          Measurement(
            id: 'm3',
            takenAt: now.subtract(const Duration(hours: 12, minutes: 10)),
            ageHours: 72,
            bilirubinMgDl: 15.0,
            imageLabel: 'Forehead capture #2',
          ),
        ],
      ),
      Baby(
        id: 'baby_2',
        name: 'Tanya Myroniuk',
        weightKg: 2.9,
        dateOfBirth: now.subtract(const Duration(days: 1, hours: 8)),
        measurements: [
          Measurement(
            id: 'm4',
            takenAt: now.subtract(const Duration(hours: 21)),
            ageHours: 11,
            bilirubinMgDl: 4.4,
            imageLabel: 'Cheek capture',
          ),
          Measurement(
            id: 'm5',
            takenAt: now.subtract(const Duration(hours: 7, minutes: 30)),
            ageHours: 24,
            bilirubinMgDl: 8.8,
            imageLabel: 'Cheek capture repeat',
          ),
        ],
      ),
      Baby(
        id: 'baby_3',
        name: 'Mina Ortega',
        weightKg: 3.6,
        dateOfBirth: now.subtract(const Duration(hours: 20)),
        measurements: const [],
      ),
    ]);
  }

  List<Baby> fetchBabies() => List.unmodifiable(_babies);
}

class BabiesNotifier extends Notifier<List<Baby>> {
  @override
  List<Baby> build() {
    return ref.read(babiesRepositoryProvider).fetchBabies();
  }

  void selectBaby(String id) {
    ref.read(selectedBabyIdProvider.notifier).state = id;
  }

  void updateBaby(Baby updatedBaby) {
    state = [
      for (final baby in state)
        if (baby.id == updatedBaby.id) updatedBaby else baby,
    ];
  }

  void addBaby(Baby baby) {
    state = [...state, baby];
    ref.read(selectedBabyIdProvider.notifier).state = baby.id;
  }

  void addMeasurement(String babyId, Measurement measurement) {
    state = [
      for (final baby in state)
        if (baby.id == babyId)
          baby.copyWith(
            measurements: [...baby.measurements, measurement]..sort(
              (a, b) => a.takenAt.compareTo(b.takenAt),
            ),
          )
        else
          baby,
    ];
  }

  String exportCurrentBabyJson(String? babyId) {
    final baby = state.where((item) => item.id == babyId).firstOrNull;
    if (baby == null) {
      return const JsonEncoder.withIndent('  ').convert({'error': 'no_baby'});
    }
    return const JsonEncoder.withIndent('  ').convert(baby.toExportJson());
  }
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return const AppSettings(
      language: AppLanguage.english,
      themeMode: ThemeMode.system,
      appLockEnabled: false,
      wifiConfiguration: 'Ward-A Secure',
      bluetoothConfiguration: 'BiliGun-BLE',
    );
  }

  void setLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setAppLock(bool enabled) {
    state = state.copyWith(appLockEnabled: enabled);
  }

  void setWifiConfiguration(String value) {
    state = state.copyWith(wifiConfiguration: value.trim());
  }

  void setBluetoothConfiguration(String value) {
    state = state.copyWith(bluetoothConfiguration: value.trim());
  }
}

class DeviceController extends Notifier<DeviceState> {
  final Random _random = Random();

  @override
  DeviceState build() {
    return const DeviceState(
      status: DeviceConnectionStatus.connected,
      device: DeviceInfo(id: 'BG-2048', transport: DeviceTransport.wifi),
      busy: false,
    );
  }

  Future<void> toggleConnection() async {
    if (state.busy) {
      return;
    }
    state = state.copyWith(busy: true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (state.status == DeviceConnectionStatus.connected) {
      state = state.copyWith(
        status: DeviceConnectionStatus.disconnected,
        busy: false,
        clearDevice: true,
      );
    } else {
      state = state.copyWith(
        status: DeviceConnectionStatus.connected,
        busy: false,
        device: DeviceInfo(
          id: 'BG-${1000 + _random.nextInt(8999)}',
          transport: _random.nextBool()
              ? DeviceTransport.wifi
              : DeviceTransport.ble,
        ),
      );
    }
  }

  Future<Measurement?> simulateScan(Baby? baby) async {
    if (baby == null || state.status != DeviceConnectionStatus.connected || state.busy) {
      return null;
    }

    state = state.copyWith(busy: true);
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final ageHours = max<int>(
      3,
      DateTime.now().difference(baby.dateOfBirth).inHours,
    );
    final baseline = baby.measurements.isEmpty
        ? 6.5 + _random.nextDouble() * 3.0
        : baby.measurements.last.bilirubinMgDl + (_random.nextDouble() * 2.4 - 0.3);
    final measurement = Measurement(
      id: 'm_${DateTime.now().microsecondsSinceEpoch}',
      takenAt: DateTime.now(),
      ageHours: ageHours,
      bilirubinMgDl: double.parse(baseline.clamp(2.2, 21.8).toStringAsFixed(1)),
      imageLabel: 'Simulated scan ${_random.nextInt(90) + 10}',
    );

    state = state.copyWith(busy: false);
    ref.read(babiesProvider.notifier).addMeasurement(baby.id, measurement);
    return measurement;
  }
}
