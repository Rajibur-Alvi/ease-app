import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

class EaseTheme {
  // Brand Colors
  static const Color primarySage = Color(0xFF37693F);
  static const Color primaryContainer = Color(0xFF6A9E6F);
  static const Color secondary = Color(0xFF5F5E5C);
  static const Color tertiaryTerracotta = Color(0xFF8C4A5D);
  static const Color background = Color(0xFFF7F5F2); // The Canvas
  static const Color surface = Color(0xFFF8FAF4);
  static const Color surfaceDim = Color(0xFFD9DBD5);
  static const Color onSurface = Color(0xFF191C19);
  static const Color onSurfaceVariant = Color(0xFF414940);
  static const Color outline = Color(0xFF71796F);
  static const Color surfaceContainerLow = Color(0xFFF3F4EE);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primarySage,
        primaryContainer: primaryContainer,
        secondary: secondary,
        tertiary: tertiaryTerracotta,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
      ),
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
          height: 1.1,
          color: primarySage,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: onSurface,
        ),
        bodyLarge: GoogleFonts.notoSerif(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: onSurface,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.05,
          color: onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.75),
        border: OutlineInputBorder(
          borderRadius: EaseRadius.md,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: EaseRadius.md,
          borderSide: BorderSide(color: surfaceDim),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: EaseRadius.md,
          borderSide: const BorderSide(color: primarySage, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: EaseSpace.md,
          vertical: EaseSpace.sm,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: EaseRadius.md),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: EaseRadius.lg),
        elevation: 1.5,
      ),
    );
  }

  // Neumorphic Shadow (Soft double shadow)
  static List<BoxShadow> get neumorphicShadows => [
        BoxShadow(
          color: primaryContainer.withValues(alpha: 0.1),
          offset: const Offset(10, 10),
          blurRadius: 20,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.8),
          offset: const Offset(-10, -10),
          blurRadius: 20,
        ),
      ];

  // Glassmorphism Decoration
  static BoxDecoration get glassDecoration => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: neumorphicShadows,
      );
}
