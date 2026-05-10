import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bilirubin/providers/baby_providers.dart';
import 'package:bilirubin/providers/measurement_providers.dart';
import 'package:bilirubin/providers/supabase_providers.dart';
import 'package:bilirubin/providers/sync_queue_providers.dart';
import 'package:bilirubin/providers/user_profile_provider.dart';
import 'package:bilirubin/repositories/cloud_sync_repository.dart';
import 'package:bilirubin/services/sync_service.dart';

final cloudSyncRepositoryProvider = Provider<CloudSyncRepository>((ref) {
  return CloudSyncRepository(ref.watch(supabaseClientProvider));
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    outbox: ref.watch(localSyncOutboxProvider),
    cloudSync: ref.watch(cloudSyncRepositoryProvider),
  );
});

/// Call `ref.read(syncNotifierProvider.notifier).push()` to drain the outbox.
/// The async value holds the last [SyncResult], or null before the first push.
class SyncNotifier extends AsyncNotifier<SyncResult?> {
  @override
  Future<SyncResult?> build() async => null;

  Future<void> push() async {
    final profile = await ref.read(userProfileProvider.future);
    final hospitalId = profile?.hospitalId;
    if (hospitalId == null) return; // parent or unauthenticated

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(syncServiceProvider);
      final babyRepo = ref.read(babyRepositoryProvider);
      final measurementRepo = ref.read(measurementRepositoryProvider);

      final allBabies = await babyRepo.getAll();

      // Pull first: gun's direct-to-cloud records + other devices' measurements.
      await service.pullMeasurements(
        hospitalId: hospitalId,
        babies: allBabies,
        measurementRepo: measurementRepo,
      );

      // Then push: fill in baby_local_id on any records the gun wrote first.
      await service.pushAllBabies(hospitalId: hospitalId, babies: allBabies);
      return service.pushPending(hospitalId: hospitalId);
    });
  }
}

final syncNotifierProvider =
    AsyncNotifierProvider<SyncNotifier, SyncResult?>(SyncNotifier.new);
