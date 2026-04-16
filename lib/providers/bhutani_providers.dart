import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilirubin/models/bhutani_zone.dart';
import 'package:bilirubin/providers/measurement_providers.dart';
import 'package:bilirubin/utils/bhutani_classifier.dart' as classifier;

/// The Bhutani risk zone for the latest measurement of the selected baby.
/// Returns null when there is no measurement or the value is out of bounds.
final currentBhutaniZoneProvider = Provider<BhutaniZone?>((ref) {
  final m = ref.watch(latestMeasurementProvider);
  if (m == null) return null;
  return classifier.classify(m.ageHours, m.bilirubinMgDl);
});
