import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../models/flight_booking_details.dart';

class FlightInfoCard extends StatelessWidget {
  final FlightBookingDetails details;

  const FlightInfoCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.flight, color: AppTheme.accentBlue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Flight Itinerary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                if (details.airlineBookingReference != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PNR: ${details.airlineBookingReference}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentBlue,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 20, color: AppTheme.borderSubtle),
            ...details.segments.map((segment) => _buildSegmentItem(segment)),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentItem(FlightSegment segment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${segment.airline} • ${segment.flightNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Text(
                  '${segment.cabinClass} Class',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Departure
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment.departureAirportCode,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    Text(
                      segment.departureCity ?? segment.departureAirport,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormatter.formatDate(segment.departureDateTime)}\n${DateFormatter.formatTime(segment.departureDateTime)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                    ),
                    if (segment.departureTerminal != null)
                      Text(
                        'Term: ${segment.departureTerminal}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                  ],
                ),
              ),
              // Arrow and duration
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text(
                      DateFormatter.formatDuration(segment.duration),
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_forward, color: AppTheme.accentBlue, size: 18),
                    const Text(
                      'Direct',
                      style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              // Arrival
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      segment.arrivalAirportCode,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    Text(
                      segment.arrivalCity ?? segment.arrivalAirport,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormatter.formatDate(segment.arrivalDateTime)}\n${DateFormatter.formatTime(segment.arrivalDateTime)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                      textAlign: TextAlign.end,
                    ),
                    if (segment.arrivalTerminal != null)
                      Text(
                        'Term: ${segment.arrivalTerminal}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        textAlign: TextAlign.end,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (segment.baggageAllowance != null) ...[
            const Divider(height: 16, color: AppTheme.borderSubtle),
            Row(
              children: [
                const Icon(Icons.luggage_outlined, size: 16, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Baggage: ${segment.baggageAllowance}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
