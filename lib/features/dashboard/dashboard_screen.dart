import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/features/dashboard/widgets/baby_metadata_section.dart';
import 'package:bilirubin/features/dashboard/widgets/baby_selector.dart';
import 'package:bilirubin/features/dashboard/widgets/bhutani_chart.dart';
import 'package:bilirubin/features/dashboard/widgets/device_strip.dart';
import 'package:bilirubin/features/dashboard/widgets/empty_state.dart';
import 'package:bilirubin/features/dashboard/widgets/image_carousel.dart';
import 'package:bilirubin/features/dashboard/widgets/latest_result_card.dart';
import 'package:bilirubin/features/dashboard/widgets/recommendation_card.dart';
import 'package:bilirubin/providers/baby_providers.dart';

/// Main dashboard screen — composes all dashboard widgets.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final babiesAsync = ref.watch(babiesListProvider);
    final baby = ref.watch(selectedBabyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardTitle)),
      body: babiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (babies) {
          if (babies.isEmpty) {
            return const EmptyState.noBabies();
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Re-read stream — no-op but satisfies the gesture.
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Baby selector
                      const BabySelector(),

                      // 2. Device strip
                      const DeviceStrip(),

                      if (baby == null) ...[
                        const EmptyState.noMeasurements(),
                      ] else ...[
                        // 3. Image carousel + latest result
                        Card(
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ImageCarousel(babyId: baby.id, embedded: true),
                                const SizedBox(height: 1),
                                const LatestResultCard(embedded: true),
                              ],
                            ),
                          ),
                        ),

                        // 5. Bhutani chart
                        BhutaniChart(babyId: baby.id),

                        // 6. Baby metadata
                        BabyMetadataSection(baby: baby),

                        // 7. Recommendation
                        const RecommendationCard(),

                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
