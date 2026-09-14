import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ar', ''),
  ];

  Future<bool> load() async {
    try {
      final jsonString = await rootBundle.loadString('assets/translations/${locale.languageCode}.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    } catch (e) {
      // Fallback to empty map if asset loading fails in tests
      _localizedStrings = {};
      return false;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  bool get isRTL => locale.languageCode == 'ar';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
