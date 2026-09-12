import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/services/provider_redirect_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../bookings/presentation/widgets/price_summary_card.dart';
import '../../../checkout/bloc/checkout_bloc.dart';
import '../../../checkout/presentation/pages/flight_checkout_screen.dart';
import '../../../checkout/services/payment_gateway_service.dart';
import '../../models/flight_offer.dart';

class FlightOfferDetailsScreen extends StatelessWidget {
  final FlightOffer offer;

  const FlightOfferDetailsScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final segment = offer.primaryOutboundSegment;

    return Scaffold(
      appBar: AppBar(
        title: Text('${segment.departureAirportCode} → ${segment.arrivalAirportCode} Details'),
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Airline & Cabin Top Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.flight, color: AppTheme.accentBlue, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.validatingAirline,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                            ),
                            Text(
                              'Flight ${segment.flightNumber} • ${segment.aircraftType ?? "Standard Jet"}',
                              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.electricCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          segment.cabinClass,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.accentBlue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Itinerary Details Card
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
                          const Text(
                            'Flight Itinerary & Timetable',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: offer.isDirect
                                  ? AppTheme.successGreen.withValues(alpha: 0.12)
                                  : AppTheme.warningOrange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              offer.stopsLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: offer.isDirect ? AppTheme.successGreen : AppTheme.warningOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Total Journey Time: ${DateFormatter.formatDuration(offer.totalJourneyDuration)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accentBlue),
                      ),
                      const Divider(height: 20, color: AppTheme.cardBorder),

                      // Build all flight legs and layovers
                      ...List.generate(offer.outboundSegments.length, (index) {
                        final seg = offer.outboundSegments[index];
                        final isLast = index == offer.outboundSegments.length - 1;

                        Duration? layover;
                        if (!isLast) {
                          layover = offer.outboundSegments[index + 1].departureDateTime.difference(seg.arrivalDateTime);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Flight segment header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.slateBackground,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Flight Leg ${index + 1}: ${seg.airline} (${seg.flightNumber}) • ${seg.aircraftType ?? "Jet"}',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Departure
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.flight_takeoff, color: AppTheme.accentBlue, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${DateFormatter.formatTime(seg.departureDateTime)} • ${seg.departureCity ?? seg.departureAirport}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                                      ),
                                      Text(
                                        '${seg.departureAirport} (${seg.departureAirportCode})${seg.departureTerminal != null ? " • Terminal ${seg.departureTerminal}" : ""}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      ),
                                      Text(
                                        DateFormatter.formatDateFull(seg.departureDateTime),
                                        style: const TextStyle(fontSize: 11.5, color: AppTheme.textDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Flight duration
                            Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: Text(
                                'Air Time: ${DateFormatter.formatDuration(seg.duration)}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Arrival
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.flight_land, color: AppTheme.accentBlue, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${DateFormatter.formatTime(seg.arrivalDateTime)} • ${seg.arrivalCity ?? seg.arrivalAirport}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                                      ),
                                      Text(
                                        '${seg.arrivalAirport} (${seg.arrivalAirportCode})${seg.arrivalTerminal != null ? " • Terminal ${seg.arrivalTerminal}" : ""}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      ),
                                      Text(
                                        DateFormatter.formatDateFull(seg.arrivalDateTime),
                                        style: const TextStyle(fontSize: 11.5, color: AppTheme.textDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Layover Box if connecting
                            if (!isLast && layover != null) ...[
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 14),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningOrange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.warningOrange.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.transfer_within_a_station, color: AppTheme.warningOrange, size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Transit & Layover: ${DateFormatter.formatDuration(layover)} at ${seg.arrivalAirportCode} (${seg.arrivalCity ?? seg.arrivalAirport})',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppTheme.primaryNavy),
                                          ),
                                          const Text(
                                            'نقطة عبور وترانزيت • تبديل الطائرة مع تحويل الأمتعة تلقائياً',
                                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (!isLast) ...[
                              const SizedBox(height: 14),
                            ],
                          ],
                        );
                      }),
                      const Divider(height: 20, color: AppTheme.cardBorder),

                      // Baggage & Policy Specs
                      Row(
                        children: [
                          const Icon(Icons.luggage, size: 18, color: AppTheme.textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Baggage: ${segment.baggageAllowance ?? offer.baggageSummary}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.primaryNavy),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(offer.isRefundable ? Icons.check_circle : Icons.info_outline, size: 18, color: offer.isRefundable ? AppTheme.successGreen : AppTheme.textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              offer.isRefundable ? 'Refundable ticket with standard carrier fees' : 'Non-refundable standard promotional fare',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Trust Badge for Meta-Search Direct Booking
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'حجز مباشر من شركة الطيران • بدون أي عمولة أو رسوم إضافية (0% Extra Fees)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Direct Official Airline Redirect CTA Button
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.open_in_new, fontWeight: FontWeight.bold),
                  label: Text(
                    'احجز من الموقع الرسمي (${CurrencyFormatter.format(offer.price.totalAmount, currency: offer.price.currency)})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
}
