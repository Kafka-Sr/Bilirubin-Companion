import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/features/dashboard/widgets/bhutani_painter.dart';
import 'package:bilirubin/providers/device_providers.dart';
import 'package:bilirubin/providers/measurement_providers.dart';
import 'package:bilirubin/utils/bhutani_classifier.dart' as bc;

/// Wrapper widget for the Bhutani nomogram chart.
///
/// Computes the effective Y-axis maximum, handles the history toggle,
/// and supplies the [BhutaniPainter] with appropriate data.
class BhutaniChart extends ConsumerWidget {
  const BhutaniChart({super.key, required this.babyId});

  final int babyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(measurementsProvider(babyId));
    final showHistory = ref.watch(showHistoryProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return measurementsAsync.when(
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Chart error: $e'),
      data: (measurements) {
        final maxY = bc.effectiveYMax(
          measurements.map((m) => m.bilirubinMgDl),
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Text(
                        l10n.bhutaniChartTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text(
                        l10n.showPreviousBilirubin,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      Checkbox(
                        value: showHistory,
                        onChanged: (v) =>
                            ref.read(showHistoryProvider.notifier).state =
                                v ?? false,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Chart canvas
                AspectRatio(
                  aspectRatio: 1.6,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: BhutaniPainter(
                        measurements: measurements,
                        showHistory: showHistory,
                        maxY: maxY,
                        labelStyle: theme.textTheme.labelSmall!.copyWith(
                          color: theme.colorScheme.outline,
                          fontSize: 9,
                        ),
                        gridColor: theme.colorScheme.outline,
                      ),
                    ),
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
