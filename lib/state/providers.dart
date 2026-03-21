import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/helpers.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

final babyRepositoryProvider = Provider<BabyRepository>(
  (ref) => InMemoryBabyRepository.seeded(),
);

final measurementRepositoryProvider = Provider<MeasurementRepository>(
  (ref) => InMemoryMeasurementRepository.seeded(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => InMemorySettingsRepository.seeded(),
);

final deviceServiceProvider = Provider<DeviceService>(
  (ref) => MockDeviceService.seeded(),
);

class BabiesController extends StateNotifier<List<Baby>> {
  BabiesController(this._repository) : super(_repository.fetchBabies());

  final BabyRepository _repository;

  void upsert(Baby baby) {
    _repository.saveBaby(baby);
    final updated = List<Baby>.from(state);
    final index = updated.indexWhere((item) => item.id == baby.id);
    if (index == -1) {
      updated.add(baby);
    } else {
      updated[index] = baby;
    }
    state = updated;
  }
}

class MeasurementsController
    extends StateNotifier<Map<String, List<Measurement>>> {
  MeasurementsController(this._repository)
    : super(_repository.fetchAllMeasurements());

  final MeasurementRepository _repository;

  void addMeasurement(Measurement measurement) {
    _repository.addMeasurement(measurement);
    final current = state[measurement.babyId] ?? const <Measurement>[];
    final updatedList = List<Measurement>.from(current)..add(measurement);
    updatedList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    state = <String, List<Measurement>>{
      ...state,
      measurement.babyId: updatedList,
    };
  }
}

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._repository) : super(_repository.loadSettings());

  final SettingsRepository _repository;

  void _save(AppSettings next) {
    state = next;
    _repository.saveSettings(next);
  }

  void setThemeMode(ThemeMode mode) => _save(state.copyWith(themeMode: mode));

  void setLanguage(AppLanguage language) =>
      _save(state.copyWith(language: language));

  void setAppLock(bool enabled) =>
      _save(state.copyWith(appLockEnabled: enabled));

  void setWifiSsid(String value) => _save(state.copyWith(wifiSsid: value));

  void setWifiPassword(String value) =>
      _save(state.copyWith(wifiPassword: value));

  void setBluetoothName(String value) =>
      _save(state.copyWith(bluetoothName: value));

  void setBluetoothAutoReconnect(bool value) =>
      _save(state.copyWith(bluetoothAutoReconnect: value));
}

class UiTogglesController extends StateNotifier<UiToggles> {
  UiTogglesController() : super(const UiToggles(showPreviousBilirubin: true));

  void setShowPreviousBilirubin(bool value) {
    state = state.copyWith(showPreviousBilirubin: value);
  }
}

class DeviceController extends StateNotifier<DeviceInfo> {
  DeviceController(DeviceService service) : super(service.currentDevice());

  void setBusy(bool isBusy) {
    state = state.copyWith(isBusy: isBusy);
  }

  void setDevice(DeviceInfo device) {
    state = device;
  }
}

final babiesControllerProvider =
    StateNotifierProvider<BabiesController, List<Baby>>(
      (ref) => BabiesController(ref.watch(babyRepositoryProvider)),
    );

final measurementsControllerProvider =
    StateNotifierProvider<
      MeasurementsController,
      Map<String, List<Measurement>>
    >(
      (ref) => MeasurementsController(ref.watch(measurementRepositoryProvider)),
    );

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>(
      (ref) => SettingsController(ref.watch(settingsRepositoryProvider)),
    );

final uiTogglesControllerProvider =
    StateNotifierProvider<UiTogglesController, UiToggles>(
      (ref) => UiTogglesController(),
    );

final deviceControllerProvider =
    StateNotifierProvider<DeviceController, DeviceInfo>(
      (ref) => DeviceController(ref.watch(deviceServiceProvider)),
    );

final selectedBabyIdProvider = StateProvider<String?>((ref) {
  final babies = ref.watch(babiesControllerProvider);
  if (babies.isEmpty) {
    return null;
  }
  return babies.first.id;
});

final selectedBabyProvider = Provider<Baby?>((ref) {
  final babies = ref.watch(babiesControllerProvider);
  final selectedId = ref.watch(selectedBabyIdProvider);
  if (babies.isEmpty) {
    return null;
  }
  return babies.firstWhereOrNull((baby) => baby.id == selectedId) ??
      babies.first;
});

final currentMeasurementsProvider = Provider<List<Measurement>>((ref) {
  final selectedBaby = ref.watch(selectedBabyProvider);
  final allMeasurements = ref.watch(measurementsControllerProvider);
  if (selectedBaby == null) {
    return const <Measurement>[];
  }
  final measurements = List<Measurement>.from(
    allMeasurements[selectedBaby.id] ?? const <Measurement>[],
  );
  measurements.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return measurements;
});

final latestMeasurementProvider = Provider<Measurement?>((ref) {
  final measurements = ref.watch(currentMeasurementsProvider);
  if (measurements.isEmpty) {
    return null;
  }
  return measurements.last;
});

final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(settingsControllerProvider).themeMode,
);

final languageProvider = Provider<AppLanguage>(
  (ref) => ref.watch(settingsControllerProvider).language,
);

final showPreviousBilirubinProvider = Provider<bool>(
  (ref) => ref.watch(uiTogglesControllerProvider).showPreviousBilirubin,
);

class AppActions {
  const AppActions(this.ref);

  final Ref ref;

  void selectBaby(String babyId) {
    ref.read(selectedBabyIdProvider.notifier).state = babyId;
  }

  void upsertBaby(Baby baby) {
    ref.read(babiesControllerProvider.notifier).upsert(baby);
    ref.read(selectedBabyIdProvider.notifier).state = baby.id;
  }

  Future<DeviceInfo> toggleDeviceConnection() async {
    final controller = ref.read(deviceControllerProvider.notifier);
    final current = ref.read(deviceControllerProvider);
    controller.setBusy(true);

    try {
      final service = ref.read(deviceServiceProvider);
      final next = current.isConnected
          ? await service.disconnect()
          : await service.connect();
      controller.setDevice(next);
      return next;
    } finally {
      controller.setBusy(false);
    }
  }

  Future<Measurement> simulateScan() async {
    final baby = ref.read(selectedBabyProvider);
    if (baby == null) {
      throw StateError('Add a baby before simulating a scan.');
    }

    final device = ref.read(deviceControllerProvider);
    if (!device.isConnected) {
      throw StateError('Connect the device before simulating a scan.');
    }

    final controller = ref.read(deviceControllerProvider.notifier);
    controller.setBusy(true);
    try {
      final measurement = await ref
          .read(deviceServiceProvider)
          .simulateScan(
            baby: baby,
            existingMeasurements: ref.read(currentMeasurementsProvider),
          );
      ref
          .read(measurementsControllerProvider.notifier)
          .addMeasurement(measurement);
      return measurement;
    } finally {
      controller.setBusy(false);
    }
  }

  Future<String> buildExportJson() async {
    final baby = ref.read(selectedBabyProvider);
    if (baby == null) {
      throw StateError('No baby selected for export.');
    }

    final measurements = ref.read(currentMeasurementsProvider);
    final payload = <String, Object?>{
      'exported_at': DateTime.now().toIso8601String(),
      'baby': <String, Object?>{
        'id': baby.id,
        'name': baby.name,
        'weight_kg': baby.weightKg,
        'date_of_birth': baby.dateOfBirth.toIso8601String(),
      },
      'measurements': measurements
          .map(
            (measurement) => <String, Object?>{
              'id': measurement.id,
              'timestamp': measurement.timestamp.toIso8601String(),
              'bilirubin_mg_dl': measurement.bilirubinMgDl,
              'age_hours': measurement.ageHours,
              'has_image': measurement.hasImage,
            },
          )
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}

final appActionsProvider = Provider<AppActions>((ref) => AppActions(ref));
