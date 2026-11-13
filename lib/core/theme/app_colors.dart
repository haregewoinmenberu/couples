import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary purple palette (matches mockup)
  static const Color primary = Color(0xFF7B4FBF);
  static const Color primaryLight = Color(0xFF9B6FDF);
  static const Color accent = Color(0xFFC77DFF);
  static const Color accentLight = Color(0xFFE5B8FF);

  // Background
  static const Color background = Color(0xFFFBF7FF);
  static const Color backgroundSecondary = Color(0xFFF3ECFC);
  static const Color textPrimary = Color(0xFF1A1030);
  static const Color textSecondary = Color(0xFF8B7AAB);

  // Legacy rose (used in some places — mapped to primary)
  static const Color rose = Color(0xFF9B6FDF);
  static const Color lavender = Color(0xFFA99ACB);
  static const Color softPink = Color(0xFFF0E8FF);
  static const Color softLavender = Color(0xFFEDE4FF);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8DEFF);
  static const Color success = Color(0xFF5DB87A);
  static const Color warning = Color(0xFFD8A15D);
  static const Color error = Color(0xFFD46C75);
  static const Color darkPlayer = Color(0xFF1A0D30);
  static const Color darkPlayerSecondary = Color(0xFF2D1F4A);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B4FBF), Color(0xFFC77DFF)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8D5FF), Color(0xFFFBF7FF)],
  );

  static const LinearGradient loveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softPink, softLavender],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A2080), Color(0xFF1A0D30)],
  );

  static const List<List<Color>> artworkPalettes = [
    [Color(0xFF7B4FBF), Color(0xFFC77DFF)],
    [Color(0xFF9B6FDF), Color(0xFFE5B8FF)],
    [Color(0xFF5B3A8F), Color(0xFF9B6FDF)],
    [Color(0xFFB899E8), Color(0xFF7B4FBF)],
    [Color(0xFFD8A15D), Color(0xFF9B6FDF)],
    [Color(0xFF5DB87A), Color(0xFF7B4FBF)],
    [Color(0xFF8D6BC9), Color(0xFFC77DFF)],
    [Color(0xFF6E4894), Color(0xFFB899E8)],
  ];
}
