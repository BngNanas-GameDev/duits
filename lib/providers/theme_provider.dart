import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/palette.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _paletteKey = 'duits_palette';
  static const String _themeModeKey = 'duits_theme_mode';

  AppPalette _palette = AppPalette.defaultTheme;
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = true;

  ThemeProvider() {
    _loadFromPrefs();
  }

  // ---- Getters ----
  AppPalette get palette => _palette;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  /// The currently active palette name for display.
  String get paletteName => _palette.displayName;

  /// Whether the app is currently using a dark visual theme.
  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  // ---- Setters ----

  /// Change the color palette and persist the choice.
  Future<void> setPalette(AppPalette palette) async {
    if (_palette == palette) return;
    _palette = palette;
    await _saveToPrefs();
    notifyListeners();
  }

  /// Change the theme mode (light / dark / system) and persist.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _saveToPrefs();
    notifyListeners();
  }

  // ---- Persistence ----

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final paletteIndex = prefs.getInt(_paletteKey);
      if (paletteIndex != null &&
          paletteIndex >= 0 &&
          paletteIndex < AppPalette.values.length) {
        _palette = AppPalette.values[paletteIndex];
      }

      final modeString = prefs.getString(_themeModeKey) ?? 'light';
      _themeMode = _parseThemeMode(modeString);
    } catch (e) {
      debugPrint('ThemeProvider: Failed to load preferences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_paletteKey, _palette.index);
      await prefs.setString(_themeModeKey, _serializeThemeMode(_themeMode));
    } catch (e) {
      debugPrint('ThemeProvider: Failed to save preferences: $e');
    }
  }

  static String _serializeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
}
