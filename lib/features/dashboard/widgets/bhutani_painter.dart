import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bilirubin/core/constants.dart';
import 'package:bilirubin/core/l10n/app_localizations.dart';
import 'package:bilirubin/models/measurement.dart';
import 'package:bilirubin/utils/bhutani_classifier.dart' as bc;

/// [CustomPainter] that draws the Bhutani nomogram chart.
///
/// X-axis spans 0–168 h (baby age). Y-axis spans 0–maxY mg/dL.
/// Readings with ageHours > 168 are clamped to x=168 and rendered in purple.
class BhutaniPainter extends CustomPainter {
  const BhutaniPainter({
    required this.context,
    required this.measurements,
    required this.showHistory,
    required this.showOutsideRange,
    required this.maxY,
  });

  final BuildContext context;
  final List<Measurement> measurements;
  final bool showHistory;
  final bool showOutsideRange;
  final double maxY;

  // Chart margins (left is larger to allow Y-axis number labels)
  static const double _left = 36;
  static const double _right = 16;
  static const double _top = 8;
  static const double _bottom = 28;

  // Zone fill colours: low → lowIntermediate → highIntermediate → high
  static const List<Color> _zoneColors = [
    Color(0xFFBBF7D0), // green
    Color(0xFFFEF08A), // yellow
    Color(0xFFFECACA), // light red
    Color(0xFFFCA5A5), // red
  ];

  static List<String> _zoneLabels(AppLocalizations l10n) => [
    l10n.zoneLowFull,
    l10n.zoneLowIntermediateFull,
    l10n.zoneHighIntermediateFull,
    l10n.zoneHighFull,
  ];

  // Three boundary curves: 40th, 75th, 95th percentile
  static final List<List<(double, double)>> _boundaries = [
    bc.kBoundaryHighIntermediate, // 40th  – Low / LowIntermediate boundary
    bc.kBoundaryHigh,             // 75th  – LowIntermediate / HighIntermediate boundary
    bc.kBoundaryVeryHigh,         // 95th  – HighIntermediate / High boundary
  ];

  static const Color _purpleColor = Color(0xFF7C3AED); // violet-700

  bool _isOutside(Measurement m) => m.ageHours > kNomogramMaxHours;

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

      // Zone label – vertically centred in its zone at the right edge
      final lowerEndY = pxY(lower.last.$2);
      final upperEndY = pxY(min(upper.last.$2, maxY));
      final midY = (lowerEndY + upperEndY) / 2;
      _paintText(
        canvas,
        _zoneLabels(l10n)[i],
        Offset(chartRect.right - 130, midY - 5),
        colorScheme.onSurface.withValues(alpha: 0.72),
        fontSize: 9,
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

    // X-axis ticks every 12 h
    for (final tick in kNomogramXTicks) {
      final x = pxX(tick);
      canvas.drawLine(Offset(x, chartRect.top), Offset(x, chartRect.bottom), gridPaint);
      _paintText(
        canvas,
        tick.toInt().toString(),
        Offset(x, chartRect.bottom + 3),
        colorScheme.onSurfaceVariant,
        center: true,
        fontSize: 8,
      );
    }

    // Y-axis ticks every 5 mg/dL
    for (double y = 0; y <= maxY; y += 5) {
      final py = pxY(y);
      canvas.drawLine(Offset(chartRect.left, py), Offset(chartRect.right, py), gridPaint);
      // Right-align the number just left of the chart area
      final label = y.toInt().toString();
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(chartRect.left - tp.width - 3, py - tp.height / 2));
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
      ..strokeWidth = 1.2
      ..color = colorScheme.outline.withValues(alpha: 0.65);

    for (final curve in _boundaries) {
      // Solid segment 0–120 h, dashed 120–168 h
      final solidPath = Path()
        ..moveTo(pxX(curve.first.$1), pxY(curve.first.$2));
      for (final p in curve) {
        if (p.$1 <= 120) solidPath.lineTo(pxX(p.$1), pxY(p.$2));
      }
      canvas.drawPath(solidPath, paint);

      // Dashed extension 120–168 h
      final dashPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = colorScheme.outline.withValues(alpha: 0.65);

      final x120 = pxX(120);
      final x168 = pxX(168);
      final y120 = pxY(curve.last.$2); // plateau value
      double dx = x120;
      while (dx < x168) {
        canvas.drawLine(
          Offset(dx, y120),
          Offset(min(dx + 5, x168), y120),
          dashPaint,
        );
        dx += 9;
      }
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
    final latestIsOutside = _isOutside(latest);

    // ── History line + dots ─────────────────────────────────────────────────
    if (showHistory && measurements.length > 1) {
      final sorted = measurements.reversed.toList();

      // Build a filtered list for the history line:
      // include in-range always; include outside-range only when toggle is on,
      // but NEVER include latest here (it's drawn separately below).
      final historyMeasurements = sorted
          .where((m) => m != latest)
          .where((m) => !_isOutside(m) || showOutsideRange)
          .toList();

      if (historyMeasurements.isNotEmpty) {
        final linePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = colorScheme.primary.withValues(alpha: 0.6);

        final path = Path();
        bool started = false;
        for (final m in historyMeasurements) {
          final pt = Offset(
            pxX(m.ageHours.clamp(kNomogramMinHours, kNomogramMaxHours)),
            pxY(m.bilirubinMgDl.clamp(0, maxY)),
          );
          if (!started) {
            path.moveTo(pt.dx, pt.dy);
            started = true;
          } else {
            path.lineTo(pt.dx, pt.dy);
          }
        }
        canvas.drawPath(path, linePaint);

        for (final m in historyMeasurements) {
          final outside = _isOutside(m);
          canvas.drawCircle(
            Offset(
              pxX(m.ageHours.clamp(kNomogramMinHours, kNomogramMaxHours)),
              pxY(m.bilirubinMgDl.clamp(0, maxY)),
            ),
            3.5,
            Paint()
              ..color = outside
                  ? _purpleColor.withValues(alpha: 0.8)
                  : colorScheme.primary.withValues(alpha: 0.8),
          );
        }
      }
    }

    // ── Latest point ─────────────────────────────────────────────────────────
    // Always shown; purple if outside 168 h range.
    final dotColor = latestIsOutside ? _purpleColor : colorScheme.error;
    final lx = pxX(latest.ageHours.clamp(kNomogramMinHours, kNomogramMaxHours));
    final ly = pxY(latest.bilirubinMgDl.clamp(0, maxY));

    // Dashed vertical line from chart top to dot
    final dashPaint = Paint()
      ..color = dotColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.2;
    var dashY = chartRect.top;
    while (dashY < ly) {
      canvas.drawLine(Offset(lx, dashY), Offset(lx, min(dashY + 4, ly)), dashPaint);
      dashY += 7;
    }

    canvas.drawCircle(Offset(lx, ly), 7, Paint()..color = dotColor);
    canvas.drawCircle(Offset(lx, ly), 3, Paint()..color = Colors.white);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    double fontSize = 10,
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
      old.showOutsideRange != showOutsideRange ||
      old.maxY != maxY;
}
