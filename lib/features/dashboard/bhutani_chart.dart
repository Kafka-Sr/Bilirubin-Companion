import 'dart:math';

import 'package:bilirubin/core/theme/app_theme.dart';
import 'package:bilirubin/models/app_enums.dart';
import 'package:bilirubin/models/measurement.dart';
import 'package:flutter/material.dart';

const List<double> xAnchors = [3, 12, 24, 48, 72, 96, 120];
const List<double> lowUpperY = [1.0, 4.0, 6.0, 8.0, 9.0, 11.0, 11.0];
const List<double> intermediateUpperY = [2.0, 6.0, 8.5, 11.0, 13.5, 14.0, 15.0];
const List<double> highInterUpperY = [3.0, 9.0, 12.0, 15.0, 17.0, 17.0, 17.0];
const List<double> highUpperY = [4.0, 10.5, 15.5, 17.5, 19.5, 19.0, 18.5];

BhutaniZone? classifyBhutaniZone({required double ageHours, required double bilirubinMgDl}) {
  if (bilirubinMgDl.isNaN || bilirubinMgDl.isInfinite) {
    return null;
  }
  final x = ageHours.clamp(3, 120).toDouble();
  final y = max(0, bilirubinMgDl);

  final lowUpper = _interpolate(x, lowUpperY);
  final intermediateUpper = _interpolate(x, intermediateUpperY);
  final highIntermediateUpper = _interpolate(x, highInterUpperY);
  final highRiskUpper = _interpolate(x, highUpperY);

  if (y <= lowUpper) {
    return BhutaniZone.lowRiskZone;
  }
  if (y <= intermediateUpper) {
    return BhutaniZone.intermediateRiskZone;
  }
  if (y <= highIntermediateUpper) {
    return BhutaniZone.highIntermediateRiskZone;
  }
  if (y <= highRiskUpper) {
    return BhutaniZone.highRiskZone;
  }
  return BhutaniZone.veryHighRiskZone;
}

double _interpolate(double x, List<double> yValues) {
  for (var index = 0; index < xAnchors.length - 1; index++) {
    final x1 = xAnchors[index];
    final x2 = xAnchors[index + 1];
    if (x >= x1 && x <= x2) {
      final t = (x - x1) / (x2 - x1);
      return yValues[index] + (yValues[index + 1] - yValues[index]) * t;
    }
  }
  return yValues.last;
}

class BhutaniChartCard extends StatelessWidget {
  const BhutaniChartCard({
    super.key,
    required this.measurements,
    required this.showPrevious,
    required this.onTogglePrevious,
  });

  final List<Measurement> measurements;
  final bool showPrevious;
  final ValueChanged<bool> onTogglePrevious;

  @override
  Widget build(BuildContext context) {
    final latest = measurements.isEmpty ? null : measurements.last;
    final maxMeasurement = measurements.fold<double>(23, (value, item) => max(value, item.bilirubinMgDl));
    final yMax = maxMeasurement <= 23 ? 23.0 : ((maxMeasurement / 2).ceil() * 2 + 1).toDouble();
    final textColor = Theme.of(context).colorScheme.onSurface;
    final muted = textColor.withOpacity(0.68);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bhutani',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: CustomPaint(
            painter: BhutaniChartPainter(
              brightness: Theme.of(context).brightness,
              measurements: measurements,
              latest: latest,
              yMax: yMax,
              showPrevious: showPrevious,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Switch.adaptive(
              value: showPrevious,
              onChanged: onTogglePrevious,
            ),
            const SizedBox(width: 8),
            Text(
              'Show Previous Bilirubin',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            if (latest != null)
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD36B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    latest.bilirubinMgDl.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: muted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class BhutaniChartPainter extends CustomPainter {
  BhutaniChartPainter({
    required this.brightness,
    required this.measurements,
    required this.latest,
    required this.yMax,
    required this.showPrevious,
  });

  final Brightness brightness;
  final List<Measurement> measurements;
  final Measurement? latest;
  final double yMax;
  final bool showPrevious;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 40.0;
    const bottomPad = 34.0;
    const topPad = 18.0;
    const rightPad = 14.0;

    final chartRect = Rect.fromLTWH(
      leftPad,
      topPad,
      size.width - leftPad - rightPad,
      size.height - topPad - bottomPad,
    );

    final axisColor = AppThemeTokens.textFor(brightness).withOpacity(0.85);
    final gridColor = axisColor.withOpacity(0.14);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawZone(List<double> lower, List<double> upper, List<Color> colors) {
      final path = Path();
      path.moveTo(chartRect.left + _dx(3, chartRect), chartRect.bottom - _dy(lower.first));
      for (var i = 1; i < xAnchors.length; i++) {
        path.lineTo(chartRect.left + _dx(xAnchors[i], chartRect), chartRect.bottom - _dy(lower[i]));
      }
      for (var i = xAnchors.length - 1; i >= 0; i--) {
        path.lineTo(chartRect.left + _dx(xAnchors[i], chartRect), chartRect.bottom - _dy(upper[i]));
      }
      path.close();
      final bounds = path.getBounds();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            colors: colors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
      );
    }

    final yTicks = <int>[];
    for (var value = 0; value <= yMax.round(); value += 2) {
      yTicks.add(value);
    }

    for (final tick in yTicks) {
      final y = chartRect.bottom - _dy(tick.toDouble());
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1,
      );
      textPainter.text = TextSpan(
        text: '$tick',
        style: TextStyle(color: axisColor.withOpacity(0.86), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(8, y - 6));
    }

    for (final tick in xAnchors) {
      final x = chartRect.left + _dx(tick, chartRect);
      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1,
      );
      textPainter.text = TextSpan(
        text: tick.toInt().toString(),
        style: TextStyle(color: axisColor.withOpacity(0.86), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 8, chartRect.bottom + 8));
    }

    drawZone(List.filled(xAnchors.length, 0), lowUpperY, [
      const Color(0xFF254231).withOpacity(brightness == Brightness.dark ? 0.85 : 0.72),
      const Color(0xFF6AB879).withOpacity(brightness == Brightness.dark ? 0.68 : 0.65),
    ]);
    drawZone(lowUpperY, intermediateUpperY, [
      const Color(0x66486377),
      const Color(0x9988A2B5),
    ]);
    drawZone(intermediateUpperY, highInterUpperY, [
      const Color(0x99C87934),
      const Color(0xCCF1A34F),
    ]);
    drawZone(highInterUpperY, highUpperY, [
      const Color(0x99D4B13F),
      const Color(0xCCEFD86E),
    ]);
    drawZone(highUpperY, List.filled(xAnchors.length, yMax), [
      const Color(0x99A22E38),
      const Color(0xCCCF5A63),
    ]);

    void drawBoundary(List<double> values) {
      final path = Path();
      path.moveTo(chartRect.left + _dx(xAnchors.first, chartRect), chartRect.bottom - _dy(values.first));
      for (var i = 1; i < values.length; i++) {
        path.lineTo(chartRect.left + _dx(xAnchors[i], chartRect), chartRect.bottom - _dy(values[i]));
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withOpacity(brightness == Brightness.dark ? 0.72 : 0.92)
          ..strokeWidth = 1.05
          ..style = PaintingStyle.stroke,
      );
    }

    drawBoundary(lowUpperY);
    drawBoundary(intermediateUpperY);
    drawBoundary(highInterUpperY);
    drawBoundary(highUpperY);

    final labels = [
      ('Very High Risk Zone', const Offset(0.72, 0.07)),
      ('High Risk Zone', const Offset(0.74, 0.21)),
      ('High Intermediate Risk Zone', const Offset(0.64, 0.38)),
      ('Intermediate Risk Zone', const Offset(0.7, 0.58)),
      ('Low Risk Zone', const Offset(0.77, 0.82)),
    ];
    for (final label in labels) {
      textPainter.text = TextSpan(
        text: label.$1,
        style: TextStyle(
          color: Colors.white.withOpacity(0.92),
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      );
      textPainter.layout(maxWidth: chartRect.width * 0.28);
      textPainter.paint(
        canvas,
        Offset(
          chartRect.left + chartRect.width * label.$2.dx,
          chartRect.top + chartRect.height * label.$2.dy,
        ),
      );
    }

    canvas.drawRect(
      chartRect,
      Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = axisColor.withOpacity(0.32),
    );

    if (showPrevious && measurements.length > 1) {
      final linePath = Path();
      for (var i = 0; i < measurements.length; i++) {
        final measurement = measurements[i];
        final point = Offset(
          chartRect.left + _dx(measurement.ageHours.toDouble(), chartRect),
          chartRect.bottom - _dy(measurement.bilirubinMgDl),
        );
        if (i == 0) {
          linePath.moveTo(point.dx, point.dy);
        } else {
          linePath.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(
        linePath,
        Paint()
          ..color = const Color(0xCCFFFFFF)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );

      for (final measurement in measurements.take(measurements.length - 1)) {
        final point = Offset(
          chartRect.left + _dx(measurement.ageHours.toDouble(), chartRect),
          chartRect.bottom - _dy(measurement.bilirubinMgDl),
        );
        canvas.drawCircle(point, 3.5, Paint()..color = Colors.white.withOpacity(0.75));
      }
    }

    if (latest != null) {
      final x = chartRect.left + _dx(latest!.ageHours.toDouble(), chartRect);
      final y = chartRect.bottom - _dy(latest!.bilirubinMgDl);
      _drawDashedLine(canvas, Offset(x, chartRect.bottom), Offset(x, y), Colors.white.withOpacity(0.58));
      canvas.drawCircle(
        Offset(x, y),
        7,
        Paint()..color = const Color(0xFFFFD36B),
      );
      canvas.drawCircle(
        Offset(x, y),
        12,
        Paint()..color = const Color(0x33FFD36B),
      );
    }

    textPainter.text = TextSpan(
      text: 'Hour of Life',
      style: TextStyle(color: axisColor, fontWeight: FontWeight.w700, fontSize: 11),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(chartRect.center.dx - 28, size.height - 18));

    canvas.save();
    canvas.translate(10, chartRect.center.dy + 32);
    canvas.rotate(-pi / 2);
    textPainter.text = TextSpan(
      text: 'Bilirubin (mg/dL)',
      style: TextStyle(color: axisColor, fontWeight: FontWeight.w700, fontSize: 11),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, 0));
    canvas.restore();
  }

  double _dx(double x, Rect rect) => ((x - 3) / (120 - 3)) * rect.width;
  double _dy(double y) => (y / yMax) * (300 - 18 - 34);

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    const dashHeight = 4.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    var currentY = start.dy;
    while (currentY > end.dy) {
      final nextY = max(end.dy, currentY - dashHeight);
      canvas.drawLine(Offset(start.dx, currentY), Offset(start.dx, nextY), paint);
      currentY -= dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant BhutaniChartPainter oldDelegate) {
    return oldDelegate.measurements != measurements ||
        oldDelegate.brightness != brightness ||
        oldDelegate.showPrevious != showPrevious ||
        oldDelegate.yMax != yMax;
  }
}
