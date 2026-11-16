import 'package:flutter/material.dart';

/// Fluent-подібна тема застосунку (акцентний синій Windows 11).
class AppTheme {
  static const Color accent = Color(0xFF0067C0);

  static ThemeData _build(Brightness brightness) {
    var scheme = ColorScheme.fromSeed(seedColor: accent, brightness: brightness);
    if (brightness == Brightness.light) {
      scheme = scheme.copyWith(primary: accent, onPrimary: Colors.white);
    }
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Segoe UI',
      scaffoldBackgroundColor: scheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);
}
