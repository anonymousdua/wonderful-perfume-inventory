import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const plum = Color(0xFF2E1228);
  static const plumLight = Color(0xFF4A2A44);
  static const cream = Color(0xFFF8F0E7);
  static const card = Color(0xFFFEFCF8);
  static const gold = Color(0xFFB08A3E);
  static const goldLight = Color(0xFFD9B26A);
  static const border = Color(0xFFE6D8C4);
  static const ink = Color(0xFF2A0E24);
  static const muted = Color(0xFF6B5A66);
  static const green = Color(0xFF1F7A5A);
  static const greenBg = Color(0xFFDDF0E8);
  static const red = Color(0xFFB4344A);
  static const redBg = Color(0xFFF9DDE2);
  static const amber = Color(0xFF9A6B00);
  static const amberBg = Color(0xFFFBEFC8);
}

class AppTheme {
  static TextStyle heading(double size) => GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.plum,
        surface: AppColors.card,
      ),
      scaffoldBackgroundColor: AppColors.cream,
    );

    OutlineInputBorder border([Color c = AppColors.border]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c),
        );

    return base.copyWith(
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: AppColors.card),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: border(),
        enabledBorder: border(),
        focusedBorder: border(AppColors.gold),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.plum,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
