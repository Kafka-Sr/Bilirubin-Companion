import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/providers/database_provider.dart';
import 'package:bilirubin/repositories/baby_repository.dart';

/// [BabyRepository] instance, derived from the singleton database.
final babyRepositoryProvider = Provider<BabyRepository>((ref) {
  return BabyRepository(ref.watch(appDatabaseProvider));
});

/// Stream of all non-archived babies, ordered by name.
final babiesListProvider = StreamProvider<List<Baby>>((ref) {
  return ref.watch(babyRepositoryProvider).watchAllActive();
});

/// The currently selected baby's ID. Null means "none selected".
final selectedBabyIdProvider = StateProvider<int?>((ref) => null);

/// The currently selected [Baby] object, or null if none is selected or
/// the list hasn't loaded yet.
final selectedBabyProvider = Provider<Baby?>((ref) {
  final id = ref.watch(selectedBabyIdProvider);
  if (id == null) return null;
  return ref.watch(babiesListProvider).valueOrNull
      ?.firstWhereOrNull((b) => b.id == id);
});

extension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
