import 'package:flutter/material.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/features/shared/baby_edit_modal.dart';
import 'package:bilirubin/models/baby.dart';

/// Card showing name, weight, date of birth, and computed age of [baby].
class BabyMetadataSection extends StatelessWidget {
  const BabyMetadataSection({super.key, required this.baby});

  final Baby baby;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ageHours = baby.ageHoursAt(DateTime.now());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.metadataTitle,
                    style: theme.textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l10n.metadataEdit,
                  onPressed: () =>
                      showBabyEditModal(context, existing: baby),
                ),
              ],
            ),
            const Divider(),
            _Row(label: l10n.metadataName, value: baby.name),
            _Row(
              label: l10n.metadataWeight,
              value: l10n.metadataWeightKg(
                  baby.weightKg.toStringAsFixed(1)),
            ),
            _Row(
              label: l10n.metadataDob,
              value:
                  '${baby.dateOfBirth.day}/${baby.dateOfBirth.month}/${baby.dateOfBirth.year}',
            ),
            _Row(
              label: l10n.metadataAge,
              value: l10n.metadataAgeHours(
                ageHours >= 24
                    ? '${(ageHours / 24).floor()}d ${(ageHours % 24).floor()}h'
                    : ageHours.toStringAsFixed(0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline)),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
