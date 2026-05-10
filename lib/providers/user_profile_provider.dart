import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { admin, staff, parent }

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.role,
    this.hospitalId,
  });

  final String userId;
  final UserRole role;
  final String? hospitalId; // null for parents

  bool get isStaff => role == UserRole.admin || role == UserRole.staff;
  bool get isAdmin => role == UserRole.admin;
  bool get isParent => role == UserRole.parent;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['user_id'] as String,
      role: parseUserRole(map['role'] as String? ?? ''),
      hospitalId: map['hospital_id'] as String?,
    );
  }
}

UserRole parseUserRole(String raw) {
  switch (raw) {
    case 'admin':
      return UserRole.admin;
    case 'staff':
    case 'nurse': // legacy value — treated as staff
      return UserRole.staff;
    default:
      return UserRole.parent;
  }
}

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;

  final response = await Supabase.instance.client
      .from('user_profiles')
      .select()
      .eq('user_id', user.id)
      .maybeSingle();

  if (response == null) return null;
  return UserProfile.fromMap(response);
});

final hospitalNameProvider = FutureProvider<String?>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null || profile.isParent || profile.hospitalId == null) {
    return null;
  }

  final response = await Supabase.instance.client
      .from('hospitals')
      .select('name')
      .eq('id', profile.hospitalId!)
      .maybeSingle();

  return response?['name'] as String?;
});
