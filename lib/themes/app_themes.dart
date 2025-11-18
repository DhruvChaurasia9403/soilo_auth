import 'package:flutter/material.dart';
import 'app_factory.dart';

class AppThemes {
  // --- Premium Green & Gold Palette ---
  // Deep, rich emerald for a sense of stability and wealth
  static const Color primary = Color(0xFF0F4C3A);

  // Lighter sage/forest tone for secondary elements
  static const Color primaryLight = Color(0xFF37745B);

  // Matte Gold for a luxurious accent without being flashy
  static const Color accent = Color(0xFFC1A150);

  // --- Backgrounds ---
  // Very subtle mint-tinted white for a fresh, airy feel
  static const Color _lightScaffoldBg = Color(0xFFF8FBF9);
  // Rich, dark charcoal green for dark mode (optional, but included)
  static const Color _darkScaffoldBg = Color(0xFF051F18);

  // --- Inputs ---
  // Pure white inputs with subtle borders look more premium than grey filled ones
  static const Color _lightInputFill = Colors.white;
  static final Color _darkInputFill = Colors.white.withOpacity(0.05);

  // --- Text Colors ---
  static const Color _lightText = Color(0xFF1A2E26); // Dark green-grey, softer than black
  static const Color _darkText = Color(0xFFE2E8E5);

  // --- Gradients ---
  // Very subtle top-down gradient for the background
  static final Color _lightGradientStart = primary.withOpacity(0.05);
  static const Color _lightGradientEnd = _lightScaffoldBg;

  static final Color _darkGradientStart = primary.withOpacity(0.3);
  static const Color _darkGradientEnd = _darkScaffoldBg;

  // ----------------------------------------------------------------
  // LIGHT THEME (Premium)
  // ----------------------------------------------------------------
  static ThemeData light = ThemeFactory(
    config: ThemeConfig(
      primaryColor: primary,
      accentColor: accent,
      lightAccent: primaryLight,
      isDark: false,

      // Clean, expensive looking background
      scaffoldBg: _lightScaffoldBg,
      appBarBg: Colors.transparent,
      textColor: _lightText,

      // Sleek Inputs
      inputFillColor: _lightInputFill,
      inputLabel: Color(0xFF8DA696), // Muted sage text
      inputFloatingLabel: primary,
      inputPrefixIcon: accent, // Gold icons
      inputBorder: Color(0xFFE0ECE5), // Very light green border
      inputFocusedBorder: primary,

      // Feedback
      errorColor: Color(0xFFB00020),
      progressColor: accent,
      snackBarBg: primary,

      // Ambient Gradient
      gradientStart: _lightGradientStart,
      gradientEnd: _lightGradientEnd,
    ),
  ).createTheme();

  // ----------------------------------------------------------------
  // DARK THEME (Luxury Night)
  // ----------------------------------------------------------------
  static ThemeData dark = ThemeFactory(
    config: ThemeConfig(
      primaryColor: primaryLight,
      accentColor: accent,
      lightAccent: primary,
      isDark: true,

      scaffoldBg: _darkScaffoldBg,
      appBarBg: Colors.transparent,
      textColor: _darkText,

      inputFillColor: _darkInputFill,
      inputLabel: Colors.white38,
      inputFloatingLabel: accent,
      inputPrefixIcon: accent,
      inputBorder: Colors.white10,
      inputFocusedBorder: accent,

      errorColor: Color(0xFFCF6679),
      progressColor: accent,
      snackBarBg: Color(0xFF0F2920),

      gradientStart: _darkGradientStart,
      gradientEnd: _darkGradientEnd,
    ),
  ).createTheme();
}