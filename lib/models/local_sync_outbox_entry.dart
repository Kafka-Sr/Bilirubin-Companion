class LocalSyncOutboxEntry {
  const LocalSyncOutboxEntry({
    required this.id,
    required this.table,
    required this.action,
    required this.entityId,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final String table;
  final String action;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'table': table,
        'action': action,
        'entityId': entityId,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LocalSyncOutboxEntry.fromJson(Map<String, dynamic> json) {
    return LocalSyncOutboxEntry(
      id: json['id'] as String,
      table: json['table'] as String,
      action: json['action'] as String,
      entityId: json['entityId'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}