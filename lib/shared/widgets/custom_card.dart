import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Luxury World-Class Card with Airbnb/Booking soft ambient shadows and rounded contours
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;
  final bool hasBorder;
  final BorderSide? customBorder;
  final List<BoxShadow>? customShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.backgroundColor,
    this.borderRadius = AppSpacing.radiusMd,
    this.hasBorder = true,
    this.customBorder,
    this.customShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final defaultBorder = BorderSide(
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
      width: 1,
    );

    final shadows = customShadow ?? (isDark ? AppColors.darkCardShadow : AppColors.softCardShadow);

    Widget content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
      ),
      child: Material(
        color: backgroundColor ?? defaultBg,
        shape: hasBorder
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                side: customBorder ?? defaultBorder,
              )
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    return content;
  }
}
