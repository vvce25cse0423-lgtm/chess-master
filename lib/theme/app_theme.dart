// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF1A1A2E);
  static const Color secondary = Color(0xFF16213E);
  static const Color accent = Color(0xFFE94560);
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);

  // Board Colors
  static const Color lightSquare = Color(0xFFF0D9B5);
  static const Color darkSquare = Color(0xFFB58863);
  static const Color selectedSquare = Color(0xFF7FC97F);
  static const Color legalMoveSquare = Color(0xFF7FC97F);
  static const Color lastMoveLight = Color(0xFFCDD16E);
  static const Color lastMoveDark = Color(0xFFAAA23A);
  static const Color checkSquare = Color(0xFFE94560);

  // Surface Colors
  static const Color surface = Color(0xFF0F3460);
  static const Color surfaceVariant = Color(0xFF162447);
  static const Color cardColor = Color(0xFF1A1A2E);

  // Text Colors
  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textAccent = Color(0xFFE94560);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: gold,
        surface: surface,
        background: primary,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      scaffoldBackgroundColor: primary,
      cardColor: cardColor,
      textTheme: GoogleFonts.rajdhaniTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ).copyWith(
        displayLarge: GoogleFonts.cinzel(
          color: textPrimary,
          fontSize: 40,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.cinzel(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.cinzel(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.rajdhani(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
        headlineMedium: GoogleFonts.rajdhani(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.rajdhani(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          color: textSecondary,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.rajdhani(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: accent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      dividerColor: Colors.white12,
      appBarTheme: AppBarTheme(
        backgroundColor: secondary,
        elevation: 0,
        titleTextStyle: GoogleFonts.cinzel(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
    );
  }
}
