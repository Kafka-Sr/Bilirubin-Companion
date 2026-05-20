import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bilirubin/core/app_theme.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';
import 'package:bilirubin/providers/device_providers.dart';
import 'package:bilirubin/providers/supabase_providers.dart';
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
              Icon(
                _deviceIcon(connectionState, info),
                size: 20,
                color: _deviceColor(connectionState, cs),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _deviceText(connectionState, info, l10n),
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
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
                  style: Theme.of(context).textTheme.bodyMedium,
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
                  onPressed: () => _toggle(ref, isConnected),
                  icon: Icon(
                    isConnected ? Icons.link_off_rounded : Icons.link_rounded,
                    size: 16,
                  ),
                  label: Text(
                      isConnected ? l10n.deviceDisconnect : l10n.deviceConnect),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => context.go('/settings'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.settings_outlined, size: 16),
                      const SizedBox(width: 8),
                      Text(l10n.settingsTitle),
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
    final repo = ref.read(deviceRepositoryProvider);
    if (isConnected) {
      repo.disconnect();
    } else {
      repo.connect();
    }
  }

  IconData _deviceIcon(DeviceConnectionState? state, DeviceInfo? info) {
    if (state == DeviceConnectionState.connected && info != null) {
      switch (info.transport) {
        case DeviceTransport.wifi:
          return Icons.router_outlined;
        case DeviceTransport.ble:
          return Icons.bluetooth;
      }
    }
    return Icons.signal_wifi_off_rounded;
  }

  Color _deviceColor(DeviceConnectionState? state, ColorScheme cs) {
    if (state == DeviceConnectionState.connected) return AppColors.connected;
    if (state == DeviceConnectionState.connecting ||
        state == DeviceConnectionState.scanning) {
      return Colors.amber;
    }
    return cs.error;
  }

  String _deviceText(
      DeviceConnectionState? state, DeviceInfo? info, AppLocalizations l10n) {
    if (state == DeviceConnectionState.connected && info != null) {
      final transport = info.transport == DeviceTransport.wifi
          ? l10n.deviceTransportWifi
          : l10n.deviceTransportBle;
      return '${info.displayName} · $transport';
    }
    if (state == DeviceConnectionState.connecting ||
        state == DeviceConnectionState.scanning) {
      return l10n.deviceConnecting;
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
