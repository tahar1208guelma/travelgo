import 'package:flutter/material.dart';

/// Modern Luxury Travel Palette inspired by Airbnb & Booking.com
/// [Ocean Blue, Caribbean Teal, Crisp White, Midnight Slate]
class AppColors {
  AppColors._();

  // Primary Brand Colors (Deep Ocean / Mediterranean Navy)
  static const Color primary = Color(0xFF0F4C81);
  static const Color primaryLight = Color(0xFF1E6FBA);
  static const Color primaryDark = Color(0xFF0A2540);
  static const Color primaryContainer = Color(0xFFE0F2FE);
  static const Color primaryContainerDark = Color(0xFF1E3A5F);

  // Secondary Brand Colors (Caribbean Teal / Turquoise)
  static const Color secondary = Color(0xFF0D9488);
  static const Color secondaryLight = Color(0xFF14B8A6);
  static const Color secondaryDark = Color(0xFF0F766E);
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color secondaryContainerDark = Color(0xFF134E4A);

  // Accent & Glow Highlights (Vibrant Cyan & Coral Glow)
  static const Color accent = Color(0xFF06B6D4);
  static const Color accentCoral = Color(0xFFFF5A5F); // Airbnb coral signature for wishlist/deals
  static const Color accentGold = Color(0xFFF59E0B);  // Booking.com luxury star rating

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);

  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);

  // Neutral Colors (Light Theme - Crisp, Clean, Luxury Alabaster)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Neutral Colors (Dark Theme - Midnight Slate & Obsidian Luxury)
  static const Color backgroundDark = Color(0xFF0B1120);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color cardDarkElevated = Color(0xFF273549);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color dividerDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);

  // Soft Luxury Shadows
  static const List<BoxShadow> softCardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> floatingButtonShadow = [
    BoxShadow(
      color: Color(0x250F4C81),
      blurRadius: 20,
      spreadRadius: 2,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> darkCardShadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A2540), Color(0xFF0F4C81), Color(0xFF0D9488)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A2540), Color(0xFF0F4C81), Color(0xFF115E59)],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D9488), Color(0xFF14B8A6), Color(0xFF06B6D4)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D9488), Color(0xFF06B6D4)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF111827)],
  );

  static const LinearGradient luxuryShimmer = LinearGradient(
    colors: [Color(0xFFE2E8F0), Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
    stops: [0.1, 0.5, 0.9],
  );
}
