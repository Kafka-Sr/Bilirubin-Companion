import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bilirubin/device/pi_beacon_discovery.dart';
import 'package:bilirubin/models/pi_beacon.dart';

final piBeaconDiscoveryServiceProvider = Provider<PiBeaconDiscoveryService>((ref) {
  final service = PiBeaconDiscoveryService();
  ref.onDispose(service.dispose);
  return service;
});

final piBeaconListProvider = StreamProvider<List<PiBeacon>>((ref) {
  return ref.watch(piBeaconDiscoveryServiceProvider).beacons;
});