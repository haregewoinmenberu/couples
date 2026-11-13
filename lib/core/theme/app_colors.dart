import 'package:flutter/material.dart';

/// OurSound design system colors — light palette.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFFAF9F7);
  static const Color backgroundSecondary = Color(0xFFF3F0EF);
  static const Color textPrimary = Color(0xFF26242A);
  static const Color textSecondary = Color(0xFF88838B);
  static const Color rose = Color(0xFFD96B85);
  static const Color lavender = Color(0xFFA99ACB);
  static const Color softPink = Color(0xFFF7E7EC);
  static const Color softLavender = Color(0xFFF0ECF7);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFECE8E8);
  static const Color success = Color(0xFF6D9D82);
  static const Color warning = Color(0xFFD8A15D);
  static const Color error = Color(0xFFD46C75);
  static const Color darkPlayer = Color(0xFF25232B);
  static const Color darkPlayerSecondary = Color(0xFF3B3743);

  /// Primary gradient used for key CTAs (rose -> lavender tint).
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [rose, Color(0xFFCB7C9A)],
  );

  static const LinearGradient loveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softPink, softLavender],
  );

  /// Deterministic palette used to generate placeholder artwork tiles.
  static const List<List<Color>> artworkPalettes = [
    [Color(0xFFD96B85), Color(0xFFA99ACB)],
    [Color(0xFFE8A0AE), Color(0xFFC9B6E4)],
    [Color(0xFFB98BA6), Color(0xFF7D7AA8)],
    [Color(0xFFE7C6CF), Color(0xFF9FA8DA)],
    [Color(0xFFD8A15D), Color(0xFFD96B85)],
    [Color(0xFF6D9D82), Color(0xFFA99ACB)],
    [Color(0xFF8D86C9), Color(0xFFD96B85)],
    [Color(0xFFCB7C9A), Color(0xFF6E6894)],
  ];
}
