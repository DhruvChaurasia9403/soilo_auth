import 'package:flutter/material.dart';
import 'app_factory.dart';

class AppThemes {
  // Base Colors
  static const Color primary = Color(0xFF2E7D32); // Green 800
  static const Color accent = Color(0xFF388E3C); // Green 700
  static const Color lightGreen = Color(0xFFA5D6A7); // Green 300

  // --- LIGHT THEME DEFINITIONS ---
  static const Color _lightScaffoldBg = Color(0xFFF5F5F5);
  static const Color _lightAppBarBg = primary;
  static const Color _lightInputFill = Colors.white; // Inputs are white
  static const Color _lightInputLabel = Colors.grey;
  static const Color _lightInputFloatingLabel = primary;
  static const Color _lightInputPrefixIcon = Colors.grey;
  static const Color _lightInputBorder = Colors.transparent;
  static const Color _lightInputFocusedBorder = primary;
  static final Color _lightError = Colors.red.shade600;

  // Gradient Colors (Minty Green for Light Mode)
  static const Color _lightGradientStart = Color(0xFFE8F5E9); // Very light green
  static const Color _lightGradientEnd = Color(0xFFC8E6C9);   // Light green

  // --- DARK THEME DEFINITIONS ---
  static const Color _darkScaffoldBg = Color(0xFF121212);
  static const Color _darkAppBarBg = Color(0xFF1B1B1B);
  static const Color _darkInputFill = Color(0xFF2C2C2C);
  static const Color _darkInputLabel = Colors.grey;
  static const Color _darkInputFloatingLabel = lightGreen;
  static const Color _darkInputPrefixIcon = Colors.grey;
  static const Color _darkInputBorder = Colors.transparent;
  static const Color _darkInputFocusedBorder = lightGreen;
  static final Color _darkError = Colors.red.shade400;

  // Gradient Colors (Dark Green for Dark Mode)
  static const Color _darkGradientStart = Color(0xFF1B5E20);
  static const Color _darkGradientEnd = Color(0xFF0D3311);

  // ----------------------------------------------------------------
  // LIGHT THEME CREATION
  // ----------------------------------------------------------------
  static ThemeData light = ThemeFactory(
    config: ThemeConfig(
      primaryColor: primary,
      accentColor: accent,
      lightAccent: lightGreen,
      isDark: false,
      scaffoldBg: _lightScaffoldBg,
      appBarBg: _lightAppBarBg,
      inputFillColor: _lightInputFill,
      inputLabel: _lightInputLabel,
      inputFloatingLabel: _lightInputFloatingLabel,
      inputPrefixIcon: _lightInputPrefixIcon,
      inputBorder: _lightInputBorder,
      inputFocusedBorder: _lightInputFocusedBorder,
      errorColor: _lightError,
      progressColor: primary,
      snackBarBg: primary,
      // Pass gradient colors
      gradientStart: _lightGradientStart,
      gradientEnd: _lightGradientEnd,
    ),
  ).createTheme();

  // ----------------------------------------------------------------
  // DARK THEME CREATION
  // ----------------------------------------------------------------
  static ThemeData dark = ThemeFactory(
    config: ThemeConfig(
      primaryColor: primary,
      accentColor: accent,
      lightAccent: lightGreen,
      isDark: true,
      scaffoldBg: _darkScaffoldBg,
      appBarBg: _darkAppBarBg,
      inputFillColor: _darkInputFill,
      inputLabel: _darkInputLabel,
      inputFloatingLabel: _darkInputFloatingLabel,
      inputPrefixIcon: _darkInputPrefixIcon,
      inputBorder: _darkInputBorder,
      inputFocusedBorder: _darkInputFocusedBorder,
      errorColor: _darkError,
      progressColor: lightGreen,
      snackBarBg: const Color(0xFF1E1E1E),
      // Pass gradient colors
      gradientStart: _darkGradientStart,
      gradientEnd: _darkGradientEnd,
    ),
  ).createTheme();
}