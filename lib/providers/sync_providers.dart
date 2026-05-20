import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bilirubin/providers/database_provider.dart';
import 'package:bilirubin/providers/supabase_providers.dart';
import 'package:bilirubin/providers/sync_queue_providers.dart';
import 'package:bilirubin/repositories/cloud_sync_repository.dart';
import 'package:bilirubin/services/sync_service.dart';

enum SyncStatus { idle, syncing, error }

class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  SyncStatusNotifier() : super(SyncStatus.idle);
  void set(SyncStatus s) => state = s;
}

final syncStatusProvider =
    StateNotifierProvider<SyncStatusNotifier, SyncStatus>(
        (_) => SyncStatusNotifier());

final cloudSyncRepositoryProvider = Provider<CloudSyncRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CloudSyncRepository(client);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(localSyncOutboxProvider),
    ref.watch(cloudSyncRepositoryProvider),
    ref.watch(appDatabaseProvider),
  );
});

/// Eagerly activated in main.dart — drains the outbox then pulls cloud changes on startup.
final startupSyncProvider = Provider<void>((ref) {
  final sync = ref.watch(syncServiceProvider);
  Future.microtask(() async {
    await sync.drainOutbox();
    await sync.pullChanges();
  });
});
