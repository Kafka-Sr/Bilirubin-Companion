import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/providers/parent_providers.dart';
import 'package:bilirubin/providers/supabase_providers.dart';
import 'package:bilirubin/utils/bhutani_classifier.dart' as bc;

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessAsync = ref.watch(parentAccessProvider);

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.parentDashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.signOutTooltip,
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: accessAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (access) {
          if (access == null) {
            return _NotLinkedView(
                email: ref.watch(supabaseUserProvider)?.email ?? '');
          }
          return _LinkedView(babyId: access['baby_id'] as String);
        },
      ),
    );
  }
}

// Not linked

class _NotLinkedView extends StatelessWidget {
  const _NotLinkedView({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty_outlined,
                size: 72, color: cs.outline),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).awaitingLinkageTitle,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).awaitingLinkageBody(email),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.outline),
            ),
          ],
        ),
      ),
    );
  }
}

// Linked

class _LinkedView extends ConsumerWidget {
  const _LinkedView({required this.babyId});
  final String babyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyAsync = ref.watch(parentBabyProvider);
    final measurementsAsync = ref.watch(parentMeasurementsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(parentBabyProvider);
        ref.invalidate(parentMeasurementsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Baby info card
          babyAsync.when(
            loading: () => const Card(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()))),
            error: (e, _) => Card(child: Text('Error: $e')),
            data: (baby) =>
                baby == null ? const SizedBox.shrink() : _BabyCard(baby: baby),
          ),
          const SizedBox(height: 16),

          // Measurements
          Text(AppLocalizations.of(context).measurementsSectionTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          measurementsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (measurements) {
              if (measurements.isEmpty) {
                return Text(AppLocalizations.of(context).noMeasurementsParent);
              }
              return Column(
                children: measurements
                    .map((m) => _MeasurementTile(measurement: m))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BabyCard extends StatelessWidget {
  const _BabyCard({required this.baby});
  final Map<String, dynamic> baby;

  @override
  Widget build(BuildContext context) {
    final name = baby['baby_name'] as String? ?? '—';
    final dobStr = baby['baby_dob'] as String?;
    final weight = (baby['baby_weight'] as num?)?.toDouble();
    final dob = dobStr != null ? DateTime.tryParse(dobStr) : null;
    final ageHours = dob != null
        ? DateTime.now().difference(dob).inMinutes / 60.0
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.child_friendly, size: 28),
              const SizedBox(width: 8),
              Text(name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            if (dob != null)
              Text('DOB: ${dob.day}/${dob.month}/${dob.year}'),
            if (ageHours != null)
              Text('Age: ${ageHours.toStringAsFixed(1)} hours'),
            if (weight != null)
              Text('Weight: ${weight.toStringAsFixed(1)} kg'),
          ],
        ),
      ),
    );
  }
}

class _MeasurementTile extends StatelessWidget {
  const _MeasurementTile({required this.measurement});
  final Map<String, dynamic> measurement;

  @override
  Widget build(BuildContext context) {
    final bilirubin = (measurement['bilirubin_mgdl'] as num?)?.toDouble();
    final ageHours = (measurement['age_hours'] as num?)?.toDouble();
    final capturedAt = measurement['captured_at'] as String?;
    final ts = capturedAt != null ? DateTime.tryParse(capturedAt)?.toLocal() : null;
    final zone = (bilirubin != null && ageHours != null)
        ? bc.classify(ageHours, bilirubin)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: zone != null
            ? CircleAvatar(
                backgroundColor: _zoneColor(zone).withValues(alpha: 0.15),
                child: Text(
                  bilirubin?.toStringAsFixed(1) ?? '—',
                  style: TextStyle(
                      color: _zoneColor(zone),
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              )
            : const CircleAvatar(child: Icon(Icons.science_outlined)),
        title: Text(
          bilirubin != null ? '${bilirubin.toStringAsFixed(2)} mg/dL' : '—',
        ),
        subtitle: Text([
          if (ageHours != null) '${ageHours.toStringAsFixed(1)}h old',
          if (zone != null) zone.name,
        ].join(' · ')),
        trailing: ts != null
            ? Text(
                '${ts.day}/${ts.month}\n${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
      ),
    );
  }

  Color _zoneColor(zone) => switch (zone.name) {
        'high' => Colors.red,
        'highIntermediate' => Colors.orange,
        'lowIntermediate' => Colors.amber,
        _ => Colors.green,
      };
}
