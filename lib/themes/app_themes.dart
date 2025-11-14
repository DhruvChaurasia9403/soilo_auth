import 'package:flutter/material.dart';

import 'app_factory.dart';

class AppThemes {
  /// Base Colors
  static const Color primary = Color(0xFF2E7D32); // Green 800
  static const Color accent  = Color(0xFF388E3C); // Green 700
  static const Color lightGreen = Color(0xFFA5D6A7); // Green 300

  static ThemeData light = ThemeFactory(
    config: ThemeConfig(
      primaryColor: primary,
      accentColor: accent,
      lightAccent: lightGreen,
      isDark: false,
    ),
  ).createTheme();

  static ThemeData dark = ThemeFactory(
    config: ThemeConfig(
      primaryColor: primary,
      accentColor: accent,
      lightAccent: lightGreen,
      isDark: true,
    ),
  ).createTheme();
}
