import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../flights/presentation/controllers/flight_search_controller.dart';
import '../../../hotels/presentation/controllers/hotel_search_controller.dart';
import '../../data/datasources/ai_agent_datasource.dart';
import '../../data/repositories/ai_agent_repository_impl.dart';
import '../../domain/entities/ai_budget_breakdown.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../domain/entities/ai_trip_plan_entity.dart';
import '../../domain/repositories/ai_agent_repository.dart';

class AIAgentState {
  final List<AIMessageEntity> messages;
  final bool isThinking;
  final AITripPlanEntity? activeTripPlan;
  final AIBudgetBreakdown? activeBudget;
  final String? errorMessage;

  const AIAgentState({
    this.messages = const [],
    this.isThinking = false,
    this.activeTripPlan,
    this.activeBudget,
    this.errorMessage,
  });

  AIAgentState copyWith({
    List<AIMessageEntity>? messages,
    bool? isThinking,
    AITripPlanEntity? activeTripPlan,
    AIBudgetBreakdown? activeBudget,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AIAgentState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      activeTripPlan: activeTripPlan ?? this.activeTripPlan,
      activeBudget: activeBudget ?? this.activeBudget,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final aiAgentRepositoryProvider = Provider<AIAgentRepository>((ref) {
  final flightRepo = ref.watch(flightRepositoryProvider);
  final hotelRepo = ref.watch(hotelRepositoryProvider);
  final dataSource = AIAgentDataSourceImpl(flightRepo, hotelRepo);
  return AIAgentRepositoryImpl(dataSource);
});

final aiAgentControllerProvider = StateNotifierProvider<AIAgentController, AIAgentState>((ref) {
  final repository = ref.watch(aiAgentRepositoryProvider);
  return AIAgentController(repository);
});

class AIAgentController extends StateNotifier<AIAgentState> {
  final AIAgentRepository _repository;
  final _uuid = const Uuid();

  AIAgentController(this._repository) : super(const AIAgentState()) {
    _initWelcomeMessage();
  }

  void _initWelcomeMessage({bool isArabic = false}) {
    final welcomeMsg = AIMessageEntity(
      id: 'msg_welcome',
      sender: AIMessageSender.assistant,
      content: isArabic
          ? 'مرحباً بك في **المساعد الذكي لترافل جو**! ✈️\n\n'
            'أنا هنا لمساعدتك في تخطيط رحلتك، البحث الطبيعي عن التذاكر، واقتراح أفضل الفنادق مع تحسين الميزانية.\n\n'
            'جرّب أن تسألني: *"خطط لرحلة 4 أيام إلى باريس بميزانية 900 دولار"* أو اختر من الاقتراحات السريعة أدناه.'
          : 'Welcome to **TRAVELGO AI Travel Assistant**! ✈️\n\n'
            'I can craft customized multi-day itineraries, discover verified flight deals, optimize your travel budget, and find top-rated hotels.\n\n'
            'Try asking: *"Plan a 4-day trip to Paris under \$900"* or tap any quick suggestion below.',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(messages: [welcomeMsg]);
  }

  Future<void> sendQuery(String userQuery, {bool isArabic = false}) async {
    if (userQuery.trim().isEmpty) return;

    final userMsg = AIMessageEntity(
      id: 'msg_${_uuid.v4().substring(0, 8)}',
      sender: AIMessageSender.user,
      content: userQuery.trim(),
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
      clearError: true,
    );

    try {
      final response = await _repository.sendMessage(
        userQuery: userQuery,
        conversationHistory: state.messages,
        isArabic: isArabic,
      );

      state = state.copyWith(
        messages: [...state.messages, response],
        isThinking: false,
        activeTripPlan: response.tripPlan ?? state.activeTripPlan,
        activeBudget: response.budgetBreakdown ?? state.activeBudget,
      );
    } catch (e) {
      state = state.copyWith(
        isThinking: false,
        errorMessage: isArabic
            ? 'تعذر معالجة الطلب حالياً. يرجى المحاولة مرة أخرى.'
            : 'Could not process query. Please try again.',
      );
    }
  }

  void updateBudgetOptimization({
    required double totalBudgetUSD,
    required int durationDays,
    required int travelers,
  }) {
    final updatedBudget = _repository.optimizeBudget(
      totalBudgetUSD: totalBudgetUSD,
      durationDays: durationDays,
      travelers: travelers,
    );
    state = state.copyWith(activeBudget: updatedBudget);
  }

  void clearConversation({bool isArabic = false}) {
    state = const AIAgentState();
    _initWelcomeMessage(isArabic: isArabic);
  }
}
