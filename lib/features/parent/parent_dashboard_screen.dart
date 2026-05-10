import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/models/bhutani_zone.dart';
import 'package:bilirubin/providers/parent_providers.dart';
import 'package:bilirubin/utils/bhutani_classifier.dart' as bc;

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accessAsync = ref.watch(parentBabyAccessProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilirubin Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.signOut,
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: accessAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (access) {
          if (access == null) return _WaitingView();
          return _LinkedView(ref: ref, l10n: l10n);
        },
      ),
    );
  }
}

// ── Waiting state (not yet linked by hospital) ────────────────────────────────

class _WaitingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty_rounded,
                size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 24),
            Text(l10n.waitingForHospital,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              l10n.waitingForHospitalBody,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Linked state (baby data available) ───────────────────────────────────────

class _LinkedView extends ConsumerWidget {
  const _LinkedView({required this.ref, required this.l10n});
  final WidgetRef ref;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyAsync = ref.watch(parentBabyInfoProvider);
    final measurementsAsync = ref.watch(parentMeasurementsProvider);

    Future<void> refresh() async {
      ref.invalidate(parentBabyAccessProvider);
      ref.invalidate(parentBabyInfoProvider);
      ref.invalidate(parentMeasurementsProvider);
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Baby info card
                babyAsync.when(
                  loading: () => const _LoadingCard(),
                  error: (e, _) => _ErrorCard(message: e.toString()),
                  data: (baby) =>
                      baby == null ? const SizedBox() : _BabyInfoCard(baby: baby, l10n: l10n),
                ),

                // Latest reading card
                measurementsAsync.when(
                  loading: () => const _LoadingCard(),
                  error: (e, _) => _ErrorCard(message: e.toString()),
                  data: (measurements) {
                    if (measurements.isEmpty) return const SizedBox();
                    return _LatestReadingCard(
                        measurement: measurements.first, l10n: l10n);
                  },
                ),

                // History list
                measurementsAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                  data: (measurements) {
                    if (measurements.length <= 1) return const SizedBox();
                    return _HistoryCard(measurements: measurements, l10n: l10n);
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Baby info card ────────────────────────────────────────────────────────────

class _BabyInfoCard extends StatelessWidget {
  const _BabyInfoCard({required this.baby, required this.l10n});
  final CloudBabyInfo baby;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ageHours = baby.ageHoursNow;
    final ageDays = (ageHours / 24).floor();
    final remHours = (ageHours % 24).floor();

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.child_friendly,
                  color: theme.colorScheme.onPrimaryContainer, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baby.name,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '${baby.weightKg.toStringAsFixed(2)} kg  ·  '
                    '$ageDays d $remHours h ${l10n.metadataAge.toLowerCase()}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                  Text(
                    '${l10n.metadataDob}: '
                    '${baby.dateOfBirth.day}/${baby.dateOfBirth.month}/${baby.dateOfBirth.year}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Latest reading card ───────────────────────────────────────────────────────

class _LatestReadingCard extends StatelessWidget {
  const _LatestReadingCard(
      {required this.measurement, required this.l10n});
  final CloudMeasurement measurement;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zone = bc.classify(measurement.ageHours, measurement.bilirubinMgDl);
    final zoneColor = zone?.color ?? theme.colorScheme.primary;
    final dt = measurement.capturedAt.toLocal();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.recommendationHeader,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.bilirubinValue(
                      measurement.bilirubinMgDl.toStringAsFixed(1)),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: zoneColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                if (zone != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: zone.fillColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      zone.localizedLabel(l10n),
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: zoneColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.metadataAgeHours(measurement.ageHours.toStringAsFixed(1))}  ·  '
              '${dt.day}/${dt.month}/${dt.year} '
              '${dt.hour.toString().padLeft(2, '0')}:'
              '${dt.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            if (zone != null) ...[
              const Divider(height: 24),
              Text(
                _recommendationText(zone, l10n),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _recommendationText(BhutaniZone zone, AppLocalizations l10n) {
    switch (zone) {
      case BhutaniZone.low:
        return l10n.recommendationLow;
      case BhutaniZone.lowIntermediate:
        return l10n.recommendationLowIntermediate;
      case BhutaniZone.highIntermediate:
        return l10n.recommendationHighIntermediate;
      case BhutaniZone.high:
        return l10n.recommendationHigh;
    }
  }
}

// ── History card ──────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.measurements, required this.l10n});
  final List<CloudMeasurement> measurements;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.previousReadings,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          // Skip index 0 — that's the latest already shown above.
          for (final m in measurements.skip(1)) _HistoryTile(m: m, l10n: l10n),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.m, required this.l10n});
  final CloudMeasurement m;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zone = bc.classify(m.ageHours, m.bilirubinMgDl);
    final zoneColor = zone?.color ?? theme.colorScheme.primary;
    final dt = m.capturedAt.toLocal();

    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: zoneColor,
        ),
      ),
      title: Text(
        l10n.bilirubinValue(m.bilirubinMgDl.toStringAsFixed(1)),
        style: theme.textTheme.bodyLarge
            ?.copyWith(fontWeight: FontWeight.w600, color: zoneColor),
      ),
      subtitle: Text(
        '${l10n.metadataAgeHours(m.ageHours.toStringAsFixed(1))}  ·  '
        '${dt.day}/${dt.month}/${dt.year}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: zone == null
          ? null
          : Text(
              zone.localizedLabel(l10n),
              style:
                  theme.textTheme.labelSmall?.copyWith(color: zoneColor),
            ),
    );
  }
}

// ── Utility widgets ───────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) => const Card(
        margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error)),
        ),
      );
}
