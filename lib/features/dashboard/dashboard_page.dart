import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
import '../../app/glass.dart';
import '../../core/bhutani.dart';
import '../../core/helpers.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../settings/settings_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babies = ref.watch(babiesControllerProvider);
    final selectedBaby = ref.watch(selectedBabyProvider);
    final measurements = ref.watch(currentMeasurementsProvider);
    final latestMeasurement = ref.watch(latestMeasurementProvider);
    final device = ref.watch(deviceControllerProvider);
    final showPrevious = ref.watch(showPreviousBilirubinProvider);
    final theme = Theme.of(context);
    final glass = glassThemeOf(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Biligun Companion',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Offline-first bilirubin monitoring frontend',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: glass.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.54),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: glass.border),
                    ),
                    child: Text(
                      ref.watch(languageProvider).label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: glass.mutedText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (babies.isEmpty)
                EmptyDashboardState(
                  onAddBaby: () => _showEditBabySheet(context, ref, null),
                )
              else ...[
                HeroSection(
                  baby: selectedBaby,
                  onSelectBaby: () => _showBabySelector(context, ref),
                  onSimulateScan: () => _handleSimulateScan(context, ref),
                  onExport: () => _handleExport(context, ref),
                ),
                const SizedBox(height: 16),
                DeviceSection(
                  device: device,
                  onTap: () => _handleToggleDevice(context, ref),
                  onOpenSettings: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ImageSection(
                  measurements: measurements,
                  latestMeasurement: latestMeasurement,
                ),
                const SizedBox(height: 16),
                BhutaniSection(
                  measurements: measurements,
                  latestMeasurement: latestMeasurement,
                  showPreviousBilirubin: showPrevious,
                  onToggleShowPrevious: (value) {
                    ref
                        .read(uiTogglesControllerProvider.notifier)
                        .setShowPreviousBilirubin(value);
                  },
                ),
                const SizedBox(height: 16),
                MetadataSection(
                  baby: selectedBaby,
                  onEdit: () => _showEditBabySheet(context, ref, selectedBaby),
                ),
                const SizedBox(height: 16),
                RecommendationSection(latestMeasurement: latestMeasurement),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyDashboardState extends StatelessWidget {
  const EmptyDashboardState({super.key, required this.onAddBaby});

  final VoidCallback onAddBaby;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = glassThemeOf(context);

    return GlassCard(
      child: Column(
        children: [
          Icon(
            Icons.child_care_rounded,
            size: 52,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text('No babies yet', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Start by adding a baby profile to unlock the six dashboard sections and simulated device flow.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: glass.mutedText),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onAddBaby,
            icon: const Icon(Icons.add),
            label: const Text('Add baby'),
          ),
        ],
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.baby,
    required this.onSelectBaby,
    required this.onSimulateScan,
    required this.onExport,
  });

  final Baby? baby;
  final VoidCallback onSelectBaby;
  final VoidCallback onSimulateScan;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = glassThemeOf(context);

    return Row(
      children: [
        Expanded(
          child: GlassPillButton(
            onTap: onSelectBaby,
            child: Row(
              children: [
                Container(
                  height: 18,
                  width: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.16),
                  ),
                  child: Icon(
                    Icons.child_friendly,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        baby?.name ?? 'Select baby',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        baby == null
                            ? 'Open the baby selector'
                            : 'Current patient',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: glass.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GlassActionButton(
          child: PopupMenuButton<String>(
            tooltip: 'More',
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'simulate_scan') {
                onSimulateScan();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'simulate_scan',
                child: Text('Simulate Scan'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GlassActionButton(
          child: IconButton(
            tooltip: 'Export',
            onPressed: onExport,
            icon: const Icon(Icons.file_upload_outlined),
          ),
        ),
      ],
    );
  }
}

class DeviceSection extends StatelessWidget {
  const DeviceSection({
    super.key,
    required this.device,
    required this.onTap,
    required this.onOpenSettings,
  });

  final DeviceInfo device;
  final VoidCallback onTap;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = glassThemeOf(context);

    return GlassCard(
      onTap: device.isBusy ? null : onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: device.isConnected
                  ? const Color(0xFF2DBE67)
                  : const Color(0xFFE45757),
              boxShadow: [
                BoxShadow(
                  color:
                      (device.isConnected
                              ? const Color(0xFF2DBE67)
                              : const Color(0xFFE45757))
                          .withOpacity(0.35),
                  blurRadius: 14,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              device.isBusy
                  ? 'Updating connection...'
                  : device.isConnected
                  ? 'Connected: ${device.id} (${device.transport?.label ?? 'BLE'})'
                  : 'Not connected',
              style: theme.textTheme.titleMedium?.copyWith(
                color: device.isBusy ? glass.mutedText : null,
              ),
            ),
          ),
          GlassActionButton(
            child: IconButton(
              tooltip: 'Settings',
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageSection extends StatefulWidget {
  const ImageSection({
    super.key,
    required this.measurements,
    required this.latestMeasurement,
  });

  final List<Measurement> measurements;
  final Measurement? latestMeasurement;

  @override
  State<ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<ImageSection> {
  late final PageController _pageController;
  int _pageIndex = 0;

  List<Measurement> get _images => widget.measurements
      .where((measurement) => measurement.hasImage)
      .toList()
      .reversed
      .take(5)
      .toList();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.96);
  }

  @override
  void didUpdateWidget(covariant ImageSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final images = _images;
    if (_pageIndex >= images.length && images.isNotEmpty) {
      setState(() {
        _pageIndex = 0;
      });
      _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    final latestMeasurement = widget.latestMeasurement;
    final theme = Theme.of(context);
    final glass = glassThemeOf(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Image', style: theme.textTheme.titleLarge),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: images.isEmpty
                ? const _EmptyImagePlaceholder()
                : PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (value) {
                      setState(() {
                        _pageIndex = value;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _MeasurementImageCard(
                          measurement: images[index],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              images.isEmpty ? 1 : images.length,
              (index) {
                final isActive = index == _pageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: isActive ? 20 : 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withOpacity(0.24),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.58),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: glass.border),
            ),
            padding: const EdgeInsets.all(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _ImageMetaBlock(
                      label: 'Timestamp',
                      value: latestMeasurement == null
                          ? '—'
                          : formatTimestamp(latestMeasurement.timestamp),
                    ),
                  ),
                  VerticalDivider(
                    color: theme.dividerColor,
                    thickness: 1,
                    width: 24,
                  ),
                  Expanded(
                    child: _ImageMetaBlock(
                      label: 'Bilirubin Level',
                      value: formatBilirubinValue(
                        latestMeasurement?.bilirubinMgDl,
                      ),
                      caption: latestMeasurement == null
                          ? 'age_hours —'
                          : 'age_hours ${compactNumber(latestMeasurement.ageHours)}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BhutaniSection extends StatelessWidget {
  const BhutaniSection({
    super.key,
    required this.measurements,
    required this.latestMeasurement,
    required this.showPreviousBilirubin,
    required this.onToggleShowPrevious,
  });

  final List<Measurement> measurements;
  final Measurement? latestMeasurement;
  final bool showPreviousBilirubin;
  final ValueChanged<bool> onToggleShowPrevious;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = glassThemeOf(context);
    final yMax = bhutaniYMaxForLevels(
      measurements.map((measurement) => measurement.bilirubinMgDl),
    );

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bhutani', style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Bhutani nomogram with the latest bilirubin point, historical trend, and pure Dart zone classification.',
            style: theme.textTheme.bodyMedium?.copyWith(color: glass.mutedText),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 340,
            child: CustomPaint(
              painter: BhutaniChartPainter(
                measurements: measurements,
                latestMeasurement: latestMeasurement,
                showPreviousBilirubin: showPreviousBilirubin,
                yMax: yMax,
                theme: theme,
                glass: glass,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            value: showPreviousBilirubin,
            onChanged: (value) => onToggleShowPrevious(value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text('Show Previous Bilirubin'),
          ),
        ],
      ),
    );
  }
}

class MetadataSection extends StatelessWidget {
  const MetadataSection({super.key, required this.baby, required this.onEdit});

  final Baby? baby;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = glassThemeOf(context);
    final age = baby == null
        ? null
        : DateTime.now().difference(baby!.dateOfBirth);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Metadata', style: theme.textTheme.titleLarge),
              ),
              GlassActionButton(
                child: IconButton(
                  tooltip: 'Edit metadata',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetadataValueCard(label: 'Name', value: baby?.name ?? '—'),
              _MetadataValueCard(
                label: 'weight_kg',
                value: baby == null ? '—' : formatWeightKg(baby!.weightKg),
              ),
              _MetadataValueCard(
                label: 'date_of_birth',
                value: baby == null ? '—' : formatLongDate(baby!.dateOfBirth),
              ),
              _MetadataValueCard(
                label: 'Age',
                value: age == null ? '—' : formatAgeVerbose(age),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            baby == null
                ? 'No baby selected.'
                : 'Computed age: ${formatAgeShort(age!)}',
            style: theme.textTheme.bodySmall?.copyWith(color: glass.mutedText),
          ),
        ],
      ),
    );
  }
}

class RecommendationSection extends StatelessWidget {
  const RecommendationSection({super.key, required this.latestMeasurement});

  final Measurement? latestMeasurement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = glassThemeOf(context);
    final zone = latestMeasurement == null
        ? null
        : classifyBhutaniPoint(
            ageHours: latestMeasurement!.ageHours,
            bilirubinMgDl: latestMeasurement!.bilirubinMgDl,
          );

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.16),
                  theme.colorScheme.secondary.withOpacity(0.14),
                ],
              ),
              border: Border.all(color: glass.border),
            ),
            child: Text(
              'Recommendation',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.82),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: glass.border),
              boxShadow: [
                BoxShadow(
                  color: glass.shadow,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: zone == null
                ? Text(
                    'No recommendation yet (no measurement)',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        zone.uppercaseLabel,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        zone.recommendationBody,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Based on AAP 2022',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: glass.mutedText,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class BabySelectorSheet extends ConsumerStatefulWidget {
  const BabySelectorSheet({super.key});

  @override
  ConsumerState<BabySelectorSheet> createState() => _BabySelectorSheetState();
}

class _BabySelectorSheetState extends ConsumerState<BabySelectorSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final babies = ref.watch(babiesControllerProvider);
    final selectedBaby = ref.watch(selectedBabyProvider);
    final theme = Theme.of(context);
    final glass = glassThemeOf(context);
    final filtered = babies.where((baby) {
      if (_query.isEmpty) {
        return true;
      }
      return baby.name.toLowerCase().contains(_query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 42,
              decoration: BoxDecoration(
                color: glass.mutedText.withOpacity(0.28),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text('Select baby', style: theme.textTheme.titleLarge),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showEditBabySheet(context, ref, null);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add baby'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search babies',
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Text(
                        'No babies found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: glass.mutedText,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final baby = filtered[index];
                      final isSelected = selectedBaby?.id == baby.id;
                      return GlassCard(
                        onTap: () {
                          ref.read(appActionsProvider).selectBaby(baby.id);
                          Navigator.of(context).pop();
                        },
                        radius: 22,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.14),
                              foregroundColor: theme.colorScheme.primary,
                              child: Text(
                                baby.name.characters.first.toUpperCase(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    baby.name,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${formatWeightKg(baby.weightKg)} â€¢ ${formatAgeShort(DateTime.now().difference(baby.dateOfBirth))}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: glass.mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class EditBabySheet extends ConsumerStatefulWidget {
  const EditBabySheet({super.key, this.baby});

  final Baby? baby;

  @override
  ConsumerState<EditBabySheet> createState() => _EditBabySheetState();
}

class _EditBabySheetState extends ConsumerState<EditBabySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late DateTime? _selectedDate;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.baby?.name ?? '');
    _weightController = TextEditingController(
      text: widget.baby == null ? '' : compactNumber(widget.baby!.weightKg),
    );
    _selectedDate = widget.baby?.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = glassThemeOf(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 42,
                  decoration: BoxDecoration(
                    color: glass.mutedText.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.baby == null ? 'Add baby' : 'Edit baby',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Baby name',
                ),
                validator: validateBabyName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: '3.1',
                ),
                validator: validateWeightKg,
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 60),
                    ),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                      );
                      _dateError = null;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of birth',
                    errorText: _dateError,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Select date of birth'
                              : formatLongDate(_selectedDate!),
                        ),
                      ),
                      const Icon(Icons.calendar_today_outlined),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final formValid =
                        _formKey.currentState?.validate() ?? false;
                    final dateError = validateDateOfBirth(_selectedDate);
                    setState(() {
                      _dateError = dateError;
                    });
                    if (!formValid || dateError != null) {
                      return;
                    }

                    final parsedWeight = parseSafeDouble(
                      _weightController.text,
                    )!;
                    final baby = Baby(
                      id:
                          widget.baby?.id ??
                          'baby_${DateTime.now().millisecondsSinceEpoch}',
                      name: sanitizeBabyName(_nameController.text),
                      weightKg: parsedWeight,
                      dateOfBirth: _selectedDate!,
                    );
                    ref.read(appActionsProvider).upsertBaby(baby);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${baby.name} saved locally.')),
                    );
                  },
                  child: Text(
                    widget.baby == null ? 'Create baby' : 'Save changes',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasurementImageCard extends StatelessWidget {
  const _MeasurementImageCard({required this.measurement});

  final Measurement measurement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = <List<Color>>[
      [
        theme.colorScheme.primary.withOpacity(0.22),
        theme.colorScheme.secondary.withOpacity(0.26),
      ],
      [const Color(0xFFDDE7EF), theme.colorScheme.primary.withOpacity(0.16)],
      [theme.colorScheme.secondary.withOpacity(0.18), const Color(0xFFEFE7D9)],
    ];
    final colors = palette[measurement.id.hashCode.abs() % palette.length];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -20,
              top: -18,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.26),
                ),
              ),
            ),
            Positioned(
              left: -12,
              bottom: -22,
              child: Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.32),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            measurement.imageLabel ?? 'Scan image',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyImagePlaceholder extends StatelessWidget {
  const _EmptyImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = glassThemeOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.08),
            theme.colorScheme.surface.withOpacity(0.74),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: glass.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_back_outlined,
            size: 38,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text('No scan image yet', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ImageMetaBlock extends StatelessWidget {
  const _ImageMetaBlock({
    required this.label,
    required this.value,
    this.caption,
  });

  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = glassThemeOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: glass.mutedText),
        ),
        const SizedBox(height: 6),
        Text(value, style: theme.textTheme.titleMedium),
        if (caption != null) ...[
          const SizedBox(height: 4),
          Text(
            caption!,
            style: theme.textTheme.bodySmall?.copyWith(color: glass.mutedText),
          ),
        ],
      ],
    );
  }
}

class _MetadataValueCard extends StatelessWidget {
  const _MetadataValueCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = glassThemeOf(context);

    return SizedBox(
      width: 156,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.64),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: glass.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: glass.mutedText,
              ),
            ),
            const SizedBox(height: 6),
            Text(value, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class BhutaniChartPainter extends CustomPainter {
  BhutaniChartPainter({
    required this.measurements,
    required this.latestMeasurement,
    required this.showPreviousBilirubin,
    required this.yMax,
    required this.theme,
    required this.glass,
  });

  final List<Measurement> measurements;
  final Measurement? latestMeasurement;
  final bool showPreviousBilirubin;
  final double yMax;
  final ThemeData theme;
  final AppGlassTheme glass;

  static const double _leftPad = 50;
  static const double _topPad = 20;
  static const double _rightPad = 20;
  static const double _bottomPad = 56;

  @override
  void paint(Canvas canvas, Size size) {
    final plotRect = Rect.fromLTWH(
      _leftPad,
      _topPad,
      size.width - _leftPad - _rightPad,
      size.height - _topPad - _bottomPad,
    );

    final plotBackground = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.colorScheme.surface.withOpacity(0.32),
          theme.colorScheme.surface.withOpacity(0.12),
        ],
      ).createShader(plotRect);
    final clipRRect = RRect.fromRectAndRadius(
      plotRect,
      const Radius.circular(22),
    );
    canvas.drawRRect(clipRRect, plotBackground);

    canvas.save();
    canvas.clipRRect(clipRRect);
    _drawZones(canvas, plotRect);
    _drawGrid(canvas, plotRect);
    _drawBoundaries(canvas, plotRect);
    _drawMeasurementOverlay(canvas, plotRect);
    canvas.restore();

    canvas.drawRRect(
      clipRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = theme.colorScheme.outline.withOpacity(0.24),
    );

    _drawAxes(canvas, plotRect);
    _drawZoneLabels(canvas, plotRect);
  }

  @override
  bool shouldRepaint(covariant BhutaniChartPainter oldDelegate) {
    return oldDelegate.measurements != measurements ||
        oldDelegate.latestMeasurement != latestMeasurement ||
        oldDelegate.showPreviousBilirubin != showPreviousBilirubin ||
        oldDelegate.yMax != yMax ||
        oldDelegate.theme.brightness != theme.brightness;
  }

  void _drawZones(Canvas canvas, Rect rect) {
    final zero = List<double>.filled(bhutaniXAnchors.length, 0);
    final top = List<double>.filled(bhutaniXAnchors.length, yMax);

    final zones = <_ZonePaint>[
      _ZonePaint(
        lower: highUpperY,
        upper: top,
        colors: const [Color(0xE05A2228), Color(0xAAE36D6D)],
      ),
      _ZonePaint(
        lower: highInterUpperY,
        upper: highUpperY,
        colors: const [Color(0xD6E9CB4C), Color(0xA0F6D86B)],
      ),
      _ZonePaint(
        lower: intermediateUpperY,
        upper: highInterUpperY,
        colors: const [Color(0xD8D67E33), Color(0xAAF0B567)],
      ),
      _ZonePaint(
        lower: lowUpperY,
        upper: intermediateUpperY,
        colors: [
          theme.colorScheme.secondary.withOpacity(0.24),
          theme.colorScheme.secondary.withOpacity(0.4),
        ],
      ),
      _ZonePaint(
        lower: zero,
        upper: lowUpperY,
        colors: const [Color(0xD24A8B57), Color(0xA672C68A)],
      ),
    ];

    for (final zone in zones) {
      final path = _buildFilledZonePath(rect, zone.lower, zone.upper);
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: zone.colors,
        ).createShader(rect);
      canvas.drawPath(path, paint);
    }
  }

  void _drawGrid(Canvas canvas, Rect rect) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = theme.colorScheme.outline.withOpacity(0.12);

    for (final anchor in bhutaniXAnchors) {
      final dx = _dxForX(rect, anchor);
      canvas.drawLine(Offset(dx, rect.top), Offset(dx, rect.bottom), gridPaint);
    }

    final ticks = _yTicks();
    for (final tick in ticks) {
      final dy = _dyForY(rect, tick.toDouble());
      canvas.drawLine(Offset(rect.left, dy), Offset(rect.right, dy), gridPaint);
    }
  }

  void _drawBoundaries(Canvas canvas, Rect rect) {
    final boundaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withOpacity(
        theme.brightness == Brightness.dark ? 0.7 : 0.88,
      );

    for (final boundary in <List<double>>[
      lowUpperY,
      intermediateUpperY,
      highInterUpperY,
      highUpperY,
    ]) {
      final points = <Offset>[
        for (var index = 0; index < bhutaniXAnchors.length; index++)
          Offset(
            _dxForX(rect, bhutaniXAnchors[index]),
            _dyForY(rect, boundary[index]),
          ),
      ];
      final path = _smoothPath(points);
      canvas.drawPath(path, boundaryPaint);
    }
  }

  void _drawMeasurementOverlay(Canvas canvas, Rect rect) {
    final visibleMeasurements =
        measurements
            .where((measurement) => measurement.ageHours.isFinite)
            .toList()
          ..sort((a, b) => a.ageHours.compareTo(b.ageHours));

    if (showPreviousBilirubin && visibleMeasurements.length > 1) {
      final points = visibleMeasurements
          .map(
            (measurement) => Offset(
              _dxForX(rect, measurement.ageHours),
              _dyForY(rect, measurement.bilirubinMgDl),
            ),
          )
          .toList();
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = theme.colorScheme.primary.withOpacity(0.76);
      canvas.drawPath(_smoothPath(points), linePaint);

      for (final point in points.take(points.length - 1)) {
        canvas.drawCircle(
          point,
          4,
          Paint()..color = theme.colorScheme.primary.withOpacity(0.58),
        );
      }
    }

    if (latestMeasurement == null) {
      return;
    }

    final latestPoint = Offset(
      _dxForX(rect, latestMeasurement!.ageHours),
      _dyForY(rect, latestMeasurement!.bilirubinMgDl),
    );

    _drawDashedLine(
      canvas,
      start: Offset(latestPoint.dx, rect.top),
      end: Offset(latestPoint.dx, rect.bottom),
      color: theme.colorScheme.primary.withOpacity(0.55),
    );

    canvas.drawCircle(
      latestPoint,
      10,
      Paint()..color = theme.colorScheme.primary.withOpacity(0.18),
    );
    canvas.drawCircle(
      latestPoint,
      5.5,
      Paint()..color = theme.colorScheme.primary,
    );
    canvas.drawCircle(
      latestPoint,
      2.4,
      Paint()..color = theme.colorScheme.onPrimary,
    );
  }

  void _drawAxes(Canvas canvas, Rect rect) {
    final axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = theme.colorScheme.outline.withOpacity(0.4);
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.right, rect.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.bottom),
      axisPaint,
    );

    final tickStyle = theme.textTheme.labelSmall?.copyWith(
      color: glass.mutedText,
      fontWeight: FontWeight.w600,
    );

    for (final tick in bhutaniXAnchors) {
      _drawText(
        canvas,
        text: tick.toInt().toString(),
        style: tickStyle,
        offset: Offset(_dxForX(rect, tick) - 10, rect.bottom + 10),
      );
    }

    for (final tick in _yTicks()) {
      _drawText(
        canvas,
        text: tick.toString(),
        style: tickStyle,
        offset: Offset(rect.left - 28, _dyForY(rect, tick.toDouble()) - 8),
      );
    }

    _drawText(
      canvas,
      text: 'Hour of Life',
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      offset: Offset(rect.center.dx - 38, rect.bottom + 32),
    );

    canvas.save();
    canvas.translate(16, rect.center.dy + 34);
    canvas.rotate(-math.pi / 2);
    _drawText(
      canvas,
      text: 'Bilirubin (mg/dL)',
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      offset: Offset.zero,
    );
    canvas.restore();
  }

  void _drawZoneLabels(Canvas canvas, Rect rect) {
    final style = theme.textTheme.labelMedium?.copyWith(
      color: Colors.white.withOpacity(
        theme.brightness == Brightness.dark ? 0.88 : 0.94,
      ),
      fontWeight: FontWeight.w700,
      shadows: [Shadow(color: Colors.black.withOpacity(0.26), blurRadius: 10)],
    );

    _drawText(
      canvas,
      text: 'Very High Risk Zone',
      style: style,
      offset: Offset(rect.left + (rect.width * 0.58), rect.top + 8),
    );
    _drawText(
      canvas,
      text: 'High Risk Zone',
      style: style,
      offset: Offset(
        rect.left + (rect.width * 0.65),
        rect.top + (rect.height * 0.2),
      ),
    );
    _drawText(
      canvas,
      text: 'High Intermediate\nRisk Zone',
      style: style,
      offset: Offset(
        rect.left + (rect.width * 0.54),
        rect.top + (rect.height * 0.39),
      ),
    );
    _drawText(
      canvas,
      text: 'Intermediate Risk Zone',
      style: style,
      offset: Offset(
        rect.left + (rect.width * 0.53),
        rect.top + (rect.height * 0.62),
      ),
    );
    _drawText(
      canvas,
      text: 'Low Risk Zone',
      style: style,
      offset: Offset(
        rect.left + (rect.width * 0.67),
        rect.top + (rect.height * 0.84),
      ),
    );
  }

  Path _buildFilledZonePath(Rect rect, List<double> lower, List<double> upper) {
    final topPoints = <Offset>[
      for (var index = 0; index < bhutaniXAnchors.length; index++)
        Offset(
          _dxForX(rect, bhutaniXAnchors[index]),
          _dyForY(rect, upper[index]),
        ),
    ];
    final bottomPoints = <Offset>[
      for (var index = bhutaniXAnchors.length - 1; index >= 0; index--)
        Offset(
          _dxForX(rect, bhutaniXAnchors[index]),
          _dyForY(rect, lower[index]),
        ),
    ];

    final path = _smoothPath(topPoints);
    _appendSmoothSegments(path, bottomPoints);
    path.close();
    return path;
  }

  Path _smoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) {
      return path;
    }
    path.moveTo(points.first.dx, points.first.dy);
    _appendSmoothSegments(
      path,
      points.skip(1).toList(),
      firstPoint: points.first,
    );
    return path;
  }

  void _appendSmoothSegments(
    Path path,
    List<Offset> points, {
    Offset? firstPoint,
  }) {
    final pathPoints = <Offset>[?firstPoint, ...points];
    if (pathPoints.length < 2) {
      return;
    }

    for (var index = 0; index < pathPoints.length - 1; index++) {
      final p0 = index == 0 ? pathPoints[index] : pathPoints[index - 1];
      final p1 = pathPoints[index];
      final p2 = pathPoints[index + 1];
      final p3 = index + 2 < pathPoints.length ? pathPoints[index + 2] : p2;

      final cp1 = Offset(
        p1.dx + ((p2.dx - p0.dx) / 6),
        p1.dy + ((p2.dy - p0.dy) / 6),
      );
      final cp2 = Offset(
        p2.dx - ((p3.dx - p1.dx) / 6),
        p2.dy - ((p3.dy - p1.dy) / 6),
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
  }

  double _dxForX(Rect rect, double x) {
    final normalizedX = x.clamp(3, 120).toDouble();
    return rect.left + (((normalizedX - 3) / 117) * rect.width);
  }

  double _dyForY(Rect rect, double y) {
    final normalizedY = y.clamp(0, yMax).toDouble();
    return rect.bottom - ((normalizedY / yMax) * rect.height);
  }

  List<int> _yTicks() {
    final ticks = <int>[0];
    for (var value = 5; value < yMax; value += 5) {
      ticks.add(value.toInt());
    }
    if (ticks.last != yMax.toInt()) {
      ticks.add(yMax.toInt());
    }
    return ticks;
  }

  void _drawText(
    Canvas canvas, {
    required String text,
    required TextStyle? style,
    required Offset offset,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 120);
    painter.paint(canvas, offset);
  }

  void _drawDashedLine(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    const dash = 5.0;
    const gap = 4.0;
    final totalLength = (end - start).distance;
    final direction = (end - start) / totalLength;
    var drawn = 0.0;
    while (drawn < totalLength) {
      final dashStart = start + (direction * drawn);
      final dashEnd = start + (direction * math.min(drawn + dash, totalLength));
      canvas.drawLine(dashStart, dashEnd, paint);
      drawn += dash + gap;
    }
  }
}

class _ZonePaint {
  const _ZonePaint({
    required this.lower,
    required this.upper,
    required this.colors,
  });

  final List<double> lower;
  final List<double> upper;
  final List<Color> colors;
}

Future<void> _handleToggleDevice(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final device = await ref.read(appActionsProvider).toggleDeviceConnection();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          device.isConnected
              ? 'Device connected to ${device.id}.'
              : 'Device disconnected.',
        ),
      ),
    );
  } on StateError catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(error.message)));
  }
}

Future<void> _handleSimulateScan(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final measurement = await ref.read(appActionsProvider).simulateScan();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Simulated scan complete: ${compactNumber(measurement.bilirubinMgDl)} mg/dL at ${compactNumber(measurement.ageHours)} hours.',
        ),
      ),
    );
  } on StateError catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(error.message)));
  }
}

Future<void> _handleExport(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final exportJson = await ref.read(appActionsProvider).buildExportJson();
    if (!context.mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 42,
                  decoration: BoxDecoration(
                    color: glassThemeOf(context).mutedText.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Mock export preview',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 340),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.74),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    exportJson,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Mock export completed successfully.'),
                      ),
                    );
                  },
                  child: const Text('Simulate export'),
                ),
              ),
            ],
          ),
        );
      },
    );
  } on StateError catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(error.message)));
  }
}

Future<void> _showBabySelector(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const BabySelectorSheet(),
  );
}

Future<void> _showEditBabySheet(
  BuildContext context,
  WidgetRef ref,
  Baby? baby,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => EditBabySheet(baby: baby),
  );
}
