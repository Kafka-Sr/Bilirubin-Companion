import 'dart:async';
import 'package:flutter/material.dart';

enum PairingState { notPaired, pairing, paired, error }

/// Animated Wi-Fi icon that reflects the current pairing state.
///
/// - notPaired / error : static red wifi-off icon
/// - pairing           : yellow icon cycling through signal-strength frames
/// - paired            : static green full-bars icon
class PairingStatusIcon extends StatefulWidget {
  const PairingStatusIcon({super.key, required this.state, this.size = 20});

  final PairingState state;
  final double size;

  @override
  State<PairingStatusIcon> createState() => _PairingStatusIconState();
}

class _PairingStatusIconState extends State<PairingStatusIcon> {
  static const _frames = [
    Icons.signal_wifi_statusbar_null_rounded,
    Icons.network_wifi_1_bar_rounded,
    Icons.network_wifi_2_bar_rounded,
    Icons.network_wifi_3_bar_rounded,
    Icons.signal_wifi_statusbar_4_bar_rounded,
  ];

  int _frame = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startOrStopTimer();
  }

  @override
  void didUpdateWidget(PairingStatusIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) _startOrStopTimer();
  }

  void _startOrStopTimer() {
    _timer?.cancel();
    _timer = null;
    if (widget.state == PairingState.pairing) {
      _timer = Timer.periodic(const Duration(milliseconds: 350), (_) {
        setState(() => _frame = (_frame + 1) % _frames.length);
      });
    } else {
      setState(() => _frame = 0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (widget.state) {
      PairingState.paired => (
          Icons.signal_wifi_statusbar_4_bar_rounded,
          Colors.green,
        ),
      PairingState.pairing => (_frames[_frame], Colors.amber),
      _ => (Icons.signal_wifi_off_rounded, Theme.of(context).colorScheme.error),
    };

    return Icon(icon, size: widget.size, color: color);
  }
}
