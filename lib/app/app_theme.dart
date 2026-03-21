import 'package:flutter/material.dart';

class AppPalette {
  static const lightBackground = Color(0xFFFCFDFD);
  static const lightSurface = Color(0xFFF4F4F4);
  static const lightPrimary = Color(0xFF2D517E);
  static const lightSecondary = Color(0xFF5179A3);
  static const lightText = Color(0xFF1E1E1E);

  static const darkBackground = Color(0xFF111313);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkPrimary = Color(0xFF97C8E9);
  static const darkSecondary = Color(0xFFC3E0F1);
  static const darkText = Color(0xFFF4F4F4);
}

@immutable
class AppGlassTheme extends ThemeExtension<AppGlassTheme> {
  const AppGlassTheme({
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.cardFill,
    required this.cardOverlay,
    required this.border,
    required this.shadow,
    required this.mutedText,
    required this.accentA,
    required this.accentB,
    required this.surfaceHighlight,
  });

  final Color backgroundTop;
  final Color backgroundBottom;
  final Color cardFill;
  final Color cardOverlay;
  final Color border;
  final Color shadow;
  final Color mutedText;
  final Color accentA;
  final Color accentB;
  final Color surfaceHighlight;

  @override
  AppGlassTheme copyWith({
    Color? backgroundTop,
    Color? backgroundBottom,
    Color? cardFill,
    Color? cardOverlay,
    Color? border,
    Color? shadow,
    Color? mutedText,
    Color? accentA,
    Color? accentB,
    Color? surfaceHighlight,
  }) {
    return AppGlassTheme(
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      cardFill: cardFill ?? this.cardFill,
      cardOverlay: cardOverlay ?? this.cardOverlay,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      mutedText: mutedText ?? this.mutedText,
      accentA: accentA ?? this.accentA,
      accentB: accentB ?? this.accentB,
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
    );
  }

  @override
  ThemeExtension<AppGlassTheme> lerp(
    covariant ThemeExtension<AppGlassTheme>? other,
    double t,
  ) {
    if (other is! AppGlassTheme) {
      return this;
    }

    return AppGlassTheme(
      backgroundTop: Color.lerp(backgroundTop, other.backgroundTop, t)!,
      backgroundBottom: Color.lerp(
        backgroundBottom,
        other.backgroundBottom,
        t,
      )!,
      cardFill: Color.lerp(cardFill, other.cardFill, t)!,
      cardOverlay: Color.lerp(cardOverlay, other.cardOverlay, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      accentA: Color.lerp(accentA, other.accentA, t)!,
      accentB: Color.lerp(accentB, other.accentB, t)!,
      surfaceHighlight: Color.lerp(
        surfaceHighlight,
        other.surfaceHighlight,
        t,
      )!,
    );
  }
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark
        ? AppPalette.darkBackground
        : AppPalette.lightBackground;
    final surface = isDark ? AppPalette.darkSurface : AppPalette.lightSurface;
    final primary = isDark ? AppPalette.darkPrimary : AppPalette.lightPrimary;
    final secondary = isDark
        ? AppPalette.darkSecondary
        : AppPalette.lightSecondary;
    final text = isDark ? AppPalette.darkText : AppPalette.lightText;

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          secondary: secondary,
          surface: surface,
          onSurface: text,
          onPrimary: isDark ? AppPalette.darkBackground : Colors.white,
          onSecondary: isDark ? AppPalette.darkBackground : Colors.white,
          outline: secondary.withOpacity(isDark ? 0.34 : 0.22),
          outlineVariant: secondary.withOpacity(isDark ? 0.22 : 0.12),
        );

    final glassTheme = AppGlassTheme(
      backgroundTop: isDark ? const Color(0xFF141818) : const Color(0xFFFDFEFF),
      backgroundBottom: isDark
          ? const Color(0xFF0D1012)
          : const Color(0xFFF0F5F9),
      cardFill: isDark ? const Color(0xB3262D2F) : const Color(0xC8FFFFFF),
      cardOverlay: isDark ? const Color(0x88223134) : const Color(0xAAEEF4FB),
      border: isDark ? const Color(0x55D5ECFA) : const Color(0x55FFFFFF),
      shadow: isDark
          ? Colors.black.withOpacity(0.26)
          : primary.withOpacity(0.12),
      mutedText: text.withOpacity(isDark ? 0.72 : 0.64),
      accentA: primary.withOpacity(isDark ? 0.18 : 0.14),
      accentB: secondary.withOpacity(isDark ? 0.18 : 0.12),
      surfaceHighlight: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.white.withOpacity(0.58),
    );

    final baseTextTheme = ThemeData(brightness: brightness).textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: baseTextTheme.copyWith(
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          color: text,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: text,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: text, height: 1.35),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: text,
          height: 1.35,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.withOpacity(isDark ? 0.62 : 0.9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.34)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.error, width: 1.2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surface.withOpacity(isDark ? 0.95 : 0.98),
        contentTextStyle: TextStyle(color: text, fontWeight: FontWeight.w500),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface.withOpacity(isDark ? 0.96 : 0.98),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: glassTheme.border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface.withOpacity(isDark ? 0.92 : 0.96),
        modalBackgroundColor: surface.withOpacity(isDark ? 0.92 : 0.96),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
      dividerColor: colorScheme.outlineVariant,
      extensions: <ThemeExtension<dynamic>>[glassTheme],
    );
  }
}
