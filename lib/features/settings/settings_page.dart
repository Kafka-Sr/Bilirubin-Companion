import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/glass.dart';
import '../../core/helpers.dart';
import '../../models/models.dart';
import '../../state/providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _wifiSsidController;
  late final TextEditingController _wifiPasswordController;
  late final TextEditingController _bluetoothNameController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsControllerProvider);
    _wifiSsidController = TextEditingController(text: settings.wifiSsid);
    _wifiPasswordController = TextEditingController(
      text: settings.wifiPassword,
    );
    _bluetoothNameController = TextEditingController(
      text: settings.bluetoothName,
    );

    _wifiSsidController.addListener(() {
      ref
          .read(settingsControllerProvider.notifier)
          .setWifiSsid(_wifiSsidController.text.trim());
    });
    _wifiPasswordController.addListener(() {
      ref
          .read(settingsControllerProvider.notifier)
          .setWifiPassword(_wifiPasswordController.text);
    });
    _bluetoothNameController.addListener(() {
      ref
          .read(settingsControllerProvider.notifier)
          .setBluetoothName(_bluetoothNameController.text.trim());
    });
  }

  @override
  void dispose() {
    _wifiSsidController.dispose();
    _wifiPasswordController.dispose();
    _bluetoothNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final device = ref.watch(deviceControllerProvider);
    final glass = glassThemeOf(context);
    final theme = Theme.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Settings')),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Companion configuration',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Frontend-only mock settings for Wi-Fi, Bluetooth, language, theme, and local device protection.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: glass.mutedText,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                            color: device.isConnected
                                ? const Color(0xFF2DBE67)
                                : const Color(0xFFE45757),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            device.isConnected
                                ? 'Connected to ${device.id} (${device.transport?.label ?? 'BLE'})'
                                : 'Device not connected',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wi-Fi configurations',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _wifiSsidController,
                      decoration: const InputDecoration(
                        labelText: 'SSID',
                        hintText: 'NICU network name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _wifiPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Passphrase',
                        hintText: 'Local secure passphrase',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.62),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: glass.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.wifi_tethering,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Preferred network for bedside sync and metadata transfer. Stored in memory only.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: glass.mutedText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bluetooth configurations',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _bluetoothNameController,
                      decoration: const InputDecoration(
                        labelText: 'Preferred device label',
                        hintText: 'Biligun Floor A',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      value: settings.bluetoothAutoReconnect,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto reconnect'),
                      subtitle: Text(
                        'Reconnect to the last known handheld device when available.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: glass.mutedText,
                        ),
                      ),
                      onChanged: (value) {
                        ref
                            .read(settingsControllerProvider.notifier)
                            .setBluetoothAutoReconnect(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Language', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: AppLanguage.values.map((language) {
                        final isSelected = settings.language == language;
                        return ChoiceChip(
                          label: Text(language.label),
                          selected: isSelected,
                          onSelected: (_) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .setLanguage(language);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Text('Theme mode', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: ThemeMode.values.map((mode) {
                        final isSelected = settings.themeMode == mode;
                        return ChoiceChip(
                          label: Text(mode.label),
                          selected: isSelected,
                          onSelected: (_) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .setThemeMode(mode);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('App lock', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 10),
                    SwitchListTile.adaptive(
                      value: settings.appLockEnabled,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable app lock'),
                      subtitle: Text(
                        'Mock toggle only. No platform secure storage or OS lock hooks are active.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: glass.mutedText,
                        ),
                      ),
                      onChanged: (value) {
                        ref
                            .read(settingsControllerProvider.notifier)
                            .setAppLock(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Current language: ${settings.language.label}. Current theme: ${settings.themeMode.label}. Last updated locally at ${formatTimestamp(DateTime.now())}.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
