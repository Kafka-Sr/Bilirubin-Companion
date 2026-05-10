import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Data classes ──────────────────────────────────────────────────────────────

class ParentBabyAccess {
  const ParentBabyAccess({
    required this.hospitalId,
    required this.babyLocalId,
  });

  final String hospitalId;
  final int babyLocalId;

  factory ParentBabyAccess.fromMap(Map<String, dynamic> m) => ParentBabyAccess(
        hospitalId: m['hospital_id'] as String,
        babyLocalId: (m['baby_local_id'] as num).toInt(),
      );
}

class CloudBabyInfo {
  const CloudBabyInfo({
    required this.name,
    required this.dateOfBirth,
    required this.weightKg,
  });

  final String name;
  final DateTime dateOfBirth;
  final double weightKg;

  double get ageHoursNow =>
      DateTime.now().difference(dateOfBirth).inMinutes / 60.0;

  factory CloudBabyInfo.fromMap(Map<String, dynamic> m) => CloudBabyInfo(
        name: m['name'] as String,
        dateOfBirth: DateTime.parse(m['date_of_birth'] as String),
        weightKg: (m['weight_kg'] as num).toDouble(),
      );
}

class CloudMeasurement {
  const CloudMeasurement({
    required this.measurementId,
    required this.capturedAt,
    required this.ageHours,
    required this.bilirubinMgDl,
  });

  final String measurementId;
  final DateTime capturedAt;
  final double ageHours;
  final double bilirubinMgDl;

  factory CloudMeasurement.fromMap(Map<String, dynamic> m) => CloudMeasurement(
        measurementId: m['measurement_id'] as String,
        capturedAt: DateTime.parse(m['captured_at'] as String),
        ageHours: (m['age_hours'] as num).toDouble(),
        bilirubinMgDl: (m['bilirubin_mg_dl'] as num).toDouble(),
      );
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// The parent_baby_access row for the current user, or null if not yet linked.
final parentBabyAccessProvider = FutureProvider<ParentBabyAccess?>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;

  final row = await Supabase.instance.client
      .from('parent_baby_access')
      .select()
      .eq('parent_user_id', user.id)
      .maybeSingle();

  if (row == null) return null;
  return ParentBabyAccess.fromMap(row);
});

/// Baby info from the cloud babies table for the parent's linked baby.
final parentBabyInfoProvider = FutureProvider<CloudBabyInfo?>((ref) async {
  final access = await ref.watch(parentBabyAccessProvider.future);
  if (access == null) return null;

  final row = await Supabase.instance.client
      .from('babies')
      .select('name, date_of_birth, weight_kg')
      .eq('hospital_id', access.hospitalId)
      .eq('local_id', access.babyLocalId)
      .maybeSingle();

  if (row == null) return null;
  return CloudBabyInfo.fromMap(row);
});

/// Measurements from the cloud for the parent's linked baby (newest first).
final parentMeasurementsProvider =
    FutureProvider<List<CloudMeasurement>>((ref) async {
  final access = await ref.watch(parentBabyAccessProvider.future);
  if (access == null) return [];

  final rows = await Supabase.instance.client
      .from('measurements')
      .select('measurement_id, captured_at, age_hours, bilirubin_mg_dl')
      .eq('hospital_id', access.hospitalId)
      .eq('baby_local_id', access.babyLocalId)
      .order('captured_at', ascending: false)
      .limit(100);

  return (rows as List).map((m) => CloudMeasurement.fromMap(m)).toList();
});
