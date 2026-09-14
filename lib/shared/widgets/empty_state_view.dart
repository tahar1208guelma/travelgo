import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'custom_button.dart';

class EmptyStateView extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionTap;

  const EmptyStateView({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.search_off_rounded,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 54,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
            if (actionText != null && onActionTap != null) ...[
              const SizedBox(height: AppSpacing.lg),
              CustomButton(
                text: actionText!,
                onPressed: onActionTap,
                isFullWidth: false,
                width: 180,
                height: 46,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
