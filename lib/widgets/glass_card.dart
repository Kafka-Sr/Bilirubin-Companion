import 'dart:ui';

import 'package:bilirubin/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 28,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppThemeTokens.glassColor(brightness),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppThemeTokens.borderColor(brightness),
            ),
            boxShadow: AppThemeTokens.shadows(brightness),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(brightness == Brightness.dark ? 0.08 : 0.45),
                Colors.white.withOpacity(brightness == Brightness.dark ? 0.03 : 0.14),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      ),
    );
  }
}
