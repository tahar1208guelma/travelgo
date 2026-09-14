import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 14.0,
    this.color = AppColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, size: size, color: color);
        } else if (index == fullStars && hasHalf) {
          return Icon(Icons.star_half, size: size, color: color);
        } else {
          return Icon(Icons.star_border, size: size, color: color.withOpacity(0.4));
        }
      }),
    );
  }
}
