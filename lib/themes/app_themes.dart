import 'package:flutter/material.dart';

import 'app_factory.dart';

class AppThemes {
  // ----------------------------------------------------------------
  // BASE COLORS (Brand)
  // ----------------------------------------------------------------
  static const Color primary = Color(0xFF2E7D32); // Green 800
  static const Color accent = Color(0xFF388E3C); // Green 700
  static const Color lightGreen = Color(0xFFA5D6A7); // Green 300

  // ----------------------------------------------------------------
  // LIGHT THEME COLORS
  // ----------------------------------------------------------------
  static const Color _lightScaffoldBg = Colors.white;
  static const Color _lightAppBarBg = primary;
  static const Color _lightInputLabel = accent;
  static const Color _lightInputFloatingLabel = primary;
  static const Color _lightInputPrefixIcon = primary;
  static const Color _lightInputBorder = lightGreen;
  static const Color _lightInputFocusedBorder = primary;
  static final Color _lightError = Colors.red.shade600;
  static const Color _lightProgress = primary;
  static const Color _lightSnackBarBg = primary;

  // ----------------------------------------------------------------
  // DARK THEME COLORS
  // ----------------------------------------------------------------
  static const Color _darkScaffoldBg = Color(0xFF121212);
  static const Color _darkAppBarBg = primary;
  static const Color _darkInputFill = Color(0xFF1E1E1E);
  static const Color _darkInputLabel = lightGreen;
  static const Color _darkInputFloatingLabel = lightGreen;
  static const Color _darkInputPrefixIcon = lightGreen;
  static final Color _darkInputBorder = Colors.green.shade800;
  static const Color _darkInputFocusedBorder = lightGreen;
  static final Color _darkError = Colors.red.shade600; // Or Colors.red.shade400
  static const Color _darkProgress = lightGreen;
  static const Color _darkSnackBarBg = Color(0xFF1E1E1E);

  // ----------------------------------------------------------------
  // LIGHT THEME
  // ----------------------------------------------------------------
  static ThemeData light = ThemeFactory(
    config: ThemeConfig(
      // Base
      primaryColor: primary,
      accentColor: accent,
      lightAccent: lightGreen,
      isDark: false,
      borderRadius: 12,
      // Specific
      scaffoldBg: _lightScaffoldBg,
      appBarBg: _lightAppBarBg,
      inputFillColor: null, // No fill for light mode
      inputLabel: _lightInputLabel,
      inputFloatingLabel: _lightInputFloatingLabel,
      inputPrefixIcon: _lightInputPrefixIcon,
      inputBorder: _lightInputBorder,
      inputFocusedBorder: _lightInputFocusedBorder,
      errorColor: _lightError,
      progressColor: _lightProgress,
      snackBarBg: _lightSnackBarBg,
    ),
  ).createTheme();

  // ----------------------------------------------------------------
  // DARK THEME
  // ----------------------------------------------------------------
  static ThemeData dark = ThemeFactory(
    config: ThemeConfig(
      // Base
      primaryColor: primary,
      accentColor: accent,
      lightAccent: lightGreen,
      isDark: true,
      borderRadius: 12,
      // Specific
      scaffoldBg: _darkScaffoldBg,
      appBarBg: _darkAppBarBg,
      inputFillColor: _darkInputFill, // Has fill for dark mode
      inputLabel: _darkInputLabel,
      inputFloatingLabel: _darkInputFloatingLabel,
      inputPrefixIcon: _darkInputPrefixIcon,
      inputBorder: _darkInputBorder,
      inputFocusedBorder: _darkInputFocusedBorder,
      errorColor: _darkError,
      progressColor: _darkProgress,
      snackBarBg: _darkSnackBarBg,
    ),
  ).createTheme();
}