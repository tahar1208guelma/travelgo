import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _key = 'theme_mode_preference';

  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_key);
      if (isDark != null) {
        state = isDark ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, state == ThemeMode.dark);
    } catch (_) {}
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, mode == ThemeMode.dark);
    } catch (_) {}
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
