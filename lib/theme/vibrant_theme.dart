import 'package:flutter/material.dart';

class VibrantColors {
  // Ultra-vibrant neon palette
  static const Color neonLime = Color(0xFF00FF87);
  static const Color neonCyan = Color(0xFF60EFFF);
  static const Color neonMagenta = Color(0xFFFF007A);
  static const Color neonAmber = Color(0xFFFFB800);
  static const Color neonGold = Color(0xFFFFE600);
  static const Color neonPurple = Color(0xFF9D00FF);
  static const Color neonElectricBlue = Color(0xFF0072FF);

  // Modern luminous slate background palette
  static const Color obsidianVoid = Color(0xFF0F172A); // Elevated slate 900
  static const Color deepSpace = Color(0xFF1E293B);    // Elevated slate 800
  static const Color cardSurface = Color(0xFF1E293B);
  static const Color elevatedSurface = Color(0xFF334155);
  static const Color glassSurface = Color(0x33FFFFFF);
  static const Color glassSurfaceDark = Color(0x551E293B);

  // Highlight & Lowlight accents for 3D depth
  static const Color specularHighlight = Color(0xB3FFFFFF);
  static const Color lowlightShadow = Color(0x66000000);

  // LED Glow definitions
  static List<BoxShadow> neonGlow(Color color, {double intensity = 1.0}) => [
        BoxShadow(
          color: color.withValues(alpha: 0.65 * intensity),
          blurRadius: 18 * intensity,
          spreadRadius: 2 * intensity,
        ),
        BoxShadow(
          color: color.withValues(alpha: 0.3 * intensity),
          blurRadius: 36 * intensity,
          spreadRadius: 6 * intensity,
        ),
      ];
}

class VibrantTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: VibrantColors.obsidianVoid,
      primaryColor: VibrantColors.neonLime,
      colorScheme: const ColorScheme.dark(
        primary: VibrantColors.neonLime,
        secondary: VibrantColors.neonCyan,
        tertiary: VibrantColors.neonMagenta,
        surface: VibrantColors.deepSpace,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFFCBD5E1),
          fontSize: 13,
        ),
      ),
    );
  }
}
