import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/providers/auth_providers.dart';
import 'package:bilirubin/providers/database_provider.dart';
import 'package:bilirubin/providers/sync_queue_providers.dart';
import 'package:bilirubin/repositories/audit_repository.dart';

/// Scoped [AuditRepository] using the current user's hospital.
final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return AuditRepository(
    ref.watch(appDatabaseProvider),
    hospitalId: profile?.hospitalId,
    outbox: ref.watch(localSyncOutboxProvider),
  );
});
