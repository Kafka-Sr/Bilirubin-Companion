import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/models/bhutani_zone.dart';
import 'package:bilirubin/providers/bhutani_providers.dart';

/// Card showing a clinical recommendation based on the current Bhutani zone.
class RecommendationCard extends ConsumerWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zone = ref.watch(currentBhutaniZoneProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final zoneColor = zone?.color ?? theme.colorScheme.primary;
    final bodyText = zone != null ? _bodyText(zone, l10n) : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Coloured header bar ──────────────────────────────────────────
          Container(
            color: zoneColor,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              l10n.recommendationHeader,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // ── Body ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: zone == null
                ? Text(
                    l10n.noMeasurementsBody,
                    style: theme.textTheme.bodyMedium,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.localizedLabel(l10n).toUpperCase(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: zoneColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bodyText!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _bodyText(BhutaniZone zone, AppLocalizations l10n) {
    switch (zone) {
      case BhutaniZone.low:
        return l10n.recommendationLow;
      case BhutaniZone.intermediate:
        return l10n.recommendationIntermediate;
      case BhutaniZone.highIntermediate:
        return l10n.recommendationHighIntermediate;
      case BhutaniZone.high:
        return l10n.recommendationHigh;
      case BhutaniZone.veryHigh:
        return l10n.recommendationVeryHigh;
    }
  }
}
