/// Immutable model for the authenticated user's profile row.
class UserProfile {
  const UserProfile({
    required this.userId,
    required this.hospitalId,
    required this.role,
    required this.fullName,
    required this.isActive,
  });

  final String userId;
  final String hospitalId;

  /// One of: 'admin', 'staff', 'parent'
  final String role;
  final String fullName;
  final bool isActive;

  bool get isAdmin => role == 'admin';
  bool get isStaff => role == 'staff';
  bool get isParent => role == 'parent';
  bool get isStaffOrAdmin => isActive && (role == 'admin' || role == 'staff');

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        userId: map['user_id'] as String,
        hospitalId: map['hospital_id'] as String,
        role: map['role'] as String,
        fullName: map['full_name'] as String,
        isActive: map['is_active'] as bool? ?? true,
      );

  @override
  String toString() => 'UserProfile($fullName, $role, active=$isActive)';
}
