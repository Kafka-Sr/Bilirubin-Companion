import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/providers/measurement_providers.dart';
import 'package:bilirubin/utils/bhutani_classifier.dart' as classifier;

/// Card showing the carousel-selected bilirubin value, timestamp, and age.
///
/// Swipes to a historical reading update this card. Falls back to the latest
/// reading when nothing is carousel-selected.
///
/// Set [embedded] to true when hosting inside another card.
class LatestResultCard extends ConsumerWidget {
  const LatestResultCard({super.key, required this.babyId, this.embedded = false});

  final String babyId;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(activeMeasurementProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final dimColor = theme.colorScheme.outline;

    if (m == null) {
      final emptyContent = Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          l10n.noReadings,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: dimColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      if (embedded) return emptyContent;
      return Card(child: emptyContent);

    }

    final zone = classifier.classify(m.ageHours, m.bilirubinMgdl);
    final zoneColor = zone?.color ?? theme.colorScheme.primary;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Big bilirubin value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bilirubinValue(m.bilirubinMgdl.toStringAsFixed(1)),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: zoneColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (zone != null)
                  Text(
                    zone.localizedLabel(l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: zoneColor,
                    ),
                  ),
              ],
            ),
          ),
          // Timestamp + age
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTimestamp(m.capturedAt),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.metadataAgeHours(m.ageHours.toStringAsFixed(1)),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final swipeable = GestureDetector(
      onHorizontalDragEnd: (details) => _handleSwipe(details, ref),
      child: content,
    );

    if (embedded) return swipeable;
    return Card(child: swipeable);
  }

  void _handleSwipe(DragEndDetails details, WidgetRef ref) {
    final measurements =
        ref.read(measurementsProvider(babyId)).valueOrNull ?? [];
    if (measurements.isEmpty) return;
    final currentId = ref.read(selectedCarouselMeasurementIdProvider);
    final currentIdx = currentId == null
        ? 0
        : measurements.indexWhere((m) => m.measurementId == currentId);
    final safeIdx = currentIdx < 0 ? 0 : currentIdx;
    final velocity = details.primaryVelocity ?? 0;
    final nextIdx = velocity < 0
        ? (safeIdx + 1).clamp(0, measurements.length - 1)
        : (safeIdx - 1).clamp(0, measurements.length - 1);
    ref.read(selectedCarouselMeasurementIdProvider.notifier).state =
        measurements[nextIdx].measurementId;
  }

  String _formatTimestamp(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day}/${d.month}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}
