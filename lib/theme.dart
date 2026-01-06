import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFFE0E7FF);
  static const calm = Color(0xFF14B8A6);
  static const calmLight = Color(0xFFD1FAE5);
  static const accent = Color(0xFFF97316);
  static const accentLight = Color(0xFFFFEDD5);
  static const clarity = Color(0xFF0EA5E9);
  static const clarityLight = Color(0xFFE0F2FE);
  static const card = Color(0xFFFFFFFF);
  static const muted = Color(0xFFF1F5F9);
  static const mutedText = Color(0xFF64748B);
}

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.card,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    textTheme: base.textTheme.copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium:
          base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}
