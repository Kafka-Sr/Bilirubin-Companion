import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:bilirubin/core/constants.dart';
import 'package:bilirubin/device/device_repository.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';

/// Direct LAN client for a Raspberry Pi bilirubin capture service.
///
/// Expected Pi API:
/// - GET /health -> 200 OK
/// - GET /device -> JSON device info
/// - GET /measurements?after=<iso8601> -> JSON array of measurement events
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
    if (_connected) return;

    _emit(DeviceConnectionState.connecting, null);

    try {
      await _healthCheck();
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
    }
  }

  @override
  Future<void> disconnect() async {
    if (!_connected) return;
    _pollTimer?.cancel();
    _pollTimer = null;
    _connected = false;
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

  Future<void> _healthCheck() async {
    final response = await _client
        .get(_baseUri.resolve('health'))
        .timeout(const Duration(seconds: 3));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Pi health check failed: ${response.statusCode}');
    }
  }

  Future<DeviceInfo> _loadDeviceInfo() async {
    final response = await _client
        .get(_baseUri.resolve('device'))
        .timeout(const Duration(seconds: 3));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Pi device lookup failed: ${response.statusCode}');
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    return DeviceInfo(
      deviceId: (jsonMap['deviceId'] as String?) ?? kFakeDeviceId,
      displayName: (jsonMap['displayName'] as String?) ?? 'Raspberry Pi',
      transport: DeviceTransport.wifi,
      connectionState: DeviceConnectionState.connected,
      lastSeen: DateTime.now(),
      firmwareVersion: jsonMap['firmwareVersion'] as String?,
    );
  }

  Future<void> _pollOnce() async {
    if (!_connected) return;

    try {
      final since = _lastCapturedAt?.toIso8601String();
      final uri = since == null
          ? _baseUri.resolve('measurements')
          : _baseUri.resolve('measurements?after=$since');
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
      _emit(DeviceConnectionState.error, null);
    }
  }

  IncomingMeasurement? _parseMeasurement(Map<String, dynamic> jsonMap) {
    final measurementId = jsonMap['measurementId'] as String? ?? _uuid.v4();
    final capturedAtRaw = jsonMap['capturedAt'] as String?;
    final bilirubin = (jsonMap['bilirubinMgDl'] as num?)?.toDouble();
    final deviceId = jsonMap['deviceId'] as String? ?? kFakeDeviceId;
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
      bilirubinMgDl: bilirubin,
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
