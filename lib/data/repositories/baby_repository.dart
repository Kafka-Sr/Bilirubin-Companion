import 'package:bilirubin_companion/data/app_database.dart';
import 'package:bilirubin_companion/data/encryption_service.dart';
import 'package:bilirubin_companion/data/models.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';

class BabyRepository {
  BabyRepository(this.db, this.encryptionService);

  final AppDatabase db;
  final EncryptionService encryptionService;
  final uuid = const Uuid();

  Future<List<BabyRecord>> listBabies({String search = ''}) => db.getBabies(search: search);

  Future<BabyRecord> saveBaby({
    String? babyId,
    required String name,
    DateTime? dateOfBirth,
    double? weightKg,
  }) async {
    final now = DateTime.now();
    final record = BabyRecord(
      babyId: babyId ?? uuid.v4(),
      name: name,
      dateOfBirth: dateOfBirth,
      weightKg: weightKg,
      createdAt: now,
      updatedAt: now,
      isArchived: false,
    );
    await db.upsertBaby(record);
    await db.addAuditEvent(auditEventId: uuid.v4(), eventType: 'babySaved', babyId: record.babyId);
    return record;
  }

  Future<List<MeasurementRecord>> listMeasurements(String babyId) => db.getMeasurements(babyId);

  Future<void> addMeasurement({
    required String babyId,
    required String measurementId,
    required DateTime capturedAt,
    required int ageHours,
    required double bilirubinMgDl,
    Uint8List? imageBytes,
    required String deviceId,
  }) async {
    final encrypted = imageBytes == null ? null : await encryptionService.encrypt(imageBytes);
    final measurement = MeasurementRecord(
      measurementId: measurementId,
      babyId: babyId,
      capturedAt: capturedAt,
      receivedAt: DateTime.now(),
      ageHours: ageHours,
      bilirubinMgDl: bilirubinMgDl,
      hasImage: encrypted != null,
      imageBytes: encrypted,
      deviceId: deviceId,
      modelVersion: 'v1.0.0',
    );
    await db.insertMeasurement(measurement);
    await db.addAuditEvent(
      auditEventId: uuid.v4(),
      eventType: 'measurementSaved',
      babyId: babyId,
      measurementId: measurementId,
      deviceId: deviceId,
    );
  }
}
