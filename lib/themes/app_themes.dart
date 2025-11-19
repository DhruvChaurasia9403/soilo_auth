import 'package:flutter/material.dart';
import 'app_factory.dart';

class AppThemes {
  // ===========================================================================
  // LIGHT THEME PALETTE (New: Green, Expensive, Light)
  // ===========================================================================
  static const Color _lightPrimary = Color(0xFF2D6A4F); // "Forest Fern" - Rich & Natural
  static const Color _lightAccent = Color(0xFF52B788);  // "Fresh Mint"
  static const Color _lightSecondary = Color(0xFF74C69D);

  static const Color _lightBg = Color(0xFFF7F9F8); // "Mint Cream" - Premium Off-White
  static const Color _lightText = Color(0xFF1B4332); // Deep Green-Black text

  static const Color _lightInputFill = Colors.white;
  static const Color _lightInputBorder = Color(0xFFD8E6DE); // Subtle green-grey border

  // ===========================================================================
  // DARK THEME PALETTE (Original: Deep Teal & Amber)
  // ===========================================================================
  static const Color _darkPrimary = Color(0xFF004D40); // Original Deep Teal
  static const Color _darkPrimaryLight = Color(0xFF00796B);
  static const Color _darkAccent = Color(0xFFFFA726); // Original Warm Amber

  static const Color _darkBg = Color(0xFF121212); // Original Dark Grey
  static const Color _darkText = Color(0xFFE0E0E0); // Original Off-White text

  static final Color _darkInputFill = Colors.grey.shade800.withOpacity(0.5);


  // ----------------------------------------------------------------
  // LIGHT THEME CONFIGURATION
  // ----------------------------------------------------------------
  static ThemeData light = ThemeFactory(
    config: ThemeConfig(
      primaryColor: _lightPrimary,
      accentColor: _lightAccent,
      lightAccent: _lightSecondary,
      isDark: false,

      scaffoldBg: _lightBg,
      appBarBg: Colors.transparent,
      textColor: _lightText,

      // Premium Light Inputs
      inputFillColor: _lightInputFill,
      inputLabel: Color(0xFFA4C3B2),
      inputFloatingLabel: _lightPrimary,
      inputPrefixIcon: _lightSecondary,
      inputBorder: _lightInputBorder,
      inputFocusedBorder: _lightPrimary,

      errorColor: Color(0xFFD32F2F),
      progressColor: _lightAccent,
      snackBarBg: _lightPrimary,

      gradientStart: _lightPrimary.withOpacity(0.08),
      gradientEnd: _lightBg,
    ),
  ).createTheme();

  // ----------------------------------------------------------------
  // DARK THEME CONFIGURATION (Restored to Original)
  // ----------------------------------------------------------------
  static ThemeData dark = ThemeFactory(
    config: ThemeConfig(
      primaryColor: _darkPrimaryLight, // Dark mode uses lighter teal (from original)
      accentColor: _darkAccent,
      lightAccent: _darkPrimary,
      isDark: true,

      scaffoldBg: _darkBg,
      appBarBg: Colors.transparent,
      textColor: _darkText,

      // Original Dark Inputs
      inputFillColor: _darkInputFill,
      inputLabel: Colors.grey,
      inputFloatingLabel: _darkPrimaryLight,
      inputPrefixIcon: _darkText,
      inputBorder: Colors.transparent,
      inputFocusedBorder: _darkPrimaryLight,

      errorColor: Colors.red.shade400,
      progressColor: _darkPrimaryLight,
      snackBarBg: const Color(0xFF1E1E1E),

      gradientStart: _darkPrimaryLight.withOpacity(0.2),
      gradientEnd: _darkBg,
    ),
  ).createTheme();
}