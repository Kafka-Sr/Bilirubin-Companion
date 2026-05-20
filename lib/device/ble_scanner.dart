import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Live stream of BLE scan results from [FlutterBluePlus].
/// Call [FlutterBluePlus.startScan] separately to populate results.
Stream<List<ScanResult>> scanForBleDevices() => FlutterBluePlus.scanResults;
