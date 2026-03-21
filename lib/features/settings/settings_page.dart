import 'package:bilirubin/app/providers.dart';
import 'package:bilirubin/models/app_enums.dart';
import 'package:bilirubin/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wi-Fi configurations', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: settings.wifiConfiguration),
                  onSubmitted: ref.read(appSettingsProvider.notifier).setWifiConfiguration,
                  decoration: const InputDecoration(
                    labelText: 'Preferred Wi-Fi profile',
                    suffixIcon: Icon(Icons.wifi_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bluetooth configurations', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: settings.bluetoothConfiguration),
                  onSubmitted: ref.read(appSettingsProvider.notifier).setBluetoothConfiguration,
                  decoration: const InputDecoration(
                    labelText: 'Preferred BLE profile',
                    suffixIcon: Icon(Icons.bluetooth_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Language options', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final language in AppLanguage.values)
                      ChoiceChip(
                        label: Text(language.label),
                        selected: settings.language == language,
                        onSelected: (_) => ref.read(appSettingsProvider.notifier).setLanguage(language),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme toggle', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (selection) =>
                      ref.read(appSettingsProvider.notifier).setThemeMode(selection.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('App lock'),
              subtitle: const Text('Stub setting for future secure access flows.'),
              value: settings.appLockEnabled,
              onChanged: ref.read(appSettingsProvider.notifier).setAppLock,
            ),
          ),
        ],
      ),
    );
  }
}
