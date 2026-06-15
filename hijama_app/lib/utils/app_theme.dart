import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color deepGreen   = Color(0xFF1A4A2E);
  static const Color midGreen    = Color(0xFF2D7A4A);
  static const Color lightGreen  = Color(0xFFE8F4EC);
  static const Color gold        = Color(0xFFC4922A);
  static const Color lightGold   = Color(0xFFF0D080);
  static const Color darkGold    = Color(0xFF8A6010);
  static const Color cream       = Color(0xFFFDF8F0);

  // Status colors
  static const Color statusSunnah      = Color(0xFF1A4A2E); // dark green
  static const Color statusRecommended = Color(0xFF2D7A4A);
  static const Color statusAvoid       = Color(0xFF993C1D);
  static const Color statusAllowed     = Color(0xFF5F5E5A);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: midGreen,
          primary: midGreen,
          secondary: gold,
          surface: Colors.white,
          background: const Color(0xFFF7F5F0),
        ),
        textTheme: GoogleFonts.nunitoSansTextTheme().copyWith(
          headlineLarge: GoogleFonts.nunitoSans(
            fontSize: 22, fontWeight: FontWeight.w600, color: deepGreen),
          headlineMedium: GoogleFonts.nunitoSans(
            fontSize: 18, fontWeight: FontWeight.w600, color: deepGreen),
          titleMedium: GoogleFonts.nunitoSans(
            fontSize: 15, fontWeight: FontWeight.w500),
          bodyMedium: GoogleFonts.nunitoSans(fontSize: 14),
          bodySmall: GoogleFonts.nunitoSans(fontSize: 12, color: const Color(0xFF5F5E5A)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: deepGreen,
          foregroundColor: lightGold,
          elevation: 0,
          titleTextStyle: GoogleFonts.nunitoSans(
            fontSize: 18, fontWeight: FontWeight.w600, color: lightGold),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: midGreen,
          unselectedItemColor: Color(0xFF888780),
          backgroundColor: Colors.white,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0x26000000), width: 0.5),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: lightGreen,
          labelStyle: const TextStyle(color: deepGreen, fontSize: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        dividerColor: const Color(0x1A000000),
        extensions: const [HijamaColors.light],
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: midGreen,
          brightness: Brightness.dark,
          primary: const Color(0xFF5DCAA5),
          secondary: lightGold,
          surface: const Color(0xFF1E1E1C),
          background: const Color(0xFF141412),
        ),
        textTheme: GoogleFonts.nunitoSansTextTheme(ThemeData.dark().textTheme).copyWith(
          headlineLarge: GoogleFonts.nunitoSans(
            fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFFF0D080)),
          headlineMedium: GoogleFonts.nunitoSans(
            fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFFF0D080)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0F2E1A),
          foregroundColor: lightGold,
          elevation: 0,
          titleTextStyle: GoogleFonts.nunitoSans(
            fontSize: 18, fontWeight: FontWeight.w600, color: lightGold),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF5DCAA5),
          unselectedItemColor: Color(0xFF888780),
          backgroundColor: Color(0xFF1E1E1C),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1C),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0x26FFFFFF), width: 0.5),
          ),
        ),
        dividerColor: const Color(0x1AFFFFFF),
        extensions: const [HijamaColors.dark],
      );
}

/// Custom color extension for Hijama-specific colors (gold, status colors).
@immutable
class HijamaColors extends ThemeExtension<HijamaColors> {
  const HijamaColors({
    required this.gold,
    required this.goldLight,
    required this.deepGreen,
    required this.hadithBackground,
    required this.sunnahBadge,
    required this.sunnahBadgeText,
    required this.avoidBadge,
    required this.avoidBadgeText,
  });

  final Color gold;
  final Color goldLight;
  final Color deepGreen;
  final Color hadithBackground;
  final Color sunnahBadge;
  final Color sunnahBadgeText;
  final Color avoidBadge;
  final Color avoidBadgeText;

  static const light = HijamaColors(
    gold: Color(0xFFC4922A),
    goldLight: Color(0xFFF0D080),
    deepGreen: Color(0xFF1A4A2E),
    hadithBackground: Color(0xFFF5F0E8),
    sunnahBadge: Color(0xFFE8F4EC),
    sunnahBadgeText: Color(0xFF1A4A2E),
    avoidBadge: Color(0xFFFCEBEB),
    avoidBadgeText: Color(0xFF501313),
  );

  static const dark = HijamaColors(
    gold: Color(0xFFF0C060),
    goldLight: Color(0xFFF5D88A),
    deepGreen: Color(0xFF9FCAA0),
    hadithBackground: Color(0xFF1C1A12),
    sunnahBadge: Color(0xFF0F2E1A),
    sunnahBadgeText: Color(0xFF9FCAA0),
    avoidBadge: Color(0xFF2E0F0F),
    avoidBadgeText: Color(0xFFF09595),
  );

  @override
  HijamaColors copyWith({
    Color? gold, Color? goldLight, Color? deepGreen,
    Color? hadithBackground, Color? sunnahBadge, Color? sunnahBadgeText,
    Color? avoidBadge, Color? avoidBadgeText,
  }) => HijamaColors(
    gold: gold ?? this.gold,
    goldLight: goldLight ?? this.goldLight,
    deepGreen: deepGreen ?? this.deepGreen,
    hadithBackground: hadithBackground ?? this.hadithBackground,
    sunnahBadge: sunnahBadge ?? this.sunnahBadge,
    sunnahBadgeText: sunnahBadgeText ?? this.sunnahBadgeText,
    avoidBadge: avoidBadge ?? this.avoidBadge,
    avoidBadgeText: avoidBadgeText ?? this.avoidBadgeText,
  );

  @override
  HijamaColors lerp(HijamaColors? other, double t) {
    if (other == null) return this;
    return HijamaColors(
      gold: Color.lerp(gold, other.gold, t)!,
      goldLight: Color.lerp(goldLight, other.goldLight, t)!,
      deepGreen: Color.lerp(deepGreen, other.deepGreen, t)!,
      hadithBackground: Color.lerp(hadithBackground, other.hadithBackground, t)!,
      sunnahBadge: Color.lerp(sunnahBadge, other.sunnahBadge, t)!,
      sunnahBadgeText: Color.lerp(sunnahBadgeText, other.sunnahBadgeText, t)!,
      avoidBadge: Color.lerp(avoidBadge, other.avoidBadge, t)!,
      avoidBadgeText: Color.lerp(avoidBadgeText, other.avoidBadgeText, t)!,
    );
  }
}
