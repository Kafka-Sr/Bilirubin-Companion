import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/device/device_repository.dart';
import 'package:bilirubin/device/null_device_repository.dart';
import 'package:bilirubin/device/pi_device_repository.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';
import 'package:bilirubin/providers/pi_discovery_providers.dart';
import 'package:bilirubin/providers/baby_providers.dart';
import 'package:bilirubin/providers/measurement_providers.dart';
import 'package:bilirubin/providers/settings_providers.dart';

/// Derives the single "winning" base URL.
///
/// Manual URL (saved by the user) takes priority over beacon auto-discovery.
/// Beacon is only used as a fallback when no manual URL is stored — matching
/// standard IoT app behaviour (Home Assistant, Hue, etc.).
///
/// Being a [Provider<String>], Riverpod only notifies dependents when the
/// *value* changes. When a manual URL is set, [piBeaconListProvider] is not
/// watched at all — beacon ticks have zero cost and cannot rebuild
/// [deviceRepositoryProvider], eliminating the 10-second disconnect bug.
final activeBaseUrlProvider = Provider<String>((ref) {
  final piBaseUrl = ref.watch(piBaseUrlProvider);
  if (piBaseUrl.isNotEmpty) return piBaseUrl;
  final discoveredBeacons =
      ref.watch(piBeaconListProvider).valueOrNull ?? const [];
  return discoveredBeacons.isNotEmpty ? discoveredBeacons.first.baseUrl : '';
});

/// The active [DeviceRepository] implementation.
///
/// Watches [activeBaseUrlProvider] (a String) rather than the raw beacon
/// StreamProvider. Rebuilds only when the URL *value* changes.
/// Auto-connects via [Future.microtask] whenever a new repo is created.
final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  final baseUrl = ref.watch(activeBaseUrlProvider);

  if (baseUrl.isNotEmpty) {
    final repo = PiDeviceRepository(baseUrl: baseUrl);
    ref.onDispose(repo.dispose);
    Future.microtask(() => repo.connect());
    return repo;
  }

  return NullDeviceRepository();
});

/// Live stream of device connection states.
final connectionStateProvider = StreamProvider<DeviceConnectionState>((ref) {
  return ref.watch(deviceRepositoryProvider).connectionState;
});

/// Live stream of current device info (null when disconnected).
final deviceInfoProvider = StreamProvider<DeviceInfo?>((ref) {
  return ref.watch(deviceRepositoryProvider).deviceInfo;
});

/// Whether the "Show Previous Bilirubin" toggle is on.
final showHistoryProvider = StateProvider<bool>((ref) => false);

/// Whether the "Show Readings Outside 168 h" toggle is on.
final showOutsideRangeProvider = StateProvider<bool>((ref) => false);

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
