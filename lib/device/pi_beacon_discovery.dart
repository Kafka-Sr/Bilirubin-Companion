import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bilirubin/core/constants.dart';
import 'package:bilirubin/models/pi_beacon.dart';

/// Listens for Raspberry Pi beacon packets on the local network.
///
/// The Pi is expected to broadcast a small JSON payload periodically to
/// [kPiBeaconPort].
class PiBeaconDiscoveryService {
  PiBeaconDiscoveryService() {
    _controller = StreamController<List<PiBeacon>>.broadcast(
      onListen: _start,
      onCancel: _scheduleEmit,
    );
  }

  late final StreamController<List<PiBeacon>> _controller;
  RawDatagramSocket? _socket;
  Timer? _cleanupTimer;
  bool _starting = false;

  final Map<String, PiBeacon> _beacons = {};

  Stream<List<PiBeacon>> get beacons => _controller.stream;

  void _start() {
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    if (_starting || _socket != null) return;
    _starting = true;

    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        kPiBeaconPort,
        reuseAddress: true,
        reusePort: true,
      );
      _socket!
        ..broadcastEnabled = true
        ..listen(_handleSocketEvent);
      _cleanupTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _pruneExpiredBeacons(),
      );
    } catch (_) {
      // Discovery is optional; fall back to manual Pi address entry.
    } finally {
      _starting = false;
    }
  }

  void _handleSocketEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;

    final socket = _socket;
    if (socket == null) return;

    final packet = socket.receive();
    if (packet == null) return;

    try {
      final decoded = jsonDecode(utf8.decode(packet.data));
      if (decoded is! Map<String, dynamic>) return;

      final beaconType = decoded['type'] as String?;
      if (beaconType != null && beaconType != kPiBeaconType) return;

      final deviceId =
          (decoded['deviceId'] as String?) ?? packet.address.address;
      final displayName = (decoded['displayName'] as String?) ?? 'Raspberry Pi';
      final host = (decoded['host'] as String?) ?? packet.address.address;
      final port = (decoded['port'] as int?) ?? 8080;
      final firmwareVersion = decoded['firmwareVersion'] as String?;
      final beacon = PiBeacon(
        deviceId: deviceId,
        displayName: displayName,
        host: host,
        port: port,
        lastSeenAt: DateTime.now(),
        firmwareVersion: firmwareVersion,
      );

      _beacons[deviceId] = beacon;
      _emit();
    } catch (_) {
      // Ignore malformed packets.
    }
  }

  void _pruneExpiredBeacons() {
    final cutoff = DateTime.now().subtract(const Duration(seconds: 15));
    final before = _beacons.length;
    _beacons.removeWhere((_, beacon) => beacon.lastSeenAt.isBefore(cutoff));
    if (_beacons.length != before) {
      _emit();
    }
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(_beacons.values.toList());
    }
  }

  void _scheduleEmit() {
    if (_beacons.isNotEmpty) {
      _emit();
    }
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _socket?.close();
    _controller.close();
  }
}
