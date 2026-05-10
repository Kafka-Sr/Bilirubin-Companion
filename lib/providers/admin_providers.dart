import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bilirubin/providers/user_profile_provider.dart';

// ── Staff list ────────────────────────────────────────────────────────────────

class StaffMember {
  const StaffMember({
    required this.userId,
    required this.role,
    required this.email,
    required this.hospitalId,
  });

  final String userId;
  final UserRole role;
  final String email;
  final String hospitalId;

  factory StaffMember.fromMap(Map<String, dynamic> m) => StaffMember(
        userId: m['user_id'] as String,
        role: parseUserRole(m['role'] as String? ?? ''),
        email: m['email'] as String? ?? '(no email)',
        hospitalId: m['hospital_id'] as String,
      );
}

final staffListProvider = FutureProvider.autoDispose<List<StaffMember>>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null || !profile.isAdmin) return [];

  final rows = await Supabase.instance.client
      .from('user_profiles')
      .select()
      .eq('hospital_id', profile.hospitalId!)
      .inFilter('role', ['admin', 'staff', 'nurse'])
      .order('role')
      .order('email');

  return (rows as List).map((m) => StaffMember.fromMap(m)).toList();
});

// ── Transfer requests ─────────────────────────────────────────────────────────

class TransferRequest {
  const TransferRequest({
    required this.id,
    required this.babyName,
    required this.fromHospitalId,
    required this.fromHospitalName,
    required this.toHospitalId,
    required this.toHospitalName,
    required this.status,
    required this.initiatedAt,
  });

  final String id;
  final String babyName;
  final String fromHospitalId;
  final String fromHospitalName;
  final String toHospitalId;
  final String toHospitalName;
  final String status;
  final DateTime initiatedAt;

  bool get isPending => status == 'pending';

  factory TransferRequest.fromMap(Map<String, dynamic> m) => TransferRequest(
        id: m['id'] as String,
        babyName: m['baby_name'] as String? ?? '—',
        fromHospitalId: m['from_hospital_id'] as String,
        fromHospitalName:
            (m['from_hospital'] as Map?)?['name'] as String? ?? '—',
        toHospitalId: m['to_hospital_id'] as String,
        toHospitalName:
            (m['to_hospital'] as Map?)?['name'] as String? ?? '—',
        status: m['status'] as String,
        initiatedAt: DateTime.parse(m['initiated_at'] as String),
      );
}

final transfersProvider =
    FutureProvider.autoDispose<List<TransferRequest>>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null || !profile.isAdmin) return [];

  final rows = await Supabase.instance.client
      .from('transfer_requests')
      .select('''
        *,
        from_hospital:hospitals!from_hospital_id(name),
        to_hospital:hospitals!to_hospital_id(name)
      ''')
      .or('from_hospital_id.eq.${profile.hospitalId},to_hospital_id.eq.${profile.hospitalId}')
      .order('initiated_at', ascending: false);

  return (rows as List).map((m) => TransferRequest.fromMap(m)).toList();
});
