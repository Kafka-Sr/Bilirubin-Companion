import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/models/measurement.dart';
import 'package:bilirubin/providers/baby_providers.dart';
import 'package:bilirubin/providers/database_provider.dart';
import 'package:bilirubin/repositories/measurement_repository.dart';
import 'package:bilirubin/security/encryption_service.dart';
import 'package:bilirubin/providers/sync_queue_providers.dart';

/// Singleton [EncryptionService].
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

/// [MeasurementRepository] instance.
final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  return MeasurementRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(encryptionServiceProvider),
    outbox: ref.watch(localSyncOutboxProvider),
  );
});

/// Stream of all measurements for [babyId], newest first.
final measurementsProvider =
    StreamProvider.family<List<Measurement>, int>((ref, babyId) {
  return ref.watch(measurementRepositoryProvider).watchByBaby(babyId);
});

/// The most recent measurement for the currently selected baby, or null.
final latestMeasurementProvider = Provider<Measurement?>((ref) {
  final baby = ref.watch(selectedBabyProvider);
  if (baby == null) return null;
  return ref.watch(measurementsProvider(baby.id)).valueOrNull?.firstOrNull;
});

/// The measurement ID selected via the image carousel. Null = show latest.
final selectedCarouselMeasurementIdProvider =
    StateProvider<String?>((ref) => null);

/// The measurement currently highlighted by the carousel, or the latest if
/// no carousel selection is active.
final activeMeasurementProvider = Provider<Measurement?>((ref) {
  final selectedId = ref.watch(selectedCarouselMeasurementIdProvider);
  final baby = ref.watch(selectedBabyProvider);
  if (baby == null) return null;
  final all = ref.watch(measurementsProvider(baby.id)).valueOrNull;
  if (all == null || all.isEmpty) return null;
  if (selectedId == null) return all.firstOrNull;
  return all.firstWhere(
    (m) => m.measurementId == selectedId,
    orElse: () => all.first,
  );
});

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
