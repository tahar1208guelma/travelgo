import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../models/hotel_offer.dart';

class HotelOfferCard extends StatelessWidget {
  final HotelOffer offer;
  final VoidCallback onSelect;

  const HotelOfferCard({
    super.key,
    required this.offer,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (offer.mainImageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                  child: Image.network(
                    offer.mainImageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(height: 150, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              if (offer.mainImageUrl != null) const SizedBox(height: 12),
              // Hotel Name & Star Rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (offer.mainImageUrl == null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.hotel, color: AppTheme.accentBlue, size: 24),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          offer.address,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(
                              offer.starRating,
                              (i) => const Icon(Icons.star, size: 14, color: Colors.amber),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Text(
                                '${offer.userRating} (${offer.reviewCount} reviews)',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, color: AppTheme.cardBorder),

              // Room & Meal Plan info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.primaryRoom.roomType,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy),
                        ),
                        if (offer.primaryRoom.bedType != null)
                          Text(
                            offer.primaryRoom.bedType!,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          offer.mealPlan,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accentBlue),
                        ),
                        if (offer.amenities.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: offer.amenities.take(3).map((a) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                a,
                                style: const TextStyle(fontSize: 9, color: AppTheme.textDark),
                              ),
                            )).toList(),
                          )
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${CurrencyFormatter.format(offer.pricePerNight, currency: offer.price.currency)} / night',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                      Text(
                        CurrencyFormatter.format(offer.price.totalAmount, currency: offer.price.currency),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                      ),
                      if (offer.price.hasServiceFee)
                        const Text(
                          '0.75% Fee & Taxes incl.',
                          style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Policy & CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      offer.cancellationPolicy,
                      style: const TextStyle(fontSize: 11, color: AppTheme.successGreen, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View Deal', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
