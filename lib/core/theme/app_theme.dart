import 'dart:ui';

import 'package:flutter/material.dart';

class AppThemeTokens {
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

  static LinearGradient backgroundGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return LinearGradient(
        colors: [
          darkBackground,
          darkBackground.withOpacity(0.96),
          const Color(0xFF161B20),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [
        lightBackground,
        const Color(0xFFF8FAFB),
        const Color(0xFFEFF4F8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Color surfaceFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkSurface : lightSurface;
  }

  static Color textFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkText : lightText;
  }

  static Color primaryFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkPrimary : lightPrimary;
  }

  static Color secondaryFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkSecondary : lightSecondary;
  }

  static Color glassColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? Colors.white.withOpacity(0.085)
        : Colors.white.withOpacity(0.62);
  }

  static Color borderColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? Colors.white.withOpacity(0.12)
        : Colors.white.withOpacity(0.75);
  }

  static List<BoxShadow> shadows(Brightness brightness) {
    return [
      BoxShadow(
        color: brightness == Brightness.dark
            ? Colors.black.withOpacity(0.25)
            : const Color(0x332D517E),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ];
  }
}

ThemeData buildAppTheme(Brightness brightness) {
  final background = AppThemeTokens.backgroundGradient(brightness).colors.first;
  final surface = AppThemeTokens.surfaceFor(brightness);
  final primary = AppThemeTokens.primaryFor(brightness);
  final secondary = AppThemeTokens.secondaryFor(brightness);
  final text = AppThemeTokens.textFor(brightness);

  final scheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
    secondary: secondary,
    onSecondary: brightness == Brightness.dark ? Colors.black : Colors.white,
    error: const Color(0xFFD64545),
    onError: Colors.white,
    surface: surface,
    onSurface: text,
    background: background,
    onBackground: text,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    dividerColor: text.withOpacity(0.1),
    textTheme: Typography.blackMountainView.apply(
      bodyColor: text,
      displayColor: text,
    ),
    cardColor: AppThemeTokens.glassColor(brightness),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: text,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: brightness == Brightness.dark
          ? const Color(0xFF252B2F)
          : const Color(0xFFF3F5F7),
      contentTextStyle: TextStyle(color: text, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.dark
          ? Colors.white.withOpacity(0.06)
          : Colors.white.withOpacity(0.86),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppThemeTokens.borderColor(brightness)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primary.withOpacity(0.6), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD64545), width: 1.2),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
