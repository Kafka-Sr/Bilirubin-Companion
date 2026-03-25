import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/providers/bhutani_providers.dart';
import 'package:bilirubin/providers/measurement_providers.dart';

/// Card showing the most recent bilirubin value, timestamp, and age.
class LatestResultCard extends ConsumerWidget {
  const LatestResultCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(latestMeasurementProvider);
    final zone = ref.watch(currentBhutaniZoneProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (m == null) return const SizedBox.shrink();

    final zoneColor = zone?.color ?? theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Big bilirubin value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bilirubinValue(
                      m.bilirubinMgDl.toStringAsFixed(1),
                    ),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: zoneColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (zone != null)
                    Text(
                      zone.label,
                      style: theme.textTheme.labelMedium?.copyWith(
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
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.metadataAgeHours(m.ageHours.toStringAsFixed(1)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day}/${d.month}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}
