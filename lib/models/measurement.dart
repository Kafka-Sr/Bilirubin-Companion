class Measurement {
  const Measurement({
    required this.id,
    required this.takenAt,
    required this.ageHours,
    required this.bilirubinMgDl,
    this.imageLabel,
  });

  final String id;
  final DateTime takenAt;
  final int ageHours;
  final double bilirubinMgDl;
  final String? imageLabel;

  bool get hasImage => (imageLabel ?? '').trim().isNotEmpty;

  Map<String, Object?> toExportJson() {
    return {
      'id': id,
      'taken_at': takenAt.toIso8601String(),
      'age_hours': ageHours,
      'bilirubin_mg_dl': bilirubinMgDl,
      'has_image': hasImage,
      'image_label': imageLabel,
    };
  }
}
