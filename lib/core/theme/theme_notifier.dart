import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [ThemeNotifier] отвечает за хранение и смену темы (светлая / тёмная / системная).
class ThemeNotifier extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  /// Конструктор сразу загружает сохранённую тему из памяти.
  ThemeNotifier() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  /// Загрузка сохранённой темы из SharedPreferences.
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);

    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    }
  }

  /// Смена темы и сохранение нового значения.
  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }
}
