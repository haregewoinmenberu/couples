import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// OurSound typography — Plus Jakarta Sans throughout.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle displayLarge({Color? color}) => _base(
        size: 28,
        weight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle h1({Color? color}) => _base(
        size: 24,
        weight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        height: 1.25,
      );

  static TextStyle h2({Color? color}) => _base(
        size: 20,
        weight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle h3({Color? color}) => _base(
        size: 17,
        weight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle bodyLarge({Color? color}) => _base(
        size: 16,
        weight: FontWeight.w400,
        color: color ?? AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle body({Color? color}) => _base(
        size: 14,
        weight: FontWeight.w400,
        color: color ?? AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle bodyMedium({Color? color}) => _base(
        size: 14,
        weight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle caption({Color? color}) => _base(
        size: 12,
        weight: FontWeight.w500,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle small({Color? color}) => _base(
        size: 11,
        weight: FontWeight.w500,
        color: color ?? AppColors.textSecondary,
        letterSpacing: 0.2,
      );

  static TextStyle button({Color? color}) => _base(
        size: 15,
        weight: FontWeight.w600,
        color: color ?? Colors.white,
      );
}
