import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// UPDATED: Extends ThemeExtension so we can retrieve it in LoginScreen
class ThemeConfig extends ThemeExtension<ThemeConfig> {
  final Color primaryColor;
  final Color accentColor;
  final Color lightAccent;
  final bool isDark;

  final Color scaffoldBg;
  final Color appBarBg;
  final Color textColor;

  final Color? inputFillColor;
  final Color inputLabel;
  final Color inputFloatingLabel;
  final Color inputPrefixIcon;
  final Color inputBorder;
  final Color inputFocusedBorder;

  final Color errorColor;
  final Color progressColor;
  final Color snackBarBg;

  final Color gradientStart;
  final Color gradientEnd;

  ThemeConfig({
    required this.primaryColor,
    required this.accentColor,
    required this.lightAccent,
    required this.isDark,
    required this.scaffoldBg,
    required this.appBarBg,
    required this.textColor,
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

  @override
  ThemeConfig copyWith({
    Color? primaryColor,
    Color? accentColor,
    Color? lightAccent,
    bool? isDark,
    Color? scaffoldBg,
    Color? appBarBg,
    Color? textColor,
    Color? inputFillColor,
    Color? inputLabel,
    Color? inputFloatingLabel,
    Color? inputPrefixIcon,
    Color? inputBorder,
    Color? inputFocusedBorder,
    Color? errorColor,
    Color? progressColor,
    Color? snackBarBg,
    Color? gradientStart,
    Color? gradientEnd,
  }) {
    return ThemeConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      lightAccent: lightAccent ?? this.lightAccent,
      isDark: isDark ?? this.isDark,
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      appBarBg: appBarBg ?? this.appBarBg,
      textColor: textColor ?? this.textColor,
      inputFillColor: inputFillColor ?? this.inputFillColor,
      inputLabel: inputLabel ?? this.inputLabel,
      inputFloatingLabel: inputFloatingLabel ?? this.inputFloatingLabel,
      inputPrefixIcon: inputPrefixIcon ?? this.inputPrefixIcon,
      inputBorder: inputBorder ?? this.inputBorder,
      inputFocusedBorder: inputFocusedBorder ?? this.inputFocusedBorder,
      errorColor: errorColor ?? this.errorColor,
      progressColor: progressColor ?? this.progressColor,
      snackBarBg: snackBarBg ?? this.snackBarBg,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
    );
  }

  // Simple lerp that switches themes instantly (sufficient for Login)
  @override
  ThemeConfig lerp(ThemeExtension<ThemeConfig>? other, double t) {
    if (other is! ThemeConfig) return this;
    return t < 0.5 ? this : other;
  }
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
      secondary: config.accentColor,
    );

    final TextTheme baseTextTheme = GoogleFonts.poppinsTextTheme(
      config.isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    final TextTheme customTextTheme = baseTextTheme.apply(
      bodyColor: config.textColor,
      displayColor: config.textColor,
    ).copyWith(
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: config.primaryColor,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: config.isDark ? Colors.grey[300] : const Color(0xFF1C2A3A),
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: config.textColor,
      ),
    );

    return ThemeData(
      useMaterial3: false,
      brightness: brightness,
      colorScheme: scheme,
      primaryColor: config.primaryColor,
      scaffoldBackgroundColor: config.scaffoldBg,
      textTheme: customTextTheme,

      // -------------------------------------------------------
      // CRITICAL FIX: Register the config as an extension here
      // -------------------------------------------------------
      extensions: [
        config,
      ],

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: config.textColor),
        titleTextStyle: customTextTheme.titleLarge,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: config.inputFillColor,
        labelStyle: TextStyle(color: config.inputLabel),
        floatingLabelStyle: TextStyle(
          color: config.inputFloatingLabel,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: config.inputPrefixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: config.inputFocusedBorder,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: config.errorColor),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: config.primaryColor.withOpacity(0.3),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: config.progressColor,
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        color: config.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: config.primaryColor.withOpacity(0.1),
      ),
    );
  }
}