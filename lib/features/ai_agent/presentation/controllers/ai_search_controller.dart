import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../flights/presentation/controllers/flight_search_controller.dart';
import '../../../hotels/presentation/controllers/hotel_search_controller.dart';
import '../../domain/entities/ai_search_intent.dart';
import 'ai_agent_controller.dart';

class AISearchState {
  final bool isParsing;
  final AISearchIntent? intent;
  final String? errorMessage;
  final bool readyToNavigate;

  const AISearchState({
    this.isParsing = false,
    this.intent,
    this.errorMessage,
    this.readyToNavigate = false,
  });

  AISearchState copyWith({
    bool? isParsing,
    AISearchIntent? intent,
    String? errorMessage,
    bool? readyToNavigate,
    bool clearError = false,
    bool clearIntent = false,
  }) {
    return AISearchState(
      isParsing: isParsing ?? this.isParsing,
      intent: clearIntent ? null : (intent ?? this.intent),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      readyToNavigate: readyToNavigate ?? this.readyToNavigate,
    );
  }
}

final aiSearchControllerProvider =
    StateNotifierProvider<AISearchController, AISearchState>((ref) {
  final repository = ref.watch(aiAgentRepositoryProvider);
  return AISearchController(ref, repository);
});

class AISearchController extends StateNotifier<AISearchState> {
  final Ref _ref;
  final dynamic _repository;

  AISearchController(this._ref, this._repository) : super(const AISearchState());

  Future<AISearchIntent?> processNaturalSearch(String query, {bool isArabic = false}) async {
    if (query.trim().isEmpty) return null;

    state = state.copyWith(isParsing: true, clearError: true, readyToNavigate: false);

    try {
      final intent = await _repository.parseSearchIntent(query, isArabic: isArabic);

      if (intent.isComplete) {
        _applyIntentToCoreControllers(intent);
        state = state.copyWith(isParsing: false, intent: intent, readyToNavigate: true);
      } else {
        state = state.copyWith(isParsing: false, intent: intent, readyToNavigate: false);
      }

      return intent;
    } catch (e) {
      state = state.copyWith(
        isParsing: false,
        errorMessage: isArabic
            ? 'حدث خطأ أثناء معالجة الطلب. يرجى المحاولة مرة أخرى.'
            : 'Error processing search query. Please try again.',
      );
      return null;
    }
  }

  void updateIntent(AISearchIntent updatedIntent) {
    if (updatedIntent.isComplete) {
      _applyIntentToCoreControllers(updatedIntent);
      state = state.copyWith(intent: updatedIntent, readyToNavigate: true);
    } else {
      state = state.copyWith(intent: updatedIntent, readyToNavigate: false);
    }
  }

  void _applyIntentToCoreControllers(AISearchIntent intent) {
    if (intent.isFlightSearch && intent.isCompleteForFlightSearch) {
      final flightParams = intent.toFlightSearchParams();
      if (flightParams != null) {
        _ref.read(flightSearchControllerProvider.notifier).updateSearchParams(flightParams);
        _ref.read(flightSearchControllerProvider.notifier).searchFlights();
      }
    } else if (intent.isHotelSearch && intent.isCompleteForHotelSearch) {
      final hotelParams = intent.toHotelSearchParams();
      if (hotelParams != null) {
        _ref.read(hotelSearchControllerProvider.notifier).updateSearchParams(hotelParams);
        _ref.read(hotelSearchControllerProvider.notifier).searchHotels();
      }
    }
  }

  void reset() {
    state = const AISearchState();
  }
}
