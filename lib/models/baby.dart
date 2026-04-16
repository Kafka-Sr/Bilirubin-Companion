/// Immutable domain model representing a registered baby.
class Baby {
  const Baby({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.weightKg,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  final int id;
  final String name;
  final DateTime dateOfBirth;
  final double weightKg;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  /// Returns the baby's postnatal age in whole hours relative to [reference].
  double ageHoursAt(DateTime reference) {
    final diff = reference.difference(dateOfBirth);
    return diff.inMinutes / 60.0;
  }

  Baby copyWith({
    int? id,
    String? name,
    DateTime? dateOfBirth,
    double? weightKg,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return Baby(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weightKg: weightKg ?? this.weightKg,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Baby && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Baby(id: $id, name: $name)';
}
