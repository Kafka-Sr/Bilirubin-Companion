import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';

AppGlassTheme glassThemeOf(BuildContext context) {
  return Theme.of(context).extension<AppGlassTheme>()!;
}

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glass.backgroundTop, glass.backgroundBottom],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: _GlowBlob(color: glass.accentA, size: 220),
          ),
          Positioned(
            left: -40,
            top: 180,
            child: _GlowBlob(color: glass.accentB, size: 160),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: _GlowBlob(color: glass.accentA.withOpacity(0.9), size: 180),
          ),
          child,
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 28,
    this.onTap,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final borderRadius = BorderRadius.circular(radius);
    final backgroundGradient =
        gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glass.cardFill, glass.cardOverlay],
        );

    final content = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: backgroundGradient,
            border: Border.all(color: glass.border),
            boxShadow: [
              BoxShadow(
                color: glass.shadow,
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [glass.surfaceHighlight, Colors.transparent],
                stops: const [0, 0.42],
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: borderRadius, child: content),
    );
  }
}

class GlassActionButton extends StatelessWidget {
  const GlassActionButton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      padding: EdgeInsets.zero,
      child: SizedBox(height: 52, width: 52, child: Center(child: child)),
    );
  }
}

class GlassPillButton extends StatelessWidget {
  const GlassPillButton({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: child,
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
        ),
      ),
    );
  }
}
