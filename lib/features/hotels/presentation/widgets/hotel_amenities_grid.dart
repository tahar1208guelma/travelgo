import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class HotelAmenitiesGrid extends StatelessWidget {
  final List<String> amenities;

  const HotelAmenitiesGrid({super.key, required this.amenities});

  IconData _getAmenityIcon(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi')) return Icons.wifi_rounded;
    if (lower.contains('pool') || lower.contains('beach')) return Icons.pool_rounded;
    if (lower.contains('spa')) return Icons.spa_rounded;
    if (lower.contains('gym') || lower.contains('fitness')) return Icons.fitness_center_rounded;
    if (lower.contains('dining') || lower.contains('restaurant') || lower.contains('breakfast')) return Icons.restaurant_rounded;
    if (lower.contains('shuttle') || lower.contains('transfer') || lower.contains('valet')) return Icons.directions_car_rounded;
    if (lower.contains('butler') || lower.contains('concierge')) return Icons.room_service_rounded;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: amenities.map((amenity) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.primaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getAmenityIcon(amenity), size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                amenity,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
