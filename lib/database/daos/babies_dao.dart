import 'package:drift/drift.dart';
import 'package:bilirubin/database/database.dart';
import 'package:bilirubin/database/tables/babies_table.dart';

part 'babies_dao.g.dart';

@DriftAccessor(tables: [Babies])
class BabiesDao extends DatabaseAccessor<AppDatabase> with _$BabiesDaoMixin {
  BabiesDao(super.db);

  /// Stream of all non-archived babies, ordered by name.
  Stream<List<Baby>> watchAllActive() => (select(babies)
        ..where((b) => b.isArchived.equals(false))
        ..orderBy([(b) => OrderingTerm.asc(b.name)]))
      .watch();

  /// Returns a single baby by [id], or null if not found.
  Future<Baby?> getBabyById(int id) =>
      (select(babies)..where((b) => b.id.equals(id))).getSingleOrNull();

  /// Inserts a new baby row.
  Future<int> insertBaby(BabiesCompanion companion) =>
      into(babies).insert(companion);

  /// Updates an existing baby row.
  Future<bool> updateBaby(BabiesCompanion companion) =>
      update(babies).replace(companion);

  /// Soft-deletes a baby by setting [isArchived] = true.
  Future<void> archiveBaby(int id) => (update(babies)
        ..where((b) => b.id.equals(id)))
      .write(
    const BabiesCompanion(isArchived: Value(true)),
  );
}
