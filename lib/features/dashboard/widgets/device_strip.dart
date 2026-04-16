import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bilirubin/core/app_theme.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';
import 'package:bilirubin/providers/device_providers.dart';

/// Thin strip showing device connection status + a shortcut to Settings.
class DeviceStrip extends ConsumerWidget {
  const DeviceStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(connectionStateProvider);
    final infoAsync = ref.watch(deviceInfoProvider);
    final l10n = AppLocalizations.of(context);

    final connectionState = stateAsync.valueOrNull;
    final info = infoAsync.valueOrNull;

    final isConnected = connectionState == DeviceConnectionState.connected;
    final isConnecting = connectionState == DeviceConnectionState.connecting ||
        connectionState == DeviceConnectionState.scanning;

    return InkWell(
      onTap: () => _toggle(ref, isConnected),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
        children: [
          // Status dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected
                  ? AppColors.connected
                  : isConnecting
                      ? Colors.amber
                      : AppColors.disconnected,
            ),
          ),
          const SizedBox(width: 8),

          // Status text
          Expanded(
            child: isConnected && info != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.deviceConnectedLabel,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${info.displayName} (${_transportLabel(info.transport, l10n)})',
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                : Text(
                    isConnecting ? l10n.deviceConnecting : l10n.deviceDisconnected,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
          ),

          // Connect / disconnect toggle
          TextButton(
            onPressed: () => _toggle(ref, isConnected),
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: Text(isConnected ? l10n.deviceDisconnect : l10n.deviceConnect),
          ),

          const SizedBox(width: 8),

          // Settings shortcut
          FilledButton.tonal(
            onPressed: () => context.go('/settings'),
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 48),
              maximumSize: const Size(48, 48),
            ),
            child: const Icon(Icons.settings_outlined, size: 20),
          ),
        ],
        ),
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

  String _transportLabel(DeviceTransport transport, AppLocalizations l10n) {
    switch (transport) {
      case DeviceTransport.wifi:
        return l10n.deviceTransportWifi;
      case DeviceTransport.ble:
        return l10n.deviceTransportBle;
      case DeviceTransport.fake:
        return l10n.deviceTransportFake;
    }
  }
}
 