import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (Sapphire Blue)
  static const Color primary = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF002171);
  static const Color primaryContainer = Color(0xFFE3F2FD);

  // Secondary Brand Colors (Amber / Gold Accent)
  static const Color secondary = Color(0xFFFF8F00);
  static const Color secondaryLight = Color(0xFFFFB300);
  static const Color secondaryDark = Color(0xFFC56000);
  static const Color secondaryContainer = Color(0xFFFFF8E1);

  // Success / Emerald
  static const Color success = Color(0xFF00897B);
  static const Color successLight = Color(0xFFE0F2F1);

  // Error / Crimson
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);

  // Warning / Orange
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);

  // Info / Sky Blue
  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFFE1F5FE);

  // Neutral Colors (Light)
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFCBD5E1);

  // Neutral Colors (Dark)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color dividerDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF475569);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF0288D1)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8F00), Color(0xFFFFB300)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );
}
