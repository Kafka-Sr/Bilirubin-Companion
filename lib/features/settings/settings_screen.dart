import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/models/pi_beacon.dart';
import 'package:bilirubin/features/shared/pin_lock_screen.dart';
import 'package:bilirubin/providers/pi_discovery_providers.dart';
import 'package:bilirubin/providers/settings_providers.dart';
import 'package:bilirubin/security/app_lock_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: const [
          _PiLanSection(),
          _WifiSection(),
          _BleSection(),
          _LanguageSection(),
          _ThemeSection(),
          _AppLockSection(),
        ],
      ),
    );
  }
}

// ── Raspberry Pi LAN ─────────────────────────────────────────────────────────

class _PiLanSection extends ConsumerStatefulWidget {
  const _PiLanSection();

  @override
  ConsumerState<_PiLanSection> createState() => _PiLanSectionState();
}

class _PiLanSectionState extends ConsumerState<_PiLanSection> {
  late final TextEditingController _baseUrlCtrl;

  @override
  void initState() {
    super.initState();
    _baseUrlCtrl = TextEditingController(text: ref.read(piBaseUrlProvider));
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final beaconsAsync = ref.watch(piBeaconListProvider);
    final beacons = beaconsAsync.valueOrNull ?? const <PiBeacon>[];

    return _Section(
      title: 'Raspberry Pi LAN',
      icon: Icons.router_outlined,
      children: [
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
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Pi address or URL',
            hintText: '192.168.1.50:8080 or http://raspi.local:8080',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Pi address'),
              onPressed: () {
                ref.read(piBaseUrlProvider.notifier).set(_baseUrlCtrl.text);
              },
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () {
                _baseUrlCtrl.clear();
                ref.read(piBaseUrlProvider.notifier).clear();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'If the phone and Pi are on the same Wi-Fi network, the app can discover the Pi automatically by beacon. Supabase still stores the synced history.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
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
              child: const Text('Use'),
            ),
          ),
      ],
    );
  }
}

// ── Wi-Fi ─────────────────────────────────────────────────────────────────────

class _WifiSection extends StatefulWidget {
  const _WifiSection();

  @override
  State<_WifiSection> createState() => _WifiSectionState();
}

class _WifiSectionState extends State<_WifiSection> {
  final _ssidCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _ssidCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Section(
      title: l10n.settingsWifi,
      icon: Icons.wifi,
      children: [
        TextField(
          controller: _ssidCtrl,
          decoration: InputDecoration(labelText: l10n.settingsWifiSsid),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passCtrl,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: l10n.settingsWifiPassword,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
      ],
    );
  }
}

// ── BLE ───────────────────────────────────────────────────────────────────────

class _BleSection extends StatelessWidget {
  const _BleSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Section(
      title: l10n.settingsBle,
      icon: Icons.bluetooth,
      children: [
        Text(
          l10n.settingsBleNotAvailable,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }
}

// ── Language ──────────────────────────────────────────────────────────────────

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

// ── Theme ─────────────────────────────────────────────────────────────────────

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

// ── App lock ──────────────────────────────────────────────────────────────────

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

// ── Shared section wrapper ────────────────────────────────────────────────────

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
