import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class SpecialOffersBanner extends StatelessWidget {
  const SpecialOffersBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF00897B), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D40).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Text(
                    'LIMITED OFFER',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Up to 30% Off Luxury Dubai & Paris Stays',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use code TRAVELGO30 at checkout.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
