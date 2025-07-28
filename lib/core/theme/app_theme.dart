import 'package:flutter/material.dart';

/// Настройки светлой и тёмной темы приложения.
class AppTheme {
  /// Светлая тема с использованием Material 3.
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF2F2F2),
    ),
  );

  /// Тёмная тема, основанная на [ThemeData.dark].
  static final darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueAccent,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
