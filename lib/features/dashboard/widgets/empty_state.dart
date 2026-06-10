import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/features/shared/archived_babies_sheet.dart';
import 'package:bilirubin/features/shared/baby_edit_modal.dart';
import 'package:bilirubin/providers/baby_providers.dart';

/// Empty state widget with two variants: no babies registered, or no
/// measurements yet for the selected baby.
class EmptyState extends ConsumerWidget {
  const EmptyState.noBabies({super.key}) : _variant = _Variant.noBabies;
  const EmptyState.noMeasurements({super.key})
      : _variant = _Variant.noMeasurements;

  final _Variant _variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final hasArchived = _variant == _Variant.noBabies &&
        (ref.watch(archivedBabiesListProvider).valueOrNull ?? []).isNotEmpty;

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
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l10n.noBabiesCta),
                  onPressed: () => showBabyEditModal(context),
                ),
              ),
              if (hasArchived) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: Text(l10n.archivedBabies),
                    onPressed: () => openArchivedBabiesSheet(context),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

enum _Variant { noBabies, noMeasurements }
