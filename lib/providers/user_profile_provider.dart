import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { admin, nurse, parent }

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.role,
    this.hospitalId,
  });

  final String userId;
  final UserRole role;
  final String? hospitalId; // null for parents

  bool get isStaff => role == UserRole.admin || role == UserRole.nurse;
  bool get isAdmin => role == UserRole.admin;
  bool get isParent => role == UserRole.parent;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['user_id'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.parent,
      ),
      hospitalId: map['hospital_id'] as String?,
    );
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
