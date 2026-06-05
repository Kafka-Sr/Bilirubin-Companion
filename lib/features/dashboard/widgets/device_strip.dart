import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/app_theme.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/features/shared/marquee_text.dart';
import 'package:bilirubin/features/shared/pairing_status_icon.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';
import 'package:bilirubin/models/pi_beacon.dart';
import 'package:bilirubin/providers/device_providers.dart';
import 'package:bilirubin/providers/pi_discovery_providers.dart';
import 'package:bilirubin/providers/settings_providers.dart';
import 'package:bilirubin/providers/supabase_providers.dart';
import 'package:bilirubin/providers/auth_providers.dart';
import 'package:bilirubin/providers/sync_providers.dart';

class DeviceStrip extends ConsumerWidget {
  const DeviceStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionStateProvider).valueOrNull;
    final info = ref.watch(deviceInfoProvider).valueOrNull;
    final syncStatus = ref.watch(syncStatusProvider);
    final client = ref.watch(supabaseClientProvider);
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final isConnected = connectionState == DeviceConnectionState.connected;
    final isConnecting = connectionState == DeviceConnectionState.connecting ||
        connectionState == DeviceConnectionState.scanning;
    final isSyncing = syncStatus == SyncStatus.syncing;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Gun connection status
          Row(
            children: [
              PairingStatusIcon(state: _pairingState(connectionState), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: MarqueeText(
                  text: _deviceText(connectionState, info, l10n),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Row 2: Cloud / Supabase status
          Row(
            children: [
              Icon(
                Icons.cloud_sync_rounded,
                size: 20,
                color: _cloudColor(client, syncStatus, cs),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _cloudText(client, syncStatus, l10n),
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Row 3: Action buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      isConnecting ? null : () => _toggle(ref, isConnected),
                  icon: Icon(
                    isConnected
                        ? Icons.link_off_rounded
                        : isConnecting
                            ? Icons.sync_rounded
                            : Icons.link_rounded,
                    size: 16,
                  ),
                  label: Text(
                    isConnected
                        ? l10n.deviceUnpair
                        : isConnecting
                            ? l10n.deviceConnecting
                            : l10n.deviceConnect,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: isSyncing ? null : () async {
                    final notifier = ref.read(syncStatusProvider.notifier);
                    final syncService = ref.read(syncServiceProvider);
                    final hospitalId =
                        ref.read(userProfileProvider).valueOrNull?.hospitalId;
                    notifier.set(SyncStatus.syncing);
                    try {
                      if (hospitalId != null && hospitalId.isNotEmpty) {
                        await syncService.repairBabySync(hospitalId);
                      }
                      await syncService.drainOutbox();
                      await syncService.pullChanges();
                      notifier.set(SyncStatus.idle);
                    } catch (_) {
                      notifier.set(SyncStatus.error);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sync, size: 16),
                      const SizedBox(width: 8),
                      Text(isSyncing ? l10n.syncButtonSyncing : l10n.syncButton),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggle(WidgetRef ref, bool isConnected) {
    if (isConnected) {
      ref.read(deviceRepositoryProvider).disconnect();
      return;
    }

    final manualPiUrl = ref.read(piBaseUrlProvider).trim();
    if (manualPiUrl.isEmpty) {
      final discovered = ref.read(piBeaconListProvider).valueOrNull ?? const <PiBeacon>[];
      if (discovered.isNotEmpty) {
        ref.read(piBaseUrlProvider.notifier).set(discovered.first.baseUrl);
        return;
      }
    }

    ref.read(deviceRepositoryProvider).connect();
  }

  PairingState _pairingState(DeviceConnectionState? state) {
    if (state == DeviceConnectionState.connected) { return PairingState.paired; }
    if (state == DeviceConnectionState.connecting ||
        state == DeviceConnectionState.scanning) { return PairingState.pairing; }
    if (state == DeviceConnectionState.error) { return PairingState.error; }
    return PairingState.notPaired;
  }

  String _deviceText(
      DeviceConnectionState? state, DeviceInfo? info, AppLocalizations l10n) {
    if (state == DeviceConnectionState.connected && info != null) {
      return l10n.deviceConnectedTo(info.displayName);
    }
    if (state == DeviceConnectionState.connecting ||
        state == DeviceConnectionState.scanning) {
      return l10n.deviceConnecting;
    }
    if (state == DeviceConnectionState.error) {
      return l10n.deviceConnectionError;
    }
    return l10n.deviceDisconnected;
  }

  Color _cloudColor(dynamic client, SyncStatus status, ColorScheme cs) {
    if (client == null) { return cs.error; }
    if (status == SyncStatus.syncing) { return Colors.amber; }
    if (status == SyncStatus.error) { return cs.error; }
    return AppColors.connected;
  }

  String _cloudText(dynamic client, SyncStatus status, AppLocalizations l10n) {
    if (client == null) { return l10n.cloudNotConfigured; }
    if (status == SyncStatus.syncing) { return l10n.cloudSyncing; }
    if (status == SyncStatus.error) { return l10n.cloudSyncError; }
    return l10n.cloudSynced;
  }
}

