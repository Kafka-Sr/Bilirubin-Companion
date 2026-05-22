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
        ..orderBy([(b) => OrderingTerm.asc(b.babyName)]))
      .watch();

  /// Returns a single baby by [id], or null if not found.
  Future<Baby?> getBabyById(String id) =>
      (select(babies)..where((b) => b.babyId.equals(id))).getSingleOrNull();

  /// Inserts a new baby row.
  Future<void> insertBaby(BabiesCompanion companion) =>
      into(babies).insert(companion);

  /// Updates an existing baby row.
  Future<bool> updateBaby(BabiesCompanion companion) =>
      update(babies).replace(companion);

  /// Soft-deletes a baby by setting [isArchived] = true.
  Future<void> archiveBaby(String id) => (update(babies)
        ..where((b) => b.babyId.equals(id)))
      .write(
    const BabiesCompanion(isArchived: Value(true)),
  );

  /// Stream of all archived babies, ordered by name.
  Stream<List<Baby>> watchAllArchived() => (select(babies)
        ..where((b) => b.isArchived.equals(true))
        ..orderBy([(b) => OrderingTerm.asc(b.babyName)]))
      .watch();

  /// Restores an archived baby by setting [isArchived] = false.
  Future<void> restoreBaby(String id) => (update(babies)
        ..where((b) => b.babyId.equals(id)))
      .write(
    const BabiesCompanion(isArchived: Value(false)),
  );

  /// Upserts a baby row — inserts or overwrites on conflict with [babyId].
  Future<void> upsertBaby(BabiesCompanion companion) =>
      into(babies).insertOnConflictUpdate(companion);

  /// Inserts a baby row only if no row with the same [babyId] exists locally.
  /// Used by cloud pull — local data always wins on conflict.
  Future<void> insertBabyIfAbsent(BabiesCompanion companion) =>
      into(babies).insert(companion, mode: InsertMode.insertOrIgnore);

  /// Permanently deletes a baby row by [id].
  Future<void> deleteBaby(String id) =>
      (delete(babies)..where((b) => b.babyId.equals(id))).go();
}
