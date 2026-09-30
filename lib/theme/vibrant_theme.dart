import 'package:flutter/material.dart';

class VibrantColors {
  // Sophisticated athletic palette (non-neon, high contrast, clean)
  static const Color neonLime = Color(0xFF059669);        // Rich energetic emerald 600
  static const Color neonCyan = Color(0xFF0284C7);        // Crisp ocean/sky blue 600
  static const Color neonMagenta = Color(0xFFE11D48);     // Crisp vibrant rose 600
  static const Color neonAmber = Color(0xFFD97706);       // Warm amber 600
  static const Color neonGold = Color(0xFFD97706);        // Warm gold/amber 600
  static const Color neonPurple = Color(0xFF7C3AED);      // Clean violet 600
  static const Color neonElectricBlue = Color(0xFF2563EB);// Royal blue 600

  // Modern clean light background palette
  static const Color obsidianVoid = Color(0xFFF8FAFC);    // Clean airy light canvas (slate 50)
  static const Color deepSpace = Color(0xFFFFFFFF);       // Crisp white surface
  static const Color cardSurface = Color(0xFFFFFFFF);     // Crisp white card
  static const Color elevatedSurface = Color(0xFFF1F5F9); // Light slate 100
  static const Color glassSurface = Color(0xF2FFFFFF);    // Frosted white glass
  static const Color glassSurfaceDark = Color(0xE6FFFFFF);

  // Modern crisp typography colors
  static const Color textPrimary = Color(0xFF0F172A);     // Deep slate 900
  static const Color textSecondary = Color(0xFF475569);   // Slate 600
  static const Color textMuted = Color(0xFF94A3B8);       // Slate 400
  static const Color border = Color(0xFFE2E8F0);          // Slate 200 border

  // Highlight & Lowlight accents for clean modern cards
  static const Color specularHighlight = Color(0x1A000000);
  static const Color lowlightShadow = Color(0x0A000000);

  // Clean modern soft drop shadow (no fluorescent neon glow)
  static List<BoxShadow> neonGlow(Color color, {double intensity = 1.0}) => [
        BoxShadow(
          color: color.withValues(alpha: 0.15 * intensity),
          blurRadius: 10 * intensity,
          offset: const Offset(0, 3),
        ),
      ];
}

class VibrantTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: VibrantColors.obsidianVoid,
      primaryColor: VibrantColors.neonLime,
      cardColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: VibrantColors.neonLime,
        secondary: VibrantColors.neonCyan,
        tertiary: VibrantColors.neonMagenta,
        surface: VibrantColors.deepSpace,
        onSurface: VibrantColors.textPrimary,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: VibrantColors.textPrimary,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
        headlineMedium: TextStyle(
          color: VibrantColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
        titleLarge: TextStyle(
          color: VibrantColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: VibrantColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: VibrantColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: VibrantColors.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }
}
