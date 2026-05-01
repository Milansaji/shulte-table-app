import 'package:flutter/material.dart';

/// App theme configuration for light and dark modes
class AppTheme {
  // Light theme colors
  static const Color lightPrimary = Colors.black;
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.grey;
  static const Color lightSecondary = Colors.black87;

  // Dark theme colors
  static const Color darkPrimary = Color.fromARGB(255, 255, 0, 0);
  static const Color darkBackground = Color.fromARGB(255, 25, 15, 15);
  static const Color darkSurface = Color.fromARGB(255, 46, 26, 26);
  static const Color darkSecondary = Color.fromARGB(255, 218, 41, 5);

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
