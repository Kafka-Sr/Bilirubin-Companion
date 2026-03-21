import 'package:bilirubin/models/measurement.dart';

class Baby {
  const Baby({
    required this.id,
    required this.name,
    required this.weightKg,
    required this.dateOfBirth,
    required this.measurements,
  });

  final String id;
  final String name;
  final double weightKg;
  final DateTime dateOfBirth;
  final List<Measurement> measurements;

  Measurement? get latestMeasurement =>
      measurements.isEmpty ? null : (measurements.toList()..sort((a, b) => a.takenAt.compareTo(b.takenAt))).last;

  Baby copyWith({
    String? id,
    String? name,
    double? weightKg,
    DateTime? dateOfBirth,
    List<Measurement>? measurements,
  }) {
    return Baby(
      id: id ?? this.id,
      name: name ?? this.name,
      weightKg: weightKg ?? this.weightKg,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      measurements: measurements ?? this.measurements,
    );
  }

  Map<String, Object?> toExportJson() {
    return {
      'id': id,
      'name': name,
      'weight_kg': weightKg,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'measurements': measurements.map((measurement) => measurement.toExportJson()).toList(),
    };
  }
}
