import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return MaterialApp(
      title: 'Bilirubin Companion PoC',
      debugShowCheckedModeBanner: false,
      themeMode: state.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2FA597)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2FA597),
          brightness: Brightness.dark,
        ),
      ),
      home: const DashboardPage(),
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

    return Scaffold(
      appBar: AppBar(title: Text(strings.t('dashboard'))),
      body: hasBabies
          ? ListView(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.child_care, size: 56),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Row(
                children: [
                  const Icon(Icons.child_friendly),
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
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'scan') notifier.simulateScan();
            if (value == 'add') notifier.addBaby();
            if (value == 'delete') notifier.deleteSelectedBaby();
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'scan', child: Text(strings.t('simulateScan'))),
            PopupMenuItem(value: 'add', child: Text(strings.t('addBaby'))),
            PopupMenuItem(value: 'delete', child: Text(strings.t('deleteBaby'))),
          ],
        ),
        IconButton(
          onPressed: () => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Export simulated'))),
          icon: const Icon(Icons.download),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: connected ? Colors.green : Colors.red,
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
            TextButton.icon(
              onPressed: () => _goSettings(context),
              icon: const Icon(Icons.settings),
              label: Text(strings.t('settings')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageCarousel(List<Measurement> measurements) {
    if (measurements.isEmpty) {
      return _placeholderCard('No measurement images yet');
    }

    final imageCount = min(measurements.length, 5);
    final recent = measurements.reversed.take(imageCount).toList();
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (value) => setState(() => _carouselIndex = value),
            itemCount: recent.length,
            itemBuilder: (context, index) {
              final m = recent[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade100,
                        Colors.orange.shade200,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Image • ${m.bilirubinMgDl.toStringAsFixed(1)} mg/dL\nAge ${m.ageHours.toStringAsFixed(0)} h',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
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
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _latestCard(Measurement? latest) {
    if (latest == null) {
      return _placeholderCard('No measurements yet');
    }
    return Card(
      child: ListTile(
        title: Text('${latest.bilirubinMgDl.toStringAsFixed(1)} mg/dL',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Captured: ${latest.capturedAt}\nAge: ${latest.ageHours.toStringAsFixed(0)} hours'),
      ),
    );
  }

  Widget _bhutaniCard(
      BuildContext context, List<Measurement> measurements, Measurement? latest, bool showPrevious) {
    final strings = LocalizedStrings(languageCode: ref.read(appStateProvider).localeCode);
    final notifier = ref.read(appStateProvider.notifier);
    final yMax = chartYMax(measurements.map((e) => e.bilirubinMgDl));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bhutani Nomogram', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: Text(strings.t('showPrevious'))),
                Switch(value: showPrevious, onChanged: notifier.toggleShowPrevious),
              ],
            ),
            SizedBox(
              height: 250,
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
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Metadata Bayi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                IconButton(
                  onPressed: () => _editBaby(context, baby),
                  icon: const Icon(Icons.edit),
                )
              ],
            ),
            _metadataField(context, label: 'Nama', value: baby.name),
            const SizedBox(height: 10),
            _metadataField(context, label: 'Berat', value: '${baby.weightKg.toStringAsFixed(1)} Kg'),
            const SizedBox(height: 10),
            _metadataField(context, label: 'Umur', value: ageText),
            const SizedBox(height: 10),
            _metadataField(context, label: 'Tanggal Lahir', value: dob),
          ],
        ),
      ),
    );
  }

  Widget _metadataField(BuildContext context, {required String label, required String value}) {
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
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.lightGreen.shade200,
          ),
          child: Center(
            child: Text(
              strings.t('recommendation'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(message),
          ),
        ),
      ],
    );
  }

  Widget _placeholderCard(String text) => Card(
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
      builder: (context) {
        String query = '';
        final babies = state.babies;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = babies
                .where((baby) => baby.name.toLowerCase().contains(query.toLowerCase()))
                .toList();
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search baby'),
                    onChanged: (value) => setModalState(() => query = value),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final baby = filtered[index];
                        return ListTile(
                          title: Text(baby.name),
                          subtitle: Text('Weight ${baby.weightKg.toStringAsFixed(1)} kg'),
                          onTap: () {
                            notifier.selectBaby(baby.babyId);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
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
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Baby', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 8),
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
                FilledButton(
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
                )
              ],
            ),
          );
        });
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
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(strings.t('wifi'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SwitchListTile(
                    value: state.deviceState.connected,
                    onChanged: (_) => notifier.toggleDevice(),
                    title: const Text('Auto reconnect'),
                  ),
                  const TextField(decoration: InputDecoration(labelText: 'SSID')),
                  const TextField(decoration: InputDecoration(labelText: 'Password')),
                  const SizedBox(height: 8),
                  FilledButton(onPressed: () {}, child: const Text('Test Wi-Fi')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(strings.t('bluetooth'), style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SwitchListTile(value: true, onChanged: (_) {}, title: const Text('BLE enabled')),
                  FilledButton.tonal(onPressed: () {}, child: const Text('Scan devices')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(strings.t('language'), style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 8,
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
          const SizedBox(height: 16),
          Text(strings.t('theme'), style: Theme.of(context).textTheme.titleMedium),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {state.themeMode},
            onSelectionChanged: (set) => notifier.setThemeMode(set.first),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: state.appLockEnabled,
            onChanged: notifier.setAppLock,
            title: Text(strings.t('appLock')),
          ),
        ],
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
            Paint()..color = colorScheme.primary.withValues(alpha: 0.8));
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
