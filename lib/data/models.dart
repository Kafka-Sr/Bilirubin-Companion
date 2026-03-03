import 'dart:typed_data';

enum DeviceTransport { wifi, ble }

enum BhutaniZone {
  veryHighRiskZone,
  highRiskZone,
  highIntermediateRiskZone,
  intermediateRiskZone,
  lowRiskZone,
}

class BabyRecord {
  BabyRecord({
    required this.babyId,
    required this.name,
    this.dateOfBirth,
    this.weightKg,
    required this.createdAt,
    required this.updatedAt,
    required this.isArchived,
  });

  final String babyId;
  final String name;
  final DateTime? dateOfBirth;
  final double? weightKg;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
}

class MeasurementRecord {
  MeasurementRecord({
    required this.measurementId,
    required this.babyId,
    required this.capturedAt,
    required this.receivedAt,
    required this.ageHours,
    required this.bilirubinMgDl,
    required this.hasImage,
    this.imageBytes,
    required this.deviceId,
    required this.modelVersion,
  });

  final String measurementId;
  final String babyId;
  final DateTime capturedAt;
  final DateTime receivedAt;
  final int ageHours;
  final double bilirubinMgDl;
  final bool hasImage;
  final Uint8List? imageBytes;
  final String deviceId;
  final String modelVersion;
}

class DeviceInfo {
  DeviceInfo({
    required this.deviceId,
    required this.transport,
    this.batteryPercent,
    required this.lastSeen,
  });

  final String deviceId;
  final DeviceTransport transport;
  final int? batteryPercent;
  final DateTime lastSeen;
}

class DeviceConnectionState {
  const DeviceConnectionState({required this.isConnected});

  final bool isConnected;
}

class DeviceMeasurementEvent {
  DeviceMeasurementEvent({
    required this.measurementId,
    required this.capturedAt,
    required this.ageHours,
    required this.bilirubinMgDl,
    this.imageBytes,
  });

  final String measurementId;
  final DateTime capturedAt;
  final int ageHours;
  final double bilirubinMgDl;
  final Uint8List? imageBytes;
}
