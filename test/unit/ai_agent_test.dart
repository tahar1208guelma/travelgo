import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/features/ai_agent/data/datasources/ai_agent_datasource.dart';
import 'package:travelgo/features/ai_agent/data/repositories/ai_agent_repository_impl.dart';
import 'package:travelgo/features/ai_agent/domain/entities/ai_budget_breakdown.dart';
import 'package:travelgo/features/ai_agent/domain/entities/ai_trip_plan_entity.dart';
import 'package:travelgo/features/flights/data/repositories/flight_repository_impl.dart';
import 'package:travelgo/features/hotels/data/repositories/hotel_repository_impl.dart';
import 'package:travelgo/providers_layer/mock_travel_provider.dart';

void main() {
  group('AI Travel Agent Unit Tests', () {
    late MockTravelProvider mockProvider;
    late FlightRepositoryImpl flightRepo;
    late HotelRepositoryImpl hotelRepo;
    late AIAgentDataSourceImpl dataSource;
    late AIAgentRepositoryImpl repository;

    setUp(() {
      mockProvider = MockTravelProvider();
      flightRepo = FlightRepositoryImpl(mockProvider);
      hotelRepo = HotelRepositoryImpl(mockProvider);
      dataSource = AIAgentDataSourceImpl(flightRepo, hotelRepo);
      repository = AIAgentRepositoryImpl(dataSource);
    });

    test('calculateBudgetOptimization accurately splits total budget', () {
      const totalBudget = 1000.0;
      final breakdown = dataSource.calculateBudgetOptimization(
        totalBudgetUSD: totalBudget,
        durationDays: 4,
        travelers: 1,
      );

      expect(breakdown.totalBudgetUSD, 1000.0);
      expect(breakdown.flightBudgetUSD, 400.0); // 40%
      expect(breakdown.hotelBudgetUSD, 450.0); // 45%
      expect(breakdown.activitiesBudgetUSD, 100.0); // 10%
      expect(breakdown.bufferUSD, 50.0); // 5%

      final sum = breakdown.flightBudgetUSD +
          breakdown.hotelBudgetUSD +
          breakdown.activitiesBudgetUSD +
          breakdown.bufferUSD;
      expect(sum, totalBudget);
    });

    test('generateTripPlan constructs full day-by-day itinerary', () async {
      final plan = await repository.generateTripPlan(
        destination: 'Paris',
        origin: 'Algiers',
        days: 4,
        budgetUSD: 900.0,
      );

      expect(plan.destination, 'Paris');
      expect(plan.durationDays, 4);
      expect(plan.days.length, 4);
      expect(plan.days[0].activities.length, greaterThanOrEqualTo(2));
      expect(plan.days[3].activities.length, greaterThanOrEqualTo(2));
      expect(plan.travelTips.isNotEmpty, isTrue);
    });

    test('processUserQuery parses natural language intent for Paris query', () async {
      final response = await repository.sendMessage(
        userQuery: 'Plan a 4-day trip to Paris under \$900',
        conversationHistory: [],
      );

      expect(response.extractedIntent?.destination, 'Paris');
      expect(response.extractedIntent?.durationDays, 4);
      expect(response.extractedIntent?.budgetUSD, 900.0);
      expect(response.recommendedFlights.isNotEmpty, isTrue);
      expect(response.recommendedHotels.isNotEmpty, isTrue);
      expect(response.hasTripPlan, isTrue);
      expect(response.hasBudgetBreakdown, isTrue);
    });

    test('processUserQuery parses Arabic travel queries', () async {
      final response = await repository.sendMessage(
        userQuery: 'خطط لرحلة 4 أيام في باريس بميزانية 900 دولار',
        conversationHistory: [],
        isArabic: true,
      );

      expect(response.extractedIntent?.destination, 'Paris');
      expect(response.extractedIntent?.durationDays, 4);
      expect(response.extractedIntent?.budgetUSD, 900.0);
      expect(response.content.contains('باريس'), isTrue);
      expect(response.hasQuickReplies, isTrue);
      expect(response.quickReplies.isNotEmpty, isTrue);
    });

    test('processUserQuery handles general FAQs and generates informative quick replies', () async {
      final faqResponse = await repository.sendMessage(
        userQuery: 'ما هو أفضل وقت لزيارة إسطنبول؟',
        conversationHistory: [],
        isArabic: true,
      );

      expect(faqResponse.content.contains('أفضل وقت'), isTrue);
      expect(faqResponse.hasQuickReplies, isTrue);
      expect(faqResponse.quickReplies.length, greaterThanOrEqualTo(2));
    });

    test('processUserQuery supports new destinations such as Antalya and Maldives', () async {
      final antalyaResponse = await repository.sendMessage(
        userQuery: 'Plan a 5-day beach trip to Antalya with \$1200 budget',
        conversationHistory: [],
      );

      expect(antalyaResponse.extractedIntent?.destination, 'Antalya');
      expect(antalyaResponse.extractedIntent?.durationDays, 5);
      expect(antalyaResponse.hasTripPlan, isTrue);
      expect(antalyaResponse.hasQuickReplies, isTrue);
    });
  });
}
