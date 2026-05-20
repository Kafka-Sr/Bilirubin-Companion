import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:bilirubin/device/device_repository.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';

// TODO(hardware-team): Replace with real GATT service UUID once firmware finalises.
const kBleServiceUuid = '00000000-0000-0000-0000-000000000000';

// TODO(hardware-team): Replace with real measurement characteristic UUID.
const kBleMeasurementCharacteristicUuid =
    '00000000-0000-0000-0000-000000000001';

// TODO(hardware-team): Confirm the BLE device name prefix matches firmware.
const kBleDeviceNamePrefix = 'Biligun';

/// BLE client for the bilirubin measurement device.
///
/// GATT UUIDs are placeholder values — the hardware team must replace
/// [kBleServiceUuid] and [kBleMeasurementCharacteristicUuid] once the
/// firmware is finalised before any BLE reading will function.
class BleDeviceRepository implements DeviceRepository {
  BleDeviceRepository(this._device);

  final BluetoothDevice _device;

  final _connectionCtrl =
      StreamController<DeviceConnectionState>.broadcast();
  final _deviceInfoCtrl = StreamController<DeviceInfo?>.broadcast();
  final _measurementsCtrl = StreamController<IncomingMeasurement>.broadcast();

  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<int>>? _charSub;

  @override
  Stream<DeviceConnectionState> get connectionState =>
      _connectionCtrl.stream;

  @override
  Stream<DeviceInfo?> get deviceInfo => _deviceInfoCtrl.stream;

  @override
  Stream<IncomingMeasurement> get measurements => _measurementsCtrl.stream;

  @override
  Future<void> connect() async {
    _connectionCtrl.add(DeviceConnectionState.connecting);
    _deviceInfoCtrl.add(null);

    try {
      await _device.connect(
          autoConnect: false, timeout: const Duration(seconds: 10));

      _connSub = _device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _connectionCtrl.add(DeviceConnectionState.disconnected);
          _deviceInfoCtrl.add(null);
        }
      });

      final info = DeviceInfo(
        deviceId: _device.remoteId.str,
        displayName: _device.platformName.isNotEmpty
            ? _device.platformName
            : kBleDeviceNamePrefix,
        transport: DeviceTransport.ble,
        connectionState: DeviceConnectionState.connected,
        lastSeen: DateTime.now(),
      );

      _connectionCtrl.add(DeviceConnectionState.connected);
      _deviceInfoCtrl.add(info);

      await _subscribeToMeasurements();
    } catch (_) {
      _connectionCtrl.add(DeviceConnectionState.error);
      _deviceInfoCtrl.add(null);
    }
  }

  Future<void> _subscribeToMeasurements() async {
    // TODO(hardware-team): Once GATT UUIDs are confirmed, replace the body
    // below with actual characteristic subscription:
    //
    // final services = await _device.discoverServices();
    // final svc = services.firstWhere(
    //   (s) => s.uuid.toString() == kBleServiceUuid,
    // );
    // final char = svc.characteristics.firstWhere(
    //   (c) => c.uuid.toString() == kBleMeasurementCharacteristicUuid,
    // );
    // await char.setNotifyValue(true);
    // _charSub = char.lastValueStream.listen(_handleCharacteristicValue);
  }

  // TODO(hardware-team): Replace stub with real wire-format parsing.
  // Expected wire format (little-endian):
  //   bytes[0..3]  — bilirubin mg/dL as float32
  //   bytes[4..11] — Unix timestamp (ms) as int64
  //   bytes[12..]  — optional JPEG image bytes
  // void _handleCharacteristicValue(List<int> bytes) {
  //   final measurement = _parseMeasurement(bytes);
  //   if (measurement != null) _measurementsCtrl.add(measurement);
  // }

  @override
  Future<void> disconnect() async {
    await _charSub?.cancel();
    await _connSub?.cancel();
    await _device.disconnect();
    _connectionCtrl.add(DeviceConnectionState.disconnected);
    _deviceInfoCtrl.add(null);
  }

  @override
  void dispose() {
    _charSub?.cancel();
    _connSub?.cancel();
    _connectionCtrl.close();
    _deviceInfoCtrl.close();
    _measurementsCtrl.close();
  }
}
