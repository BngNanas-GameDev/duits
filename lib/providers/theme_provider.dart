import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { defaultTheme, pinkBlossom, darkMode }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  AppTheme _currentTheme = AppTheme.defaultTheme;

  ThemeProvider() {
    _loadTheme();
  }

  AppTheme get currentTheme => _currentTheme;

  ThemeData get themeData {
    switch (_currentTheme) {
      case AppTheme.pinkBlossom:
        return _pinkBlossomTheme;
      case AppTheme.darkMode:
        return _darkModeTheme;
      case AppTheme.defaultTheme:
      default:
        return _defaultTheme;
    }
  }

  void setTheme(AppTheme theme) async {
    _currentTheme = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _currentTheme = AppTheme.values[themeIndex];
    notifyListeners();
  }

  static final ThemeData _defaultTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF),
      primary: const Color(0xFF6C63FF),
      secondary: const Color(0xFFEC4899),
      surface: const Color(0xFFF8FAFC),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  );

  static final ThemeData _pinkBlossomTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFB7C5),
      primary: const Color(0xFFFF69B4),
      secondary: const Color(0xFFFFC0CB),
      surface: const Color(0xFFFFF5F7),
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF5F7),
  );

  static final ThemeData _darkModeTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF),
      brightness: Brightness.dark,
      primary: const Color(0xFF818CF8),
      surface: const Color(0xFF0F172A),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
  );
}
