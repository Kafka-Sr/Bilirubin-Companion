import 'dart:convert';
import 'dart:io';

import 'package:bilirubin_companion/data/models.dart';
import 'package:path_provider/path_provider.dart';

class ExportRepository {
  Future<String> exportBaby({required BabyRecord baby, required List<MeasurementRecord> measurements}) async {
    final docDir = await getApplicationDocumentsDirectory();
    final file = File('${docDir.path}/${baby.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.json');
    final payload = {
      'baby': {
        'babyId': baby.babyId,
        'name': baby.name,
        'dateOfBirth': baby.dateOfBirth?.millisecondsSinceEpoch,
        'weightKg': baby.weightKg,
        'createdAt': baby.createdAt.millisecondsSinceEpoch,
        'updatedAt': baby.updatedAt.millisecondsSinceEpoch,
      },
      'measurements': measurements
          .map(
            (m) => {
              'measurementId': m.measurementId,
              'babyId': m.babyId,
              'capturedAt': m.capturedAt.millisecondsSinceEpoch,
              'receivedAt': m.receivedAt.millisecondsSinceEpoch,
              'ageHours': m.ageHours,
              'bilirubinMgDl': m.bilirubinMgDl,
              'hasImage': m.hasImage,
              'deviceId': m.deviceId,
              'modelVersion': m.modelVersion,
            },
          )
          .toList(),
    };
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file.path;
  }
}
