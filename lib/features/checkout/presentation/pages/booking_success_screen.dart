import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/print_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../bookings/models/booking.dart';
import '../../../bookings/presentation/pages/pdf_preview_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final Booking booking;
  final String eTicketOrVoucherNumber;
  final PdfService pdfService;
  final PrintService printService;
  final ShareService shareService;

  const BookingSuccessScreen({
    super.key,
    required this.booking,
    required this.eTicketOrVoucherNumber,
    required this.pdfService,
    required this.printService,
    required this.shareService,
  });

  @override
  Widget build(BuildContext context) {
    final isFlight = booking.flightDetails != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed!'),
        automaticallyImplyLeading: false,
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Celebration Badge Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryNavy, Color(0xFF065F46)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 40),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Reservation Successfully Issued!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Electronic confirmation and e-tickets sent to ${booking.customerEmail}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'TRAVELGO REF: ${booking.bookingReference}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.electricCyan,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Booking Overview Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFlight ? 'Flight Itinerary Overview' : 'Hotel Reservation Overview',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                      ),
                      const Divider(height: 20, color: AppTheme.cardBorder),
                      _buildDetailRow('Lead Passenger / Guest', booking.customerName),
                      if (isFlight && booking.flightDetails!.airlineBookingReference != null)
                        _buildDetailRow('Airline PNR', booking.flightDetails!.airlineBookingReference!),
                      if (!isFlight && booking.hotelDetails?.hotelConfirmationNumber != null)
                        _buildDetailRow('Hotel Confirmation #', booking.hotelDetails!.hotelConfirmationNumber!),
                      _buildDetailRow('E-Ticket / Voucher #', eTicketOrVoucherNumber),
                      _buildDetailRow('Total Paid (0.75% Fee Incl.)', CurrencyFormatter.format(booking.price.totalAmount, currency: booking.price.currency)),
                      _buildDetailRow('Booking Issued On', DateFormatter.formatDateFull(booking.createdAt)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons: Luxury PDF, Print, Share
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PdfPreviewScreen(
                        booking: booking,
                        pdfService: pdfService,
                        printService: printService,
                        shareService: shareService,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('View & Download Luxury PDF Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final bytes = await pdfService.generateBookingPdf(booking);
                        await printService.printPdf(bytes, documentName: 'TRAVELGO-${booking.bookingReference}');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('Print Voucher', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final bytes = await pdfService.generateBookingPdf(booking);
                        await shareService.sharePdf(
                          pdfBytes: bytes,
                          fileName: 'TRAVELGO-${booking.bookingReference}.pdf',
                          subject: 'Booking Confirmation ${booking.bookingReference}',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Return to Home / Explore', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentBlue)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
        ],
      ),
    );
  }
}
