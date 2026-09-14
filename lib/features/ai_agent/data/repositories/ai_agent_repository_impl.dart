import '../../domain/entities/ai_budget_breakdown.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../domain/entities/ai_search_intent.dart';
import '../../domain/entities/ai_trip_plan_entity.dart';
import '../../domain/repositories/ai_agent_repository.dart';
import '../datasources/ai_agent_datasource.dart';
import '../datasources/ai_nlp_intent_parser.dart';

class AIAgentRepositoryImpl implements AIAgentRepository {
  final AIAgentDataSource _dataSource;

  AIAgentRepositoryImpl(this._dataSource);

  @override
  Future<AISearchIntent> parseSearchIntent(String naturalQuery, {bool isArabic = false}) async {
    // Non-blocking asynchronous intent parsing
    await Future.delayed(const Duration(milliseconds: 100));
    return AINlpIntentParser.parseQuery(naturalQuery);
  }

  @override
  Future<AIMessageEntity> sendMessage({
    required String userQuery,
    required List<AIMessageEntity> conversationHistory,
    bool isArabic = false,
  }) {
    return _dataSource.processUserQuery(
      query: userQuery,
      history: conversationHistory,
      isArabic: isArabic,
    );
  }

  @override
  Future<AITripPlanEntity> generateTripPlan({
    required String destination,
    required String origin,
    required int days,
    required double budgetUSD,
    bool isArabic = false,
  }) {
    return _dataSource.generateTripPlan(
      destination: destination,
      origin: origin,
      days: days,
      budgetUSD: budgetUSD,
      isArabic: isArabic,
    );
  }

  @override
  AIBudgetBreakdown optimizeBudget({
    required double totalBudgetUSD,
    required int durationDays,
    required int travelers,
  }) {
    return _dataSource.calculateBudgetOptimization(
      totalBudgetUSD: totalBudgetUSD,
      durationDays: durationDays,
      travelers: travelers,
    );
  }
}
