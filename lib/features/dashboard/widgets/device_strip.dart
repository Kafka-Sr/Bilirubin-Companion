import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bilirubin/core/app_theme.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/device_info.dart';
import 'package:bilirubin/providers/device_providers.dart';
import 'package:bilirubin/providers/user_profile_provider.dart';

/// Strip showing logged-in user info + device connection status + Settings shortcut.
class DeviceStrip extends ConsumerWidget {
  const DeviceStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(connectionStateProvider);
    final infoAsync = ref.watch(deviceInfoProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final hospitalName = ref.watch(hospitalNameProvider).valueOrNull;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final connectionState = stateAsync.valueOrNull;
    final info = infoAsync.valueOrNull;

    final isConnected = connectionState == DeviceConnectionState.connected;
    final isConnecting = connectionState == DeviceConnectionState.connecting ||
        connectionState == DeviceConnectionState.scanning;

    final showUserInfo = profile != null && !profile.isParent;
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── User info row (staff only) ──────────────────────────────────
          if (showUserInfo) ...[
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  '${l10n.loggedInAs}: ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Expanded(
                  child: Text(
                    email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (hospitalName != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.local_hospital_outlined,
                      size: 14, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.hospitalLabel}: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      hospitalName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            Divider(
              height: 12,
              thickness: 0.5,
              color: theme.colorScheme.outlineVariant,
            ),
          ],

          // ── Connection row ──────────────────────────────────────────────
          Row(
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
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${info.displayName} (${_transportLabel(info.transport, l10n)})',
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : Text(
                        isConnecting
                            ? l10n.deviceConnecting
                            : l10n.deviceDisconnected,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              // Connect / disconnect toggle
              FilledButton(
                onPressed: () => _toggle(ref, isConnected),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: theme.textTheme.labelLarge,
                ),
                child: Text(
                    isConnected ? l10n.deviceDisconnect : l10n.deviceConnect),
              ),

              const SizedBox(width: 8),

              // Settings shortcut
              OutlinedButton(
                onPressed: () => context.go('/settings'),
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                  maximumSize: const Size(48, 48),
                ),
                child: const Icon(Icons.settings_outlined, size: 20),
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
 