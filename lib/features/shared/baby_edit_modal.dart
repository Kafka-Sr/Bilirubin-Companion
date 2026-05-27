import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/providers/auth_providers.dart';
import 'package:bilirubin/providers/baby_providers.dart';
import 'package:bilirubin/providers/database_provider.dart';
import 'package:bilirubin/repositories/audit_repository.dart';
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
    _nameCtrl = TextEditingController(text: widget.existing?.babyName ?? '');
    _weightCtrl = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.babyWeight.toStringAsFixed(1)
          : '',
    );
    _selectedDob = widget.existing?.babyDob;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  static InputDecoration _pillDecoration({
    Widget? suffixIcon,
    String? errorText,
  }) =>
      InputDecoration(
        errorText: errorText,
        suffixIcon: suffixIcon,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: const BorderSide(color: Colors.red),
        ),
      );

  static Widget _fieldLabel(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.existing != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? l10n.editBabyTitle : l10n.addBabyTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name
            _fieldLabel(context, l10n.fieldName),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              decoration: _pillDecoration(),
              textCapitalization: TextCapitalization.words,
              maxLength: 100,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              validator: (_) => validateName(_nameCtrl.text),
            ),
            const SizedBox(height: 12),

            // Weight
            _fieldLabel(context, l10n.fieldWeight),
            const SizedBox(height: 6),
            TextFormField(
              controller: _weightCtrl,
              decoration: _pillDecoration(),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (_) => validateWeightString(_weightCtrl.text),
            ),
            const SizedBox(height: 12),

            // Date & Time of birth
            _fieldLabel(context, l10n.fieldDob),
            const SizedBox(height: 6),
            _DobField(
              selected: _selectedDob,
              isCreating: !isEditing,
              onChanged: (d) => setState(() => _selectedDob = d),
              validator: () => validateDateOfBirth(_selectedDob),
            ),
            const SizedBox(height: 24),

            // Save
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isEditing ? l10n.editAction : l10n.save,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
            SizedBox(height: MediaQuery.viewInsetsOf(context).bottom + 24),
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
      final repo = ref.read(babyRepositoryProvider);
      final audit = AuditRepository(db);
      final name = sanitiseName(_nameCtrl.text);
      final weight = parseWeight(_weightCtrl.text)!;

      if (widget.existing == null) {
        final hospitalId = ref.read(userProfileProvider).value?.hospitalId;
        if (hospitalId == null || hospitalId.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Profile not ready — please try again.')),
            );
            setState(() => _saving = false);
          }
          return;
        }
        await repo.create(
          name: name,
          dateOfBirth: _selectedDob!,
          weightKg: weight,
          hospitalId: hospitalId,
        );
      } else {
        await repo.update(widget.existing!.copyWith(
          babyName: name,
          babyDob: _selectedDob,
          babyWeight: weight,
        ));
        await audit.logBabyEdit(widget.existing!.babyId);
      }

      // Auto-select the newly created baby.
      if (widget.existing == null) {
        final babies = await db.babiesDao.watchAllActive().first;
        if (babies.isNotEmpty) {
          ref.read(selectedBabyIdProvider.notifier).state = babies.last.babyId;
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
    required this.selected,
    required this.isCreating,
    required this.onChanged,
    required this.validator,
  });

  final DateTime? selected;
  final bool isCreating;
  final ValueChanged<DateTime?> onChanged;
  final String? Function() validator;

  static InputDecoration _pillDecoration({
    Widget? suffixIcon,
    String? errorText,
  }) =>
      InputDecoration(
        errorText: errorText,
        suffixIcon: suffixIcon,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: const BorderSide(color: Colors.red),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: selected,
      validator: (_) => validator(),
      builder: (state) {
        final dateText = selected != null
            ? '${selected!.day}/${selected!.month}/${selected!.year}'
            : '—';
        final timeText = selected != null
            ? '${selected!.hour.toString().padLeft(2, '0')}:'
              '${selected!.minute.toString().padLeft(2, '0')}'
            : '—';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Date field
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(99),
                    onTap: () async {
                      final now = DateTime.now();
                      final first = now.subtract(const Duration(days: 7));
                      final clampedInitial = selected == null
                          ? now
                          : selected!.isBefore(first)
                              ? first
                              : selected!.isAfter(now)
                                  ? now
                                  : selected!;

                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: clampedInitial,
                        firstDate: first,
                        lastDate: now,
                      );
                      if (pickedDate == null) return;
                      if (!context.mounted) return;

                      final DateTime result;
                      if (isCreating && selected == null) {
                        // First-time create: chain into time picker
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(now),
                        );
                        if (pickedTime == null) return;
                        result = DateTime(
                          pickedDate.year, pickedDate.month, pickedDate.day,
                          pickedTime.hour, pickedTime.minute,
                        );
                      } else {
                        // Date only — preserve existing time or default to now
                        final h = selected?.hour ?? now.hour;
                        final m = selected?.minute ?? now.minute;
                        result = DateTime(
                          pickedDate.year, pickedDate.month, pickedDate.day,
                          h, m,
                        );
                      }
                      state.didChange(result);
                      onChanged(result);
                    },
                    child: InputDecorator(
                      decoration: _pillDecoration(
                        suffixIcon: const Icon(Icons.event_outlined),
                        errorText: state.errorText,
                      ),
                      child: Text(dateText),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Time field
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(99),
                    onTap: () async {
                      final now = DateTime.now();
                      final initialTime = selected != null
                          ? TimeOfDay(
                              hour: selected!.hour,
                              minute: selected!.minute,
                            )
                          : TimeOfDay.fromDateTime(now);

                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: initialTime,
                      );
                      if (pickedTime == null) return;

                      // Preserve existing date or default to today
                      final base = selected ?? now;
                      final result = DateTime(
                        base.year, base.month, base.day,
                        pickedTime.hour, pickedTime.minute,
                      );
                      state.didChange(result);
                      onChanged(result);
                    },
                    child: InputDecorator(
                      decoration: _pillDecoration(
                        suffixIcon: const Icon(Icons.access_time_outlined),
                      ),
                      child: Text(timeText),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
