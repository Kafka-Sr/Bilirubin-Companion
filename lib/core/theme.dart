import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final card = isDark ? const Color(0xFF222533) : const Color(0xFFE3E3E6);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: isDark ? const Color(0xFF151824) : const Color(0xFFF0F0F2),
    cardTheme: CardThemeData(
      color: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0.7,
      shadowColor: Colors.black26,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF2B2E3C) : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    ),
  );
}
