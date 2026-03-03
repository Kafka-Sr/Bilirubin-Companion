import 'dart:math';

import 'package:bilirubin_companion/data/models.dart';
import 'package:bilirubin_companion/domain/bhutani.dart';
import 'package:flutter/material.dart';

class NomogramCard extends StatelessWidget {
  const NomogramCard({super.key, required this.measurements, required this.showPrevious, required this.onToggle});

  final List<MeasurementRecord> measurements;
  final bool showPrevious;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final yMax = computeDynamicYMax(measurements.map((m) => m.bilirubinMgDl).toList());
    return Card(
      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2335) : const Color(0xFF23283A),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bhutani Nomogram', style: TextStyle(fontSize: 32 / 1.6, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 1.35,
              child: CustomPaint(
                painter: NomogramPainter(measurements: measurements, yMax: yMax, showPrevious: showPrevious),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(value: showPrevious, onChanged: (v) => onToggle(v ?? false), checkColor: Colors.white),
                const Text('Show Previous Bilirubin', style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NomogramPainter extends CustomPainter {
  NomogramPainter({required this.measurements, required this.yMax, required this.showPrevious});

  final List<MeasurementRecord> measurements;
  final double yMax;
  final bool showPrevious;

  @override
  void paint(Canvas canvas, Size size) {
    final chartRect = Rect.fromLTWH(40, 18, size.width - 56, size.height - 54);
    final boundaryPaint = Paint()..color = Colors.white54..style = PaintingStyle.stroke..strokeWidth = 1;

    _drawGrid(canvas, chartRect);
    _drawZones(canvas, chartRect);

    for (final path in _boundaryPaths(chartRect)) {
      canvas.drawPath(path, boundaryPaint);
    }

    final points = measurements.reversed.toList();
    if (points.isNotEmpty) {
      final latest = points.last;
      final latestPoint = _toOffset(chartRect, latest.ageHours.toDouble(), latest.bilirubinMgDl);
      if (showPrevious && points.length > 1) {
        final line = Paint()..color = Colors.white70..strokeWidth = 1.2..style = PaintingStyle.stroke;
        final p = Path();
        for (var i = 0; i < points.length - 1; i++) {
          final point = _toOffset(chartRect, points[i].ageHours.toDouble(), points[i].bilirubinMgDl);
          if (i == 0) {
            p.moveTo(point.dx, point.dy);
          } else {
            p.lineTo(point.dx, point.dy);
          }
          canvas.drawCircle(point, 3, Paint()..color = Colors.white70);
        }
        canvas.drawPath(p, line);
      }
      final dash = Paint()..color = Colors.white38..strokeWidth = 1;
      for (double y = chartRect.top; y < chartRect.bottom; y += 6) {
        canvas.drawLine(Offset(latestPoint.dx, y), Offset(latestPoint.dx, min(y + 3, chartRect.bottom)), dash);
      }
      canvas.drawCircle(latestPoint, 4.5, Paint()..color = const Color(0xFFFFD369));
      canvas.drawCircle(latestPoint, 7, Paint()..color = const Color(0x88FFD369)..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    _drawAxes(canvas, chartRect);
  }

  List<Path> _boundaryPaths(Rect chartRect) => [lowUpperY, intermediateUpperY, highInterUpperY, highUpperY].map((series) {
        final p = Path();
        for (var i = 0; i < xAnchors.length; i++) {
          final point = _toOffset(chartRect, xAnchors[i], series[i]);
          if (i == 0) {
            p.moveTo(point.dx, point.dy);
          } else {
            p.lineTo(point.dx, point.dy);
          }
        }
        return p;
      }).toList();

  void _drawZones(Canvas canvas, Rect rect) {
    final bounds = [
      lowUpperY,
      intermediateUpperY,
      highInterUpperY,
      highUpperY,
      List<double>.filled(xAnchors.length, yMax),
    ];
    final lows = [
      List<double>.filled(xAnchors.length, 0),
      lowUpperY,
      intermediateUpperY,
      highInterUpperY,
      highUpperY,
    ];
    final fills = [
      const [Color(0xFF13432B), Color(0xFF56A86C)],
      const [Color(0xFF414958), Color(0xFF6D7384)],
      const [Color(0xFF955420), Color(0xFFC6843D)],
      const [Color(0xFF8D7A0F), Color(0xFFD7C340)],
      const [Color(0xFF6F1F28), Color(0xFFA43646)],
    ];

    for (var z = 0; z < bounds.length; z++) {
      final p = Path();
      for (var i = 0; i < xAnchors.length; i++) {
        final top = _toOffset(rect, xAnchors[i], bounds[z][i]);
        if (i == 0) {
          p.moveTo(top.dx, top.dy);
        } else {
          p.lineTo(top.dx, top.dy);
        }
      }
      for (var i = xAnchors.length - 1; i >= 0; i--) {
        final bottom = _toOffset(rect, xAnchors[i], lows[z][i]);
        p.lineTo(bottom.dx, bottom.dy);
      }
      p.close();
      final grad = Paint()
        ..shader = LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: fills[z]).createShader(rect);
      canvas.drawPath(p, grad);
    }

    const labels = [
      ('Very High Risk Zone', 0.78, 0.08),
      ('High Risk Zone', 0.78, 0.25),
      ('High Intermediate Risk Zone', 0.78, 0.42),
      ('Intermediate Risk Zone', 0.78, 0.59),
      ('Low Risk Zone', 0.78, 0.8),
    ];
    for (final label in labels) {
      final tp = TextPainter(
        text: TextSpan(
          text: label.$1,
          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600, shadows: [Shadow(color: Colors.black54, blurRadius: 2)]),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: rect.width * 0.28);
      tp.paint(canvas, Offset(rect.left + rect.width * label.$2, rect.top + rect.height * label.$3));
    }
  }

  void _drawGrid(Canvas canvas, Rect rect) {
    final grid = Paint()..color = Colors.white12..strokeWidth = 1;
    for (final x in xAnchors) {
      final offset = _toOffset(rect, x, 0);
      canvas.drawLine(Offset(offset.dx, rect.top), Offset(offset.dx, rect.bottom), grid);
    }
    for (int y = 0; y <= yMax; y += 2) {
      final dy = _toOffset(rect, 3, y.toDouble()).dy;
      canvas.drawLine(Offset(rect.left, dy), Offset(rect.right, dy), grid);
    }
  }

  void _drawAxes(Canvas canvas, Rect rect) {
    final xTicks = [3, 12, 24, 48, 72, 96, 120];
    for (final x in xTicks) {
      final point = _toOffset(rect, x.toDouble(), 0);
      _text(canvas, '$x', Offset(point.dx - 8, rect.bottom + 5));
    }
    for (int y = 0; y <= yMax; y += 2) {
      final point = _toOffset(rect, 3, y.toDouble());
      _text(canvas, '$y', Offset(rect.left - 26, point.dy - 7));
    }
    _text(canvas, 'Hour of Life', Offset(rect.left + rect.width / 2 - 28, rect.bottom + 22));
    canvas.save();
    canvas.translate(rect.left - 34, rect.top + rect.height / 2 + 34);
    canvas.rotate(-pi / 2);
    _text(canvas, 'Bilirubin (mg/dL)', const Offset(0, 0));
    canvas.restore();
  }

  Offset _toOffset(Rect chartRect, double x, double y) {
    final nx = ((x.clamp(3, 120) - 3) / 117);
    final ny = (y.clamp(0, yMax) / yMax);
    return Offset(chartRect.left + nx * chartRect.width, chartRect.bottom - ny * chartRect.height);
  }

  void _text(Canvas canvas, String value, Offset offset) {
    final text = TextPainter(
      text: TextSpan(text: value, style: const TextStyle(fontSize: 10, color: Colors.white70)),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant NomogramPainter oldDelegate) {
    return oldDelegate.measurements != measurements || oldDelegate.showPrevious != showPrevious || oldDelegate.yMax != yMax;
  }
}
