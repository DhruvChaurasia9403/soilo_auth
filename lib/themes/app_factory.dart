import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // --- ERROR FIXED HERE: Added 'covariant' ---
  @override
  ThemeConfig lerp(covariant ThemeConfig? other, double t) {
    if (other == null) return this;
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
      surface: config.isDark ? const Color(0xFF121212) : config.scaffoldBg,
    );

    final TextTheme baseTextTheme = GoogleFonts.mulishTextTheme(
      config.isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    final TextTheme customTextTheme = baseTextTheme.apply(
      bodyColor: config.textColor,
      displayColor: config.textColor,
    ).copyWith(
      // Expensive Looking Headers (Serif)
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: config.primaryColor,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.w600,
        color: config.primaryColor,
        letterSpacing: -0.5,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.w600,
        color: config.textColor,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: config.textColor,
        letterSpacing: 0.2,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 16,
        color: config.isDark ? Colors.grey[300] : const Color(0xFF3A4E44),
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      primaryColor: config.primaryColor,
      scaffoldBackgroundColor: config.scaffoldBg,
      textTheme: customTextTheme,

      extensions: [config],

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: config.textColor),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: config.textColor,
          letterSpacing: -0.5,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: config.inputFillColor,
        labelStyle: TextStyle(color: config.inputLabel, fontSize: 14),
        floatingLabelStyle: TextStyle(
          color: config.inputFloatingLabel,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        prefixIconColor: config.inputPrefixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: config.inputBorder,
              width: config.inputBorder == Colors.transparent ? 0 : 1
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: config.inputBorder,
              width: config.inputBorder == Colors.transparent ? 0 : 1
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: config.inputFocusedBorder,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: config.errorColor),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
          foregroundColor: config.isDark ? Colors.white : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          foregroundColor: config.primaryColor,
          side: BorderSide(color: config.primaryColor.withOpacity(0.2), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: config.progressColor,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: config.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: config.isDark ? Colors.transparent : const Color(0xFFE6E8E6),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: config.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: config.textColor,
        ),
      ),
    );
  }
}