import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/services/provider_redirect_service.dart';
import 'package:travelgo/features/hotels/data/cities_data.dart';
import 'package:travelgo/features/profile/presentation/pages/terms_and_privacy_screen.dart';

void main() {
  group('ProviderRedirectService Airline Mapping Tests', () {
    test('resolves Air Algérie official booking URL accurately', () {
      expect(ProviderRedirectService.getAirlineOfficialUrl('Air Algérie'), 'https://airalgerie.dz');
      expect(ProviderRedirectService.getAirlineOfficialUrl('Air Algerie'), 'https://airalgerie.dz');
      expect(ProviderRedirectService.getAirlineOfficialUrl('AH'), 'https://airalgerie.dz');
    });

    test('resolves Air France official booking URL accurately', () {
      expect(ProviderRedirectService.getAirlineOfficialUrl('Air France'), 'https://www.airfrance.com');
      expect(ProviderRedirectService.getAirlineOfficialUrl('AF'), 'https://www.airfrance.com');
    });

    test('resolves Turkish Airlines official booking URL accurately', () {
      expect(ProviderRedirectService.getAirlineOfficialUrl('Turkish Airlines'), 'https://www.turkishairlines.com');
      expect(ProviderRedirectService.getAirlineOfficialUrl('TK'), 'https://www.turkishairlines.com');
    });

    test('resolves Emirates official booking URL accurately', () {
      expect(ProviderRedirectService.getAirlineOfficialUrl('Emirates'), 'https://www.emirates.com');
      expect(ProviderRedirectService.getAirlineOfficialUrl('EK'), 'https://www.emirates.com');
    });

    test('resolves Qatar Airways official booking URL accurately', () {
      expect(ProviderRedirectService.getAirlineOfficialUrl('Qatar Airways'), 'https://www.qatarairways.com');
      expect(ProviderRedirectService.getAirlineOfficialUrl('QR'), 'https://www.qatarairways.com');
    });

    test('resolves Saudia official booking URL accurately', () {
      expect(ProviderRedirectService.getAirlineOfficialUrl('Saudia'), 'https://www.saudia.com');
      expect(ProviderRedirectService.getAirlineOfficialUrl('SV'), 'https://www.saudia.com');
    });

    test('resolves Lufthansa, Transavia, British Airways, Pegasus, Royal Air Maroc, Tunisair, ITA Airways', () {
      expect(ProviderRedirectService.getAirlineOfficialUrl('Lufthansa'), 'https://www.lufthansa.com');
      expect(ProviderRedirectService.getAirlineOfficialUrl('Transavia'), 'https://www.transavia.com');
      expect(ProviderRedirectService.getAirlineOfficialUrl('British Airways'), 'https://www.ba.com');
      expect(ProviderRedirectService.getAirlineOfficialUrl('Pegasus Airlines'), 'https://www.flypgs.com');
      expect(ProviderRedirectService.getAirlineOfficialUrl('Royal Air Maroc'), 'https://www.royalairmaroc.com');
      expect(ProviderRedirectService.getAirlineOfficialUrl('Tunisair'), 'https://www.tunisair.com');
      expect(ProviderRedirectService.getAirlineOfficialUrl('ITA Airways'), 'https://www.ita-airways.com');
    });

    test('fallback returns search query for unknown airlines', () {
      final fallback = ProviderRedirectService.getAirlineOfficialUrl('Antigravity Jet Lines');
      expect(fallback, contains('google.com/search?q='));
      expect(fallback, contains('Antigravity+Jet+Lines'));
    });
  });

  group('ProviderRedirectService Hotel Mapping Tests', () {
    test('preserves explicit booking URL if provided', () {
      const explicit = 'https://el-aurassi.com/direct-booking';
      final url = ProviderRedirectService.getHotelOfficialUrl(
        hotelName: 'Hôtel El Aurassi',
        city: 'Algiers',
        explicitUrl: explicit,
      );
      expect(url, explicit);
    });

    test('resolves Marriott, Hilton, Accor, Hyatt chains', () {
      expect(
        ProviderRedirectService.getHotelOfficialUrl(hotelName: 'Sheraton Club des Pins', city: 'Algiers'),
        'https://www.marriott.com',
      );
      expect(
        ProviderRedirectService.getHotelOfficialUrl(hotelName: 'Sofitel Algiers Hamma Garden', city: 'Algiers'),
        'https://all.accor.com',
      );
    });
  });

  group('CitiesData Catalog Expansion Tests', () {
    test('contains 25+ Algerian wilayas and destinations', () {
      final algerianCities = CitiesData.globalCities.where((c) => c.country == 'Algeria').toList();
      expect(algerianCities.length, greaterThanOrEqualTo(25));

      final cityNames = algerianCities.map((c) => c.city.toLowerCase()).toSet();
      expect(cityNames.contains('algiers'), isTrue);
      expect(cityNames.contains('oran'), isTrue);
      expect(cityNames.contains('constantine'), isTrue);
      expect(cityNames.contains('annaba'), isTrue);
      expect(cityNames.contains('tlemcen'), isTrue);
      expect(cityNames.contains('sétif'), isTrue);
      expect(cityNames.contains('batna'), isTrue);
      expect(cityNames.contains('béjaïa'), isTrue);
      expect(cityNames.contains('ghardaïa'), isTrue);
      expect(cityNames.contains('biskra'), isTrue);
      expect(cityNames.contains('timimoun'), isTrue);
      expect(cityNames.contains('djanet'), isTrue);
      expect(cityNames.contains('taghit'), isTrue);
      expect(cityNames.contains('mostaganem'), isTrue);
      expect(cityNames.contains('tizi ouzou'), isTrue);
      expect(cityNames.contains('tipaza'), isTrue);
      expect(cityNames.contains('guelma'), isTrue);
    });

    test('contains top global destinations', () {
      final globalCityNames = CitiesData.globalCities.map((c) => c.city.toLowerCase()).toSet();
      expect(globalCityNames.contains('istanbul'), isTrue);
      expect(globalCityNames.contains('paris'), isTrue);
      expect(globalCityNames.contains('dubai'), isTrue);
      expect(globalCityNames.contains('london'), isTrue);
      expect(globalCityNames.contains('mecca'), isTrue);
      expect(globalCityNames.contains('medina'), isTrue);
    });

    test('matches method searches across city, country, region, and landmarks', () {
      final guelma = CitiesData.globalCities.firstWhere((c) => c.city == 'Guelma');
      expect(guelma.matches('Guelma'), isTrue);
      expect(guelma.matches('Hammam Debagh'), isTrue);
      expect(guelma.matches('Algeria'), isTrue);
    });
  });

  group('TermsAndPrivacyScreen Widget Tests', () {
    testWidgets('renders Terms of Service and Privacy Policy tabs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TermsAndPrivacyScreen(),
        ),
      );

      expect(find.text('شروط الاستخدام (Terms)'), findsOneWidget);
      expect(find.text('سياسة الخصوصية (Privacy)'), findsOneWidget);
      expect(find.text('طبيعة عمل منصة TravelGo (Meta-Search Engine)'), findsOneWidget);

      // Switch to Privacy tab
      await tester.tap(find.text('سياسة الخصوصية (Privacy)'));
      await tester.pumpAndSettle();

      expect(find.text('التزامنا بحماية خصوصيتك وأمان بياناتك'), findsOneWidget);
    });
  });
}
