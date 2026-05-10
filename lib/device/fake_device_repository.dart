import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:bilirubin/core/constants.dart';
import 'package:bilirubin/device/device_repository.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';

// Each palette entry is [background, circle] as ARGB ints.
const _kImagePalettes = [
  [0xFFD6EAF8, 0xFF2980B9], // blue
  [0xFFD5F5E3, 0xFF27AE60], // green
  [0xFFFDEBD0, 0xFFE67E22], // orange
  [0xFFE8DAEF, 0xFF8E44AD], // purple
];

Future<Uint8List> _generateFakeImage(int index) async {
  const size = 320.0;
  final palette = _kImagePalettes[index % _kImagePalettes.length];
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));

  // Background
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, size, size),
    Paint()..color = Color(palette[0]),
  );

  // Outer circle
  canvas.drawCircle(
    const Offset(size / 2, size / 2),
    size * 0.35,
    Paint()..color = Color(palette[1]).withValues(alpha: 0.25),
  );

  // Inner circle
  canvas.drawCircle(
    const Offset(size / 2, size / 2),
    size * 0.2,
    Paint()..color = Color(palette[1]).withValues(alpha: 0.7),
  );

  // Crosshair lines (simulate sensor targeting)
  final linePaint = Paint()
    ..color = Color(palette[1])
    ..strokeWidth = 2;
  canvas.drawLine(
    const Offset(size / 2, size / 2 - size * 0.28),
    const Offset(size / 2, size / 2 - size * 0.18),
    linePaint,
  );
  canvas.drawLine(
    const Offset(size / 2, size / 2 + size * 0.18),
    const Offset(size / 2, size / 2 + size * 0.28),
    linePaint,
  );
  canvas.drawLine(
    const Offset(size / 2 - size * 0.28, size / 2),
    const Offset(size / 2 - size * 0.18, size / 2),
    linePaint,
  );
  canvas.drawLine(
    const Offset(size / 2 + size * 0.18, size / 2),
    const Offset(size / 2 + size * 0.28, size / 2),
    linePaint,
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return byteData!.buffer.asUint8List();
}

/// Simulated device repository for development and demo purposes.
///
/// Emits a fake bilirubin measurement every 15 seconds while connected,
/// each with a cycled JPEG image loaded from bundled assets.
class FakeDeviceRepository implements DeviceRepository {
  FakeDeviceRepository() {
    _connectionCtrl.add(DeviceConnectionState.disconnected);
    _deviceInfoCtrl.add(null);
  }

  final _uuid = const Uuid();
  final _rng = Random();
  final _images = <Uint8List>[];
  int _imageIndex = 0;

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

    // Generate placeholder images (one per palette) so _emitFakeMeasurement stays synchronous.
    if (_images.isEmpty) {
      for (var i = 0; i < _kImagePalettes.length; i++) {
        _images.add(await _generateFakeImage(i));
      }
    }

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
    final bilirubin = 4.0 + _rng.nextDouble() * 16.0; // 4–20 mg/dL
    final image = _images.isNotEmpty
        ? _images[_imageIndex++ % _images.length]
        : null;
    _measurementsCtrl.add(IncomingMeasurement(
      measurementId: _uuid.v4(),
      capturedAt: DateTime.now(),
      bilirubinMgDl: double.parse(bilirubin.toStringAsFixed(1)),
      deviceId: kFakeDeviceId,
      modelVersion: '1.0.0-sim',
      imageBytes: image,
    ));
  }
}
