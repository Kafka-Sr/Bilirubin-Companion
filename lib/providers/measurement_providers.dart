import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/models/measurement.dart';
import 'package:bilirubin/providers/baby_providers.dart';
import 'package:bilirubin/providers/database_provider.dart';
import 'package:bilirubin/repositories/measurement_repository.dart';
import 'package:bilirubin/security/encryption_service.dart';

/// Singleton [EncryptionService].
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

/// [MeasurementRepository] instance.
final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  return MeasurementRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(encryptionServiceProvider),
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

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
