import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../domain/entities/ai_trip_plan_entity.dart';

class AIItineraryTimeline extends StatelessWidget {
  final AITripPlanEntity tripPlan;
  final bool isArabic;
  final VoidCallback? onViewDetails;

  const AIItineraryTimeline({
    super.key,
    required this.tripPlan,
    required this.isArabic,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: CustomCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.route_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      tripPlan.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    '${tripPlan.durationDays} ${isArabic ? "أيام" : "Days"}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              tripPlan.summary,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Day by Day Preview
            ...tripPlan.days.take(2).map((day) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isArabic ? "اليوم" : "Day"} ${day.dayNumber}: ${day.title}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      ...day.activities.map((act) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${act.time} — ',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                              Expanded(
                                child: Text(
                                  act.title,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),

            if (onViewDetails != null)
              Center(
                child: TextButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(
                    isArabic ? 'عرض البرنامج اليومي بالكامل' : 'View Full Itinerary',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
