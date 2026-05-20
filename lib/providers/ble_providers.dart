import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bilirubin/device/ble_scanner.dart';
import 'package:bilirubin/providers/settings_providers.dart';

const _kBleDeviceIdKey = 'ble_device_id';

/// Notifier that persists the paired BLE device ID in SharedPreferences.
class PairedBleDeviceNotifier extends StateNotifier<String?> {
  PairedBleDeviceNotifier(this._prefs)
      : super(_prefs.getString(_kBleDeviceIdKey));

  final SharedPreferences _prefs;

  Future<void> pair(String deviceId) async {
    await _prefs.setString(_kBleDeviceIdKey, deviceId);
    state = deviceId;
  }

  Future<void> unpair() async {
    await _prefs.remove(_kBleDeviceIdKey);
    state = null;
  }
}

/// The persisted BLE device ID (MAC / UUID string), or null if none is paired.
final pairedBleDeviceIdProvider =
    StateNotifierProvider<PairedBleDeviceNotifier, String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PairedBleDeviceNotifier(prefs);
});

/// Live BLE scan results (updated every scan cycle).
final bleScanResultsProvider = StreamProvider<List<ScanResult>>((ref) {
  return scanForBleDevices();
});

/// Whether a BLE scan is currently in progress.
final bleScanningProvider = StreamProvider<bool>((ref) {
  return FlutterBluePlus.isScanning;
});

/// The live [BluetoothDevice] handle after the user taps "Pair".
/// Null if no device is connected via BLE.
final activeBleDeviceProvider = StateProvider<BluetoothDevice?>((ref) => null);
