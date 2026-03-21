import 'package:bilirubin/app/providers.dart';
import 'package:bilirubin/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showBabySelectorSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _BabySelectorSheet(),
  );
}

class _BabySelectorSheet extends ConsumerStatefulWidget {
  const _BabySelectorSheet();

  @override
  ConsumerState<_BabySelectorSheet> createState() => _BabySelectorSheetState();
}

class _BabySelectorSheetState extends ConsumerState<_BabySelectorSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final babies = ref.watch(babiesProvider);
    final filtered = babies
        .where((baby) => baby.name.toLowerCase().contains(query.trim().toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 48,
      ),
      child: GlassCard(
        borderRadius: 30,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Select baby',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                hintText: 'Search babies',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: filtered.isEmpty
                  ? SizedBox(
                      height: 140,
                      child: Center(
                        child: Text(
                          'No babies match your search.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final baby = filtered[index];
                        return Material(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(18),
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            title: Text(baby.name),
                            subtitle: Text('${baby.measurements.length} measurements'),
                            onTap: () {
                              ref.read(babiesProvider.notifier).selectBaby(baby.id);
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
