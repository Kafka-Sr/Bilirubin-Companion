import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/features/shared/baby_edit_modal.dart';
import 'package:bilirubin/features/shared/export_bottom_sheet.dart';
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/providers/baby_providers.dart';
import 'package:bilirubin/providers/database_provider.dart';
import 'package:bilirubin/providers/measurement_providers.dart';
import 'package:bilirubin/repositories/audit_repository.dart';
import 'package:bilirubin/repositories/baby_repository.dart';

enum _BabyMenuAction { add, archive }

/// Top-bar widget with a baby name pill, overflow menu, and export button.
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

        final selectedBaby = babies.firstWhereOrNull((b) => b.id == selectedId);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: babies.isEmpty
                    ? const SizedBox.shrink()
                    : _BabyDropdown(
                        babies: babies,
                        selectedId: selectedId,
                      ),
              ),
              const SizedBox(width: 8),
              _OverflowMenu(babies: babies, selectedBaby: selectedBaby),
              const SizedBox(width: 8),
              _ExportButton(selectedBaby: selectedBaby),
            ],
          ),
        );
      },
    );
  }
}

// ── Baby dropdown ─────────────────────────────────────────────────────────────

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
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _showSearchSheet(context),
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            const Icon(Icons.child_friendly, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selected?.name ?? AppLocalizations.of(context).selectBaby,
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
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

// ── Overflow menu ─────────────────────────────────────────────────────────────

class _OverflowMenu extends ConsumerWidget {
  const _OverflowMenu({required this.babies, required this.selectedBaby});

  final List<Baby> babies;
  final Baby? selectedBaby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasSelection = selectedBaby != null;

    return PopupMenuButton<_BabyMenuAction>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (action) => _onAction(context, ref, action),
      itemBuilder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return [
          PopupMenuItem(
            value: _BabyMenuAction.add,
            child: Text(l10n.addBabyTitle),
          ),
          PopupMenuItem(
            value: _BabyMenuAction.archive,
            enabled: hasSelection,
            child: Text(
              l10n.archiveBabyAction,
              style: hasSelection ? null : TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.38)),
            ),
          ),
        ];
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: colorScheme.surfaceContainerHighest,
        ),
        child: const Icon(Icons.more_vert),
      ),
    );
  }

  Future<void> _onAction(
      BuildContext context, WidgetRef ref, _BabyMenuAction action) async {
    switch (action) {
      case _BabyMenuAction.add:
        await showBabyEditModal(context);
      case _BabyMenuAction.archive:
        if (selectedBaby != null) {
          await _confirmArchive(context, ref, selectedBaby!);
        }
    }
  }

  Future<void> _confirmArchive(
      BuildContext context, WidgetRef ref, Baby baby) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.archiveBabyAction),
        content: Text(l10n.archiveBabyContent(baby.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.archiveAction),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final db = ref.read(appDatabaseProvider);
    await BabyRepository(db).archive(baby.id);
    await AuditRepository(db).logBabyDelete(baby.id);
    ref.read(selectedBabyIdProvider.notifier).state = null;
  }
}

// ── Export button ─────────────────────────────────────────────────────────────

class _ExportButton extends ConsumerWidget {
  const _ExportButton({required this.selectedBaby});

  final Baby? selectedBaby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = selectedBaby != null;

    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: InkWell(
        onTap: enabled ? () => _export(context, ref) : null,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.file_upload_outlined, size: 18),
              const SizedBox(width: 6),
              Text(AppLocalizations.of(context).exportAction, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final baby = selectedBaby;
    if (baby == null) return;

    final measurements =
        await ref.read(measurementRepositoryProvider).watchByBaby(baby.id).first;

    if (context.mounted) {
      await showExportBottomSheet(context, ref,
          baby: baby, measurements: measurements);
    }
  }
}

// ── Baby search sheet ─────────────────────────────────────────────────────────

class _BabySearchSheet extends ConsumerStatefulWidget {
  const _BabySearchSheet({required this.babies, required this.onSelect});

  final List<Baby> babies;
  final ValueChanged<int> onSelect;

  @override
  ConsumerState<_BabySearchSheet> createState() => _BabySearchSheetState();
}

class _BabySearchSheetState extends ConsumerState<_BabySearchSheet> {
  String _query = '';
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final archived = ref.watch(archivedBabiesListProvider).valueOrNull ?? [];

    final source = _showArchived ? archived : widget.babies;
    final filtered = source
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
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: AppLocalizations.of(context).searchBabiesHint,
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
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => setState(() => _showArchived = !_showArchived),
              borderRadius: BorderRadius.circular(99),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: _showArchived
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 20,
                      color: _showArchived
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).archivedCount(archived.length),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _showArchived
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final baby = filtered[i];
                if (_showArchived) {
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.child_care)),
                    title: Text(baby.name),
                    subtitle: Text(
                      '${baby.weightKg.toStringAsFixed(1)} kg · '
                      'DOB ${baby.dateOfBirth.day}/${baby.dateOfBirth.month}/${baby.dateOfBirth.year}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.restore),
                          tooltip: AppLocalizations.of(context).restoreAction,
                          onPressed: () async {
                            final db = ref.read(appDatabaseProvider);
                            await BabyRepository(db).restore(baby.id);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: Theme.of(context).colorScheme.error),
                          tooltip: AppLocalizations.of(context).permanentlyDeleteTooltip,
                          onPressed: () => _confirmPermanentDelete(context, ref, baby),
                        ),
                      ],
                    ),
                  );
                }
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

  Future<void> _confirmPermanentDelete(
      BuildContext context, WidgetRef ref, Baby baby) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.permanentDeleteTitle),
        content: Text(l10n.permanentDeleteContent(baby.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteForever),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final db = ref.read(appDatabaseProvider);
    await BabyRepository(db).delete(baby.id);
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
