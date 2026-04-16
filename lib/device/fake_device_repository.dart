import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:bilirubin/core/constants.dart';
import 'package:bilirubin/device/device_repository.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';

/// Simulated device repository for development and demo purposes.
///
/// Emits a fake bilirubin measurement every 15 seconds while connected.
class FakeDeviceRepository implements DeviceRepository {
  FakeDeviceRepository() {
    _connectionCtrl.add(DeviceConnectionState.disconnected);
    _deviceInfoCtrl.add(null);
  }

  final _uuid = const Uuid();
  final _rng = Random();

  final _connectionCtrl =
      StreamController<DeviceConnectionState>.broadcast();
  final _deviceInfoCtrl = StreamController<DeviceInfo?>.broadcast();
  final _measurementsCtrl =
      StreamController<IncomingMeasurement>.broadcast();

  Timer? _measurementTimer;
  bool _connected = false;

  static const _deviceInfo = DeviceInfo(
    deviceId: kFakeDeviceId,
    displayName: kFakeDeviceName,
    transport: DeviceTransport.fake,
    connectionState: DeviceConnectionState.connected,
  );

  // ── DeviceRepository ───────────────────────────────────────────────────────

  @override
  Stream<DeviceConnectionState> get connectionState =>
      _connectionCtrl.stream;

  @override
  Stream<DeviceInfo?> get deviceInfo => _deviceInfoCtrl.stream;

  @override
  Stream<IncomingMeasurement> get measurements => _measurementsCtrl.stream;

  @override
  Future<void> connect() async {
    if (_connected) return;
    _emit(DeviceConnectionState.connecting, null);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _connected = true;
    _emit(DeviceConnectionState.connected, _deviceInfo);
    _measurementTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _emitFakeMeasurement(),
    );
    // Emit one immediately so the UI shows data right away.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _emitFakeMeasurement();
  }

  @override
  Future<void> disconnect() async {
    if (!_connected) return;
    _measurementTimer?.cancel();
    _measurementTimer = null;
    _connected = false;
    _emit(DeviceConnectionState.disconnected, null);
  }

  @override
  void dispose() {
    _measurementTimer?.cancel();
    _connectionCtrl.close();
    _deviceInfoCtrl.close();
    _measurementsCtrl.close();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _emit(DeviceConnectionState state, DeviceInfo? info) {
    _connectionCtrl.add(state);
    _deviceInfoCtrl.add(info);
  }

  void _emitFakeMeasurement() {
    // Simulate a plausible bilirubin value for a newborn.
    final bilirubin = 4.0 + _rng.nextDouble() * 16.0; // 4–20 mg/dL
    _measurementsCtrl.add(IncomingMeasurement(
      measurementId: _uuid.v4(),
      capturedAt: DateTime.now(),
      bilirubinMgDl: double.parse(bilirubin.toStringAsFixed(1)),
      deviceId: kFakeDeviceId,
      modelVersion: '1.0.0-sim',
    ));
  }
}
