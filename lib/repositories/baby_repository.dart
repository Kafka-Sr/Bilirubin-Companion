import 'package:drift/drift.dart';
import 'package:bilirubin/database/database.dart';
import 'package:bilirubin/models/baby.dart' as domain;

/// Business-logic wrapper around [BabiesDao].
///
/// Converts between Drift-generated [Baby] rows and the domain [domain.Baby] model,
/// and stamps [updatedAt] on every update.
class BabyRepository {
  BabyRepository(this._db);

  final AppDatabase _db;

  Stream<List<domain.Baby>> watchAllActive() =>
      _db.babiesDao.watchAllActive().map((rows) => rows.map(_toModel).toList());

  Future<domain.Baby?> getById(int id) async {
    final row = await _db.babiesDao.getBabyById(id);
    return row == null ? null : _toModel(row);
  }

  /// Creates a new baby record. Returns the assigned [id].
  Future<int> create({
    required String name,
    required DateTime dateOfBirth,
    required double weightKg,
  }) {
    final now = DateTime.now();
    return _db.babiesDao.insertBaby(BabiesCompanion.insert(
      name: name,
      dateOfBirth: dateOfBirth,
      weightKg: weightKg,
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  /// Updates an existing baby record.
  Future<void> update(domain.Baby baby) {
    return _db.babiesDao.updateBaby(BabiesCompanion(
      id: Value(baby.id),
      name: Value(baby.name),
      dateOfBirth: Value(baby.dateOfBirth),
      weightKg: Value(baby.weightKg),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Soft-deletes (archives) a baby by [id].
  Future<void> archive(int id) => _db.babiesDao.archiveBaby(id);

  Stream<List<domain.Baby>> watchAllArchived() =>
      _db.babiesDao.watchAllArchived().map((rows) => rows.map(_toModel).toList());

  Future<void> restore(int id) => _db.babiesDao.restoreBaby(id);

  /// Permanently removes a baby record by [id].
  Future<void> delete(int id) => _db.babiesDao.deleteBaby(id);

  // ── Mapper ─────────────────────────────────────────────────────────────────

  static domain.Baby _toModel(Baby row) => domain.Baby(
        id: row.id,
        name: row.name,
        dateOfBirth: row.dateOfBirth,
        weightKg: row.weightKg,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        isArchived: row.isArchived,
      );
}
