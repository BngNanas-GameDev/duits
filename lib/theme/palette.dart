import 'package:flutter/material.dart';

/// Available color palettes for the Duits app.
/// Each palette defines a complete set of colors and can generate
/// both light and dark ThemeData.
enum AppPalette {
  defaultTheme,
  cherryBlossom,
  dark,
  ocean,
  roseGold,
  emerald;

  String get displayName {
    switch (this) {
      case AppPalette.defaultTheme:
        return 'Default';
      case AppPalette.cherryBlossom:
        return 'Pink Cherry Blossom';
      case AppPalette.dark:
        return 'Dark Mode';
      case AppPalette.ocean:
        return 'Ocean Teal';
      case AppPalette.roseGold:
        return 'Rose Gold';
      case AppPalette.emerald:
        return 'Emerald';
    }
  }

  /// Primary brand color
  Color get primary {
    switch (this) {
      case AppPalette.defaultTheme:
        return const Color(0xFF6C63FF);
      case AppPalette.cherryBlossom:
        return const Color(0xFFFF6B9D);
      case AppPalette.dark:
        return const Color(0xFFBB86FC);
      case AppPalette.ocean:
        return const Color(0xFF009688);
      case AppPalette.roseGold:
        return const Color(0xFFB76E79);
      case AppPalette.emerald:
        return const Color(0xFF2E7D32);
    }
  }

  /// Secondary/accent color
  Color get secondary {
    switch (this) {
      case AppPalette.defaultTheme:
        return const Color(0xFFEC4899);
      case AppPalette.cherryBlossom:
        return const Color(0xFFE91E63);
      case AppPalette.dark:
        return const Color(0xFF03DAC6);
      case AppPalette.ocean:
        return const Color(0xFF00BCD4);
      case AppPalette.roseGold:
        return const Color(0xFFE8B4B8);
      case AppPalette.emerald:
        return const Color(0xFF66BB6A);
    }
  }

  /// Seed color used by ColorScheme.fromSeed
  Color get seedColor => primary;

  /// Scaffold background color for light mode
  Color get scaffoldBackgroundLight {
    switch (this) {
      case AppPalette.defaultTheme:
        return const Color(0xFFF8FAFC);
      case AppPalette.cherryBlossom:
        return const Color(0xFFFFF0F5);
      case AppPalette.dark:
        return const Color(0xFF121212);
      case AppPalette.ocean:
        return const Color(0xFFF0F8F8);
      case AppPalette.roseGold:
        return const Color(0xFFFFF5F5);
      case AppPalette.emerald:
        return const Color(0xFFF1F8E9);
    }
  }

  /// Surface color for light mode
  Color get surfaceColorLight {
    switch (this) {
      case AppPalette.defaultTheme:
        return Colors.white;
      case AppPalette.cherryBlossom:
        return const Color(0xFFFFF8FA);
      case AppPalette.dark:
        return const Color(0xFF1E1E1E);
      case AppPalette.ocean:
        return const Color(0xFFE0F2F1);
      case AppPalette.roseGold:
        return const Color(0xFFFFF0F0);
      case AppPalette.emerald:
        return const Color(0xFFE8F5E9);
    }
  }

  /// Card color for light mode
  Color get cardColorLight => surfaceColorLight;

  /// Header gradient colors
  List<Color> get headerGradientLight {
    switch (this) {
      case AppPalette.defaultTheme:
        return [const Color(0xFF6C63FF), const Color(0xFFEC4899)];
      case AppPalette.cherryBlossom:
        return [const Color(0xFFFF6B9D), const Color(0xFFFF9A9E)];
      case AppPalette.dark:
        return [const Color(0xFF3700B3), const Color(0xFFBB86FC)];
      case AppPalette.ocean:
        return [const Color(0xFF00796B), const Color(0xFF00BCD4)];
      case AppPalette.roseGold:
        return [const Color(0xFFB76E79), const Color(0xFFE8B4B8)];
      case AppPalette.emerald:
        return [const Color(0xFF2E7D32), const Color(0xFF66BB6A)];
    }
  }

  /// Body text color
  Color get textLight {
    switch (this) {
      case AppPalette.defaultTheme:
        return const Color(0xFF1E293B);
      case AppPalette.cherryBlossom:
        return const Color(0xFF4A2040);
      case AppPalette.dark:
        return const Color(0xFFE0E0E0);
      case AppPalette.ocean:
        return const Color(0xFF004D40);
      case AppPalette.roseGold:
        return const Color(0xFF4E342E);
      case AppPalette.emerald:
        return const Color(0xFF1B5E20);
    }
  }

  /// Secondary/body text color
  Color get secondaryTextLight {
    switch (this) {
      case AppPalette.defaultTheme:
        return const Color(0xFF64748B);
      case AppPalette.cherryBlossom:
        return const Color(0xFF8E6A7A);
      case AppPalette.dark:
        return const Color(0xFFA0A0A0);
      case AppPalette.ocean:
        return const Color(0xFF4D7C73);
      case AppPalette.roseGold:
        return const Color(0xFFA0827A);
      case AppPalette.emerald:
        return const Color(0xFF558B2F);
    }
  }

  /// Icon color
  Color get iconColorLight => primary;

  /// Divider color
  Color get dividerColorLight {
    switch (this) {
      case AppPalette.defaultTheme:
        return const Color(0xFFE2E8F0);
      case AppPalette.cherryBlossom:
        return const Color(0xFFF5D5DE);
      case AppPalette.dark:
        return const Color(0xFF333333);
      case AppPalette.ocean:
        return const Color(0xFFB2DFDB);
      case AppPalette.roseGold:
        return const Color(0xFFE8C4C4);
      case AppPalette.emerald:
        return const Color(0xFFC8E6C9);
    }
  }

  /// Accent color (badges, highlights)
  Color get accentColorLight {
    switch (this) {
      case AppPalette.defaultTheme:
        return const Color(0xFFFF6B6B);
      case AppPalette.cherryBlossom:
        return const Color(0xFFFF80AB);
      case AppPalette.dark:
        return const Color(0xFFCF6679);
      case AppPalette.ocean:
        return const Color(0xFFFF9800);
      case AppPalette.roseGold:
        return const Color(0xFFF48FB1);
      case AppPalette.emerald:
        return const Color(0xFFFFA726);
    }
  }

  // ===== Dark mode variants =====

  Color get scaffoldBackgroundDark {
    switch (this) {
      case AppPalette.defaultTheme:
        return const Color(0xFF0F172A);
      case AppPalette.cherryBlossom:
        return const Color(0xFF1A0A14);
      case AppPalette.dark:
        return const Color(0xFF121212);
      case AppPalette.ocean:
        return const Color(0xFF0A1919);
      case AppPalette.roseGold:
        return const Color(0xFF1C1014);
      case AppPalette.emerald:
        return const Color(0xFF0B1F0B);
    }
  }

  Color get surfaceColorDark {
    switch (this) {
      case AppPalette.defaultTheme:
        return const Color(0xFF1E293B);
      case AppPalette.cherryBlossom:
        return const Color(0xFF2D1220);
      case AppPalette.dark:
        return const Color(0xFF1E1E1E);
      case AppPalette.ocean:
        return const Color(0xFF0D2137);
      case AppPalette.roseGold:
        return const Color(0xFF2A1520);
      case AppPalette.emerald:
        return const Color(0xFF1B2E1B);
    }
  }

  Color get cardColorDark => surfaceColorDark;

  List<Color> get headerGradientDark {
    switch (this) {
      case AppPalette.defaultTheme:
        return [const Color(0xFF4F46E5), const Color(0xFFDB2777)];
      case AppPalette.cherryBlossom:
        return [const Color(0xFFE91E63), const Color(0xFFAD1457)];
      case AppPalette.dark:
        return [const Color(0xFFBB86FC), const Color(0xFF3700B3)];
      case AppPalette.ocean:
        return [const Color(0xFF004D40), const Color(0xFF009688)];
      case AppPalette.roseGold:
        return [const Color(0xFF8E5060), const Color(0xFFB76E79)];
      case AppPalette.emerald:
        return [const Color(0xFF1B5E20), const Color(0xFF2E7D32)];
    }
  }

  Color get textDark {
    switch (this) {
      case AppPalette.defaultTheme:
        return const Color(0xFFF1F5F9);
      case AppPalette.cherryBlossom:
        return const Color(0xFFFFF0F5);
      case AppPalette.dark:
        return const Color(0xFFE0E0E0);
      case AppPalette.ocean:
        return const Color(0xFFE0F2F1);
      case AppPalette.roseGold:
        return const Color(0xFFFFF0F0);
      case AppPalette.emerald:
        return const Color(0xFFE8F5E9);
    }
  }

  Color get secondaryTextDark {
    switch (this) {
      case AppPalette.defaultTheme:
        return const Color(0xFF94A3B8);
      case AppPalette.cherryBlossom:
        return const Color(0xFFF0A0C0);
      case AppPalette.dark:
        return const Color(0xFFA0A0A0);
      case AppPalette.ocean:
        return const Color(0xFF80CBC4);
      case AppPalette.roseGold:
        return const Color(0xFFD4A0A8);
      case AppPalette.emerald:
        return const Color(0xFFA5D6A7);
    }
  }

  Color get iconColorDark => secondary;

  Color get dividerColorDark {
    switch (this) {
      case AppPalette.defaultTheme:
        return const Color(0xFF334155);
      case AppPalette.cherryBlossom:
        return const Color(0xFF3D1A2A);
      case AppPalette.dark:
        return const Color(0xFF333333);
      case AppPalette.ocean:
        return const Color(0xFF14363E);
      case AppPalette.roseGold:
        return const Color(0xFF3D1F28);
      case AppPalette.emerald:
        return const Color(0xFF253A25);
    }
  }

  Color get accentColorDark => accentColorLight;

  // ===== Convenience getters that pick light or dark based on a flag =====

  Color scaffoldBackground(bool isDark) =>
      isDark ? scaffoldBackgroundDark : scaffoldBackgroundLight;

  Color surfaceColor(bool isDark) =>
      isDark ? surfaceColorDark : surfaceColorLight;

  Color cardColor(bool isDark) => isDark ? cardColorDark : cardColorLight;

  List<Color> headerGradient(bool isDark) =>
      isDark ? headerGradientDark : headerGradientLight;

  Color text(bool isDark) => isDark ? textDark : textLight;

  Color secondaryText(bool isDark) =>
      isDark ? secondaryTextDark : secondaryTextLight;

  Color iconColor(bool isDark) => isDark ? iconColorDark : iconColorLight;

  Color dividerColor(bool isDark) =>
      isDark ? dividerColorDark : dividerColorLight;

  Color accentColor(bool isDark) =>
      isDark ? accentColorDark : accentColorLight;

  // ===== ThemeData builders =====

  ThemeData toLightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        primary: primary,
        secondary: secondary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: scaffoldBackgroundLight,
      cardColor: cardColorLight,
      dividerColor: dividerColorLight,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: textLight,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textLight,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textLight,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textLight,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textLight, fontSize: 16),
        bodyMedium: TextStyle(color: textLight, fontSize: 14),
        bodySmall: TextStyle(color: secondaryTextLight, fontSize: 12),
        labelSmall: TextStyle(color: secondaryTextLight, fontSize: 11),
      ),
      iconTheme: IconThemeData(color: iconColorLight),
    );
  }

  ThemeData toDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        primary: primary,
        secondary: secondary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: scaffoldBackgroundDark,
      cardColor: cardColorDark,
      dividerColor: dividerColorDark,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColorDark,
        foregroundColor: textDark,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: textDark,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textDark,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textDark, fontSize: 16),
        bodyMedium: TextStyle(color: textDark, fontSize: 14),
        bodySmall: TextStyle(color: secondaryTextDark, fontSize: 12),
        labelSmall: TextStyle(color: secondaryTextDark, fontSize: 11),
      ),
      iconTheme: IconThemeData(color: iconColorDark),
    );
  }
}
