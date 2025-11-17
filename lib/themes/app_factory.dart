import 'package:flutter/material.dart';

class ThemeConfig {
  final Color primaryColor;
  final Color accentColor;
  final Color lightAccent;
  final double borderRadius;
  final bool isDark;

  // Specific Component Colors
  final Color scaffoldBg;
  final Color appBarBg;
  final Color? inputFillColor;
  final Color inputLabel;
  final Color inputFloatingLabel;
  final Color inputPrefixIcon;
  final Color inputBorder;
  final Color inputFocusedBorder;
  final Color errorColor;
  final Color progressColor;
  final Color snackBarBg;

  // NEW: Gradient Colors for Login/Auth screens
  final Color gradientStart;
  final Color gradientEnd;

  ThemeConfig({
    required this.primaryColor,
    required this.accentColor,
    required this.lightAccent,
    this.borderRadius = 12,
    required this.isDark,
    required this.scaffoldBg,
    required this.appBarBg,
    this.inputFillColor,
    required this.inputLabel,
    required this.inputFloatingLabel,
    required this.inputPrefixIcon,
    required this.inputBorder,
    required this.inputFocusedBorder,
    required this.errorColor,
    required this.progressColor,
    required this.snackBarBg,
    required this.gradientStart,
    required this.gradientEnd,
  });
}

class ThemeFactory {
  final ThemeConfig config;

  ThemeFactory({required this.config});

  ThemeData createTheme() {
    final brightness = config.isDark ? Brightness.dark : Brightness.light;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: config.primaryColor,
      brightness: brightness,
      error: config.errorColor,
    );

    // Base Text Theme
    final TextTheme baseTextTheme =
    config.isDark ? Typography.whiteMountainView : Typography.blackMountainView;

    // Custom Text Theme
    final TextTheme customTextTheme = baseTextTheme.copyWith(
      // "Welcome to ReadSoil" style
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: config.primaryColor,
        letterSpacing: -0.5,
      ),
      // "Sign in to continue" style
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: config.isDark ? Colors.grey[300] : Colors.grey[600],
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );

    return ThemeData(
      useMaterial3: false,
      brightness: brightness,
      colorScheme: scheme,
      primaryColor: config.primaryColor,
      scaffoldBackgroundColor: config.scaffoldBg,
      textTheme: customTextTheme,

      // ------------------------- APP BAR -------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: config.appBarBg,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: customTextTheme.titleLarge,
      ),

      // ------------------------- INPUT FIELDS -------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: config.inputFillColor, // White in light mode
        labelStyle: TextStyle(color: config.inputLabel),
        floatingLabelStyle: TextStyle(
          color: config.inputFloatingLabel,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: config.inputPrefixIcon,

        // PILL SHAPE STYLING
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Full pill shape
          borderSide: BorderSide.none, // No visible border line
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: config.inputFocusedBorder,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: config.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: config.errorColor, width: 2),
        ),
      ),

      // ------------------------- BUTTONS -------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Pill shape
          ),
          textStyle: customTextTheme.labelLarge,
          elevation: 2, // Subtle shadow
        ),
      ),

      // ------------------------- PROGRESS & SNACKBAR -------------------------
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: config.progressColor,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: config.snackBarBg,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}