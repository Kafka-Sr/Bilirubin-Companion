import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/providers/baby_providers.dart';
import 'package:bilirubin/providers/database_provider.dart';
import 'package:bilirubin/repositories/audit_repository.dart';
import 'package:bilirubin/repositories/baby_repository.dart';
import 'package:bilirubin/utils/input_validators.dart';

/// Shows a modal bottom sheet to add a new baby or edit an existing one.
///
/// Pass [existing] to pre-populate the form for editing.
Future<void> showBabyEditModal(
  BuildContext context, {
  Baby? existing,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _BabyEditSheet(existing: existing),
  );
}

class _BabyEditSheet extends ConsumerStatefulWidget {
  const _BabyEditSheet({this.existing});

  final Baby? existing;

  @override
  ConsumerState<_BabyEditSheet> createState() => _BabyEditSheetState();
}

class _BabyEditSheetState extends ConsumerState<_BabyEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _weightCtrl;
  DateTime? _selectedDob;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _weightCtrl = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.weightKg.toStringAsFixed(1)
          : '',
    );
    _selectedDob = widget.existing?.dateOfBirth;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? l10n.editBabyTitle : l10n.addBabyTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Name ──────────────────────────────────────────────────────
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: l10n.fieldName),
              textCapitalization: TextCapitalization.words,
              maxLength: 100,
              validator: (_) => validateName(_nameCtrl.text),
            ),
            const SizedBox(height: 12),

            // ── Weight ────────────────────────────────────────────────────
            TextFormField(
              controller: _weightCtrl,
              decoration: InputDecoration(labelText: l10n.fieldWeight),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (_) => validateWeightString(_weightCtrl.text),
            ),
            const SizedBox(height: 12),

            // ── Date of birth ─────────────────────────────────────────────
            _DobField(
              label: l10n.fieldDob,
              selected: _selectedDob,
              onChanged: (d) => setState(() => _selectedDob = d),
              validator: () => validateDateOfBirth(_selectedDob),
            ),
            const SizedBox(height: 24),

            // ── Save ──────────────────────────────────────────────────────
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      _formKey.currentState!.validate();
      return;
    }

    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final repo = BabyRepository(db);
      final audit = AuditRepository(db);
      final name = sanitiseName(_nameCtrl.text);
      final weight = parseWeight(_weightCtrl.text)!;

      if (widget.existing == null) {
        await repo.create(
          name: name,
          dateOfBirth: _selectedDob!,
          weightKg: weight,
        );
      } else {
        await repo.update(widget.existing!.copyWith(
          name: name,
          dateOfBirth: _selectedDob,
          weightKg: weight,
        ));
        await audit.logBabyEdit(widget.existing!.id);
      }

      // Auto-select the newly created baby.
      if (widget.existing == null) {
        final babies = await db.babiesDao.watchAllActive().first;
        if (babies.isNotEmpty) {
          ref.read(selectedBabyIdProvider.notifier).state = babies.last.id;
        }
      }

      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _DobField extends StatelessWidget {
  const _DobField({
    required this.label,
    required this.selected,
    required this.onChanged,
    required this.validator,
  });

  final String label;
  final DateTime? selected;
  final ValueChanged<DateTime?> onChanged;
  final String? Function() validator;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: selected,
      validator: (_) => validator(),
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: selected ?? now,
                firstDate: now.subtract(const Duration(days: 7)),
                lastDate: now,
              );
              if (picked != null) {
                state.didChange(picked);
                onChanged(picked);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                errorText: state.errorText,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                selected != null
                    ? '${selected!.day}/${selected!.month}/${selected!.year}'
                    : '—',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
