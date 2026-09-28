import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/rating_stars.dart';
import '../../domain/entities/review_entity.dart';
import 'add_review_dialog.dart';

class UserReviewsWidget extends StatefulWidget {
  final String propertyId;
  final double averageRating;
  final int totalReviews;

  const UserReviewsWidget({
    super.key,
    required this.propertyId,
    this.averageRating = 4.8,
    this.totalReviews = 142,
  });

  @override
  State<UserReviewsWidget> createState() => _UserReviewsWidgetState();
}

class _UserReviewsWidgetState extends State<UserReviewsWidget> {
  late List<ReviewEntity> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = ReviewEntity.getSampleReviews(widget.propertyId);
  }

  void _onReviewAdded(ReviewEntity review) {
    setState(() {
      _reviews = [review, ..._reviews];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Overall Rating & Write Review Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.secondary : AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        widget.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Exceptional Guest Reviews',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Based on ${_reviews.length + widget.totalReviews} verified traveler ratings',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () {
                AddReviewDialog.show(
                  context,
                  propertyId: widget.propertyId,
                  onSubmit: _onReviewAdded,
                );
              },
              icon: const Icon(Icons.rate_review_outlined, size: 16),
              label: const Text('Write Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.secondaryLight : AppColors.primary,
                side: BorderSide(color: isDark ? AppColors.secondaryLight : AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // 2. Multi-factor Category Rating Progress Bars (Cleanliness, Location, Service, Value)
        CustomCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              _buildRatingFactorRow('Cleanliness & Hygiene', 4.9, isDark),
              const SizedBox(height: 8),
              _buildRatingFactorRow('Location & Scenery', 4.8, isDark),
              const SizedBox(height: 8),
              _buildRatingFactorRow('Hospitality & Service', 4.9, isDark),
              const SizedBox(height: 8),
              _buildRatingFactorRow('Value for Money', 4.7, isDark),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 3. Traveler Reviews List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _reviews.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final rev = _reviews[index];
            return CustomCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.15),
                            child: Text(
                              rev.authorName.isNotEmpty ? rev.authorName[0] : 'U',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.secondaryLight : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rev.authorName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                '${rev.authorCountry} • ${AppDateFormatter.formatDate(rev.date)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      RatingStars(rating: rev.rating, size: 14),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (rev.isVerifiedStay)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: BadgeChip(
                        label: 'VERIFIED GUEST STAY',
                        icon: Icons.verified_user_rounded,
                        backgroundColor: AppColors.success.withValues(alpha: 0.12),
                        textColor: AppColors.success,
                        fontSize: 9,
                      ),
                    ),
                  Text(
                    rev.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    rev.comment,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, size: 14, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                      const SizedBox(width: 4),
                      Text(
                        'Helpful (${rev.helpfulVotes})',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRatingFactorRow(String label, double score, bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 5.0,
              minHeight: 6,
              backgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.secondaryLight : AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          score.toStringAsFixed(1),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
