/// Immutable domain model representing a registered baby.
class Baby {
  const Baby({
    required this.babyId,
    required this.hospitalId,
    required this.babyName,
    required this.babyDob,
    required this.babyWeight,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  final String babyId;
  final String hospitalId;
  final String babyName;
  final DateTime babyDob;
  final double babyWeight;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  /// Returns the baby's postnatal age in whole hours relative to [reference].
  double ageHoursAt(DateTime reference) {
    final diff = reference.difference(babyDob);
    return diff.inMinutes / 60.0;
  }

  Baby copyWith({
    String? babyId,
    String? hospitalId,
    String? babyName,
    DateTime? babyDob,
    double? babyWeight,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return Baby(
      babyId: babyId ?? this.babyId,
      hospitalId: hospitalId ?? this.hospitalId,
      babyName: babyName ?? this.babyName,
      babyDob: babyDob ?? this.babyDob,
      babyWeight: babyWeight ?? this.babyWeight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Baby && runtimeType == other.runtimeType && babyId == other.babyId;

  @override
  int get hashCode => babyId.hashCode;

  @override
  String toString() => 'Baby(babyId: $babyId, babyName: $babyName)';
}
