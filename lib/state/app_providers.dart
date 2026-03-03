import 'package:bilirubin_companion/data/app_database.dart';
import 'package:bilirubin_companion/data/encryption_service.dart';
import 'package:bilirubin_companion/data/models.dart';
import 'package:bilirubin_companion/data/repositories/baby_repository.dart';
import 'package:bilirubin_companion/data/repositories/device_repository.dart';
import 'package:bilirubin_companion/data/repositories/export_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final refreshTokenProvider = StateProvider<int>((ref) => 0);
final selectedBabyIdProvider = StateProvider<String?>((ref) => null);

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.disposeDatabase);
  return db;
});

final encryptionProvider = Provider<EncryptionService>((ref) {
  return EncryptionService(const FlutterSecureStorage());
});

final babyRepositoryProvider = Provider<BabyRepository>((ref) {
  return BabyRepository(ref.watch(dbProvider), ref.watch(encryptionProvider));
});

final exportRepositoryProvider = Provider<ExportRepository>((ref) => ExportRepository());

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) => FakeDeviceRepository());

final babiesProvider = FutureProvider<List<BabyRecord>>((ref) async {
  ref.watch(refreshTokenProvider);
  final babies = await ref.watch(babyRepositoryProvider).listBabies();
  if (babies.isNotEmpty && ref.read(selectedBabyIdProvider) == null) {
    ref.read(selectedBabyIdProvider.notifier).state = babies.first.babyId;
  }
  return babies;
});

final selectedBabyProvider = Provider<BabyRecord?>((ref) {
  final list = ref.watch(babiesProvider).valueOrNull ?? [];
  final selectedId = ref.watch(selectedBabyIdProvider);
  final found = list.where((b) => b.babyId == selectedId);
  return found.isEmpty ? null : found.first;
});

final measurementsProvider = FutureProvider<List<MeasurementRecord>>((ref) async {
  ref.watch(refreshTokenProvider);
  final selected = ref.watch(selectedBabyProvider);
  if (selected == null) return [];
  return ref.watch(babyRepositoryProvider).listMeasurements(selected.babyId);
});
