import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_state.dart';
import 'bhutani.dart';
import 'models.dart';

void main() {
  runApp(const ProviderScope(child: BilirubinApp()));
}

class BilirubinApp extends ConsumerWidget {
  const BilirubinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    const seed = Color(0xFF2FA597);
    return MaterialApp(
      title: 'Bilirubin Companion PoC',
      debugShowCheckedModeBanner: false,
      themeMode: state.themeMode,
      theme: _buildTheme(Brightness.light, seed),
      darkTheme: _buildTheme(Brightness.dark, seed),
      home: const DashboardPage(),
    );
  }

  ThemeData _buildTheme(Brightness brightness, Color seed) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: isDark
          ? GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme)
          : GoogleFonts.plusJakartaSansTextTheme(),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.42),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.65)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return colorScheme.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.36);
          }
          return colorScheme.outlineVariant.withValues(alpha: 0.38);
        }),
      ),
      dividerColor: Colors.white.withValues(alpha: isDark ? 0.08 : 0.32),
    );
  }

}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final PageController _pageController = PageController();
  int _carouselIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final strings = LocalizedStrings(languageCode: state.localeCode);
    final notifier = ref.read(appStateProvider.notifier);
    final selectedBaby = state.selectedBaby;
    final measurements = state.measurementsForSelected();
    final latest = measurements.isEmpty ? null : measurements.last;
    final hasBabies = state.babies.isNotEmpty;

    return AppBackground(
      child: Scaffold(
        appBar: AppBar(title: Text(strings.t('dashboard'))),
        body: SafeArea(
          top: false,
          child: hasBabies
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _topRow(context, state),
                    const SizedBox(height: 12),
                    _deviceStrip(context, state),
                    const SizedBox(height: 16),
                    _imageCarousel(measurements),
                    const SizedBox(height: 16),
                    _latestCard(latest),
                    const SizedBox(height: 16),
                    _bhutaniCard(context, measurements, latest, state.showPrevious),
                    const SizedBox(height: 16),
                    _metadataCard(context, selectedBaby),
                    const SizedBox(height: 16),
                    _recommendationCard(latest),
                  ],
                )
              : Center(
                  child: GlassPanel(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.child_care,
                          size: 56,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        const Text('No babies yet'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: notifier.addBaby,
                          icon: const Icon(Icons.add),
                          label: Text(strings.t('addBaby')),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _topRow(BuildContext context, AppState state) {
    final strings = LocalizedStrings(languageCode: ref.read(appStateProvider).localeCode);
    final notifier = ref.read(appStateProvider.notifier);
    final selectedName = state.selectedBaby?.name ?? 'Select baby';
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _showBabyPicker(context, state),
            borderRadius: BorderRadius.circular(99),
            child: GlassPanel(
              radius: 999,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.child_friendly, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GlassIconButton(
          icon: Icons.more_horiz,
          onPressed: () async {
            final value = await showMenu<String>(
              context: context,
              position: const RelativeRect.fromLTRB(1000, 88, 16, 0),
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1B2031).withValues(alpha: 0.96)
                  : Colors.white.withValues(alpha: 0.94),
              items: [
                PopupMenuItem(value: 'scan', child: Text(strings.t('simulateScan'))),
                PopupMenuItem(value: 'add', child: Text(strings.t('addBaby'))),
                PopupMenuItem(value: 'delete', child: Text(strings.t('deleteBaby'))),
              ],
            );
            if (value == 'scan') notifier.simulateScan();
            if (value == 'add') notifier.addBaby();
            if (value == 'delete') notifier.deleteSelectedBaby();
          },
        ),
        const SizedBox(width: 8),
        GlassIconButton(
          icon: Icons.download,
          onPressed: () => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Export simulated'))),
        ),
      ],
    );
  }

  Widget _deviceStrip(BuildContext context, AppState state) {
    final strings = LocalizedStrings(languageCode: ref.read(appStateProvider).localeCode);
    final device = state.deviceState;
    final notifier = ref.read(appStateProvider.notifier);
    final connected = device.connected;
    return InkWell(
      onTap: notifier.toggleDevice,
      borderRadius: BorderRadius.circular(26),
      child: GlassPanel(
        radius: 26,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: connected ? Colors.greenAccent.shade400 : Colors.redAccent.shade200,
                boxShadow: [
                  BoxShadow(
                    color: (connected ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                connected
                    ? '${strings.t('connected')}: ${device.deviceId} (${device.transport})'
                    : strings.t('notConnected'),
              ),
            ),
            GlassPillButton(
              onPressed: () => _goSettings(context),
              icon: Icons.settings,
              label: strings.t('settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroMeasurementCard(List<Measurement> measurements, Measurement? latest) {
    if (measurements.isEmpty || latest == null) {
      return _placeholderCard('No measurements yet');
    }

    final imageCount = min(measurements.length, 5);
    final recent = measurements.reversed.take(imageCount).toList();
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          SizedBox(
            height: 168,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (value) => setState(() => _carouselIndex = value),
              itemCount: recent.length,
              itemBuilder: (context, index) {
                final m = recent[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.amber.shade100.withValues(alpha: 0.95),
                          Colors.orange.shade200.withValues(alpha: 0.88),
                        ],
                      ),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.22),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Image • ${m.bilirubinMgDl.toStringAsFixed(1)} mg/dL\nAge ${m.ageHours.toStringAsFixed(0)} h',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(recent.length, (index) {
              final active = index == _carouselIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: active ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _latestCard(Measurement? latest) {
    if (latest == null) {
      return _placeholderCard('No measurements yet');
    }
    return GlassPanel(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          '${latest.bilirubinMgDl.toStringAsFixed(1)} mg/dL',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Captured: ${latest.capturedAt}\nAge: ${latest.ageHours.toStringAsFixed(0)} hours',
        ),
        trailing: GlassBadge(label: '${latest.ageHours.toStringAsFixed(0)}h'),
      ),
    );
  }

  Widget _bhutaniCard(
    BuildContext context,
    List<Measurement> measurements,
    Measurement? latest,
    bool showPrevious,
  ) {
    final strings = LocalizedStrings(languageCode: ref.read(appStateProvider).localeCode);
    final notifier = ref.read(appStateProvider.notifier);
    final yMax = chartYMax(measurements.map((e) => e.bilirubinMgDl));
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bhutani Nomogram',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text(strings.t('showPrevious'))),
                GlassTogglePill(value: showPrevious, onChanged: notifier.toggleShowPrevious),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  height: 250,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.26),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark ? 0.08 : 0.4,
                      ),
                    ),
                  ),
                  child: CustomPaint(
                    painter: BhutaniPainter(
                      context: context,
                      measurements: measurements,
                      latest: latest,
                      showPrevious: showPrevious,
                      yMax: yMax,
                    ),
                    child: Container(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metadataCard(BuildContext context, Baby? baby) {
    if (baby == null) return _placeholderCard('Select a baby');
    final age = DateTime.now().difference(baby.dateOfBirth);
    final ageText = '${age.inHours} Jam';
    final dob =
        '${baby.dateOfBirth.day.toString().padLeft(2, '0')}-${baby.dateOfBirth.month.toString().padLeft(2, '0')}-${baby.dateOfBirth.year}';
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Metadata Bayi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              GlassIconButton(
                icon: Icons.edit,
                size: 42,
                onPressed: () => _editBaby(context, baby),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _metadataField(context, label: 'Nama', value: baby.name),
          const SizedBox(height: 10),
          _metadataField(context, label: 'Berat', value: '${baby.weightKg.toStringAsFixed(1)} Kg'),
          const SizedBox(height: 10),
          _metadataField(context, label: 'Umur', value: ageText),
          const SizedBox(height: 10),
          _metadataField(context, label: 'Tanggal Lahir', value: dob),
        ],
      ),
    );
  }

  Widget _metadataField(BuildContext context, {required String label, required String value}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            isDense: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.34),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _recommendationCard(Measurement? latest) {
    final strings = LocalizedStrings(languageCode: ref.read(appStateProvider).localeCode);
    String message;
    if (latest == null) {
      message = strings.t('noMeasurement');
    } else {
      final zone = classifyBhutani(ageHours: latest.ageHours, bilirubin: latest.bilirubinMgDl);
      message = switch (zone) {
        BhutaniZone.veryHigh =>
          'Very High Risk: Immediate physician review, confirmatory serum test, and urgent treatment planning.',
        BhutaniZone.high =>
          'High Risk: Repeat bilirubin soon, evaluate hydration/feeding, and consider phototherapy protocol.',
        BhutaniZone.highIntermediate =>
          'High Intermediate Risk: Follow-up within 24h and reinforce breastfeeding support.',
        BhutaniZone.intermediate =>
          'Intermediate Risk: Continue monitoring and routine reassessment.',
        BhutaniZone.low => 'Low Risk: Standard newborn follow-up and parental education.',
      };
    }

    return Column(
      children: [
        GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.medical_information, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                strings.t('recommendation'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GlassPanel(child: Text(message)),
      ],
    );
  }

  Widget _placeholderCard(String text) => GlassPanel(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: Text(text)),
        ),
      );

  Future<void> _showBabyPicker(BuildContext context, AppState state) async {
    final notifier = ref.read(appStateProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String query = '';
        final babies = state.babies;
        return Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final filtered = babies
                  .where((baby) => baby.name.toLowerCase().contains(query.toLowerCase()))
                  .toList();
              return GlassPanel(
                radius: 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search baby',
                      ),
                      onChanged: (value) => setModalState(() => query = value),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final baby = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GlassPanel(
                              radius: 20,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              child: ListTile(
                                title: Text(baby.name),
                                subtitle: Text('Weight ${baby.weightKg.toStringAsFixed(1)} kg'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  notifier.selectBaby(baby.babyId);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _editBaby(BuildContext context, Baby baby) async {
    final notifier = ref.read(appStateProvider.notifier);
    final nameController = TextEditingController(text: baby.name);
    final weightController = TextEditingController(text: baby.weightKg.toString());
    DateTime selectedDob = baby.dateOfBirth;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return GlassPanel(
                radius: 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Baby',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                    const SizedBox(height: 10),
                    TextField(
                      controller: weightController,
                      decoration: const InputDecoration(labelText: 'Weight (kg)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Text('DoB: ${selectedDob.toLocal().toString().split('.').first}')),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              initialDate: selectedDob,
                            );
                            if (picked != null) setModalState(() => selectedDob = picked);
                          },
                          child: const Text('Pick date'),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final weight = double.tryParse(weightController.text.trim());
                          if (name.isEmpty) {
                            _toast(context, 'Name is required');
                            return;
                          }
                          if (weight == null || weight < 0.8 || weight > 7.0) {
                            _toast(context, 'Weight must be between 0.8 and 7.0 kg');
                            return;
                          }
                          if (selectedDob.isAfter(DateTime.now())) {
                            _toast(context, 'DoB cannot be in the future');
                            return;
                          }
                          notifier.updateBaby(
                            baby.copyWith(name: name, weightKg: weight, dateOfBirth: selectedDob),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _goSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  void _toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);
    final strings = LocalizedStrings(languageCode: state.localeCode);
    return AppBackground(
      child: Scaffold(
        appBar: AppBar(title: Text(strings.t('settings'))),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(strings.t('wifi'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GlassPanel(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: state.deviceState.connected,
                    onChanged: (_) => notifier.toggleDevice(),
                  ),
                  const TextField(decoration: InputDecoration(labelText: 'SSID')),
                  const SizedBox(height: 10),
                  const TextField(decoration: InputDecoration(labelText: 'Password')),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(onPressed: () {}, child: const Text('Test Wi-Fi')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(strings.t('bluetooth'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GlassPanel(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: true,
                    onChanged: (_) {},
                    title: const Text('BLE enabled'),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(onPressed: () {}, child: const Text('Scan devices')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(strings.t('language'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GlassPanel(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Indonesian'),
                    selected: state.localeCode == 'id',
                    onSelected: (_) => notifier.setLocale('id'),
                  ),
                  ChoiceChip(
                    label: const Text('English'),
                    selected: state.localeCode == 'en',
                    onSelected: (_) => notifier.setLocale('en'),
                  ),
                  ChoiceChip(
                    label: const Text('German'),
                    selected: state.localeCode == 'de',
                    onSelected: (_) => notifier.setLocale('de'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(strings.t('theme'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GlassPanel(
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('System')),
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ],
                selected: {state.themeMode},
                onSelectionChanged: (set) => notifier.setThemeMode(set.first),
              ),
            ),
            const SizedBox(height: 16),
            GlassPanel(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: state.appLockEnabled,
                onChanged: notifier.setAppLock,
                title: Text(strings.t('appLock')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF0A1020) : const Color(0xFFF2F5FB);
    final overlay = isDark ? const Color(0xFF141C32) : const Color(0xFFEAF2FF);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, overlay],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -40,
            child: _GlowOrb(
              size: 220,
              color: isDark ? const Color(0xFF52D6C4) : const Color(0xFFBEE9E1),
            ),
          ),
          Positioned(
            top: 120,
            right: -40,
            child: _GlowOrb(
              size: 180,
              color: isDark ? const Color(0xFF6D7BFF) : const Color(0xFFD8DEFF),
            ),
          ),
          Positioned(
            bottom: -60,
            left: 30,
            child: _GlowOrb(
              size: 190,
              color: isDark ? const Color(0xFF143B58) : const Color(0xFFFFE2C2),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.42),
          ),
        ),
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 28,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.16),
                      Colors.white.withValues(alpha: 0.06),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.72),
                      Colors.white.withValues(alpha: 0.36),
                    ],
            ),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.66),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: GlassPanel(
        radius: size / 2,
        padding: EdgeInsets.zero,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: size * 0.42),
          splashRadius: size / 2,
        ),
      ),
    );
  }
}

class GlassBadge extends StatelessWidget {
  const GlassBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class BhutaniPainter extends CustomPainter {
  BhutaniPainter({
    required this.context,
    required this.measurements,
    required this.latest,
    required this.showPrevious,
    required this.yMax,
  });

  final BuildContext context;
  final List<Measurement> measurements;
  final Measurement? latest;
  final bool showPrevious;
  final double yMax;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 32.0;
    const bottom = 24.0;
    const top = 8.0;
    const right = 16.0;
    final chartRect = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    final colorScheme = Theme.of(context).colorScheme;

    double pxX(double x) =>
        chartRect.left + ((clampX(x) - 3.0) / (120.0 - 3.0)) * chartRect.width;
    double pxY(double y) => chartRect.bottom - ((y.clamp(0, yMax)) / yMax) * chartRect.height;

    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    for (final tick in xAnchors) {
      final x = pxX(tick);
      canvas.drawLine(Offset(x, chartRect.top), Offset(x, chartRect.bottom), gridPaint);
      final tp = _tp(tick.toInt().toString(), colorScheme.onSurfaceVariant);
      tp.paint(canvas, Offset(x - tp.width / 2, chartRect.bottom + 2));
    }

    for (double y = 0; y <= yMax; y += 4) {
      final py = pxY(y);
      canvas.drawLine(Offset(chartRect.left, py), Offset(chartRect.right, py), gridPaint);
      final tp = _tp(y.toInt().toString(), colorScheme.onSurfaceVariant);
      tp.paint(canvas, Offset(0, py - tp.height / 2));
    }

    final xs = List<double>.from(xAnchors);
    final zoneConfigs = [
      (lowUpperY, const Color(0xFFBBF7D0), 'Low Risk Zone'),
      (intermediateUpperY, const Color(0xFFECFCCB), 'Intermediate Risk Zone'),
      (highInterUpperY, const Color(0xFFFEF08A), 'High Intermediate Risk Zone'),
      (highUpperY, const Color(0xFFFECACA), 'High Risk Zone'),
      (List.filled(xAnchors.length, yMax), const Color(0xFFFCA5A5), 'Very High Risk Zone'),
    ];

    List<double> lower = List.filled(xAnchors.length, 0.0);
    for (final (upper, color, label) in zoneConfigs) {
      final path = Path()..moveTo(pxX(xs.first), pxY(lower.first));
      for (var i = 0; i < xs.length; i++) {
        path.lineTo(pxX(xs[i]), pxY(lower[i]));
      }
      for (var i = xs.length - 1; i >= 0; i--) {
        path.lineTo(pxX(xs[i]), pxY(min(upper[i], yMax)));
      }
      path.close();
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.45), color.withValues(alpha: 0.18)],
        ).createShader(chartRect);
      canvas.drawPath(path, paint);
      final yLabel = pxY(min(upper.last, yMax) - ((min(upper.last, yMax) - lower.last) / 2));
      _tp(label, colorScheme.onSurface.withValues(alpha: 0.76), 10)
          .paint(canvas, Offset(chartRect.right - 130, yLabel - 8));
      lower = List<double>.from(upper.map((v) => min(v, yMax)));
    }

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = colorScheme.outline.withValues(alpha: 0.6);

    for (final boundary in [lowUpperY, intermediateUpperY, highInterUpperY, highUpperY]) {
      final path = Path();
      for (var i = 0; i < xs.length; i++) {
        final p = Offset(pxX(xs[i]), pxY(boundary[i]));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, border);
    }

    if (showPrevious && measurements.length > 1) {
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = colorScheme.primary.withValues(alpha: 0.6);
      final path = Path();
      for (var i = 0; i < measurements.length; i++) {
        final p = measurements[i];
        final point = Offset(pxX(p.ageHours), pxY(p.bilirubinMgDl));
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, line);
      for (final p in measurements) {
        canvas.drawCircle(
          Offset(pxX(p.ageHours), pxY(p.bilirubinMgDl)),
          3,
          Paint()..color = colorScheme.primary.withValues(alpha: 0.8),
        );
      }
    }

    if (latest != null) {
      final latestPoint = Offset(pxX(latest!.ageHours), pxY(latest!.bilirubinMgDl));
      final dashPaint = Paint()
        ..color = colorScheme.error.withValues(alpha: 0.5)
        ..strokeWidth = 1.2;
      for (double y = chartRect.top; y < chartRect.bottom; y += 7) {
        canvas.drawLine(Offset(latestPoint.dx, y), Offset(latestPoint.dx, y + 4), dashPaint);
      }
      canvas.drawCircle(latestPoint, 7, Paint()..color = colorScheme.error);
      canvas.drawCircle(latestPoint, 3, Paint()..color = colorScheme.onError);
    }
  }

  TextPainter _tp(String text, Color color, [double size = 11]) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 140);
    return tp;
  }

  @override
  bool shouldRepaint(covariant BhutaniPainter oldDelegate) {
    return oldDelegate.measurements != measurements ||
        oldDelegate.latest != latest ||
        oldDelegate.showPrevious != showPrevious ||
        oldDelegate.yMax != yMax;
  }
}
