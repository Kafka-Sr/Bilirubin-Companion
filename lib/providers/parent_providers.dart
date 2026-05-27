import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/providers/supabase_providers.dart';

/// All baby IDs linked to the current parent via parent_access.
final parentLinkedBabyIdsProvider = FutureProvider<List<String>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(supabaseUserProvider);
  if (client == null || user == null) return [];
  final data = await client
      .from('parent_access')
      .select('baby_id')
      .eq('parent_id', user.id);
  return (data as List).map((e) => e['baby_id'] as String).toList();
});

/// The parent_access row for the current user, or null if not linked.
final parentAccessProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  final user = ref.watch(supabaseUserProvider);
  if (user == null) return null;

  final data = await client
      .from('parent_access')
      .select()
      .eq('parent_id', user.id)
      .maybeSingle();

  return data;
});

/// The baby linked to the current parent, or null.
final parentBabyProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final access = await ref.watch(parentAccessProvider.future);
  if (access == null) return null;

  final client = ref.read(supabaseClientProvider);
  if (client == null) return null;

  final data = await client
      .from('babies')
      .select()
      .eq('baby_id', access['baby_id'] as String)
      .maybeSingle();

  return data;
});

/// Measurements for the parent's linked baby, newest first.
final parentMeasurementsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final access = await ref.watch(parentAccessProvider.future);
  if (access == null) return [];

  final client = ref.read(supabaseClientProvider);
  if (client == null) return [];

  final data = await client
      .from('measurements')
      .select()
      .eq('baby_id', access['baby_id'] as String)
      .order('captured_at', ascending: false)
      .limit(100);

  return (data as List).cast<Map<String, dynamic>>();
});
