import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:bilirubin/models/local_sync_outbox_entry.dart';

class LocalSyncOutbox {
  LocalSyncOutbox({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  Future<void> enqueue({
    required String table,
    required String action,
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    final entries = await readPending();
    entries.add(LocalSyncOutboxEntry(
      id: _uuid.v4(),
      table: table,
      action: action,
      entityId: entityId,
      payload: payload,
      createdAt: DateTime.now(),
    ));
    await _write(entries);
  }

  Future<List<LocalSyncOutboxEntry>> readPending() async {
    final file = await _file();
    if (!await file.exists()) return [];

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(LocalSyncOutboxEntry.fromJson)
        .toList();
  }

  Future<void> clear() async {
    final file = await _file();
    if (await file.exists()) {
      await file.writeAsString('[]');
    }
  }

  Future<void> _write(List<LocalSyncOutboxEntry> entries) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'sync_outbox.json'));
  }
}