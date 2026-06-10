import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:bilirubin/database/database.dart';
import 'package:bilirubin/models/baby.dart' as domain;
import 'package:bilirubin/repositories/audit_repository.dart';
import 'package:bilirubin/repositories/local_sync_outbox.dart';

const _uuid = Uuid();

/// Business-logic wrapper around [BabiesDao].
///
/// Converts between Drift-generated [Baby] rows and the domain [domain.Baby] model,
/// and stamps [updatedAt] on every update.
class BabyRepository {
  BabyRepository(this._db, {LocalSyncOutbox? outbox, void Function()? onQueued, AuditRepository? audit})
      : _outbox = outbox,
        _onQueued = onQueued,
        _audit = audit;

  final AppDatabase _db;
  final LocalSyncOutbox? _outbox;
  final void Function()? _onQueued;
  final AuditRepository? _audit;

  Stream<List<domain.Baby>> watchAllActive() =>
      _db.babiesDao.watchAllActive().map((rows) => rows.map(_toModel).toList());

  Future<domain.Baby?> getById(String id) async {
    final row = await _db.babiesDao.getBabyById(id);
    return row == null ? null : _toModel(row);
  }

  /// Creates a new baby record. Returns the assigned [babyId] UUID.
  Future<String> create({
    required String name,
    required DateTime dateOfBirth,
    required double weightKg,
    required String hospitalId,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db.babiesDao.insertBaby(BabiesCompanion.insert(
      babyId: id,
      hospitalId: hospitalId,
      babyName: name,
      babyDob: dateOfBirth,
      babyWeight: weightKg,
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    _audit?.logBabyCreate(id,
        babyName: name, dob: dateOfBirth, weightKg: weightKg);
    await _queue('upsert', {
      'baby_id': id,
      'hospital_id': hospitalId,
      'baby_name': name,
      'baby_dob': dateOfBirth.toIso8601String(),
      'baby_weight': weightKg,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'is_archived': false,
    });
    return id;
  }

  /// Updates an existing baby record.
  Future<void> update(domain.Baby baby) async {
    final now = DateTime.now();
    final oldRow = await _db.babiesDao.getBabyById(baby.babyId);
    await _db.babiesDao.updateBaby(BabiesCompanion(
      babyId: Value(baby.babyId),
      hospitalId: Value(baby.hospitalId),
      babyName: Value(baby.babyName),
      babyDob: Value(baby.babyDob),
      babyWeight: Value(baby.babyWeight),
      updatedAt: Value(now),
    ));
    if (oldRow != null) {
      _audit?.logBabyEdit(_toModel(oldRow), baby);
    }
    await _queue('upsert', {
      'baby_id': baby.babyId,
      'hospital_id': baby.hospitalId,
      'baby_name': baby.babyName,
      'baby_dob': baby.babyDob.toIso8601String(),
      'baby_weight': baby.babyWeight,
      'created_at': baby.createdAt.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'is_archived': baby.isArchived,
    });
  }

  /// Soft-deletes (archives) a baby by [id].
  Future<void> archive(String id) async {
    final now = DateTime.now();
    final baby = await _db.babiesDao.getBabyById(id);
    if (baby == null) return;
    await _db.babiesDao.archiveBaby(id);
    _audit?.logBabyDelete(id,
        babyName: baby.babyName, dob: baby.babyDob, weightKg: baby.babyWeight);
    await _queue('upsert', {
      'baby_id': id,
      'hospital_id': baby.hospitalId,
      'baby_name': baby.babyName,
      'baby_dob': baby.babyDob.toIso8601String(),
      'baby_weight': baby.babyWeight,
      'created_at': baby.createdAt.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'is_archived': true,
    });
  }

  Stream<List<domain.Baby>> watchAllArchived() => _db.babiesDao
      .watchAllArchived()
      .map((rows) => rows.map(_toModel).toList());

  Future<void> restore(String id) async {
    final now = DateTime.now();
    final baby = await _db.babiesDao.getBabyById(id);
    if (baby == null) return;
    await _db.babiesDao.restoreBaby(id);
    await _queue('upsert', {
      'baby_id': id,
      'hospital_id': baby.hospitalId,
      'baby_name': baby.babyName,
      'baby_dob': baby.babyDob.toIso8601String(),
      'baby_weight': baby.babyWeight,
      'created_at': baby.createdAt.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'is_archived': false,
    });
  }

  /// Permanently removes a baby record by [id].
  Future<void> delete(String id) async {
    final baby = await _db.babiesDao.getBabyById(id);
    await _db.babiesDao.deleteBaby(id);
    if (baby != null) {
      _audit?.logBabyDelete(id,
          babyName: baby.babyName, dob: baby.babyDob, weightKg: baby.babyWeight);
    }
    await _queue('delete', {'baby_id': id});
  }

  Future<void> _queue(String action, Map<String, dynamic> payload) async {
    final outbox = _outbox;
    if (outbox == null) return;
    try {
      await outbox.enqueue(
        table: 'babies',
        action: action,
        entityId: '${payload['baby_id'] ?? payload['baby_name'] ?? 'unknown'}',
        payload: payload,
      );
      _onQueued?.call();
    } catch (_) {
      // Temporary staging must not block local CRUD.
    }
  }

  // Mapper

  static domain.Baby _toModel(Baby row) => domain.Baby(
        babyId: row.babyId,
        hospitalId: row.hospitalId,
        babyName: row.babyName,
        babyDob: row.babyDob,
        babyWeight: row.babyWeight,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        isArchived: row.isArchived,
      );
}
