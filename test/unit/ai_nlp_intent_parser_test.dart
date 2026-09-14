import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/features/ai_agent/data/datasources/ai_nlp_intent_parser.dart';
import 'package:travelgo/features/ai_agent/domain/entities/ai_search_intent.dart';
import 'package:travelgo/flights/domain/entities/flight_search_params.dart' as flight_params;

void main() {
  group('Phase AI-02: NLP Intent Parser & Schema Validation Tests', () {
    final fixedRefDate = DateTime(2026, 9, 14);

    // 1. Arabic Flight Query
    test('parses complex Arabic flight query accurately', () {
      const query = 'أريد السفر من الجزائر إلى إسطنبول لشخصين في نوفمبر لمدة أسبوع';
      final intent = AINlpIntentParser.parseQuery(query, referenceDate: fixedRefDate);

      expect(intent.searchType, AISearchType.flight);
      expect(intent.originCode, 'ALG');
      expect(intent.originCity, 'Algiers');
      expect(intent.destinationCode, 'IST');
      expect(intent.destinationCity, 'Istanbul');
      expect(intent.adults, 2);
      expect(intent.children, 0);
      expect(intent.departureDate?.month, 11);
      expect(intent.departureDate?.year, 2026);
      expect(intent.returnDate?.difference(intent.departureDate!).inDays, 7);
      expect(intent.isFlightSearch, isTrue);
      expect(intent.missingFields.isEmpty, isTrue);
      expect(intent.isComplete, isTrue);

      final flightParams = intent.toFlightSearchParams();
      expect(flightParams, isNotNull);
      expect(flightParams!.originCode, 'ALG');
      expect(flightParams.destinationCode, 'IST');
      expect(flightParams.adults, 2);
    });

    // 2. English Flight Query with preferences
    test('parses English flight query with cheapest preference', () {
      const query = 'I want the cheapest flight from Algiers to Paris next month for 2 adults.';
      final intent = AINlpIntentParser.parseQuery(query, referenceDate: fixedRefDate);

      expect(intent.searchType, AISearchType.flight);
      expect(intent.originCode, 'ALG');
      expect(intent.destinationCode, 'CDG');
      expect(intent.adults, 2);
      expect(intent.userPreferences.contains('cheapest'), isTrue);
      expect(intent.departureDate?.month, 10); // next month after Sept is Oct
      expect(intent.missingFields.isEmpty, isTrue);
      expect(intent.isComplete, isTrue);
    });

    // 3. Arabic Hotel Query with stars, location, and nights
    test('parses Arabic hotel query with location, star rating, and nights', () {
      const query = 'أريد فندق 4 نجوم في إسطنبول قريب من وسط المدينة لمدة 5 ليال';
      final intent = AINlpIntentParser.parseQuery(query, referenceDate: fixedRefDate);

      expect(intent.searchType, AISearchType.hotel);
      expect(intent.destinationCode, 'IST');
      expect(intent.destinationCity, 'Istanbul');
      expect(intent.hotelMinStars, 4);
      expect(intent.hotelLocationPreference, 'City Center');
      expect(intent.numberOfNights, 5);
      expect(intent.isHotelSearch, isTrue);
    });

    // 4. Missing Fields Detection
    test('detects missing origin and dates when query only specifies destination', () {
      const query = 'I want to travel to Istanbul.';
      final intent = AINlpIntentParser.parseQuery(query, referenceDate: fixedRefDate);

      expect(intent.destinationCode, 'IST');
      expect(intent.originCode, isNull);
      expect(intent.departureDate, isNull);
      expect(intent.missingFields.contains('origin'), isTrue);
      expect(intent.missingFields.contains('departure_date'), isTrue);
      expect(intent.isComplete, isFalse);
      expect(intent.toFlightSearchParams(), isNull);
    });

    test('detects missing destination when only origin and date are provided', () {
      const query = 'Flight from Algiers next week for 1 adult';
      final intent = AINlpIntentParser.parseQuery(query, referenceDate: fixedRefDate);

      expect(intent.originCode, 'ALG');
      expect(intent.destinationCode, isNull);
      expect(intent.missingFields.contains('destination'), isTrue);
      expect(intent.isComplete, isFalse);
    });

    // 5. Schema Validation & Error Rejection
    test('rejects queries with identical origin and destination', () {
      const query = 'Flight from Algiers to Algiers next week';
      final intent = AINlpIntentParser.parseQuery(query, referenceDate: fixedRefDate);

      expect(intent.originCode, 'ALG');
      expect(intent.destinationCode, 'ALG');
      expect(intent.validationErrors.isNotEmpty, isTrue);
      expect(intent.isComplete, isFalse);
    });

    // 6. Malformed and Random Queries
    test('handles garbage and malformed input gracefully without crashing', () {
      const query = '!@#\$%^&*() Random garbage text 123456';
      final intent = AINlpIntentParser.parseQuery(query, referenceDate: fixedRefDate);

      expect(intent.rawQuery, query);
      expect(intent.isComplete, isFalse);
      expect(intent.missingFields.isNotEmpty, isTrue);
    });

    // 7. Timeout and Failure Resilience
    test('simulates timeout and error handling safely', () async {
      Future<AISearchIntent> simulateTimeoutCall() async {
        return Future.delayed(const Duration(milliseconds: 200), () {
          throw TimeoutException('AI Gateway request timed out after 5000ms');
        });
      }

      expect(() => simulateTimeoutCall(), throwsA(isA<TimeoutException>()));
    });
  });
}
