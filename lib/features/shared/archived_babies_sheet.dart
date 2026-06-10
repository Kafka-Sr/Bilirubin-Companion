import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/providers/baby_providers.dart';

Future<void> openArchivedBabiesSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _ArchivedBabiesSheet(),
  );
}

class _ArchivedBabiesSheet extends ConsumerWidget {
  const _ArchivedBabiesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final archivedAsync = ref.watch(archivedBabiesListProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined),
                const SizedBox(width: 12),
                Text(l10n.archivedBabies, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: archivedAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (babies) {
                if (babies.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noBabiesTitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: scrollCtrl,
                  itemCount: babies.length,
                  itemBuilder: (_, i) {
                    final baby = babies[i];
                    return ListTile(
                      leading:
                          const CircleAvatar(child: Icon(Icons.child_friendly)),
                      title: Text(baby.babyName),
                      subtitle: Text(
                        '${baby.babyWeight.toStringAsFixed(1)} kg · '
                        'DOB ${baby.babyDob.day}/${baby.babyDob.month}/${baby.babyDob.year}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore),
                            tooltip: l10n.restoreAction,
                            onPressed: () async {
                              await ref.read(babyRepositoryProvider).restore(baby.babyId);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: theme.colorScheme.error),
                            tooltip: l10n.permanentlyDeleteTooltip,
                            onPressed: () =>
                                _confirmPermanentDelete(context, ref, baby),
                          ),
                        ],
                      ),
                    );
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
        content: Text(l10n.permanentDeleteContent(baby.babyName)),
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

    await ref.read(babyRepositoryProvider).delete(baby.babyId);
  }
}
