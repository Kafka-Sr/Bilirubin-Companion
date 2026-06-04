import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/providers/auth_providers.dart';
import 'package:bilirubin/providers/supabase_providers.dart';

/// All user profiles in the current hospital (all roles, includes is_active).
final allUsersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return [];
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile == null) return [];

  final data = await client
      .from('user_profiles')
      .select('user_id, full_name, role, is_active, created_at')
      .eq('hospital_id', profile.hospitalId)
      .order('full_name');

  return (data as List).cast<Map<String, dynamic>>();
});

/// List of staff/admin profiles in the current user's hospital.
final staffListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return [];
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile == null) return [];

  final data = await client
      .from('user_profiles')
      .select('user_id, full_name, role, created_at')
      .eq('hospital_id', profile.hospitalId)
      .inFilter('role', ['admin', 'staff'])
      .order('full_name');

  return (data as List).cast<Map<String, dynamic>>();
});

/// All parent–baby links for the current hospital.
final parentLinksProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return [];
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile == null) return [];

  final data = await client
      .from('parent_access')
      .select(
          'parent_id, baby_id, user_profiles(full_name), babies(baby_name)')
      .eq('hospital_id', profile.hospitalId)
      .order('baby_id');

  return (data as List).cast<Map<String, dynamic>>();
});

/// Babies in the current hospital fetched directly from Supabase.
/// Used wherever a baby_id must exist in Supabase (e.g. parent_access FK).
final supabaseBabiesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return [];
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile == null) return [];

  final data = await client
      .from('babies')
      .select('baby_id, baby_name')
      .eq('hospital_id', profile.hospitalId)
      .eq('is_archived', false)
      .order('baby_name');

  return (data as List).cast<Map<String, dynamic>>();
});

/// Transfer requests involving the current user's hospital (both directions).
final transfersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return [];
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile == null) return [];

  final data = await client
      .from('transfer_requests')
      .select('*, babies(baby_name), from_hospital:hospitals!from_hospital_id(hospital_name), to_hospital:hospitals!to_hospital_id(hospital_name)')
      .or('from_hospital_id.eq.${profile.hospitalId},to_hospital_id.eq.${profile.hospitalId}')
      .order('initiated_at', ascending: false);

  return (data as List).cast<Map<String, dynamic>>();
});

/// Paginated audit events for the current hospital.
/// Fetches 51 rows per page so the screen can detect whether a next page
/// exists (length > 50) without a separate count query.
final auditEventsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, page) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return [];

  const pageSize = 50;
  final data = await client
      .from('audit_events')
      .select('*')
      .order('created_at', ascending: false)
      .range(page * pageSize, (page + 1) * pageSize);

  return (data as List).cast<Map<String, dynamic>>();
});
