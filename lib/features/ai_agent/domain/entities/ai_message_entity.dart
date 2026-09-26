import 'ai_budget_breakdown.dart';
import 'ai_trip_plan_entity.dart';
import '../../../flights/domain/entities/flight_entity.dart';
import '../../../hotels/domain/entities/hotel_entity.dart';

enum AIMessageSender { user, assistant, system }

class AIExtractedIntent {
  final String? destination;
  final String? origin;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? durationDays;
  final double? budgetUSD;
  final int? passengers;
  final String? travelStyle; // "luxury", "budget", "family", "romantic"

  const AIExtractedIntent({
    this.destination,
    this.origin,
    this.startDate,
    this.endDate,
    this.durationDays,
    this.budgetUSD,
    this.passengers,
    this.travelStyle,
  });
}

class AIMessageEntity {
  final String id;
  final AIMessageSender sender;
  final String content;
  final DateTime timestamp;
  final AIExtractedIntent? extractedIntent;
  final List<FlightEntity> recommendedFlights;
  final List<HotelEntity> recommendedHotels;
  final AITripPlanEntity? tripPlan;
  final AIBudgetBreakdown? budgetBreakdown;
  final String? aiRationale;
  final List<String> quickReplies;

  const AIMessageEntity({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.extractedIntent,
    this.recommendedFlights = const [],
    this.recommendedHotels = const [],
    this.tripPlan,
    this.budgetBreakdown,
    this.aiRationale,
    this.quickReplies = const [],
  });

  bool get isUser => sender == AIMessageSender.user;
  bool get hasRecommendations => recommendedFlights.isNotEmpty || recommendedHotels.isNotEmpty;
  bool get hasTripPlan => tripPlan != null;
  bool get hasBudgetBreakdown => budgetBreakdown != null;
  bool get hasQuickReplies => quickReplies.isNotEmpty;
}
