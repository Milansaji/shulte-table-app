import 'package:flutter/material.dart';

/// App theme configuration for light and dark modes
class AppTheme {
  // Light theme colors (white background, black foreground)
  static const Color lightPrimary = Colors.black;
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightSecondary = Colors.black;

  // Dark theme colors (black background, white foreground)
  static const Color darkPrimary = Colors.white;
  static const Color darkBackground = Colors.black;
  static const Color darkSurface = Colors.black;
  static const Color darkSecondary = Colors.white;

  /// Light theme configuration
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: lightPrimary,
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 1,
        centerTitle: true,
        foregroundColor: lightPrimary,
      ),
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightSurface,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 1,
        centerTitle: true,
        foregroundColor: darkPrimary,
      ),
      colorScheme: ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
      ),
    );
  }
}
