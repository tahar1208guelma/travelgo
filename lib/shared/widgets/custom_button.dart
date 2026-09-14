import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

enum ButtonType { primary, secondary, outline, text, success }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double? width;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 52.0,
    this.width,
    this.borderRadius = AppSpacing.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (isLoading) {
      content = const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getTextColor(context),
            ),
          ),
        ],
      );
    }

    Widget button;
    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: content,
        );
        break;
      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: content,
        );
        break;
      case ButtonType.success:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: content,
        );
        break;
      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: content,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: content,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: button,
    );
  }

  Color _getTextColor(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.success:
        return Colors.white;
      case ButtonType.outline:
      case ButtonType.text:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
