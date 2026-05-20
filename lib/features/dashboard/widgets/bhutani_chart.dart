import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/constants.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/features/dashboard/widgets/bhutani_painter.dart';
import 'package:bilirubin/providers/device_providers.dart';
import 'package:bilirubin/providers/measurement_providers.dart';
import 'package:bilirubin/utils/bhutani_classifier.dart' as bc;

/// Wrapper widget for the Bhutani nomogram chart.
///
/// Handles the history and outside-range toggles, caution text,
/// axis labels, and pinch-to-zoom via [InteractiveViewer].
class BhutaniChart extends ConsumerWidget {
  const BhutaniChart({super.key, required this.babyId});

  final int babyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(measurementsProvider(babyId));
    final showHistory = ref.watch(showHistoryProvider);
    final showOutsideRange = ref.watch(showOutsideRangeProvider);
    final selectedMeasurementId =
        ref.watch(selectedCarouselMeasurementIdProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return measurementsAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Chart error: $e'),
      data: (measurements) {
        final maxY = bc.effectiveYMax(
          measurements.map((m) => m.bilirubinMgdl),
        );

        final latestIsOutside = measurements.isNotEmpty &&
            measurements.first.ageHours > kNomogramMaxHours;

        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    l10n.bhutaniChartTitle,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                // Y-axis label + Chart
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        l10n.axisLabelTotalSerumBilirubin,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: SizedBox(
                        height: 280,
                        child: InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 5.0,
                          panEnabled: false,
                          child: RepaintBoundary(
                            child: CustomPaint(
                              painter: BhutaniPainter(
                                context: context,
                                measurements: measurements,
                                showHistory: showHistory,
                                showOutsideRange: showOutsideRange,
                                maxY: maxY,
                                selectedMeasurementId: selectedMeasurementId,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // X-axis label
                Center(
                  child: Text(
                    l10n.axisLabelAgeHours,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Caution notice (above toggles)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.bhutaniOutsideRangeNotice,
                          style: theme.textTheme.bodySmall,
                        ),
                        if (latestIsOutside) ...[
                          const SizedBox(height: 4),
                          Text(
                            l10n.bhutaniCurrentBeyond168h,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF7C3AED),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Toggle: Show Previous Readings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.showPreviousBilirubin,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Transform.scale(
                        scale: 0.75,
                        alignment: Alignment.centerRight,
                        child: Switch(
                          value: showHistory,
                          onChanged: (v) =>
                              ref.read(showHistoryProvider.notifier).state = v,
                        ),
                      ),
                    ],
                  ),
                ),

                // Toggle: Show Readings Outside 168 h
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.showReadingsOutside168h,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Transform.scale(
                        scale: 0.75,
                        alignment: Alignment.centerRight,
                        child: Switch(
                          value: showOutsideRange,
                          activeTrackColor: const Color(0xFF7C3AED),
                          activeThumbColor:
                              theme.brightness == Brightness.light
                                  ? Colors.white
                                  : null,
                          onChanged: (v) => ref
                              .read(showOutsideRangeProvider.notifier)
                              .state = v,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
