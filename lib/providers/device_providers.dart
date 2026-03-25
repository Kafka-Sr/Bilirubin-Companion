import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/device/device_repository.dart';
import 'package:bilirubin/device/fake_device_repository.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';
import 'package:bilirubin/providers/baby_providers.dart';
import 'package:bilirubin/providers/measurement_providers.dart';

/// The active [DeviceRepository] implementation (fake in v1).
///
/// Swap [FakeDeviceRepository] for [WifiDeviceRepository] or
/// [BleDeviceRepository] in a future release.
final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  final repo = FakeDeviceRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

/// Live stream of device connection states.
final connectionStateProvider =
    StreamProvider<DeviceConnectionState>((ref) {
  return ref.watch(deviceRepositoryProvider).connectionState;
});

/// Live stream of current device info (null when disconnected).
final deviceInfoProvider = StreamProvider<DeviceInfo?>((ref) {
  return ref.watch(deviceRepositoryProvider).deviceInfo;
});

/// Whether the "Show Previous Bilirubin" toggle is on.
final showHistoryProvider = StateProvider<bool>((ref) => false);

/// Bridge: listens to incoming device measurements and persists them
/// for the currently selected baby.
///
/// This provider must be eagerly activated in [main.dart] via
/// `ref.read(measurementBridgeProvider)` so that measurements are
/// persisted even if the dashboard is not yet built.
final measurementBridgeProvider = Provider<void>((ref) {
  final repo = ref.watch(deviceRepositoryProvider);
  final measurementRepo = ref.watch(measurementRepositoryProvider);

  ref.listen<AsyncValue<DeviceConnectionState>>(
    connectionStateProvider,
    (_, __) {}, // just keep the stream alive
  );

  // Subscribe to incoming measurements from the device.
  final sub = repo.measurements.listen((event) async {
    final baby = ref.read(selectedBabyProvider);
    if (baby == null) return; // no baby selected — discard
    await measurementRepo.handleIncoming(event, baby);
  });

  ref.onDispose(sub.cancel);
});
