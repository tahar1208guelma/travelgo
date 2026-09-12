import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/passenger.dart';

class PassengerInfoCard extends StatelessWidget {
  final List<Passenger> passengers;
  final Map<String, String>? ticketNumbers;

  const PassengerInfoCard({
    super.key,
    required this.passengers,
    this.ticketNumbers,
  });

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
            const Row(
              children: [
                Icon(Icons.person_outline, color: AppTheme.accentBlue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Passenger Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: AppTheme.borderSubtle),
            ...passengers.map((passenger) {
              final ticket = ticketNumbers?[passenger.id];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          passenger.fullName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${passenger.passengerType.displayName}${passenger.nationality != null ? ' • ${passenger.nationality}' : ''}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (passenger.seatNumber != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.borderSubtle),
                            ),
                            child: Text(
                              'Seat ${passenger.seatNumber}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentBlue,
                              ),
                            ),
                          ),
                        if (ticket != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'E-Ticket: $ticket',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
