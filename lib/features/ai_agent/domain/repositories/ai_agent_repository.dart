import '../entities/ai_budget_breakdown.dart';
import '../entities/ai_message_entity.dart';
import '../entities/ai_search_intent.dart';
import '../entities/ai_trip_plan_entity.dart';

abstract class AIAgentRepository {
  Future<AISearchIntent> parseSearchIntent(String naturalQuery, {bool isArabic = false});

  Future<AIMessageEntity> sendMessage({
    required String userQuery,
    required List<AIMessageEntity> conversationHistory,
    bool isArabic = false,
  });

  Future<AITripPlanEntity> generateTripPlan({
    required String destination,
    required String origin,
    required int days,
    required double budgetUSD,
    bool isArabic = false,
  });

  AIBudgetBreakdown optimizeBudget({
    required double totalBudgetUSD,
    required int durationDays,
    required int travelers,
  });
}
