import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/features/shared/pairing_status_icon.dart';
import 'package:bilirubin/models/device_connection_state.dart';
import 'package:bilirubin/models/pi_beacon.dart';
import 'package:bilirubin/features/shared/pin_lock_screen.dart';
import 'package:bilirubin/providers/auth_providers.dart';
import 'package:bilirubin/providers/device_providers.dart';
import 'package:bilirubin/providers/pi_discovery_providers.dart';
import 'package:bilirubin/providers/settings_providers.dart';
import 'package:bilirubin/providers/supabase_providers.dart';
import 'package:bilirubin/security/app_lock_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isStaffOrAdmin = ref.watch(isStaffOrAdminProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _AccountSection(),
          if (isStaffOrAdmin) const _HotspotSection(),
          const _LanguageSection(),
          const _ThemeSection(),
          if (isStaffOrAdmin) const _AppLockSection(),
        ],
      ),
    );
  }
}

// Account

class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final user = ref.watch(supabaseUserProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return _Section(
      title: l10n.settingsAccountTitle,
      icon: Icons.account_circle_outlined,
      children: [
        profileAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => Text(l10n.couldNotLoadProfile),
          data: (profile) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile?.fullName ?? user?.email ?? '—',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    (profile?.role ?? 'unknown').toUpperCase(),
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: cs.onPrimaryContainer),
                  ),
                ),
              ]),
              if (user?.email != null) ...[
                const SizedBox(height: 4),
                Text(user!.email!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.outline)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout, size: 18),
          label: Text(l10n.signOutLabel),
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.error,
            side: BorderSide(color: cs.error),
          ),
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            // Router redirect will send to /login automatically.
          },
        ),
      ],
    );
  }
}

// Hotspot Connection

class _HotspotSection extends ConsumerStatefulWidget {
  const _HotspotSection();

  @override
  ConsumerState<_HotspotSection> createState() => _HotspotSectionState();
}

class _HotspotSectionState extends ConsumerState<_HotspotSection> {
  late final TextEditingController _baseUrlCtrl;
  late final FocusNode _urlFocus;

  @override
  void initState() {
    super.initState();
    final stored = ref.read(piBaseUrlProvider);
    _baseUrlCtrl = TextEditingController(
      text: stored.replaceFirst(RegExp(r'^https?://'), ''),
    );
    _urlFocus = FocusNode();
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _urlFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ref.listen<String>(piBaseUrlProvider, (_, next) {
      final stripped = next.replaceFirst(RegExp(r'^https?://'), '');
      if (_baseUrlCtrl.text != stripped) {
        _baseUrlCtrl.text = stripped;
      }
    });

    final beaconsAsync = ref.watch(piBeaconListProvider);
    final beacons = beaconsAsync.valueOrNull ?? const <PiBeacon>[];

    return _Section(
      title: l10n.settingsHotspotTitle,
      icon: Icons.router_outlined,
      children: [
        Text(
          l10n.settingsHotspotInstructions,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 12),
        if (beacons.isNotEmpty) ...[
          _BeaconList(
            beacons: beacons,
            onUseBeacon: (beacon) {
              _baseUrlCtrl.text = beacon.baseUrl;
              ref.read(piBaseUrlProvider.notifier).set(beacon.baseUrl);
            },
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _baseUrlCtrl,
          focusNode: _urlFocus,
          keyboardType: TextInputType.url,
          onTap: () {
            if (_urlFocus.hasFocus && _baseUrlCtrl.text.isEmpty) {
              final hint = l10n.settingsPiAddressHint;
              _baseUrlCtrl.text = hint;
              _baseUrlCtrl.selection = TextSelection.collapsed(
                offset: hint.length,
              );
            }
          },
          decoration: InputDecoration(
            labelText: l10n.settingsPiAddressLabel,
            hintText: l10n.settingsPiAddressHint,
            prefixText: 'http://',
            suffixIcon: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(connectionStateProvider).valueOrNull;
                final PairingState ps;
                if (state == DeviceConnectionState.connected) {
                  ps = PairingState.paired;
                } else if (state == DeviceConnectionState.connecting ||
                    state == DeviceConnectionState.scanning) {
                  ps = PairingState.pairing;
                } else if (state == DeviceConnectionState.error) {
                  ps = PairingState.error;
                } else {
                  ps = PairingState.notPaired;
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PairingStatusIcon(state: ps),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.link_rounded),
              label: Text(l10n.settingsPiSave),
              onPressed: () {
                final host = _baseUrlCtrl.text.trim().isEmpty
                    ? l10n.settingsPiAddressHint
                    : _baseUrlCtrl.text.trim();
                ref.read(piBaseUrlProvider.notifier).set('http://$host');
                Future.microtask(
                    () => ref.read(deviceRepositoryProvider).connect());
              },
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () {
                _baseUrlCtrl.clear();
                ref.read(deviceRepositoryProvider).disconnect();
                ref.read(piBaseUrlProvider.notifier).clear();
              },
              child: Text(l10n.settingsPiClear),
            ),
          ],
        ),
      ],
    );
  }
}

class _BeaconList extends StatelessWidget {
  const _BeaconList({
    required this.beacons,
    required this.onUseBeacon,
  });

  final List<PiBeacon> beacons;
  final ValueChanged<PiBeacon> onUseBeacon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        for (final beacon in beacons)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.radar_outlined),
            title: Text(beacon.displayName),
            subtitle: Text('${beacon.baseUrl} • ${beacon.deviceId}'),
            trailing: TextButton(
              onPressed: () => onUseBeacon(beacon),
              child: Text(l10n.settingsPiBeaconUse),
            ),
          ),
      ],
    );
  }
}

// Language

class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(appLocaleProvider);

    return _Section(
      title: l10n.settingsLanguage,
      icon: Icons.language,
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            selected: {locale.languageCode},
            onSelectionChanged: (s) =>
                ref.read(appLocaleProvider.notifier).set(Locale(s.first)),
            segments: [
              ButtonSegment(
                value: 'en',
                icon: const Text('🇬🇧'),
                label: Text(l10n.languageEnglish),
              ),
              ButtonSegment(
                value: 'id',
                icon: const Text('🇮🇩'),
                label: Text(l10n.languageIndonesian),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Theme

class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(appThemeModeProvider);

    return _Section(
      title: l10n.settingsTheme,
      icon: Icons.palette_outlined,
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            selected: {mode},
            onSelectionChanged: (s) =>
                ref.read(appThemeModeProvider.notifier).set(s.first),
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(l10n.settingsThemeSystem),
                icon: const Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(l10n.settingsThemeLight),
                icon: const Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(l10n.settingsThemeDark),
                icon: const Icon(Icons.dark_mode),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// App lock

class _AppLockSection extends ConsumerWidget {
  const _AppLockSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final enabled = ref.watch(appLockEnabledProvider);
    final lockService = AppLockService();

    return _Section(
      title: l10n.settingsAppLock,
      icon: Icons.lock_outline,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsAppLock),
          subtitle: Text(l10n.settingsAppLockSubtitle),
          trailing: Transform.scale(
            scale: 0.75,
            alignment: Alignment.centerRight,
            child: Switch(
              value: enabled,
              onChanged: (v) async {
                if (v) {
                  final set = await showSetPinSheet(context);
                  if (set) {
                    ref.read(appLockEnabledProvider.notifier).state = true;
                  }
                } else {
                  await lockService.disableLock();
                  ref.read(appLockEnabledProvider.notifier).state = false;
                }
              },
            ),
          ),
        )
      ],
    );
  }
}

// Shared section wrapper

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
