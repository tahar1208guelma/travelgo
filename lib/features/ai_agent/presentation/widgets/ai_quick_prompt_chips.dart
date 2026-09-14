import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class AIQuickPromptChips extends StatelessWidget {
  final bool isArabic;
  final void Function(String prompt) onSelectPrompt;

  const AIQuickPromptChips({
    super.key,
    required this.isArabic,
    required this.onSelectPrompt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> prompts = isArabic
        ? [
            {'icon': Icons.explore_outlined, 'text': 'خطط لرحلة 4 أيام في باريس بأقل من 900 دولار'},
            {'icon': Icons.flight_takeoff, 'text': 'أرخص الرحلات المباشرة إلى دبي'},
            {'icon': Icons.hotel_outlined, 'text': 'فنادق فاخرة في إسطنبول مع إفطار مجاني'},
            {'icon': Icons.savings_outlined, 'text': 'توزيع ميزانية 1200 دولار لرحلة 5 أيام'},
          ]
        : [
            {'icon': Icons.explore_outlined, 'text': 'Plan a 4-day trip to Paris under \$900'},
            {'icon': Icons.flight_takeoff, 'text': 'Cheapest direct flights to Dubai'},
            {'icon': Icons.hotel_outlined, 'text': 'Top luxury hotel in Istanbul with breakfast'},
            {'icon': Icons.savings_outlined, 'text': 'Optimize \$1200 budget for 5 days'},
          ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final p = prompts[index];
          return ActionChip(
            avatar: Icon(p['icon'] as IconData, size: 16, color: AppColors.primary),
            label: Text(
              p['text'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            side: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.primary.withOpacity(0.25),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
            onPressed: () => onSelectPrompt(p['text'] as String),
          );
        },
      ),
    );
  }
}
