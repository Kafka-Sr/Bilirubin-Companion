import 'package:flutter/material.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/features/shared/baby_edit_modal.dart';
import 'package:bilirubin/models/baby.dart';

/// Card showing name, weight, date of birth, and computed age of [baby].
///
/// Each field is rendered as a readonly filled text input (matches frontend design).
class BabyMetadataSection extends StatelessWidget {
  const BabyMetadataSection({super.key, required this.baby});

  final Baby baby;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ageHours = baby.ageHoursAt(DateTime.now());

    final ageLabel = ageHours >= 24
        ? '${(ageHours / 24).floor()}d ${(ageHours % 24).floor()}h'
        : l10n.metadataAgeHours(ageHours.toStringAsFixed(0));

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
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                FilledButton.tonal(
                  onPressed: () => showBabyEditModal(context, existing: baby),
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 48),
                    maximumSize: const Size(48, 48),
                  ),
                  child: const Icon(Icons.edit_outlined, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 4),

            _MetadataField(label: l10n.metadataName, value: baby.name),
            const SizedBox(height: 10),
            _MetadataField(
              label: l10n.metadataWeight,
              value: l10n.metadataWeightKg(baby.weightKg.toStringAsFixed(1)),
            ),
            const SizedBox(height: 10),
            _MetadataField(label: l10n.metadataAge, value: ageLabel),
            const SizedBox(height: 10),
            _MetadataField(
              label: l10n.metadataDob,
              value:
                  '${baby.dateOfBirth.day.toString().padLeft(2, '0')}/'
                  '${baby.dateOfBirth.month.toString().padLeft(2, '0')}/'
                  '${baby.dateOfBirth.year}',
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataField extends StatelessWidget {
  const _MetadataField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: ValueKey(value),
          initialValue: value,
          readOnly: true,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
