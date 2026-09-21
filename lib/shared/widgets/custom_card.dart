import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;
  final bool hasBorder;
  final BorderSide? customBorder;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.backgroundColor,
    this.borderRadius = AppSpacing.radiusMd,
    this.hasBorder = true,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.surfaceDark : AppColors.cardLight;
    final defaultBorder = BorderSide(
      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
      width: 1,
    );

    Widget content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}
