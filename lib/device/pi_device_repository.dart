import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:bilirubin/device/device_repository.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';

/// Direct LAN client for a Biligun bilirubin capture device.
///
/// Expected Biligun API (base http://10.42.0.1:7878):
/// - GET /api/sync/status  -> JSON with device_id + success flag (health + identity)
/// - GET /api/history      -> JSON array of measurement events
class PiDeviceRepository implements DeviceRepository {
  PiDeviceRepository({
    required String baseUrl,
    http.Client? client,
  })  : _baseUri = Uri.parse(_normalizeBaseUrl(baseUrl)),
        _client = client ?? http.Client() {
    _connectionCtrl.add(DeviceConnectionState.disconnected);
    _deviceInfoCtrl.add(null);
  }

  final Uri _baseUri;
  final http.Client _client;
  final _uuid = const Uuid();

  final _connectionCtrl = StreamController<DeviceConnectionState>.broadcast();
  final _deviceInfoCtrl = StreamController<DeviceInfo?>.broadcast();
  final _measurementsCtrl = StreamController<IncomingMeasurement>.broadcast();

  Timer? _pollTimer;
  bool _connected = false;
  bool _connecting = false;
  DateTime? _lastCapturedAt;
  final Set<String> _recentMeasurementIds = <String>{};

  @override
  Stream<DeviceConnectionState> get connectionState => _connectionCtrl.stream;

  @override
  Stream<DeviceInfo?> get deviceInfo => _deviceInfoCtrl.stream;

  @override
  Stream<IncomingMeasurement> get measurements => _measurementsCtrl.stream;

  @override
  Future<void> connect() async {
    if (_connected || _connecting) return;
    _connecting = true;

    _emit(DeviceConnectionState.connecting, null);

    try {
      final info = await _loadDeviceInfo();
      _connected = true;
      _emit(DeviceConnectionState.connected, info);
      await _pollOnce();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _pollOnce(),
      );
    } catch (_) {
      _emit(DeviceConnectionState.error, null);
    } finally {
      _connecting = false;
    }
  }

  @override
  Future<void> disconnect() async {
    if (!_connected) return;
    _pollTimer?.cancel();
    _pollTimer = null;
    _connected = false;
    _connecting = false;
    _emit(DeviceConnectionState.disconnected, null);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _client.close();
    _connectionCtrl.close();
    _deviceInfoCtrl.close();
    _measurementsCtrl.close();
  }

  Future<DeviceInfo> _loadDeviceInfo() async {
    final response = await _client
        .get(_baseUri.resolve('api/sync/status'))
        .timeout(const Duration(seconds: 3));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Biligun unreachable: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final success = json['success'] as bool? ?? false;
    if (!success) throw StateError('Biligun reports failure');

    final deviceId = (json['device_id'] as String?) ?? 'unknown-device';
    return DeviceInfo(
      deviceId: deviceId,
      displayName: deviceId,
      connectionState: DeviceConnectionState.connected,
      lastSeen: DateTime.now(),
      firmwareVersion: null,
    );
  }

  Future<void> _pollOnce() async {
    if (!_connected) return;

    try {
      final since = _lastCapturedAt?.toIso8601String();
      final uri = since == null
          ? _baseUri.resolve('api/history')
          : _baseUri.resolve('api/history?after=$since');
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) return;

      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;
        final measurement = _parseMeasurement(item);
        if (measurement == null) continue;
        if (_recentMeasurementIds.contains(measurement.measurementId)) {
          continue;
        }

        _recentMeasurementIds.add(measurement.measurementId);
        if (_recentMeasurementIds.length > 100) {
          _recentMeasurementIds.remove(_recentMeasurementIds.first);
        }
        _lastCapturedAt = measurement.capturedAt;
        _measurementsCtrl.add(measurement);
      }
    } catch (_) {
      // Poll failure is not a disconnect — transient network hiccup or
      // endpoint not yet implemented. Retry silently on the next tick.
    }
  }

  IncomingMeasurement? _parseMeasurement(Map<String, dynamic> jsonMap) {
    final measurementId = jsonMap['measurementId'] as String? ?? _uuid.v4();
    final capturedAtRaw = jsonMap['capturedAt'] as String?;
    final bilirubin = (jsonMap['bilirubinMgDl'] as num?)?.toDouble();
    final deviceId = jsonMap['deviceId'] as String? ?? 'unknown-device';
    final modelVersion = jsonMap['modelVersion'] as String? ?? 'pi-1';
    final imageBytesBase64 = jsonMap['imageBytesBase64'] as String?;

    if (capturedAtRaw == null || bilirubin == null) return null;

    Uint8List? imageBytes;
    if (imageBytesBase64 != null && imageBytesBase64.isNotEmpty) {
      imageBytes = base64Decode(imageBytesBase64);
    }

    return IncomingMeasurement(
      measurementId: measurementId,
      capturedAt: DateTime.parse(capturedAtRaw),
      bilirubinMgdl: bilirubin,
      deviceId: deviceId,
      modelVersion: modelVersion,
      imageBytes: imageBytes,
    );
  }

  void _emit(DeviceConnectionState state, DeviceInfo? info) {
    _connectionCtrl.add(state);
    _deviceInfoCtrl.add(info);
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'http://$trimmed';
  }
}
