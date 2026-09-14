import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_colors.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/language_provider.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/presentation/controllers/auth_controller.dart';
import 'features/favorites/presentation/controllers/favorites_controller.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize persistent storage service
  final storageService = await StorageService.init();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        authRepositoryProvider.overrideWithValue(AuthRepositoryImpl(storageService)),
      ],
      child: const TravelGoApp(),
    ),
  );
}

class TravelGoApp extends ConsumerWidget {
  const TravelGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    return MaterialApp(
      title: 'TRAVELGO',
      debugShowCheckedModeBanner: false,

      // Theming (Material 3)
      themeMode: themeMode,
      theme: AppTheme.getLightTheme(isArabic: isArabic),
      darkTheme: AppTheme.getDarkTheme(isArabic: isArabic),

      // Localization & RTL/LTR Directionality
      locale: currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supported in supportedLocales) {
          if (supported.languageCode == locale?.languageCode) {
            return supported;
          }
        }
        return supportedLocales.first;
      },

      home: const SplashScreen(),
    );
  }
}
