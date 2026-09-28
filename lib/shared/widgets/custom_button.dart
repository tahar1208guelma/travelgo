import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

enum ButtonType { primary, secondary, outline, text, success, gradient }

class CustomButton extends StatefulWidget {
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
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content;
    if (widget.isLoading) {
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
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 19, color: _getTextColor(context, isDark)),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: _getTextColor(context, isDark),
            ),
          ),
        ],
      );
    }

    Widget button;
    if (widget.type == ButtonType.gradient) {
      button = Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: widget.onPressed == null ? null : AppColors.floatingButtonShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Center(child: content),
          ),
        ),
      );
    } else {
      switch (widget.type) {
        case ButtonType.primary:
          button = ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            child: content,
          );
          break;
        case ButtonType.secondary:
          button = ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.secondaryContainerDark : AppColors.secondary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            child: content,
          );
          break;
        case ButtonType.success:
          button = ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            child: content,
          );
          break;
        case ButtonType.outline:
          button = OutlinedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.secondaryLight : AppColors.primary,
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            child: content,
          );
          break;
        case ButtonType.text:
          button = TextButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColors.secondaryLight : AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            child: content,
          );
          break;
        default:
          button = Container();
      }
    }

    final sized = widget.isFullWidth
        ? SizedBox(width: double.infinity, height: widget.height, child: button)
        : SizedBox(width: widget.width, height: widget.height, child: button);

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: sized,
      ),
    );
  }

  Color _getTextColor(BuildContext context, bool isDark) {
    switch (widget.type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.success:
      case ButtonType.gradient:
        return Colors.white;
      case ButtonType.outline:
        return isDark ? AppColors.textPrimaryDark : AppColors.primary;
      case ButtonType.text:
        return isDark ? AppColors.secondaryLight : AppColors.primary;
    }
  }
}
