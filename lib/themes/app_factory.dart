import 'package:flutter/material.dart';

/// 1. ThemeConfig is expanded to hold all theme-specific values.
///    It no longer just holds "base" colors, but the *actual*
///    colors the theme components will use.
class ThemeConfig {
  final Color primaryColor;
  final Color accentColor;
  final Color lightAccent;
  final double borderRadius;
  final bool isDark;

  // Added colors
  final Color scaffoldBg;
  final Color appBarBg;
  final Color? inputFillColor; // Nullable for light mode
  final Color inputLabel;
  final Color inputFloatingLabel;
  final Color inputPrefixIcon;
  final Color inputBorder;
  final Color inputFocusedBorder;
  final Color errorColor;
  final Color progressColor;
  final Color snackBarBg;

  ThemeConfig({
    // Base
    required this.primaryColor,
    required this.accentColor,
    required this.lightAccent,
    this.borderRadius = 12,
    required this.isDark,

    // Specific
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
  });
}

/// 2. ThemeFactory is now "dumb". It just applies values from
///    config and has NO color logic or isDark checks for colors.
class ThemeFactory {
  final ThemeConfig config;

  ThemeFactory({required this.config});

  ThemeData createTheme() {
    final brightness = config.isDark ? Brightness.dark : Brightness.light;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: config.primaryColor,
      brightness: brightness,
      // You can also define your error color for the whole scheme
      error: config.errorColor,
    );

    // --- (Copied from your previous file) ---
    final TextTheme baseTextTheme =
    config.isDark ? Typography.whiteMountainView : Typography.blackMountainView;

    final TextTheme customTextTheme = baseTextTheme.copyWith(
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: config.isDark ? config.lightAccent : config.primaryColor,
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
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
    // --- (End of copy) ---

    return ThemeData(
      useMaterial3: false,
      brightness: brightness,
      colorScheme: scheme,
      primaryColor: config.primaryColor,
      // All 'isDark' checks are GONE
      scaffoldBackgroundColor: config.scaffoldBg,
      textTheme: customTextTheme,

      // ------------------------- APP BAR -------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: config.appBarBg, // Just use config value
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: customTextTheme.titleLarge,
      ),

      // ------------------------- INPUT FIELDS -------------------------
      inputDecorationTheme: InputDecorationTheme(
        // This is a behavior, not a color, so isDark is fine here
        filled: config.isDark,
        fillColor: config.inputFillColor, // Just use config value
        labelStyle: TextStyle(color: config.inputLabel),
        floatingLabelStyle: TextStyle(
          color: config.inputFloatingLabel,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: config.inputPrefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: config.inputBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: config.inputBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: config.inputFocusedBorder,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: config.errorColor,
            width: 1.5,
          ),
        ),
      ),

      // ------------------------- BUTTONS -------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.accentColor, // This was already good
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.borderRadius),
          ),
          textStyle: customTextTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          // This one still needs a check, or you can pass it in config
          foregroundColor:
          config.isDark ? config.lightAccent : config.primaryColor,
          textStyle: customTextTheme.labelMedium,
        ),
      ),

      // ------------------------- PROGRESS -------------------------
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: config.progressColor, // Just use config value
      ),

      // ------------------------- SNACKBAR -------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: config.snackBarBg, // Just use config value
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}