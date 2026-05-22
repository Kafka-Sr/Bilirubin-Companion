import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/models/user_profile.dart';
import 'package:bilirubin/providers/supabase_providers.dart';

/// The current user's profile fetched from [user_profiles].
/// Null when unauthenticated or profile not yet loaded.
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final session = ref.watch(supabaseSessionProvider).valueOrNull;
  if (session == null) return null;

  final client = ref.read(supabaseClientProvider);
  if (client == null) return null;

  final data = await client
      .from('user_profiles')
      .select()
      .eq('user_id', session.user.id)
      .maybeSingle();

  if (data == null) return null;
  return UserProfile.fromMap(data);
});

/// True when the current user has the 'admin' role.
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).valueOrNull?.isAdmin ?? false;
});

/// True when the current user is 'admin' or 'staff'.
final isStaffOrAdminProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).valueOrNull?.isStaffOrAdmin ?? false;
});

/// True when the current user has the 'parent' role.
final isParentProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).valueOrNull?.isParent ?? false;
});
