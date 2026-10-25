import 'package:flutter/material.dart';

/// Blue and white. Blue is the only brand colour.
class AppTheme {
  AppTheme._();

  static const Color blue = Color(0xFF1565C0);
  static const Color bg = Color(0xFFF4F7FB); // screen background
  static const Color tint = Color(0xFFEAF2FC); // icon tiles, small boxes
  static const Color line = Color(0xFFD9E5F2); // borders and dividers
  static const Color ink = Color(0xFF0D2B4E); // titles

  static const LinearGradient header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F58B0), Color(0xFF3D9BF0)],
  );

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: blue,
      brightness: Brightness.light,
    );
    final scheme = base.copyWith(
      primary: blue,
      onPrimary: Colors.white,
      surface: Colors.white,
      surfaceContainerLow: const Color(0xFFF2F7FD),
      outlineVariant: line,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: bg,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        extendedTextStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
