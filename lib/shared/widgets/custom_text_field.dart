import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int maxLines;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          readOnly: readOnly,
          maxLines: maxLines,
          focusNode: focusNode,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontSize: 14,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : Colors.white,
          ),
        ),
      ],
    );
  }
}
