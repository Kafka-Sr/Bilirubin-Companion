import 'package:supabase_flutter/supabase_flutter.dart';

class CloudSyncRepository {
  CloudSyncRepository(this._client);

  final SupabaseClient? _client;

  bool get isEnabled => _client != null;

  SupabaseClient get _requiredClient {
    final client = _client;
    if (client == null) {
      throw StateError(
        'Supabase is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
    return client;
  }

  Future<List<Map<String, dynamic>>> fetchRows({
    required String table,
    String orderBy = 'updated_at',
    DateTime? updatedAfter,
    int limit = 500,
  }) async {
    var query = _requiredClient.from(table).select();

    if (updatedAfter != null) {
      query = query.gt(orderBy, updatedAfter.toIso8601String());
    }

    final rows = await query.order(orderBy).limit(limit);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<void> upsertRows({
    required String table,
    required List<Map<String, dynamic>> rows,
    String onConflict = 'id',
  }) async {
    if (rows.isEmpty) return;

    await _requiredClient.from(table).upsert(
          rows,
          onConflict: onConflict,
        );
  }

  Future<void> deleteRow({
    required String table,
    required String column,
    required Object value,
  }) async {
    await _requiredClient.from(table).delete().eq(column, value);
  }

  /// Fetches measurements from Supabase for a specific baby.
  ///
  /// Only returns rows that have a [babyLocalId] assigned (i.e. the app has
  /// previously associated them with a baby). Optionally filters to records
  /// captured after [capturedAfter] to limit payload size.
  Future<List<Map<String, dynamic>>> fetchMeasurements({
    required String hospitalId,
    required int babyLocalId,
    DateTime? capturedAfter,
  }) async {
    var query = _requiredClient
        .from('measurements')
        .select()
        .eq('hospital_id', hospitalId)
        .eq('baby_local_id', babyLocalId);

    if (capturedAfter != null) {
      query = query.gt('captured_at', capturedAfter.toIso8601String());
    }

    final rows = await query.order('captured_at');
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<void> deleteWhere({
    required String table,
    required Map<String, Object> filters,
  }) async {
    var q = _requiredClient.from(table).delete();
    for (final entry in filters.entries) {
      q = q.eq(entry.key, entry.value);
    }
    await q;
  }
}
