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

class AppUiTokens {
  static const Color secondaryColor = Color(0xFF97C8E9);
  static const double pageHorizontalPadding = 20;
  static const double pageVerticalPadding = 24;
  static const double sectionSpacing = 18;
  static const double sectionPadding = 20;
  static const double cardRadius = 28;
  static const double pillRadius = 999;
  static const double buttonHeight = 48;
  static const double titleSize = 30;
  static const double sectionTitleSize = 18;
  static const double subtitleSize = 15;
  static const double bodySize = 14;
  static const double captionSize = 12;
  static const double buttonSize = 14;

  static TextStyle pageTitle(BuildContext context) => Theme.of(context).textTheme.headlineMedium!.copyWith(
        fontSize: titleSize,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      );

  static TextStyle sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
        fontSize: sectionTitleSize,
        fontWeight: FontWeight.w700,
      );

  static TextStyle subtitle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontSize: subtitleSize,
        fontWeight: FontWeight.w600,
      );

  static TextStyle body(BuildContext context) => Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontSize: bodySize,
        height: 1.45,
      );

  static TextStyle caption(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
        fontSize: captionSize,
        fontWeight: FontWeight.w500,
      );

  static TextStyle button(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge!.copyWith(
        fontSize: buttonSize,
        fontWeight: FontWeight.w700,
      );
}

class BilirubinApp extends ConsumerWidget {
  const BilirubinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final baseText = GoogleFonts.plusJakartaSansTextTheme();
    final lightScheme = ColorScheme.fromSeed(
      seedColor: AppUiTokens.secondaryColor,
      brightness: Brightness.light,
    ).copyWith(secondary: AppUiTokens.secondaryColor);
    final darkScheme = ColorScheme.fromSeed(
      seedColor: AppUiTokens.secondaryColor,
      brightness: Brightness.dark,
    ).copyWith(secondary: AppUiTokens.secondaryColor);

    ThemeData buildTheme(ColorScheme scheme) {
      final isDark = scheme.brightness == Brightness.dark;
      return ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: baseText,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: scheme.onSurface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: baseText.headlineSmall?.copyWith(
            fontSize: AppUiTokens.titleSize,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, AppUiTokens.buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppUiTokens.pillRadius),
            ),
            textStyle: baseText.labelLarge?.copyWith(
              fontSize: AppUiTokens.buttonSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, AppUiTokens.buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppUiTokens.pillRadius),
            ),
            side: BorderSide(color: scheme.outline.withValues(alpha: 0.14)),
            backgroundColor: scheme.surface.withValues(alpha: isDark ? 0.16 : 0.38),
            textStyle: baseText.labelLarge?.copyWith(
              fontSize: AppUiTokens.buttonSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surface.withValues(alpha: isDark ? 0.18 : 0.56),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: scheme.secondary.withValues(alpha: 0.35)),
          ),
          labelStyle: baseText.bodyMedium?.copyWith(fontSize: AppUiTokens.bodySize),
        ),
        dividerColor: scheme.outlineVariant.withValues(alpha: 0.32),
      );
    }

    return MaterialApp(
      title: 'Bilirubin Companion PoC',
      debugShowCheckedModeBanner: false,
      themeMode: state.themeMode,
      theme: buildTheme(lightScheme),
      darkTheme: buildTheme(darkScheme),
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

    return FrostedPageScaffold(
      appBar: AppBar(title: Text(strings.t('dashboard'))),
      body: hasBabies
          ? ListView(
              padding: const EdgeInsets.fromLTRB(
                AppUiTokens.pageHorizontalPadding,
                AppUiTokens.pageVerticalPadding,
                AppUiTokens.pageHorizontalPadding,
                AppUiTokens.pageVerticalPadding + 12,
              ),
              children: [
                _topRow(context, state),
                const SizedBox(height: AppUiTokens.sectionSpacing),
                _deviceStrip(context, state),
                const SizedBox(height: AppUiTokens.sectionSpacing),
                _heroSection(context, measurements, latest, selectedBaby),
                const SizedBox(height: AppUiTokens.sectionSpacing),
                _bhutaniCard(context, measurements, latest, state.showPrevious),
                const SizedBox(height: AppUiTokens.sectionSpacing),
                _recommendationCard(context, latest),
              ],
            )
          : Center(
              child: FrostedSection(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.child_care_rounded,
                      size: 56,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    Text('No babies yet', style: AppUiTokens.sectionTitle(context)),
                    const SizedBox(height: 8),
                    Text(
                      'Add a baby profile to start tracking bilirubin measurements.',
                      textAlign: TextAlign.center,
                      style: AppUiTokens.body(context),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: notifier.addBaby,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(strings.t('addBaby')),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _topRow(BuildContext context, AppState state) {
    final strings = LocalizedStrings(languageCode: ref.read(appStateProvider).localeCode);
    final notifier = ref.read(appStateProvider.notifier);
    final selectedName = state.selectedBaby?.name ?? 'Select baby';

    return FrostedSection(
      padding: const EdgeInsets.all(AppUiTokens.sectionPadding - 4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showBabyPicker(context, state),
              borderRadius: BorderRadius.circular(AppUiTokens.pillRadius),
              child: Container(
                height: AppUiTokens.buttonHeight,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: _pillDecoration(context),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppUiTokens.subtitle(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _roundIconMenuButton(
            context,
            tooltip: 'More options',
            icon: Icons.more_horiz_rounded,
            onSelected: (value) {
              if (value == 'scan') notifier.simulateScan();
              if (value == 'add') notifier.addBaby();
              if (value == 'delete') notifier.deleteSelectedBaby();
            },
            items: [
              PopupMenuItem(value: 'scan', child: Text(strings.t('simulateScan'))),
              PopupMenuItem(value: 'add', child: Text(strings.t('addBaby'))),
              PopupMenuItem(value: 'delete', child: Text(strings.t('deleteBaby'))),
            ],
          ),
          const SizedBox(width: 10),
          AppPillButton(
            icon: Icons.download_rounded,
            label: 'Export',
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Export simulated'))),
          ),
        ],
      ),
    );
  }

  Widget _deviceStrip(BuildContext context, AppState state) {
    final strings = LocalizedStrings(languageCode: ref.read(appStateProvider).localeCode);
    final device = state.deviceState;
    final connected = device.connected;

    return FrostedSection(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: connected ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
              boxShadow: [
                BoxShadow(
                  color: (connected ? const Color(0xFF4CAF50) : const Color(0xFFE57373))
                      .withValues(alpha: 0.35),
                  blurRadius: 14,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Device', style: AppUiTokens.sectionTitle(context)),
                const SizedBox(height: 4),
                Text(
                  connected
                      ? '${strings.t('connected')}: ${device.deviceId} (${device.transport})'
                      : strings.t('notConnected'),
                  style: AppUiTokens.body(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppPillButton(
            icon: Icons.settings_rounded,
            label: strings.t('settings'),
            onPressed: () => _goSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _heroSection(
    BuildContext context,
    List<Measurement> measurements,
    Measurement? latest,
    Baby? baby,
  ) {
    final latestText = latest == null ? 'No measurements yet' : '${latest.bilirubinMgDl.toStringAsFixed(1)} mg/dL';
    final captureText = latest == null
        ? 'Take a scan to see the latest bilirubin result.'
        : 'Captured ${latest.capturedAt}';

    return FrostedSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageCarousel(measurements),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: _innerPanelDecoration(context, emphasized: true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Latest reading', style: AppUiTokens.caption(context)),
                const SizedBox(height: 6),
                Text(
                  latestText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                ),
                const SizedBox(height: 8),
                Text(captureText, style: AppUiTokens.body(context)),
                if (latest != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Age ${latest.ageHours.toStringAsFixed(0)} hours',
                    style: AppUiTokens.caption(context),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Text('Metadata', style: AppUiTokens.sectionTitle(context))),
              AppPillButton(
                icon: Icons.edit_rounded,
                label: 'Edit Metadata',
                onPressed: baby == null ? null : () => _editBaby(context, baby),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (baby == null)
            Text('Select a baby to view metadata.', style: AppUiTokens.body(context))
          else
            _metadataGrid(context, baby),
        ],
      ),
    );
  }

  Widget _imageCarousel(List<Measurement> measurements) {
    if (measurements.isEmpty) {
      return Container(
        height: 200,
        decoration: _innerPanelDecoration(context, emphasized: true),
        child: Center(
          child: Text('No measurement images yet', style: AppUiTokens.body(context)),
        ),
      );
    }

    final imageCount = min(measurements.length, 5);
    final recent = measurements.reversed.take(imageCount).toList();
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (value) => setState(() => _carouselIndex = value),
            itemCount: recent.length,
            itemBuilder: (context, index) {
              final m = recent[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.amber.shade100.withValues(alpha: 0.96),
                        Colors.orange.shade200.withValues(alpha: 0.92),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.12),
                                Colors.black.withValues(alpha: 0.18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              m.bilirubinMgDl.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                            ),
                            Text(
                              'mg/dL',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Captured image ${index + 1}',
                              style: AppUiTokens.subtitle(context).copyWith(color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
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
              width: active ? 22 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: active
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _bhutaniCard(
    BuildContext context,
    List<Measurement> measurements,
    Measurement? latest,
    bool showPrevious,
  ) {
    final notifier = ref.read(appStateProvider.notifier);
    final yMax = chartYMax(measurements.map((e) => e.bilirubinMgDl));

    return FrostedSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Bhutani Nomogram', style: AppUiTokens.sectionTitle(context))),
              AppToggleButton(
                label: 'Show previous',
                value: showPrevious,
                onChanged: notifier.toggleShowPrevious,
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 280,
            child: CustomPaint(
              painter: BhutaniPainter(
                context: context,
                measurements: measurements,
                latest: latest,
                showPrevious: showPrevious,
                yMax: yMax,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metadataGrid(BuildContext context, Baby baby) {
    final age = DateTime.now().difference(baby.dateOfBirth);
    final ageText = '${age.inHours} hours';
    final dob =
        '${baby.dateOfBirth.day.toString().padLeft(2, '0')}-${baby.dateOfBirth.month.toString().padLeft(2, '0')}-${baby.dateOfBirth.year}';

    final items = [
      ('Name', baby.name),
      ('Weight', '${baby.weightKg.toStringAsFixed(1)} kg'),
      ('Age', ageText),
      ('DoB', dob),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: MediaQuery.of(context).size.width > 720
                  ? (MediaQuery.of(context).size.width - 104) / 2
                  : double.infinity,
              child: _metadataField(context, label: item.$1, value: item.$2),
            ),
          )
          .toList(),
    );
  }

  Widget _metadataField(BuildContext context, {required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _innerPanelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppUiTokens.caption(context)),
          const SizedBox(height: 8),
          Text(value, style: AppUiTokens.subtitle(context)),
        ],
      ),
    );
  }

  Widget _recommendationCard(BuildContext context, Measurement? latest) {
    final strings = LocalizedStrings(languageCode: ref.read(appStateProvider).localeCode);
    String message;
    String status;

    if (latest == null) {
      status = 'Awaiting measurement';
      message = strings.t('noMeasurement');
    } else {
      final zone = classifyBhutani(ageHours: latest.ageHours, bilirubin: latest.bilirubinMgDl);
      switch (zone) {
        case BhutaniZone.veryHigh:
          status = 'Very high risk';
          message =
              'Immediate physician review, confirmatory serum test, and urgent treatment planning.';
        case BhutaniZone.high:
          status = 'High risk';
          message =
              'Repeat bilirubin soon, evaluate hydration and feeding, and consider the phototherapy protocol.';
        case BhutaniZone.highIntermediate:
          status = 'High intermediate risk';
          message = 'Follow up within 24 hours and reinforce breastfeeding support.';
        case BhutaniZone.intermediate:
          status = 'Intermediate risk';
          message = 'Continue monitoring and routine reassessment.';
        case BhutaniZone.low:
          status = 'Low risk';
          message = 'Standard newborn follow-up and parental education.';
      }
    }

    return FrostedSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.t('recommendation'), style: AppUiTokens.sectionTitle(context)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(status, style: AppUiTokens.subtitle(context)),
          ),
          const SizedBox(height: 16),
          Text(message, style: AppUiTokens.body(context)),
        ],
      ),
    );
  }

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
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 12,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final filtered = babies
                  .where((baby) => baby.name.toLowerCase().contains(query.toLowerCase()))
                  .toList();
              return FrostedSection(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Search baby',
                      ),
                      onChanged: (value) => setModalState(() => query = value),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 280,
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final baby = filtered[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              notifier.selectBaby(baby.babyId);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: _innerPanelDecoration(context),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(baby.name, style: AppUiTokens.subtitle(context)),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Weight ${baby.weightKg.toStringAsFixed(1)} kg',
                                          style: AppUiTokens.body(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ],
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
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return FrostedSection(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Edit Baby', style: AppUiTokens.sectionTitle(context)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: weightController,
                      decoration: const InputDecoration(labelText: 'Weight (kg)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _innerPanelDecoration(context),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'DoB: ${selectedDob.toLocal().toString().split('.').first}',
                              style: AppUiTokens.body(context),
                            ),
                          ),
                          AppPillButton(
                            label: 'Pick date',
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialDate: selectedDob,
                              );
                              if (picked != null) {
                                setModalState(() => selectedDob = picked);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
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

  void _goSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  void _toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Decoration _pillDecoration(BuildContext context) => BoxDecoration(
        borderRadius: BorderRadius.circular(AppUiTokens.pillRadius),
        color: Theme.of(context).colorScheme.surface.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.52,
            ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.18),
        ),
      );

  BoxDecoration _innerPanelDecoration(BuildContext context, {bool emphasized = false}) => BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? (emphasized ? 0.20 : 0.14)
                  : (emphasized ? 0.64 : 0.48),
            ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.16),
        ),
      );

  Widget _roundIconMenuButton(
    BuildContext context, {
    required String tooltip,
    required IconData icon,
    required ValueChanged<String> onSelected,
    required List<PopupMenuEntry<String>> items,
  }) {
    return PopupMenuButton<String>(
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: (_) => items,
      child: Container(
        width: AppUiTokens.buttonHeight,
        height: AppUiTokens.buttonHeight,
        decoration: _pillDecoration(context),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);
    final strings = LocalizedStrings(languageCode: state.localeCode);

    return FrostedPageScaffold(
      appBar: AppBar(title: Text(strings.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppUiTokens.pageHorizontalPadding,
          AppUiTokens.pageVerticalPadding,
          AppUiTokens.pageHorizontalPadding,
          AppUiTokens.pageVerticalPadding + 12,
        ),
        children: [
          FrostedSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.t('wifi'), style: AppUiTokens.sectionTitle(context)),
                const SizedBox(height: 16),
                _SettingsInput(label: 'SSID'),
                const SizedBox(height: 12),
                _SettingsInput(label: 'Password'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppToggleButton(
                      label: 'Auto reconnect',
                      value: state.deviceState.connected,
                      onChanged: (_) => notifier.toggleDevice(),
                    ),
                    AppPillButton(label: 'Test Wi-Fi', onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppUiTokens.sectionSpacing),
          FrostedSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.t('bluetooth'), style: AppUiTokens.sectionTitle(context)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppToggleButton(label: 'BLE enabled', value: true, onChanged: (_) {}),
                    AppPillButton(label: 'Scan devices', onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppUiTokens.sectionSpacing),
          FrostedSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.t('language'), style: AppUiTokens.sectionTitle(context)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppChoicePill(
                      label: 'Indonesian',
                      selected: state.localeCode == 'id',
                      onTap: () => notifier.setLocale('id'),
                    ),
                    AppChoicePill(
                      label: 'English',
                      selected: state.localeCode == 'en',
                      onTap: () => notifier.setLocale('en'),
                    ),
                    AppChoicePill(
                      label: 'German',
                      selected: state.localeCode == 'de',
                      onTap: () => notifier.setLocale('de'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppUiTokens.sectionSpacing),
          FrostedSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.t('theme'), style: AppUiTokens.sectionTitle(context)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppChoicePill(
                      label: 'System',
                      selected: state.themeMode == ThemeMode.system,
                      onTap: () => notifier.setThemeMode(ThemeMode.system),
                    ),
                    AppChoicePill(
                      label: 'Light',
                      selected: state.themeMode == ThemeMode.light,
                      onTap: () => notifier.setThemeMode(ThemeMode.light),
                    ),
                    AppChoicePill(
                      label: 'Dark',
                      selected: state.themeMode == ThemeMode.dark,
                      onTap: () => notifier.setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppUiTokens.sectionSpacing),
          FrostedSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.t('appLock'), style: AppUiTokens.sectionTitle(context)),
                const SizedBox(height: 16),
                AppToggleButton(
                  label: 'App lock',
                  value: state.appLockEnabled,
                  onChanged: notifier.setAppLock,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FrostedPageScaffold extends StatelessWidget {
  const FrostedPageScaffold({super.key, this.appBar, required this.body});

  final PreferredSizeWidget? appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: appBar,
      extendBodyBehindAppBar: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF09131C),
                    const Color(0xFF102535),
                    const Color(0xFF0D1720),
                  ]
                : [
                    const Color(0xFFF4F8FC),
                    const Color(0xFFE7F1F8),
                    const Color(0xFFF9FCFF),
                  ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -60,
              child: _GlowOrb(color: AppUiTokens.secondaryColor.withValues(alpha: isDark ? 0.18 : 0.22), size: 220),
            ),
            Positioned(
              bottom: -100,
              right: -40,
              child: _GlowOrb(color: scheme.primary.withValues(alpha: isDark ? 0.16 : 0.14), size: 240),
            ),
            Positioned.fill(child: SafeArea(child: body)),
          ],
        ),
      ),
    );
  }
}

class FrostedSection extends StatelessWidget {
  const FrostedSection({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppUiTokens.sectionPadding),
    this.width,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget panel = ClipRRect(
      borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
            color: scheme.surface.withValues(alpha: isDark ? 0.16 : 0.52),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.46),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.07),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (width != null) {
      panel = Center(child: panel);
    }

    return panel;
  }
}

class AppPillButton extends StatelessWidget {
  const AppPillButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
      label: Text(label, style: AppUiTokens.button(context)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, AppUiTokens.buttonHeight),
        padding: EdgeInsets.symmetric(horizontal: icon == null ? 18 : 16, vertical: 12),
      ).merge(
        ButtonStyle(
          iconSize: const MaterialStatePropertyAll(18),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppUiTokens.pillRadius),
            ),
          ),
        ),
      ),
    );
  }
}

class AppToggleButton extends StatelessWidget {
  const AppToggleButton({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: () => onChanged(!value),
      style: FilledButton.styleFrom(
        backgroundColor: value ? scheme.secondary : scheme.surface.withValues(alpha: 0.18),
        foregroundColor: value ? Colors.black87 : scheme.onSurface,
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(value ? Icons.toggle_on_rounded : Icons.toggle_off_rounded, size: 24),
          const SizedBox(width: 8),
          Text(label, style: AppUiTokens.button(context)),
        ],
      ),
    );
  }
}

class AppChoicePill extends StatelessWidget {
  const AppChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? scheme.secondary.withValues(alpha: 0.32) : null,
        foregroundColor: selected ? scheme.onSurface : scheme.onSurface,
      ),
      child: Text(label, style: AppUiTokens.button(context)),
    );
  }
}

class _SettingsInput extends StatelessWidget {
  const _SettingsInput({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(decoration: InputDecoration(labelText: label));
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
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
