import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../screens/ai_trip_plan_detail_screen.dart';
import 'ai_budget_optimizer_card.dart';
import 'ai_flight_recommendation_card.dart';
import 'ai_hotel_recommendation_card.dart';
import 'ai_itinerary_timeline.dart';

class AIChatBubble extends StatelessWidget {
  final AIMessageEntity message;
  final bool isArabic;
  final void Function(String reply)? onQuickReplySelected;

  const AIChatBubble({
    super.key,
    required this.message,
    required this.isArabic,
    this.onQuickReplySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primary
                        : (isDark ? AppColors.cardDark : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppSpacing.radiusMd),
                      topRight: const Radius.circular(AppSpacing.radiusMd),
                      bottomLeft: Radius.circular(isUser ? AppSpacing.radiusMd : 0),
                      bottomRight: Radius.circular(isUser ? 0 : AppSpacing.radiusMd),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isUser
                          ? Colors.white
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: AppColors.primary, size: 16),
                ),
              ],
            ],
          ),

          // Attached Verified Flights Recommendations
          if (!isUser && message.recommendedFlights.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...message.recommendedFlights.map((flight) {
              return AIFlightRecommendationCard(
                flight: flight,
                rationale: message.aiRationale,
              );
            }),
          ],

          // Attached Verified Hotels Recommendations
          if (!isUser && message.recommendedHotels.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...message.recommendedHotels.map((hotel) {
              return AIHotelRecommendationCard(
                hotel: hotel,
                rationale: message.aiRationale,
              );
            }),
          ],

          // Attached Trip Itinerary
          if (!isUser && message.hasTripPlan) ...[
            const SizedBox(height: 4),
            AIItineraryTimeline(
              tripPlan: message.tripPlan!,
              isArabic: isArabic,
              onViewDetails: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AITripPlanDetailScreen(tripPlan: message.tripPlan!),
                  ),
                );
              },
            ),
          ],

          // Attached Budget Optimizer
          if (!isUser && message.hasBudgetBreakdown) ...[
            const SizedBox(height: 4),
            AIBudgetOptimizerCard(
              budget: message.budgetBreakdown!,
            ),
          ],

          // Attached Interactive Quick-Reply Option Pills
          if (!isUser && message.hasQuickReplies) ...[
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: isArabic ? 0 : 28, right: isArabic ? 28 : 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: message.quickReplies.map((reply) {
                  return ActionChip(
                    label: Text(
                      reply,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    backgroundColor: isDark
                        ? AppColors.cardDark
                        : AppColors.primaryContainer.withOpacity(0.4),
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.35),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    onPressed: () {
                      if (onQuickReplySelected != null) {
                        onQuickReplySelected!(reply);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
