import 'package:flutter/material.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/features/shared/baby_edit_modal.dart';

/// Empty state widget with two variants: no babies registered, or no
/// measurements yet for the selected baby.
class EmptyState extends StatelessWidget {
  const EmptyState.noBabies({super.key}) : _variant = _Variant.noBabies;
  const EmptyState.noMeasurements({super.key})
      : _variant = _Variant.noMeasurements;

  final _Variant _variant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _variant == _Variant.noBabies
                  ? Icons.child_care_outlined
                  : Icons.monitor_heart_outlined,
              size: 72,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _variant == _Variant.noBabies
                  ? l10n.noBabiesTitle
                  : l10n.noMeasurementsTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (_variant == _Variant.noMeasurements) ...[
              const SizedBox(height: 8),
              Text(
                l10n.noMeasurementsBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (_variant == _Variant.noBabies) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l10n.noBabiesCta),
                onPressed: () => showBabyEditModal(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _Variant { noBabies, noMeasurements }
