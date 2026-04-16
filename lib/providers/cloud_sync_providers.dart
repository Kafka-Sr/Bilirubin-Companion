import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bilirubin/providers/supabase_providers.dart';
import 'package:bilirubin/repositories/cloud_sync_repository.dart';

final cloudSyncRepositoryProvider = Provider<CloudSyncRepository>((ref) {
  return CloudSyncRepository(ref.watch(supabaseClientProvider));
});
