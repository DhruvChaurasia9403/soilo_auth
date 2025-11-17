import 'package:flutter/material.dart';
import 'app_factory.dart';

class AppThemes {
  // --- Color Palette (From your Design Code) ---
  static const Color primary = Color(0xFF004D40); // Deep Teal
  static const Color primaryLight = Color(0xFF00796B);
  static const Color accent = Color(0xFFFFA726); // Warm Amber

  // Backgrounds
  static const Color _lightScaffoldBg = Color(0xFFF1F4F8);
  static const Color _darkScaffoldBg = Color(0xFF121212);

  // Inputs
  static final Color _lightInputFill = Colors.grey.shade100;
  static final Color _darkInputFill = Colors.grey.shade800.withOpacity(0.5);

  // Text Colors
  static const Color _lightText = Color(0xFF1C2A3A);
  static const Color _darkText = Color(0xFFE0E0E0);

  // Gradient Logic (Primary 10% -> Background)
  static final Color _lightGradientStart = primary.withOpacity(0.1);
  static const Color _lightGradientEnd = _lightScaffoldBg;

  static final Color _darkGradientStart = primaryLight.withOpacity(0.2);
  static const Color _darkGradientEnd = _darkScaffoldBg;

  // ----------------------------------------------------------------
  // LIGHT THEME
  // ----------------------------------------------------------------
  static ThemeData light = ThemeFactory(
    config: ThemeConfig(
      primaryColor: primary,
      accentColor: accent,
      lightAccent: primaryLight, // Using primaryLight as secondary accent
      isDark: false,

      // Specifics from design
      scaffoldBg: _lightScaffoldBg,
      appBarBg: Colors.transparent,
      textColor: _lightText,

      // Input Styles
      inputFillColor: _lightInputFill,
      inputLabel: Colors.grey,
      inputFloatingLabel: primary,
      inputPrefixIcon: primary, // Icon color matches primary in your design
      inputBorder: Colors.transparent,
      inputFocusedBorder: primary,

      // Others
      errorColor: Colors.red.shade600,
      progressColor: primary,
      snackBarBg: primary,

      // Gradient
      gradientStart: _lightGradientStart,
      gradientEnd: _lightGradientEnd,
    ),
  ).createTheme();

  // ----------------------------------------------------------------
  // DARK THEME
  // ----------------------------------------------------------------
  static ThemeData dark = ThemeFactory(
    config: ThemeConfig(
      primaryColor: primaryLight, // Dark mode uses lighter teal
      accentColor: accent,
      lightAccent: primaryLight,
      isDark: true,

      // Specifics from design
      scaffoldBg: _darkScaffoldBg,
      appBarBg: Colors.transparent,
      textColor: _darkText,

      // Input Styles
      inputFillColor: _darkInputFill,
      inputLabel: Colors.grey,
      inputFloatingLabel: primaryLight,
      inputPrefixIcon: _darkText,
      inputBorder: Colors.transparent,
      inputFocusedBorder: primaryLight,

      // Others
      errorColor: Colors.red.shade400,
      progressColor: primaryLight,
      snackBarBg: const Color(0xFF1E1E1E),

      // Gradient
      gradientStart: _darkGradientStart,
      gradientEnd: _darkGradientEnd,
    ),
  ).createTheme();
}