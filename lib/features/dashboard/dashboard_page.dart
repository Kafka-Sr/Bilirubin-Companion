import 'package:bilirubin/app/providers.dart';
import 'package:bilirubin/core/theme/app_theme.dart';
import 'package:bilirubin/core/utils/date_utils.dart';
import 'package:bilirubin/features/dashboard/baby_selector_sheet.dart';
import 'package:bilirubin/features/dashboard/bhutani_chart.dart';
import 'package:bilirubin/features/dashboard/edit_baby_sheet.dart';
import 'package:bilirubin/features/settings/settings_page.dart';
import 'package:bilirubin/models/app_enums.dart';
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/models/device_info.dart';
import 'package:bilirubin/models/measurement.dart';
import 'package:bilirubin/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babies = ref.watch(babiesProvider);
    final selectedBaby = ref.watch(selectedBabyProvider);
    final deviceState = ref.watch(deviceControllerProvider);
    final showPrevious = ref.watch(showPreviousBilirubinProvider);

    return Scaffold(
      body: SafeArea(
        child: babies.isEmpty
            ? _DashboardEmptyState(
                onAddBaby: () => showEditBabySheet(context, ref),
              )
            : RefreshIndicator.adaptive(
                onRefresh: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 500));
                },
                child: ListView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    _HeroSection(selectedBaby: selectedBaby),
                    const SizedBox(height: 16),
                    _DeviceSection(deviceState: deviceState),
                    const SizedBox(height: 16),
                    _ImageSection(selectedBaby: selectedBaby),
                    const SizedBox(height: 16),
                    GlassCard(
                      child: BhutaniChartCard(
                        measurements: selectedBaby?.measurements ?? const [],
                        showPrevious: showPrevious,
                        onTogglePrevious: (value) =>
                            ref.read(showPreviousBilirubinProvider.notifier).state = value,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _MetadataSection(selectedBaby: selectedBaby),
                    const SizedBox(height: 16),
                    _RecommendationSection(selectedBaby: selectedBaby),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DashboardEmptyState extends StatelessWidget {
  const _DashboardEmptyState({required this.onAddBaby});

  final VoidCallback onAddBaby;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.child_care_rounded, size: 48),
              const SizedBox(height: 16),
              Text(
                'No babies yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a baby to begin mock screening workflows and review Bhutani-based recommendations.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAddBaby,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add baby'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends ConsumerWidget {
  const _HeroSection({required this.selectedBaby});

  final Baby? selectedBaby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: _HeroPill(
              icon: Icons.keyboard_arrow_down_rounded,
              label: selectedBaby?.name ?? 'Select baby',
              onTap: () => showBabySelectorSheet(context, ref),
            ),
          ),
          const SizedBox(width: 12),
          _HeroIconButton(
            icon: Icons.more_vert_rounded,
            onPressed: () async {
              final action = await showMenu<String>(
                context: context,
                position: const RelativeRect.fromLTRB(1000, 88, 12, 0),
                items: const [
                  PopupMenuItem(value: 'scan', child: Text('Simulate Scan')),
                ],
              );
              if (action == 'scan') {
                final measurement = await ref
                    .read(deviceControllerProvider.notifier)
                    .simulateScan(ref.read(selectedBabyProvider));
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      measurement == null
                          ? 'Unable to simulate scan. Connect device and choose a baby.'
                          : 'Mock scan added at ${measurement.bilirubinMgDl.toStringAsFixed(1)} mg/dL.',
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 12),
          _HeroIconButton(
            icon: Icons.file_download_outlined,
            onPressed: () async {
              final json = ref.read(babiesProvider.notifier).exportCurrentBabyJson(selectedBaby?.id);
              await showDialog<void>(
                context: context,
                builder: (context) => _ExportDialog(json: json),
              );
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export preview generated successfully.')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DeviceSection extends ConsumerWidget {
  const _DeviceSection({required this.deviceState});

  final DeviceState deviceState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = deviceState.isConnected ? const Color(0xFF33C46A) : const Color(0xFFD64545);
    final text = deviceState.isConnected
        ? 'Connected: ${deviceState.device!.id} (${deviceState.device!.transport.label})'
        : 'Not connected';

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () async {
        await ref.read(deviceControllerProvider.notifier).toggleConnection();
      },
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (deviceState.busy)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            )
          else
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
        ],
      ),
    );
  }
}

class _ImageSection extends StatefulWidget {
  const _ImageSection({required this.selectedBaby});

  final Baby? selectedBaby;

  @override
  State<_ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<_ImageSection> {
  final PageController _pageController = PageController(viewportFraction: 1);
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final measurements = widget.selectedBaby?.measurements ?? const <Measurement>[];
    final latestMeasurement = widget.selectedBaby?.latestMeasurement;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Text(
              'Image',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            ),
            child: measurements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_camera_back_outlined,
                          size: 42,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 10),
                        const Text('No scan image yet'),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: measurements.length,
                      onPageChanged: (value) => setState(() => _page = value),
                      itemBuilder: (context, index) {
                        final measurement = measurements[index];
                        return _MeasurementPlaceholderCard(measurement: measurement, index: index + 1);
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              measurements.isEmpty ? 1 : measurements.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: index == _page ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: index == _page
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.22),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Theme.of(context).colorScheme.surface.withOpacity(0.62),
              border: Border.all(color: AppThemeTokens.borderColor(Theme.of(context).brightness)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: _ResultColumn(
                    label: 'Timestamp',
                    value: latestMeasurement == null ? '—' : formatShortDateTime(latestMeasurement.takenAt),
                    secondary: latestMeasurement == null ? null : formatAgeCompact(latestMeasurement.ageHours),
                  ),
                ),
                Container(
                  width: 1,
                  height: 58,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: _ResultColumn(
                    label: 'Bilirubin Level',
                    value: latestMeasurement == null
                        ? '—'
                        : '${latestMeasurement.bilirubinMgDl.toStringAsFixed(1)} mg/dL',
                    secondary: latestMeasurement == null ? null : 'Age ${latestMeasurement.ageHours}h',
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

class _MeasurementPlaceholderCard extends StatelessWidget {
  const _MeasurementPlaceholderCard({required this.measurement, required this.index});

  final Measurement measurement;
  final int index;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: brightness == Brightness.dark
              ? [const Color(0xFF273241), const Color(0xFF1A1E23)]
              : [const Color(0xFFD9E4EF), const Color(0xFFBBCDDD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -40,
            right: -20,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white.withOpacity(0.14),
            ),
          ),
          Positioned(
            bottom: -25,
            left: -10,
            child: CircleAvatar(
              radius: 58,
              backgroundColor: Colors.white.withOpacity(0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.camera_enhance_outlined,
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8), size: 32),
                const SizedBox(height: 8),
                Text(
                  measurement.imageLabel ?? 'Scan capture',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Placeholder scan card #$index',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultColumn extends StatelessWidget {
  const _ResultColumn({required this.label, required this.value, this.secondary});

  final String label;
  final String value;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
          if (secondary != null) ...[
            const SizedBox(height: 4),
            Text(
              secondary!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetadataSection extends ConsumerWidget {
  const _MetadataSection({required this.selectedBaby});

  final Baby? selectedBaby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Metadata',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => showEditBabySheet(context, ref, baby: selectedBaby),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MetadataRow(label: 'Name', value: selectedBaby?.name ?? '—'),
          _MetadataRow(
            label: 'Weight',
            value: selectedBaby == null ? '—' : '${selectedBaby!.weightKg.toStringAsFixed(1)} kg',
          ),
          _MetadataRow(
            label: 'Date of birth',
            value: selectedBaby == null ? '—' : formatLongDate(selectedBaby!.dateOfBirth),
          ),
          _MetadataRow(
            label: 'Computed age',
            value: selectedBaby == null ? '—' : formatAgeFromDob(selectedBaby!.dateOfBirth),
          ),
        ],
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: value),
            readOnly: true,
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection({required this.selectedBaby});

  final Baby? selectedBaby;

  @override
  Widget build(BuildContext context) {
    final latest = selectedBaby?.latestMeasurement;
    final zone = latest == null
        ? null
        : classifyBhutaniZone(
            ageHours: latest.ageHours.toDouble(),
            bilirubinMgDl: latest.bilirubinMgDl,
          );
    final recommendation = _recommendationFor(zone);

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFA3DDB1).withOpacity(0.95),
                  const Color(0xFFBEECCB).withOpacity(0.88),
                ],
              ),
            ),
            child: Center(
              child: Text(
                'Recommendation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF15331E),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.72),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  Text(
                    recommendation.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    recommendation.body,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    latest == null ? '' : 'Based on AAP 2022',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.62),
                          fontWeight: FontWeight.w700,
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

  _RecommendationContent _recommendationFor(BhutaniZone? zone) {
    switch (zone) {
      case BhutaniZone.veryHighRiskZone:
        return const _RecommendationContent(
          'VERY HIGH RISK ZONE',
          'Urgently repeat bilirubin confirmation, escalate clinician review, and prepare immediate phototherapy or transfer workflow.',
        );
      case BhutaniZone.highRiskZone:
        return const _RecommendationContent(
          'HIGH RISK ZONE',
          'Repeat bilirubin soon, assess feeding and hydration, and coordinate expedited pediatric review for possible phototherapy.',
        );
      case BhutaniZone.highIntermediateRiskZone:
        return const _RecommendationContent(
          'HIGH INTERMEDIATE RISK ZONE',
          'Increase surveillance, reassess within the next clinical interval, and review risk factors before discharge decisions.',
        );
      case BhutaniZone.intermediateRiskZone:
        return const _RecommendationContent(
          'INTERMEDIATE RISK ZONE',
          'Continue routine observation, ensure follow-up timing is clear, and repeat bilirubin if symptoms or risk factors change.',
        );
      case BhutaniZone.lowRiskZone:
        return const _RecommendationContent(
          'LOW RISK ZONE',
          'Current bilirubin level remains within the lower risk range. Continue routine care, feeding support, and standard follow-up.',
        );
      case null:
        return const _RecommendationContent(
          'NO RECOMMENDATION YET',
          'No recommendation yet (no measurement)',
        );
    }
  }
}

class _RecommendationContent {
  const _RecommendationContent(this.title, this.body);
  final String title;
  final String body;
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.55),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: IconButton(onPressed: onPressed, icon: Icon(icon)),
    );
  }
}

class _ExportDialog extends StatelessWidget {
  const _ExportDialog({required this.json});

  final String json;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: GlassCard(
        borderRadius: 30,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Mock Export Preview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: json));
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('JSON copied to clipboard.')),
                    );
                  },
                  icon: const Icon(Icons.copy_all_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: SingleChildScrollView(
                child: SelectableText(json, style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
