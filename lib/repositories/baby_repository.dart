import 'package:drift/drift.dart';
import 'package:bilirubin/database/database.dart';
import 'package:bilirubin/models/baby.dart' as domain;
import 'package:bilirubin/repositories/local_sync_outbox.dart';

/// Business-logic wrapper around [BabiesDao].
///
/// Converts between Drift-generated [Baby] rows and the domain [domain.Baby] model,
/// and stamps [updatedAt] on every update.
class BabyRepository {
  BabyRepository(this._db, {LocalSyncOutbox? outbox}) : _outbox = outbox;

  final AppDatabase _db;
  final LocalSyncOutbox? _outbox;

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
  }) async {
    final now = DateTime.now();
    final id = await _db.babiesDao.insertBaby(BabiesCompanion.insert(
      name: name,
      dateOfBirth: dateOfBirth,
      weightKg: weightKg,
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    await _queue('upsert', {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'weightKg': weightKg,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'isArchived': false,
    });
    return id;
  }

  /// Updates an existing baby record.
  Future<void> update(domain.Baby baby) {
    final now = DateTime.now();
    final future = _db.babiesDao.updateBaby(BabiesCompanion(
      id: Value(baby.id),
      name: Value(baby.name),
      dateOfBirth: Value(baby.dateOfBirth),
      weightKg: Value(baby.weightKg),
      updatedAt: Value(now),
    ));
    return future.then((_) => _queue('upsert', {
          'id': baby.id,
          'name': baby.name,
          'dateOfBirth': baby.dateOfBirth.toIso8601String(),
          'weightKg': baby.weightKg,
          'updatedAt': now.toIso8601String(),
          'isArchived': baby.isArchived,
        }));
  }

  /// Soft-deletes (archives) a baby by [id].
  Future<void> archive(int id) {
    final future = _db.babiesDao.archiveBaby(id);
    return future.then((_) => _queue('archive', {'id': id}));
  }

  Stream<List<domain.Baby>> watchAllArchived() => _db.babiesDao
      .watchAllArchived()
      .map((rows) => rows.map(_toModel).toList());

  Future<void> restore(int id) {
    final future = _db.babiesDao.restoreBaby(id);
    return future.then((_) => _queue('restore', {'id': id}));
  }

  /// Permanently removes a baby record by [id].
  Future<void> delete(int id) {
    final future = _db.babiesDao.deleteBaby(id);
    return future.then((_) => _queue('delete', {'id': id}));
  }

  Future<void> _queue(String action, Map<String, dynamic> payload) async {
    final outbox = _outbox;
    if (outbox == null) return;
    try {
      await outbox.enqueue(
        table: 'babies',
        action: action,
        entityId: '${payload['id'] ?? payload['name'] ?? 'unknown'}',
        payload: payload,
      );
    } catch (_) {
      // Temporary staging must not block local CRUD.
    }
  }

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
