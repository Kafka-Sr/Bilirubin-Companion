import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/database/database.dart';

/// Singleton [AppDatabase] instance kept alive for the lifetime of the app.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
