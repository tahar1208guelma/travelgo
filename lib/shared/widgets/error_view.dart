import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'custom_button.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData icon;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText,
    this.icon = Icons.error_outline_rounded,
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
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              CustomButton(
                text: retryText ?? 'Try Again',
                onPressed: onRetry,
                isFullWidth: false,
                width: 160,
                height: 44,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
