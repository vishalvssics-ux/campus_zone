import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Deep Oxford Blue for a highly professional, academic feel
  static const primaryColor = Color(0xFF1E293B); 
  static const secondaryColor = Color(0xFF3B82F6); // Vibrant Blue for primary actions
  static const backgroundColor = Color(0xFFF8FAFC); // Very light slate/grayish background
  static const surfaceColor = Colors.white;
  static const accentColor = Color(0xFF10B981); // Emerald for success states
  static const textDarkColor = Color(0xFF0F172A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(color: textDarkColor, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.outfit(color: textDarkColor, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.outfit(color: textDarkColor, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.outfit(color: textDarkColor, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.outfit(color: textDarkColor, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.outfit(color: textDarkColor),
        bodyMedium: GoogleFonts.outfit(color: textDarkColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Softer corners
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          elevation: 0, // Flat styling with deliberate color contrast
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: secondaryColor, width: 2.0), // Pop on focus
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIconColor: Colors.grey.shade500,
        suffixIconColor: Colors.grey.shade500,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textDarkColor),
        titleTextStyle: TextStyle(color: textDarkColor, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
