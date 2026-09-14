import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionTitle;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionTitle,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        if (actionTitle != null && onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionTitle!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
