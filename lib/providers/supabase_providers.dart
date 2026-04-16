import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bilirubin/core/supabase_config.dart';

final supabaseConfigProvider = Provider<SupabaseConfig>((ref) {
  return SupabaseConfig.fromEnvironment();
});

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  if (!config.isConfigured) return null;
  return Supabase.instance.client;
});

final supabaseSessionProvider = StreamProvider<Session?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const Stream<Session?>.empty();

  return client.auth.onAuthStateChange.map((event) => event.session);
});

final supabaseUserProvider = Provider<User?>((ref) {
  return ref.watch(supabaseSessionProvider).valueOrNull?.user;
});
