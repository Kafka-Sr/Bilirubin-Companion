import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/features/shared/baby_edit_modal.dart';
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/providers/baby_providers.dart';

/// Top-bar widget with a baby name dropdown and an add-baby button.
class BabySelector extends ConsumerWidget {
  const BabySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babiesAsync = ref.watch(babiesListProvider);
    final selectedId = ref.watch(selectedBabyIdProvider);

    return babiesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (babies) {
        // Auto-select the first baby if none is selected yet.
        if (selectedId == null && babies.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedBabyIdProvider.notifier).state = babies.first.id;
          });
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: babies.isEmpty
                    ? const SizedBox.shrink()
                    : _BabyDropdown(babies: babies, selectedId: selectedId),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.person_add_outlined),
                tooltip: 'Add baby',
                onPressed: () => showBabyEditModal(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BabyDropdown extends ConsumerStatefulWidget {
  const _BabyDropdown({required this.babies, required this.selectedId});

  final List<Baby> babies;
  final int? selectedId;

  @override
  ConsumerState<_BabyDropdown> createState() => _BabyDropdownState();
}

class _BabyDropdownState extends ConsumerState<_BabyDropdown> {
  @override
  Widget build(BuildContext context) {
    final selected = widget.babies.firstWhereOrNull(
      (b) => b.id == widget.selectedId,
    );

    return GestureDetector(
      onTap: () => _showSearchSheet(context),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.child_care, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selected?.name ?? 'Select baby',
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _BabySearchSheet(
        babies: widget.babies,
        onSelect: (id) {
          ref.read(selectedBabyIdProvider.notifier).state = id;
        },
      ),
    );
  }
}

class _BabySearchSheet extends StatefulWidget {
  const _BabySearchSheet({required this.babies, required this.onSelect});

  final List<Baby> babies;
  final ValueChanged<int> onSelect;

  @override
  State<_BabySearchSheet> createState() => _BabySearchSheetState();
}

class _BabySearchSheetState extends State<_BabySearchSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.babies
        .where((b) => b.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search babies…',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final baby = filtered[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.child_care)),
                  title: Text(baby.name),
                  subtitle: Text(
                    '${baby.weightKg.toStringAsFixed(1)} kg · '
                    'DOB ${baby.dateOfBirth.day}/${baby.dateOfBirth.month}/${baby.dateOfBirth.year}',
                  ),
                  onTap: () {
                    widget.onSelect(baby.id);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
