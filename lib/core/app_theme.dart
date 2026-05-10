import 'package:flutter/material.dart';

/// Clinical colour tokens.
abstract final class AppColors {
  // ── Brand / primary ────────────────────────────────────────────────────────
  static const clinicalBlue = Color(0xFF0066CC);
  static const clinicalBlueDark = Color(0xFF4DA3FF);

  // ── Zone colours ───────────────────────────────────────────────────────────
  static const zoneLow = Color(0xFF2E7D32);
  static const zoneIntermediate = Color(0xFF558B2F);
  static const zoneHighIntermediate = Color(0xFFF57F17);
  static const zoneHigh = Color(0xFFE65100);
  static const zoneVeryHigh = Color(0xFFB71C1C);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const connected = Color(0xFF2E7D32);
  static const disconnected = Color(0xFFB71C1C);
}

/// App-wide Material 3 themes.
abstract final class AppTheme {
  static ThemeData light() => _build(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.clinicalBlue,
          brightness: Brightness.light,
        ),
      );

  static ThemeData dark() => _build(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.clinicalBlueDark,
          brightness: Brightness.dark,
        ),
      );

  static ThemeData _build({required ColorScheme colorScheme}) {
    final isDark = colorScheme.brightness == Brightness.dark;
    const lightBlue = Color(0xFF425D91);
    const darkBlue = Color(0xFFA3C9FE);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'PlusJakartaSans',
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: 'PlusJakartaSans'),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? darkBlue : lightBlue,
          foregroundColor: isDark ? const Color(0xFF001D36) : Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        errorStyle: TextStyle(
          color: colorScheme.error,
          fontSize: 12,
          height: 1.4,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }
}
