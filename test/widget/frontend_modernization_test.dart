import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelgo/core/constants/app_colors.dart';
import 'package:travelgo/core/localization/app_localizations.dart';
import 'package:travelgo/core/localization/language_provider.dart';
import 'package:travelgo/core/services/storage_service.dart';
import 'package:travelgo/core/utils/responsive.dart';
import 'package:travelgo/features/home/presentation/screens/home_screen.dart';
import 'package:travelgo/features/home/presentation/widgets/popular_destinations_carousel.dart';
import 'package:travelgo/features/home/presentation/widgets/recent_searches_widget.dart';
import 'package:travelgo/features/home/presentation/widgets/special_offers_banner.dart';
import 'package:travelgo/shared/models/destination.dart';
import 'package:travelgo/shared/widgets/badge_chip.dart';
import 'package:travelgo/shared/widgets/rating_stars.dart';
import 'package:travelgo/shared/widgets/section_header.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _transparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value(_transparentImage).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

final _transparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Frontend Modernization & French Localization Tests', () {
    test('AppLocalizations supports English, Arabic, and French', () {
      expect(AppLocalizations.supportedLocales.map((l) => l.languageCode), containsAll(['en', 'ar', 'fr']));
      const delegate = AppLocalizations.delegate;
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('ar')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isTrue);
      expect(delegate.isSupported(const Locale('es')), isFalse);
    });

    test('AppLocalizations translates French fallback strings accurately', () {
      final locFr = AppLocalizations(const Locale('fr'));
      expect(locFr.translate('nav_home'), 'Accueil');
      expect(locFr.translate('nav_flights'), 'Vols');
      expect(locFr.translate('nav_hotels'), 'Hôtels');
      expect(locFr.translate('home_where_to'), 'Où souhaitez-vous aller ?');
      expect(locFr.translate('home_tab_flights'), 'Vols');
      expect(locFr.translate('home_tab_hotels'), 'Hôtels');
      expect(locFr.translate('ai_assistant_title'), 'Assistant de voyage IA');
    });

    test('LanguageNotifier cycles through en, ar, fr', () async {
      final notifier = LanguageNotifier();
      expect(notifier.state.languageCode, 'en');

      await notifier.setLanguage('fr');
      expect(notifier.state.languageCode, 'fr');
      expect(notifier.isFrench, isTrue);
      expect(notifier.isArabic, isFalse);
      expect(notifier.isEnglish, isFalse);

      await notifier.toggleLanguage(); // fr -> en
      expect(notifier.state.languageCode, 'en');

      await notifier.toggleLanguage(); // en -> ar
      expect(notifier.state.languageCode, 'ar');
      expect(notifier.isArabic, isTrue);

      await notifier.toggleLanguage(); // ar -> fr
      expect(notifier.state.languageCode, 'fr');
    });

    test('Destination model supports French multilingual getters', () {
      final dest = Destination.popularDestinations.firstWhere((d) => d.id == 'dest_paris');
      expect(dest.getCity(langCode: 'en'), 'Paris');
      expect(dest.getCity(langCode: 'ar'), 'باريس');
      expect(dest.getCity(langCode: 'fr'), 'Paris');
      expect(dest.getCountry(langCode: 'en'), 'France');
      expect(dest.getCountry(langCode: 'ar'), 'فرنسا');
      expect(dest.getCountry(langCode: 'fr'), 'France');

      final algiers = Destination.popularDestinations.firstWhere((d) => d.id == 'dest_algiers');
      expect(algiers.getCity(langCode: 'fr'), 'Alger');
      expect(algiers.getCountry(langCode: 'fr'), 'Algérie');
    });
  });

  group('Responsive Layouts & Overflows Prevention Tests', () {
    testWidgets('SectionHeader handles long title without RenderFlex overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 250,
              child: SectionHeader(
                title: 'Extremely Long Luxury Featured Hotel Title That Could Overflow Narrow Screens',
                actionTitle: 'View All',
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SectionHeader), findsOneWidget);
    });

    testWidgets('BadgeChip handles long labels flexibly without overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 140,
              child: BadgeChip(
                label: 'Direct Verified Luxury Partner Exclusive Offer',
                icon: Icons.verified,
                backgroundColor: AppColors.secondary,
                textColor: Colors.white,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(BadgeChip), findsOneWidget);
    });

    testWidgets('Responsive utility identifies small mobile, mobile, tablet, and desktop', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isSmallMobile(context), isTrue);
              expect(Responsive.isMobile(context), isTrue);
              expect(Responsive.isTablet(context), isFalse);
              expect(Responsive.isDesktop(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('Arabic RTL Layout & Mirroring Tests', () {
    testWidgets('RatingStars mirrors half star direction in RTL', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: RatingStars(rating: 3.5),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(RatingStars), findsOneWidget);
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('RecentSearchesWidget renders in RTL with mirrored arrow without error', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: RecentSearchesWidget(),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(RecentSearchesWidget), findsOneWidget);
    });

    testWidgets('SpecialOffersBanner renders smoothly in RTL without overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SpecialOffersBanner(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SpecialOffersBanner), findsOneWidget);
    });

    testWidgets('HomeScreen renders in Arabic on compact phone (360x640) with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final storage = await StorageService.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
            languageProvider.overrideWith((ref) {
              final notifier = LanguageNotifier();
              notifier.setLanguage('ar');
              return notifier;
            }),
          ],
          child: MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: HomeScreen(onNavigateTab: (_) {}),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
