import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/providers/sync_providers.dart';

final connectivitySyncProvider = Provider<void>((ref) {
  Connectivity().onConnectivityChanged.listen((results) {
    final hasNetwork = results.any((r) =>
        r == ConnectivityResult.wifi || r == ConnectivityResult.mobile);
    if (!hasNetwork) return;

    final notifier = ref.read(syncStatusProvider.notifier);
    final sync = ref.read(syncServiceProvider);
    notifier.set(SyncStatus.syncing);
    sync
        .drainOutbox()
        .then((_) => sync.pullChanges())
        .then((_) => notifier.set(SyncStatus.idle))
        .catchError((_) => notifier.set(SyncStatus.error));
  });
});
