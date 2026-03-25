import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/features/shared/pin_lock_screen.dart';
import 'package:bilirubin/providers/settings_providers.dart';
import 'package:bilirubin/security/app_lock_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: const [
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
        SegmentedButton<String>(
          selected: {locale.languageCode},
          onSelectionChanged: (s) =>
              ref.read(appLocaleProvider.notifier).set(Locale(s.first)),
          segments: [
            ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
            ButtonSegment(value: 'id', label: Text(l10n.languageIndonesian)),
            ButtonSegment(value: 'de', label: Text(l10n.languageGerman)),
          ],
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
        SegmentedButton<ThemeMode>(
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
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsAppLock),
          subtitle: Text(l10n.settingsAppLockSubtitle),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon,
                      color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
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
