import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';

class BadgeChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const BadgeChip({
    super.key,
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.fontSize = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
