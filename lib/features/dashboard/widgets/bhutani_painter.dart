import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bilirubin/core/constants.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/models/measurement.dart';
import 'package:bilirubin/utils/bhutani_classifier.dart' as bc;

/// [CustomPainter] that draws the Bhutani nomogram chart.
///
/// Design: gradient zone fills with right-side labels, red dot for the latest
/// measurement, primary-coloured connecting line for history.
class BhutaniPainter extends CustomPainter {
  const BhutaniPainter({
    required this.context,
    required this.measurements,
    required this.showHistory,
    required this.maxY,
  });

  final BuildContext context;
  final List<Measurement> measurements;
  final bool showHistory;
  final double maxY;

  // Chart margins
  static const double _left = 32;
  static const double _right = 16;
  static const double _top = 8;
  static const double _bottom = 24;

  // Zone fill colours (low → veryHigh)
  static const List<Color> _zoneColors = [
    Color(0xFFBBF7D0),
    Color(0xFFECFCCB),
    Color(0xFFFEF08A),
    Color(0xFFFECACA),
    Color(0xFFFCA5A5),
  ];

  static List<String> _zoneLabels(AppLocalizations l10n) => [
    l10n.zoneLowFull,
    l10n.zoneIntermediateFull,
    l10n.zoneHighIntermediateFull,
    l10n.zoneHighFull,
    l10n.zoneVeryHighFull,
  ];

  // Boundary curves in ascending order (lower threshold of each zone above low)
  static final List<List<(double, double)>> _boundaries = [
    bc.kBoundaryLow,
    bc.kBoundaryHighIntermediate,
    bc.kBoundaryHigh,
    bc.kBoundaryVeryHigh,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final chartRect = Rect.fromLTRB(
      _left, _top, size.width - _right, size.height - _bottom,
    );

    double pxX(double x) =>
        chartRect.left +
        ((x.clamp(kNomogramMinHours, kNomogramMaxHours) - kNomogramMinHours) /
            (kNomogramMaxHours - kNomogramMinHours)) *
            chartRect.width;
    double pxY(double y) =>
        chartRect.bottom - (y.clamp(0, maxY) / maxY) * chartRect.height;

    _drawZones(canvas, chartRect, colorScheme, l10n, pxX, pxY);
    _drawGrid(canvas, chartRect, colorScheme, pxX, pxY);
    _drawBoundaries(canvas, colorScheme, pxX, pxY);
    _drawData(canvas, chartRect, colorScheme, pxX, pxY);
  }

  // ── Zone fills + labels ───────────────────────────────────────────────────

  void _drawZones(
    Canvas canvas,
    Rect chartRect,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    double Function(double) pxX,
    double Function(double) pxY,
  ) {
    // Build list of lower/upper boundary pairs per zone
    final lowerCurves = <List<(double, double)>>[
      [(kNomogramMinHours, 0.0), (kNomogramMaxHours, 0.0)],
      ..._boundaries,
    ];
    final upperCurves = <List<(double, double)>>[
      ..._boundaries,
      [(kNomogramMinHours, maxY + 2), (kNomogramMaxHours, maxY + 2)],
    ];

    for (var i = 0; i < _zoneColors.length; i++) {
      final lower = lowerCurves[i];
      final upper = upperCurves[i];
      final color = _zoneColors[i];

      final path = Path()
        ..moveTo(pxX(lower.first.$1), pxY(lower.first.$2));
      for (final p in lower.skip(1)) {
        path.lineTo(pxX(p.$1), pxY(p.$2));
      }
      for (final p in upper.reversed) {
        path.lineTo(pxX(p.$1), pxY(min(p.$2, maxY)));
      }
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.45),
              color.withValues(alpha: 0.18),
            ],
          ).createShader(chartRect),
      );

      // Label: vertically centred within the zone on the right edge
      final lowerEndY = pxY(lower.last.$2);
      final upperEndY = pxY(min(upper.last.$2, maxY));
      final midY = (lowerEndY + upperEndY) / 2;
      _paintText(
        canvas,
        _zoneLabels(l10n)[i],
        Offset(chartRect.right - 130, midY - 6),
        colorScheme.onSurface.withValues(alpha: 0.76),
        fontSize: 10,
      );
    }
  }

  // ── Grid + axis labels ────────────────────────────────────────────────────

  void _drawGrid(
    Canvas canvas,
    Rect chartRect,
    ColorScheme colorScheme,
    double Function(double) pxX,
    double Function(double) pxY,
  ) {
    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.4)
      ..strokeWidth = 1;

    for (final tick in kNomogramXTicks) {
      final x = pxX(tick);
      canvas.drawLine(Offset(x, chartRect.top), Offset(x, chartRect.bottom), gridPaint);
      _paintText(
        canvas,
        tick.toInt().toString(),
        Offset(x, chartRect.bottom + 2),
        colorScheme.onSurfaceVariant,
        center: true,
      );
    }

    for (double y = 0; y <= maxY; y += 4) {
      final py = pxY(y);
      canvas.drawLine(Offset(chartRect.left, py), Offset(chartRect.right, py), gridPaint);
      _paintText(
        canvas,
        y.toInt().toString(),
        Offset(0, py - 6),
        colorScheme.onSurfaceVariant,
      );
    }
  }

  // ── Boundary lines ────────────────────────────────────────────────────────

  void _drawBoundaries(
    Canvas canvas,
    ColorScheme colorScheme,
    double Function(double) pxX,
    double Function(double) pxY,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = colorScheme.outline.withValues(alpha: 0.6);

    for (final curve in _boundaries) {
      final path = Path()
        ..moveTo(pxX(curve.first.$1), pxY(curve.first.$2));
      for (final p in curve.skip(1)) {
        path.lineTo(pxX(p.$1), pxY(p.$2));
      }
      canvas.drawPath(path, paint);
    }
  }

  // ── Data points ───────────────────────────────────────────────────────────

  void _drawData(
    Canvas canvas,
    Rect chartRect,
    ColorScheme colorScheme,
    double Function(double) pxX,
    double Function(double) pxY,
  ) {
    if (measurements.isEmpty) return;

    final latest = measurements.first;

    if (showHistory && measurements.length > 1) {
      final sorted = measurements.reversed.toList();
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = colorScheme.primary.withValues(alpha: 0.6);

      final path = Path();
      for (var i = 0; i < sorted.length; i++) {
        final m = sorted[i];
        final pt = Offset(
          pxX(m.ageHours.clamp(kNomogramMinHours, kNomogramMaxHours)),
          pxY(m.bilirubinMgDl.clamp(0, maxY)),
        );
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(path, linePaint);

      for (final m in sorted) {
        canvas.drawCircle(
          Offset(
            pxX(m.ageHours.clamp(kNomogramMinHours, kNomogramMaxHours)),
            pxY(m.bilirubinMgDl.clamp(0, maxY)),
          ),
          3,
          Paint()..color = colorScheme.primary.withValues(alpha: 0.8),
        );
      }
    }

    // Latest point
    final lx = pxX(latest.ageHours.clamp(kNomogramMinHours, kNomogramMaxHours));
    final ly = pxY(latest.bilirubinMgDl.clamp(0, maxY));

    // Dashed vertical line from top of chart to dot
    final dashPaint = Paint()
      ..color = colorScheme.error.withValues(alpha: 0.5)
      ..strokeWidth = 1.2;
    var dashY = chartRect.top;
    while (dashY < ly) {
      canvas.drawLine(Offset(lx, dashY), Offset(lx, min(dashY + 4, ly)), dashPaint);
      dashY += 7;
    }

    canvas.drawCircle(Offset(lx, ly), 7, Paint()..color = colorScheme.error);
    canvas.drawCircle(Offset(lx, ly), 3, Paint()..color = colorScheme.onError);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    double fontSize = 11,
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, color: color)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 140);
    tp.paint(canvas, center ? offset.translate(-tp.width / 2, 0) : offset);
  }

  @override
  bool shouldRepaint(BhutaniPainter old) =>
      old.measurements != measurements ||
      old.showHistory != showHistory ||
      old.maxY != maxY;
}
