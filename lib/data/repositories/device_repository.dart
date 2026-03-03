import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:bilirubin_companion/data/models.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

abstract class DeviceRepository {
  Stream<DeviceConnectionState> get connectionState;
  Stream<DeviceInfo?> get deviceInfo;
  Future<void> connect();
  Future<void> disconnect();
  Future<DeviceMeasurementEvent> simulateScan();
}

class FakeDeviceRepository implements DeviceRepository {
  final connection = StreamController<DeviceConnectionState>.broadcast();
  final info = StreamController<DeviceInfo?>.broadcast();
  final uuid = const Uuid();
  bool isConnected = false;
  final random = Random();

  FakeDeviceRepository() {
    connection.add(const DeviceConnectionState(isConnected: false));
    info.add(null);
  }

  @override
  Stream<DeviceConnectionState> get connectionState => connection.stream;

  @override
  Stream<DeviceInfo?> get deviceInfo => info.stream;

  @override
  Future<void> connect() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    isConnected = true;
    final device = DeviceInfo(
      deviceId: 'BG-${1000 + random.nextInt(9000)}',
      transport: random.nextBool() ? DeviceTransport.wifi : DeviceTransport.ble,
      batteryPercent: 50 + random.nextInt(50),
      lastSeen: DateTime.now(),
    );
    connection.add(const DeviceConnectionState(isConnected: true));
    info.add(device);
  }

  @override
  Future<void> disconnect() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    isConnected = false;
    connection.add(const DeviceConnectionState(isConnected: false));
    info.add(null);
  }

  @override
  Future<DeviceMeasurementEvent> simulateScan() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    Uint8List? sample;
    try {
      sample = (await rootBundle.load('assets/sample/baby_1.jpg')).buffer.asUint8List();
    } catch (_) {
      sample = null;
    }
    return DeviceMeasurementEvent(
      measurementId: uuid.v4(),
      capturedAt: DateTime.now(),
      ageHours: 12 + random.nextInt(100),
      bilirubinMgDl: (5 + random.nextDouble() * 16),
      imageBytes: sample,
    );
  }
}
