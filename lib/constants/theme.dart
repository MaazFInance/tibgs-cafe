import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Dark
  static const Color cyan = Color(0xFF00E5FF);
  static const Color purple = Color(0xFFD500F9);
  static const Color backgroundDark = Color(0xFF0A0E17); // Deep Cyber Dark
  static const Color surfaceDark = Color(0xFF141C2F); // Slightly Lighter
  static const Color cardDark = Color(0xFF1C2538);

  // Brand Colors - Light
  static const Color backgroundLight = Color(0xFFF0F4F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: cyan,
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: purple,
        surface: surfaceDark,
        background: backgroundDark,
        error: Color(0xFFFF2E2E),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: GoogleFonts.orbitron(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: GoogleFonts.orbitron(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: GoogleFonts.rajdhani(fontSize: 16, color: Colors.white70),
        bodyMedium: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white60),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: cyan),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 8,
        shadowColor: cyan.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cyan.withOpacity(0.1), width: 1),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: cyan,
      colorScheme: const ColorScheme.light(
        primary: cyan,
        secondary: purple,
        surface: surfaceLight,
        background: backgroundLight,
        error: Color(0xFFFF2E2E),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
        displayMedium: GoogleFonts.orbitron(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        titleLarge: GoogleFonts.orbitron(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
        bodyLarge: GoogleFonts.rajdhani(fontSize: 16, color: Colors.black87),
        bodyMedium: GoogleFonts.rajdhani(fontSize: 14, color: Colors.black54),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
    );
  }
}
