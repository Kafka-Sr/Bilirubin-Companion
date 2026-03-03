import 'package:bilirubin_companion/data/models.dart';
import 'package:bilirubin_companion/domain/bhutani.dart';
import 'package:bilirubin_companion/features/dashboard/nomogram_chart.dart';
import 'package:bilirubin_companion/features/settings/settings_page.dart';
import 'package:bilirubin_companion/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool showPrevious = true;
  int carouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    final babiesAsync = ref.watch(babiesProvider);
    final selectedBaby = ref.watch(selectedBabyProvider);
    final measurementsAsync = ref.watch(measurementsProvider);
    final deviceRepo = ref.watch(deviceRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: babiesAsync.when(
          data: (babies) {
            if (babies.isEmpty) {
              return Center(
                child: FilledButton(
                  onPressed: () => _showBabyEditor(context),
                  child: const Text('Add baby'),
                ),
              );
            }
            final measurements = measurementsAsync.valueOrNull ?? [];
            final latest = measurements.isEmpty ? null : measurements.first;
            return ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _topBar(selectedBaby, babies),
                const SizedBox(height: 12),
                StreamBuilder<DeviceConnectionState>(
                  stream: deviceRepo.connectionState,
                  initialData: const DeviceConnectionState(isConnected: false),
                  builder: (context, stateSnapshot) {
                    return StreamBuilder<DeviceInfo?>(
                      stream: deviceRepo.deviceInfo,
                      builder: (context, infoSnapshot) {
                        final connected = stateSnapshot.data?.isConnected ?? false;
                        final info = infoSnapshot.data;
                        return _deviceStrip(connected, info);
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                _carousel(measurements),
                const SizedBox(height: 10),
                _latestCard(latest),
                const SizedBox(height: 10),
                NomogramCard(measurements: measurements, showPrevious: showPrevious, onToggle: (v) => setState(() => showPrevious = v)),
                const SizedBox(height: 10),
                _metadataCard(selectedBaby),
                const SizedBox(height: 10),
                _recommendationCard(latest),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _topBar(BabyRecord? selected, List<BabyRecord> babies) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showBabyPicker(babies),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [const Icon(Icons.keyboard_arrow_down), Expanded(child: Text(selected?.name ?? 'Select baby', textAlign: TextAlign.center))]),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'scan') {
              final baby = ref.read(selectedBabyProvider);
              if (baby == null) return;
              final deviceRepo = ref.read(deviceRepositoryProvider);
              final event = await deviceRepo.simulateScan();
              final info = await deviceRepo.deviceInfo.first;
              await ref.read(babyRepositoryProvider).addMeasurement(
                    babyId: baby.babyId,
                    measurementId: event.measurementId,
                    capturedAt: event.capturedAt,
                    ageHours: event.ageHours,
                    bilirubinMgDl: event.bilirubinMgDl,
                    imageBytes: event.imageBytes,
                    deviceId: info?.deviceId ?? 'unknownDevice',
                  );
              ref.read(refreshTokenProvider.notifier).state++;
            }
          },
          itemBuilder: (context) => [const PopupMenuItem(value: 'scan', child: Text('Simulate Scan'))],
        ),
        IconButton(
          onPressed: _export,
          icon: const Icon(Icons.download),
        ),
      ],
    );
  }

  Widget _deviceStrip(bool connected, DeviceInfo? info) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final repo = ref.read(deviceRepositoryProvider);
        if (connected) {
          await repo.disconnect();
        } else {
          await repo.connect();
        }
      },
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: connected ? Colors.green : Colors.red, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Text(connected ? 'Connected: ${info?.deviceId ?? '-'} (${info == null ? '-' : info.transport.name.toUpperCase()})' : 'Not connected')),
            IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carousel(List<MeasurementRecord> measurements) {
    final images = measurements.where((m) => m.hasImage && m.imageBytes != null).take(5).toList();
    return Card(
      child: SizedBox(
        height: 220,
        child: images.isEmpty
            ? const Center(child: Text('No scan image yet'))
            : Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      onPageChanged: (value) => setState(() => carouselIndex = value),
                      itemCount: images.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(images[i].imageBytes!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == carouselIndex ? Colors.black : Colors.black26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _latestCard(MeasurementRecord? latest) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold)), Text(latest?.capturedAt.toString() ?? '—')]),
            ),
            Container(width: 1, height: 50, color: Colors.black54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Bilirubin Level', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(latest == null ? '—' : '${latest.bilirubinMgDl.toStringAsFixed(1)} mg/dL'),
                Text(latest == null ? '' : '${latest.ageHours} h', style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metadataCard(BabyRecord? baby) {
    String age = '—';
    if (baby?.dateOfBirth != null) {
      final diff = DateTime.now().difference(baby!.dateOfBirth!);
      age = '${diff.inDays} days ${diff.inHours % 24} hours';
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [const Expanded(child: Text('Metadata Bayi', style: TextStyle(fontSize: 28 / 1.5, fontWeight: FontWeight.w600))), IconButton(onPressed: () => _showBabyEditor(context), icon: const Icon(Icons.edit_outlined))]),
            _field('Nama', baby?.name ?? '—'),
            _field('Berat', baby?.weightKg == null ? '—' : '${baby!.weightKg} Kg'),
            _field('Umur', age),
            _field('Tanggal Lahir', baby?.dateOfBirth == null ? '—' : '${baby!.dateOfBirth!.day}-${baby.dateOfBirth!.month}-${baby.dateOfBirth!.year}'),
          ],
        ),
      ),
    );
  }

  Widget _field(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18)), const SizedBox(height: 6), TextField(enabled: false, decoration: InputDecoration(hintText: value))]),
    );
  }

  Widget _recommendationCard(MeasurementRecord? latest) {
    String heading = 'NO RECOMMENDATION YET';
    String body = 'No recommendation yet (no measurement).';
    if (latest != null) {
      final zone = classifyBhutaniZone(ageHours: latest.ageHours.toDouble(), bilirubinMgDl: latest.bilirubinMgDl);
      switch (zone) {
        case BhutaniZone.veryHighRiskZone:
          heading = 'VERY HIGH RISK ZONE';
          body = 'Urgent evaluation, confirm serum bilirubin, and prepare immediate phototherapy/escalation.';
          break;
        case BhutaniZone.highRiskZone:
          heading = 'HIGH RISK ZONE';
          body = 'Arrange near-term follow-up and assess phototherapy threshold using clinical context.';
          break;
        case BhutaniZone.highIntermediateRiskZone:
          heading = 'HIGH INTERMEDIATE RISK ZONE';
          body = 'Re-check bilirubin soon and reinforce feeding/hydration strategy.';
          break;
        case BhutaniZone.intermediateRiskZone:
          heading = 'INTERMEDIATE RISK ZONE';
          body = 'Routine observation with repeat bilirubin per protocol and risk factors.';
          break;
        case BhutaniZone.lowRiskZone:
          heading = 'LOW RISK ZONE';
          body = 'Continue standard newborn care and scheduled follow-up.';
          break;
        case null:
          heading = 'UNKNOWN';
          body = 'Measurement invalid, repeat scan.';
      }
    }
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFF97D1A6), borderRadius: BorderRadius.circular(12)),
          child: const Text('Recommendation', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26 / 1.4)),
        ),
        const SizedBox(height: 4),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(heading, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 28 / 1.4)),
                const SizedBox(height: 10),
                Text(body, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Based on AAP 2022', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showBabyPicker(List<BabyRecord> babies) async {
    final searchController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchController.text.toLowerCase();
            final filtered = babies.where((b) => b.name.toLowerCase().contains(query)).toList();
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                height: 420,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => setModalState(() {}),
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search babies'),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final baby = filtered[i];
                          return ListTile(
                            title: Text(baby.name),
                            onTap: () {
                              ref.read(selectedBabyIdProvider.notifier).state = baby.babyId;
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showBabyEditor(BuildContext context) async {
    final baby = ref.read(selectedBabyProvider);
    final name = TextEditingController(text: baby?.name);
    final weight = TextEditingController(text: baby?.weightKg?.toString());
    final dob = TextEditingController(text: baby?.dateOfBirth?.toIso8601String().split('T').first);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: 330,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Name*')),
                const SizedBox(height: 8),
                TextField(controller: weight, decoration: const InputDecoration(labelText: 'Weight Kg')),
                const SizedBox(height: 8),
                TextField(controller: dob, decoration: const InputDecoration(labelText: 'Date Of Birth yyyy-MM-dd')),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () async {
                    if (name.text.trim().isEmpty) return;
                    await ref.read(babyRepositoryProvider).saveBaby(
                          babyId: baby?.babyId,
                          name: name.text.trim(),
                          weightKg: double.tryParse(weight.text.trim()),
                          dateOfBirth: DateTime.tryParse(dob.text.trim()),
                        );
                    if (mounted) Navigator.pop(context);
                    ref.read(refreshTokenProvider.notifier).state++;
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _export() async {
    try {
      final baby = ref.read(selectedBabyProvider);
      final measurements = ref.read(measurementsProvider).valueOrNull ?? [];
      if (baby == null) throw Exception('No baby selected');
      final path = await ref.read(exportRepositoryProvider).exportBaby(baby: baby, measurements: measurements);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export success: $path')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}
