import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle getHeadingLarge({required bool isDark, required bool isArabic}) {
    final baseColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final style = TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: baseColor, height: 1.25);
    return isArabic ? GoogleFonts.cairo(textStyle: style) : GoogleFonts.plusJakartaSans(textStyle: style);
  }

  static TextStyle getHeadingMedium({required bool isDark, required bool isArabic}) {
    final baseColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final style = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: baseColor, height: 1.3);
    return isArabic ? GoogleFonts.cairo(textStyle: style) : GoogleFonts.plusJakartaSans(textStyle: style);
  }

  static TextStyle getHeadingSmall({required bool isDark, required bool isArabic}) {
    final baseColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final style = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: baseColor, height: 1.35);
    return isArabic ? GoogleFonts.cairo(textStyle: style) : GoogleFonts.plusJakartaSans(textStyle: style);
  }

  static TextStyle getBodyLarge({required bool isDark, required bool isArabic}) {
    final baseColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final style = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: baseColor, height: 1.5);
    return isArabic ? GoogleFonts.cairo(textStyle: style) : GoogleFonts.plusJakartaSans(textStyle: style);
  }

  static TextStyle getBodyMedium({required bool isDark, required bool isArabic}) {
    final baseColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final style = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: baseColor, height: 1.45);
    return isArabic ? GoogleFonts.cairo(textStyle: style) : GoogleFonts.plusJakartaSans(textStyle: style);
  }

  static TextStyle getBodySmall({required bool isDark, required bool isArabic}) {
    final baseColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final style = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: baseColor, height: 1.4);
    return isArabic ? GoogleFonts.cairo(textStyle: style) : GoogleFonts.plusJakartaSans(textStyle: style);
  }

  static TextStyle getButtonText({required bool isArabic, Color color = Colors.white}) {
    final style = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.3);
    return isArabic ? GoogleFonts.cairo(textStyle: style) : GoogleFonts.plusJakartaSans(textStyle: style);
  }

  static TextStyle getPriceTag({required bool isArabic, Color color = AppColors.primary}) {
    final style = TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color);
    return isArabic ? GoogleFonts.cairo(textStyle: style) : GoogleFonts.plusJakartaSans(textStyle: style);
  }
}
