import 'package:flutter/material.dart';

class ThemeConfig {
  final Color primaryColor;
  final Color accentColor;
  final Color lightAccent;
  final double borderRadius;
  final bool isDark;

  ThemeConfig({
    required this.primaryColor,
    required this.accentColor,
    required this.lightAccent,
    this.borderRadius = 12,
    this.isDark = false,
  });
}

class ThemeFactory {
  final ThemeConfig config;

  ThemeFactory({required this.config});

  ThemeData createTheme() {
    final brightness = config.isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: false,
      brightness: brightness,
      primaryColor: config.primaryColor,
      scaffoldBackgroundColor:
      config.isDark ? const Color(0xFF121212) : Colors.white,

      // ------------------------- APP BAR -------------------------
      appBarTheme: AppBarTheme(
        backgroundColor:
        config.isDark ? const Color(0xFF1B1B1B) : config.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // ------------------------- INPUT FIELDS -------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: config.isDark,
        fillColor: config.isDark ? const Color(0xFF1E1E1E) : null,
        labelStyle:
        TextStyle(color: config.isDark ? config.lightAccent : config.accentColor),
        floatingLabelStyle: TextStyle(
          color: config.isDark ? config.lightAccent : config.primaryColor,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor:
        config.isDark ? config.lightAccent : config.primaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: config.isDark
                ? Colors.green.shade800
                : config.lightAccent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: config.isDark
                ? Colors.green.shade800
                : config.lightAccent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: config.isDark ? config.lightAccent : config.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.red.shade600,
            width: 1.5,
          ),
        ),
      ),

      // ------------------------- BUTTONS -------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: config.isDark ? config.lightAccent : config.primaryColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // ------------------------- PROGRESS -------------------------
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: config.isDark ? config.lightAccent : config.primaryColor,
      ),

      // ------------------------- SNACKBAR -------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
        config.isDark ? const Color(0xFF1E1E1E) : config.primaryColor,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
