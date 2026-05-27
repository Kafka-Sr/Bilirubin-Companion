import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/features/dashboard/widgets/baby_metadata_section.dart';
import 'package:bilirubin/features/dashboard/widgets/bhutani_chart.dart';
import 'package:bilirubin/features/dashboard/widgets/empty_state.dart';
import 'package:bilirubin/features/dashboard/widgets/image_carousel.dart';
import 'package:bilirubin/features/dashboard/widgets/latest_result_card.dart';
import 'package:bilirubin/features/dashboard/widgets/recommendation_card.dart';
import 'package:bilirubin/models/baby.dart';
import 'package:bilirubin/providers/baby_providers.dart';
import 'package:bilirubin/providers/parent_providers.dart';
import 'package:bilirubin/providers/sync_providers.dart';
import 'package:bilirubin/utils/extensions.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final baby = ref.watch(selectedBabyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.parentDashboardTitle),
        actions: [
          Tooltip(
            message: 'Settings',
            child: OutlinedButton(
              onPressed: () => context.push('/settings'),
              style: OutlinedButton.styleFrom(
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
                minimumSize: const Size(40, 40),
                maximumSize: const Size(40, 40),
              ),
              child: const Icon(Icons.settings_outlined, size: 20),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(syncStatusProvider.notifier).set(SyncStatus.syncing);
          try {
            await ref.read(syncServiceProvider).pullChanges();
            ref.read(syncStatusProvider.notifier).set(SyncStatus.idle);
          } catch (_) {
            ref.read(syncStatusProvider.notifier).set(SyncStatus.error);
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _ParentBabySelector(),
                  if (baby == null) ...[
                    const EmptyState.noMeasurements(),
                  ] else ...[
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ImageCarousel(babyId: baby.babyId, embedded: true),
                            const SizedBox(height: 1),
                            LatestResultCard(
                                babyId: baby.babyId, embedded: true),
                          ],
                        ),
                      ),
                    ),
                    BhutaniChart(babyId: baby.babyId),
                    BabyMetadataSection(baby: baby, allowEdit: false),
                    const RecommendationCard(),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Baby selector row ─────────────────────────────────────────────────────────

class _ParentBabySelector extends ConsumerStatefulWidget {
  const _ParentBabySelector();

  @override
  ConsumerState<_ParentBabySelector> createState() =>
      _ParentBabySelectorState();
}

class _ParentBabySelectorState extends ConsumerState<_ParentBabySelector> {
  @override
  Widget build(BuildContext context) {
    final linkedIdsAsync = ref.watch(parentLinkedBabyIdsProvider);

    // Offline / error: never show any baby data.
    if (linkedIdsAsync.isLoading) {
      return const LinearProgressIndicator();
    }
    if (linkedIdsAsync.hasError) {
      return _OfflineWarning(
        onRetry: () => ref.invalidate(parentLinkedBabyIdsProvider),
      );
    }

    final linkedIds = linkedIdsAsync.value!;
    final allBabies = ref.watch(babiesListProvider).valueOrNull ?? [];
    final babies =
        allBabies.where((b) => linkedIds.contains(b.babyId)).toList();
    final selectedId = ref.watch(selectedBabyIdProvider);

    // Reset stale selection if it's no longer in the linked list.
    if (selectedId != null && !babies.any((b) => b.babyId == selectedId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedBabyIdProvider.notifier).state = null;
      });
    }
    // Auto-select first linked baby.
    if (selectedId == null && babies.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedBabyIdProvider.notifier).state =
            babies.first.babyId;
      });
    }

    final selected =
        babies.firstWhereOrNull((b) => b.babyId == selectedId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: babies.isEmpty
                ? const SizedBox.shrink()
                : babies.length == 1
                    ? _StaticPill(baby: selected ?? babies.first)
                    : _TappablePill(
                        babies: babies,
                        selected: selected,
                        onSelect: (id) {
                          ref.read(selectedBabyIdProvider.notifier).state =
                              id;
                        },
                      ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: _ParentSyncPill()),
        ],
      ),
    );
  }
}

// ── Offline warning ───────────────────────────────────────────────────────────

class _OfflineWarning extends StatelessWidget {
  const _OfflineWarning({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 48, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            l10n.parentNoConnectionTitle,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.parentNoConnectionBody,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(l10n.retryAction),
          ),
        ],
      ),
    );
  }
}

// ── Sync pill ─────────────────────────────────────────────────────────────────

class _ParentSyncPill extends ConsumerWidget {
  const _ParentSyncPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isSyncing = status == SyncStatus.syncing;
    final isError = status == SyncStatus.error;

    return InkWell(
      onTap: isSyncing
          ? null
          : () async {
              ref.read(syncStatusProvider.notifier).set(SyncStatus.syncing);
              try {
                await ref.read(syncServiceProvider).pullChanges();
                ref.read(syncStatusProvider.notifier).set(SyncStatus.idle);
              } catch (_) {
                ref.read(syncStatusProvider.notifier).set(SyncStatus.error);
              }
            },
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: isSyncing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : Icon(
                  isError ? Icons.sync_problem : Icons.sync,
                  size: 20,
                  color: isError
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}

// ── Baby pill variants ────────────────────────────────────────────────────────

class _StaticPill extends StatelessWidget {
  const _StaticPill({required this.baby});
  final Baby baby;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
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
              baby.babyName,
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TappablePill extends StatelessWidget {
  const _TappablePill({
    required this.babies,
    required this.selected,
    required this.onSelect,
  });

  final List<Baby> babies;
  final Baby? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _showPicker(context),
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
                selected?.babyName ??
                    AppLocalizations.of(context).selectBaby,
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

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
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
              onTap: () {
                onSelect(baby.babyId);
                Navigator.of(ctx).pop();
              },
            );
          },
        ),
      ),
    );
  }
}
