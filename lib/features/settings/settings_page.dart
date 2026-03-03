import 'package:bilirubin_companion/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Section(title: 'Wi-Fi configurations', child: Text('Stub: saved SSIDs and quick connect presets.')),
          const _Section(title: 'Bluetooth configurations', child: Text('Stub: paired BLE peripherals and scanning options.')),
          _Section(
            title: 'Language options',
            child: Wrap(
              spacing: 8,
              children: const [Chip(label: Text('Indonesian')), Chip(label: Text('English')), Chip(label: Text('German'))],
            ),
          ),
          _Section(
            title: 'Theme mode',
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {mode},
              onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).state = s.first,
            ),
          ),
          const _Section(
            title: 'App lock',
            child: SwitchListTile.adaptive(value: false, onChanged: null, title: Text('Enable app lock (coming soon)')),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), child]),
      ),
    );
  }
}
