import 'package:bilirubin/app/providers.dart';
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showEditBabySheet(BuildContext context, WidgetRef ref, {Baby? baby}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _EditBabySheet(baby: baby),
  );
}

class _EditBabySheet extends ConsumerStatefulWidget {
  const _EditBabySheet({this.baby});

  final Baby? baby;

  @override
  ConsumerState<_EditBabySheet> createState() => _EditBabySheetState();
}

class _EditBabySheetState extends ConsumerState<_EditBabySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.baby?.name ?? '');
    _weightController = TextEditingController(
      text: widget.baby == null ? '' : widget.baby!.weightKg.toStringAsFixed(1),
    );
    _dateOfBirth = widget.baby?.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 40,
      ),
      child: GlassCard(
        borderRadius: 30,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.baby == null ? 'Add baby' : 'Edit baby',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Name is required.';
                  }
                  if (trimmed.length > 40) {
                    return 'Name must be 40 characters or fewer.';
                  }
                  if (RegExp(r'[\x00-\x1F]').hasMatch(trimmed)) {
                    return 'Name contains unsupported control characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                validator: (value) {
                  final weight = double.tryParse((value ?? '').trim());
                  if (weight == null) {
                    return 'Enter a valid weight.';
                  }
                  if (weight < 0.5 || weight > 8) {
                    return 'Weight must be between 0.5 and 8 kg.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Material(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Date of birth'),
                  subtitle: Text(
                    _dateOfBirth == null
                        ? 'Select a date'
                        : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dateOfBirth ?? now,
                      firstDate: now.subtract(const Duration(days: 365)),
                      lastDate: now,
                    );
                    if (picked != null) {
                      setState(() => _dateOfBirth = picked);
                    }
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date of birth is required.')),
      );
      return;
    }
    if (_dateOfBirth!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date of birth cannot be in the future.')),
      );
      return;
    }

    final parsedWeight = double.parse(_weightController.text.trim());
    final notifier = ref.read(babiesProvider.notifier);
    if (widget.baby == null) {
      notifier.addBaby(
        Baby(
          id: 'baby_${DateTime.now().microsecondsSinceEpoch}',
          name: _nameController.text.trim(),
          weightKg: parsedWeight,
          dateOfBirth: _dateOfBirth!,
          measurements: const [],
        ),
      );
    } else {
      notifier.updateBaby(
        widget.baby!.copyWith(
          name: _nameController.text.trim(),
          weightKg: parsedWeight,
          dateOfBirth: _dateOfBirth,
        ),
      );
    }
    Navigator.of(context).pop();
  }
}
