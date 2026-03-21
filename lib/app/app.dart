import 'dart:ui';

import 'package:bilirubin/app/providers.dart';
import 'package:bilirubin/core/theme/app_theme.dart';
import 'package:bilirubin/features/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BilirubinApp extends StatelessWidget {
  const BilirubinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          final settings = ref.watch(appSettingsProvider);
          return MaterialApp(
            title: 'Bilirubin Companion',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: buildAppTheme(Brightness.light),
            darkTheme: buildAppTheme(Brightness.dark),
            builder: (context, child) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppThemeTokens.backgroundGradient(
                    Theme.of(context).brightness,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _AmbientPainter(
                            brightness: Theme.of(context).brightness,
                          ),
                        ),
                      ),
                    ),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            },
            home: const DashboardPage(),
          );
        },
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter({required this.brightness});

  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final primary = brightness == Brightness.light
        ? const Color(0x332D517E)
        : const Color(0x2297C8E9);
    final secondary = brightness == Brightness.light
        ? const Color(0x225179A3)
        : const Color(0x22C3E0F1);

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.12),
      size.width * 0.28,
      Paint()..color = primary,
    );
    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.24),
      size.width * 0.22,
      Paint()..color = secondary,
    );
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.9),
      size.width * 0.35,
      Paint()..color = primary.withOpacity(0.65),
    );
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) {
    return oldDelegate.brightness != brightness;
  }
}
