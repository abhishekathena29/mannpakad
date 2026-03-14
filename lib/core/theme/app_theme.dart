import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - Deep indigo/purple
  static const primary = Color(0xFF6366F1);
  static const primaryDark = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFFE0E7FF);

  // Calm palette - Teal/Green
  static const calm = Color(0xFF14B8A6);
  static const calmDark = Color(0xFF0D9488);
  static const calmLight = Color(0xFFCCFBF1);

  // Accent palette - Warm orange
  static const accent = Color(0xFFF97316);
  static const accentDark = Color(0xFFEA580C);
  static const accentLight = Color(0xFFFFEDD5);

  // Clarity palette - Sky blue
  static const clarity = Color(0xFF0EA5E9);
  static const clarityDark = Color(0xFF0284C7);
  static const clarityLight = Color(0xFFE0F2FE);

  // Neutral palette
  static const card = Color(0xFF1E293B); // Dark card by default now
  static const cardDark = Color(0xFF0F172A);
  static const background = Color(0xFF1a1a2e); // Match gradient start
  static const backgroundDark = Color(0xFF0F172A);
  static const surface = Color(0xFF1E293B);
  static const surfaceDark = Color(0xFF0F172A);
  static const muted = Color(0xFF334155); // Darker muted
  static const mutedText = Color(0xFF94A3B8);
  static const border = Color(0xFF334155);

  // Success/Error
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // Gradients
  static const gradientPrimary = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const gradientCalm = [Color(0xFF14B8A6), Color(0xFF06B6D4)];
  static const gradientAccent = [Color(0xFFF97316), Color(0xFFFB923C)];
  static const gradientDark = [
    Color(0xFF1a1a2e),
    Color(0xFF16213e),
    Color(0xFF0f3460),
  ];
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true); // Switch to dark base
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary,
      secondary: AppColors.calm,
      tertiary: AppColors.accent,
      surface: AppColors.background,
      error: AppColors.error,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withAlpha(20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withAlpha(20)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.white.withAlpha(100)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withAlpha(20),
      hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
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
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withAlpha(20),
      selectedColor: AppColors.primary.withAlpha(200),
      disabledColor: Colors.white.withAlpha(10),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withAlpha(20)),
      ),
      checkmarkColor: Colors.white,
    ),
    textTheme: base.textTheme.apply(
      fontFamily: 'Inter',
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withAlpha(30),
      thickness: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: Color(0xFF334155),
    ),
  );
}
