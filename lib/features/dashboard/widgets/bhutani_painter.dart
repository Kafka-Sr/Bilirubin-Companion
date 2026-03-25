import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bilirubin/core/constants.dart';
import 'package:bilirubin/models/bhutani_zone.dart';
import 'package:bilirubin/models/measurement.dart';
import 'package:bilirubin/utils/bhutani_classifier.dart' as bc;

/// [CustomPainter] that draws the full Bhutani nomogram chart.
///
/// Zones (bottom to top): low → intermediate → highIntermediate → high → veryHigh
/// Data points: latest measurement as filled circle; history as outlines.
class BhutaniPainter extends CustomPainter {
  BhutaniPainter({
    required this.measurements,
    required this.showHistory,
    required this.maxY,
    required this.labelStyle,
    required this.gridColor,
  });

  final List<Measurement> measurements;
  final bool showHistory;
  final double maxY;
  final TextStyle labelStyle;
  final Color gridColor;

  // Chart padding (pixels)
  static const double _leftPad = 38;
  static const double _rightPad = 8;
  static const double _topPad = 8;
  static const double _bottomPad = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width - _leftPad - _rightPad;
    final h = size.height - _topPad - _bottomPad;

    double cx(double hours) =>
        _leftPad + (hours / kNomogramMaxHours) * w;
    double cy(double mgDl) =>
        _topPad + (1 - mgDl / maxY) * h;

    // 1. Zone fills
    _drawZones(canvas, cx, cy, h);

    // 2. Boundary lines
    _drawBoundaryLines(canvas, cx, cy);

    // 3. Grid / axes
    _drawAxes(canvas, size, cx, cy, w, h);

    // 4. Data points
    _drawDataPoints(canvas, cx, cy);
  }

  // ── Zone fills ─────────────────────────────────────────────────────────────

  void _drawZones(Canvas canvas, double Function(double) cx,
      double Function(double) cy, double chartH) {
    _fillZone(
      canvas, cx, cy,
      lower: _floor(),
      upper: bc.kBoundaryLow,
      color: BhutaniZone.low.fillColor,
    );
    _fillZone(
      canvas, cx, cy,
      lower: bc.kBoundaryLow,
      upper: bc.kBoundaryHighIntermediate,
      color: BhutaniZone.intermediate.fillColor,
    );
    _fillZone(
      canvas, cx, cy,
      lower: bc.kBoundaryHighIntermediate,
      upper: bc.kBoundaryHigh,
      color: BhutaniZone.highIntermediate.fillColor,
    );
    _fillZone(
      canvas, cx, cy,
      lower: bc.kBoundaryHigh,
      upper: bc.kBoundaryVeryHigh,
      color: BhutaniZone.high.fillColor,
    );
    _fillZone(
      canvas, cx, cy,
      lower: bc.kBoundaryVeryHigh,
      upper: _ceiling(),
      color: BhutaniZone.veryHigh.fillColor,
    );
  }

  List<(double, double)> _floor() =>
      [(kNomogramMinHours, 0), (kNomogramMaxHours, 0)];

  List<(double, double)> _ceiling() => [
        (kNomogramMinHours, maxY + 2),
        (kNomogramMaxHours, maxY + 2),
      ];

  void _fillZone(
    Canvas canvas,
    double Function(double) cx,
    double Function(double) cy, {
    required List<(double, double)> lower,
    required List<(double, double)> upper,
    required Color color,
  }) {
    final path = Path();
    path.moveTo(cx(lower.first.$1), cy(lower.first.$2));
    for (final p in lower.skip(1)) {
      path.lineTo(cx(p.$1), cy(p.$2));
    }
    for (final p in upper.reversed) {
      path.lineTo(cx(p.$1), cy(p.$2));
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  // ── Boundary lines ─────────────────────────────────────────────────────────

  void _drawBoundaryLines(
      Canvas canvas, double Function(double) cx, double Function(double) cy) {
    for (final entry in [
      (bc.kBoundaryLow, BhutaniZone.low.color),
      (bc.kBoundaryHighIntermediate, BhutaniZone.intermediate.color),
      (bc.kBoundaryHigh, BhutaniZone.highIntermediate.color),
      (bc.kBoundaryVeryHigh, BhutaniZone.high.color),
    ]) {
      final curve = entry.$1;
      final color = entry.$2;
      final paint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final path = Path();
      path.moveTo(cx(curve.first.$1), cy(curve.first.$2));
      for (final p in curve.skip(1)) {
        path.lineTo(cx(p.$1), cy(p.$2));
      }
      canvas.drawPath(path, paint);
    }
  }

  // ── Axes ───────────────────────────────────────────────────────────────────

  void _drawAxes(Canvas canvas, Size size, double Function(double) cx,
      double Function(double) cy, double w, double h) {
    final axisPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    // X-axis ticks
    for (final tick in kNomogramXTicks) {
      final x = cx(tick);
      canvas.drawLine(
        Offset(x, _topPad),
        Offset(x, _topPad + h),
        axisPaint,
      );
      _paintLabel(
        canvas,
        tick.toInt().toString(),
        Offset(x, _topPad + h + 4),
        center: true,
      );
    }

    // Y-axis ticks (every 4 mg/dL)
    for (double v = 0; v <= maxY; v += 4) {
      final y = cy(v);
      canvas.drawLine(
        Offset(_leftPad, y),
        Offset(_leftPad + w, y),
        axisPaint,
      );
      _paintLabel(
        canvas,
        v.toInt().toString(),
        Offset(2, y - 6),
        center: false,
      );
    }
  }

  void _paintLabel(Canvas canvas, String text, Offset offset,
      {required bool center}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      center ? offset.translate(-tp.width / 2, 0) : offset,
    );
  }

  // ── Data points ────────────────────────────────────────────────────────────

  void _drawDataPoints(
      Canvas canvas, double Function(double) cx, double Function(double) cy) {
    if (measurements.isEmpty) return;

    final latest = measurements.first;

    // History points (if toggled on)
    if (showHistory && measurements.length > 1) {
      final histPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final path = Path();
      bool first = true;
      for (final m in measurements.reversed) {
        final x = cx(m.ageHours.clamp(kNomogramMinHours, kNomogramMaxHours));
        final y = cy(m.bilirubinMgDl.clamp(0, maxY));
        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
        canvas.drawCircle(Offset(x, y), 4, histPaint);
      }
      canvas.drawPath(
        path,
        histPaint..style = PaintingStyle.stroke,
      );
    }

    // Latest measurement — filled, zone-coloured
    final zone = bc.classify(latest.ageHours, latest.bilirubinMgDl);
    final latestColor = zone?.color ?? Colors.blueGrey;
    final x = cx(latest.ageHours.clamp(kNomogramMinHours, kNomogramMaxHours));
    final y = cy(latest.bilirubinMgDl.clamp(0, maxY));

    // Dashed vertical line from x-axis to point
    _drawDashedLine(canvas, Offset(x, _topPad + (maxY - 0) * 0),
        Offset(x, y), latestColor.withValues(alpha: 0.5));

    canvas.drawCircle(
      Offset(x, y),
      7,
      Paint()..color = latestColor,
    );
    canvas.drawCircle(
      Offset(x, y),
      7,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashLen = 4.0;
    const gapLen = 4.0;
    final total = (to - from).distance;
    final dir = (to - from) / total;
    double covered = 0;
    bool drawing = true;
    while (covered < total) {
      final segLen = min(drawing ? dashLen : gapLen, total - covered);
      if (drawing) {
        canvas.drawLine(
          from + dir * covered,
          from + dir * (covered + segLen),
          paint,
        );
      }
      covered += segLen;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(BhutaniPainter old) =>
      old.measurements != measurements ||
      old.showHistory != showHistory ||
      old.maxY != maxY;
}
