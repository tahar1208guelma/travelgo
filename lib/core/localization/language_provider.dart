import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  static const String _key = 'language_preference';

  LanguageNotifier() : super(const Locale('en', '')) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString(_key);
      if (langCode != null && (langCode == 'ar' || langCode == 'en' || langCode == 'fr')) {
        state = Locale(langCode, '');
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String languageCode) async {
    if (languageCode != 'ar' && languageCode != 'en' && languageCode != 'fr') return;
    state = Locale(languageCode, '');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, languageCode);
    } catch (_) {}
  }

  Future<void> toggleLanguage() async {
    final next = switch (state.languageCode) {
      'en' => 'ar',
      'ar' => 'fr',
      _ => 'en',
    };
    await setLanguage(next);
  }

  bool get isArabic => state.languageCode == 'ar';
  bool get isFrench => state.languageCode == 'fr';
  bool get isEnglish => state.languageCode == 'en';
}
