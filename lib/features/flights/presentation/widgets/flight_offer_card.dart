import 'package:flutter/material.dart';
import '../../../../core/services/provider_redirect_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../models/flight_offer.dart';

class FlightOfferCard extends StatelessWidget {
  final FlightOffer offer;
  final VoidCallback onSelect;

  const FlightOfferCard({
    super.key,
    required this.offer,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final segment = offer.primaryOutboundSegment;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
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
              // Airline & Cabin Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.flight_takeoff, color: AppTheme.accentBlue, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.validatingAirline,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          Text(
                            offer.outboundSegments.length > 1
                                ? offer.outboundSegments.map((s) => s.flightNumber).join(' + ')
                                : segment.flightNumber,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.electricCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      segment.cabinClass,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, color: AppTheme.cardBorder),

              // Route & Timeline Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Origin Departure
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.departureAirportCode,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        Text(
                          DateFormatter.formatTime(offer.departureDateTime),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.accentBlue),
                        ),
                        Text(
                          offer.firstSegment.departureCity ?? offer.firstSegment.departureAirport,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),

                  // Center Flight Timeline & Stops Badge
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        Text(
                          DateFormatter.formatDuration(offer.totalJourneyDuration),
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.circle, size: 6, color: AppTheme.accentBlue),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: AppTheme.accentBlue.withValues(alpha: 0.4),
                              ),
                            ),
                            if (!offer.isDirect) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningOrange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  offer.transitAirportCodes.join(' • '),
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.warningOrange),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: AppTheme.accentBlue.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                            const Icon(Icons.flight, size: 16, color: AppTheme.accentBlue),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: AppTheme.accentBlue.withValues(alpha: 0.4),
                              ),
                            ),
                            const Icon(Icons.circle, size: 6, color: AppTheme.accentBlue),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: offer.isDirect
                                ? AppTheme.successGreen.withValues(alpha: 0.12)
                                : (offer.stopsCount == 1
                                    ? AppTheme.warningOrange.withValues(alpha: 0.12)
                                    : Colors.purple.withValues(alpha: 0.12)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            offer.stopsLabel,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: offer.isDirect
                                  ? AppTheme.successGreen
                                  : (offer.stopsCount == 1 ? AppTheme.warningOrange : Colors.purple),
                            ),
                          ),
                        ),
                        if (!offer.isDirect)
                          ...offer.outboundSegments.sublist(0, offer.outboundSegments.length - 1).asMap().entries.map((entry) {
                            final idx = entry.key;
                            final seg = entry.value;
                            final nextSeg = offer.outboundSegments[idx + 1];
                            final layover = nextSeg.departureDateTime.difference(seg.arrivalDateTime);
                            final isRisky = layover.inMinutes < 60;
                            final isOptimal = layover.inMinutes >= 90 && layover.inMinutes <= 180;
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer_outlined, size: 10, color: isRisky ? AppTheme.errorRed : isOptimal ? AppTheme.successGreen : AppTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${layover.inHours}h ${layover.inMinutes.remainder(60)}m at ${seg.arrivalAirportCode}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: isRisky || isOptimal ? FontWeight.bold : FontWeight.normal,
                                      color: isRisky ? AppTheme.errorRed : isOptimal ? AppTheme.successGreen : AppTheme.textMuted,
                                    ),
                                  ),
                                  if (isRisky)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Text('(Risky)', style: TextStyle(fontSize: 8, color: AppTheme.errorRed, fontWeight: FontWeight.bold)),
                                    )
                                ],
                              ),
                            );
                          })
                      ],
                    ),
                  ),

                  // Final Arrival
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          offer.arrivalAirportCode,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        Text(
                          DateFormatter.formatTime(offer.arrivalDateTime),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.accentBlue),
                        ),
                        Text(
                          offer.lastSegment.arrivalCity ?? offer.lastSegment.arrivalAirport,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Bottom Price & Booking CTA Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            CurrencyFormatter.format(offer.price.totalAmount, currency: offer.price.currency),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Text(
                              '0% Extra Fees',
                              style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        offer.baggageSummary,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: onSelect,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accentBlue,
                          side: const BorderSide(color: AppTheme.cardBorder),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('تفاصيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton.icon(
                        onPressed: () {
                          ProviderRedirectService.showFlightRedirectDialog(
                            context: context,
                            airlineName: offer.validatingAirline,
                            flightNumber: segment.flightNumber,
                            routeSummary: '${segment.departureAirportCode} → ${segment.arrivalAirportCode}',
                            priceText: CurrencyFormatter.format(offer.price.totalAmount, currency: offer.price.currency),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.open_in_new, size: 14),
                        label: const Text('احجز رسمياً', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
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
