import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../bookings/presentation/widgets/price_summary_card.dart';
import '../../models/hotel_offer.dart';

class HotelOfferDetailsScreen extends StatelessWidget {
  final HotelOffer hotel;

  const HotelOfferDetailsScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hotel.name),
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(
                              hotel.starRating,
                              (i) => const Icon(Icons.star, size: 16, color: Colors.amber),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Guest Score: ${hotel.userRating}/5.0',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.successGreen),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hotel.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hotel.address,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Room & Amenities Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Room Details & Amenities',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                      ),
                      const Divider(height: 20, color: AppTheme.cardBorder),
                      Text(
                        hotel.primaryRoom.roomType,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                      ),
                      if (hotel.primaryRoom.bedType != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Bed Configuration: ${hotel.primaryRoom.bedType}',
                          style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                        ),
                      ],
                      if (hotel.primaryRoom.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          hotel.primaryRoom.description!,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                      const SizedBox(height: 14),
                      const Text(
                        'Included Property Amenities:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: hotel.amenities.map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.slateBackground,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.cardBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check, size: 14, color: AppTheme.accentBlue),
                                const SizedBox(width: 6),
                                Text(amenity, style: const TextStyle(fontSize: 12, color: AppTheme.primaryNavy)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 20, color: AppTheme.cardBorder),
                      Row(
                        children: [
                          const Icon(Icons.security, size: 18, color: AppTheme.successGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hotel.cancellationPolicy,
                              style: const TextStyle(fontSize: 12, color: AppTheme.successGreen, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Price Breakdown Card (With 0.75% TRAVELGO fee itemized)
              PriceSummaryCard(price: hotel.price),
              const SizedBox(height: 20),

              // Trust Badge
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user, color: AppTheme.successGreen),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'حجز مباشر من الفندق • بدون أي عمولة أو رسوم إضافية\nDirect Official Hotel Booking • 0% Extra Fees',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Reserve CTA Button
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _launchHotelUrl(context, hotel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.open_in_new, fontWeight: FontWeight.bold),
                  label: const Text(
                    'Book on Official Hotel Site / حجز مباشر من الفندق',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _launchHotelUrl(BuildContext context, HotelOffer hotel) {
    final query = Uri.encodeComponent('${hotel.name} ${hotel.city} official site');
    final urlStr = 'https://www.google.com/search?q=$query';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Redirecting to Hotel', style: TextStyle(color: AppTheme.primaryNavy)),
        content: Text('You will be redirected to search for the official website of ${hotel.name} to complete your booking securely with 0% extra fees.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              launchUrl(Uri.parse(urlStr), mode: LaunchMode.externalApplication);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
