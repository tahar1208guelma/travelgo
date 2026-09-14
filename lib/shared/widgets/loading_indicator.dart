import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
