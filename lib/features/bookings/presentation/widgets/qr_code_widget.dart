import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class SafeQrCodeWidget extends StatelessWidget {
  final String qrData;
  final double size;
  final String? caption;

  const SafeQrCodeWidget({
    super.key,
    required this.qrData,
    this.size = 140,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: size,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Color(0xFF0D47A1),
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Color(0xFF1E88E5),
            ),
            errorCorrectionLevel: QrErrorCorrectLevel.M,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 6),
          Text(
            caption!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ],
      ],
    );
  }
}
