import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';

class AppState {
  const AppState({
    required this.babies,
    required this.measurements,
    required this.selectedBabyId,
    required this.deviceState,
    required this.showPrevious,
    required this.localeCode,
    required this.themeMode,
    required this.appLockEnabled,
  });

  final List<Baby> babies;
  final List<Measurement> measurements;
  final String? selectedBabyId;
  final DeviceState deviceState;
  final bool showPrevious;
  final String localeCode;
  final ThemeMode themeMode;
  final bool appLockEnabled;

  AppState copyWith({
    List<Baby>? babies,
    List<Measurement>? measurements,
    String? selectedBabyId,
    DeviceState? deviceState,
    bool? showPrevious,
    String? localeCode,
    ThemeMode? themeMode,
    bool? appLockEnabled,
  }) {
    return AppState(
      babies: babies ?? this.babies,
      measurements: measurements ?? this.measurements,
      selectedBabyId: selectedBabyId ?? this.selectedBabyId,
      deviceState: deviceState ?? this.deviceState,
      showPrevious: showPrevious ?? this.showPrevious,
      localeCode: localeCode ?? this.localeCode,
      themeMode: themeMode ?? this.themeMode,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    );
  }

  Baby? get selectedBaby {
    if (selectedBabyId == null) return null;
    for (final baby in babies) {
      if (baby.babyId == selectedBabyId) return baby;
    }
    return null;
  }

  List<Measurement> measurementsForSelected() {
    if (selectedBabyId == null) return const [];
    final rows = measurements.where((m) => m.babyId == selectedBabyId).toList()
      ..sort((a, b) => a.ageHours.compareTo(b.ageHours));
    return rows;
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier()
      : super(
          AppState(
            babies: [
              Baby(
                babyId: 'baby-001',
                name: 'Alya',
                dateOfBirth: DateTime.now().subtract(const Duration(hours: 42)),
                weightKg: 3.2,
              ),
              Baby(
                babyId: 'baby-002',
                name: 'Bima',
                dateOfBirth: DateTime.now().subtract(const Duration(hours: 18)),
                weightKg: 2.9,
              ),
            ],
            measurements: [
              Measurement(
                measurementId: 'm-001',
                babyId: 'baby-001',
                capturedAt: DateTime.now().subtract(const Duration(hours: 26)),
                ageHours: 16,
                bilirubinMgDl: 5.8,
                hasImage: true,
              ),
              Measurement(
                measurementId: 'm-002',
                babyId: 'baby-001',
                capturedAt: DateTime.now().subtract(const Duration(hours: 14)),
                ageHours: 28,
                bilirubinMgDl: 9.7,
                hasImage: true,
              ),
              Measurement(
                measurementId: 'm-003',
                babyId: 'baby-001',
                capturedAt: DateTime.now().subtract(const Duration(hours: 1)),
                ageHours: 41,
                bilirubinMgDl: 12.9,
                hasImage: true,
              ),
            ],
            selectedBabyId: 'baby-001',
            deviceState: const DeviceState(
              connected: true,
              deviceId: 'BC-POC-01',
              transport: 'Wi-Fi',
              batteryPercent: 74,
            ),
            showPrevious: true,
            localeCode: 'en',
            themeMode: ThemeMode.system,
            appLockEnabled: false,
          ),
        );

  void selectBaby(String babyId) => state = state.copyWith(selectedBabyId: babyId);

  void toggleDevice() {
    if (!state.deviceState.connected) {
      final transport = state.deviceState.transport == 'Wi-Fi' ? 'BLE' : 'Wi-Fi';
      state = state.copyWith(
        deviceState: state.deviceState.copyWith(
          connected: true,
          deviceId: state.deviceState.deviceId ?? 'BC-POC-02',
          transport: transport,
          batteryPercent: min(100, (state.deviceState.batteryPercent ?? 64) + 4),
        ),
      );
      return;
    }

    state = state.copyWith(
      deviceState: state.deviceState.copyWith(
        connected: false,
        deviceId: null,
        transport: null,
      ),
    );
  }

  void toggleShowPrevious(bool value) => state = state.copyWith(showPrevious: value);

  void setLocale(String code) => state = state.copyWith(localeCode: code);

  void setThemeMode(ThemeMode mode) => state = state.copyWith(themeMode: mode);

  void setAppLock(bool value) => state = state.copyWith(appLockEnabled: value);

  void simulateScan() {
    final baby = state.selectedBaby;
    if (baby == null) return;
    final existing = state.measurementsForSelected();
    final latestAge = existing.isEmpty ? 3.0 : existing.last.ageHours;
    final random = Random();
    final increment = 4 + random.nextInt(9);
    final nextAge = (latestAge + increment).clamp(3, 120).toDouble();
    final nextLevel = (existing.isEmpty
            ? 5.0 + random.nextDouble() * 2
            : existing.last.bilirubinMgDl + (random.nextDouble() * 2.4 - 0.6))
        .clamp(1.0, 24.0);
    final item = Measurement(
      measurementId: randomId('m'),
      babyId: baby.babyId,
      capturedAt: DateTime.now(),
      ageHours: nextAge,
      bilirubinMgDl: double.parse(nextLevel.toStringAsFixed(1)),
      hasImage: true,
    );
    state = state.copyWith(measurements: [...state.measurements, item]);
  }

  void addBaby() {
    final id = randomId('baby');
    final newBaby = Baby(
      babyId: id,
      name: 'New Baby ${state.babies.length + 1}',
      dateOfBirth: DateTime.now().subtract(const Duration(hours: 8)),
      weightKg: 3.0,
    );
    state = state.copyWith(babies: [...state.babies, newBaby], selectedBabyId: id);
  }

  void deleteSelectedBaby() {
    final selected = state.selectedBabyId;
    if (selected == null) return;
    final babies = state.babies.where((b) => b.babyId != selected).toList();
    final measurements = state.measurements.where((m) => m.babyId != selected).toList();
    state = state.copyWith(
      babies: babies,
      measurements: measurements,
      selectedBabyId: babies.isEmpty ? null : babies.first.babyId,
    );
  }

  void updateBaby(Baby updated) {
    final babies = [
      for (final baby in state.babies)
        if (baby.babyId == updated.babyId) updated else baby,
    ];
    state = state.copyWith(babies: babies);
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);
