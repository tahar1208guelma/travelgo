import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/print_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/file_storage_helper.dart';
import '../../models/booking.dart';
import '../../models/booking_status.dart';
import '../widgets/action_button_bar.dart';
import '../widgets/flight_info_card.dart';
import '../widgets/hotel_info_card.dart';
import '../widgets/passenger_info_card.dart';
import '../widgets/price_summary_card.dart';
import '../widgets/qr_code_view.dart';
import 'pdf_preview_screen.dart';

class BookingDocumentScreen extends StatefulWidget {
  final Booking booking;
  final PdfService pdfService;
  final PrintService printService;
  final ShareService shareService;

  const BookingDocumentScreen({
    super.key,
    required this.booking,
    required this.pdfService,
    required this.printService,
    required this.shareService,
  });

  @override
  State<BookingDocumentScreen> createState() => _BookingDocumentScreenState();
}

class _BookingDocumentScreenState extends State<BookingDocumentScreen> {
  bool _isLoading = false;

  void _navigateToPreview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(
          booking: widget.booking,
          pdfService: widget.pdfService,
          printService: widget.printService,
          shareService: widget.shareService,
        ),
      ),
    );
  }

  Future<void> _handleSavePdf() async {
    setState(() => _isLoading = true);
    try {
      final bytes = await widget.pdfService.generateBookingPdf(
        widget.booking,
        format: PdfPageFormat.a4,
      );

      if (!mounted) return;
      final savedPath = await FileStorageHelper.savePdfWithPicker(
        bytes: bytes,
        suggestedFileName: widget.booking.suggestedPdfFileName,
        context: context,
      );

      if (!mounted) return;
      if (savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document saved to:\n$savedPath'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We couldn\'t save your booking document. Please try again.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePrint() async {
    setState(() => _isLoading = true);
    try {
      final bytes = await widget.pdfService.generateBookingPdf(
        widget.booking,
        format: PdfPageFormat.a4,
      );

      final result = await widget.printService.printDocument(
        pdfBytes: bytes,
        documentName: widget.booking.suggestedPdfFileName,
        format: PdfPageFormat.a4,
      );

      if (!mounted) return;
      if (!result.isSuccess && result.errorMessage != null && !result.errorMessage!.contains('cancelled')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage!),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We couldn\'t start printing. Please try again.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleShare() async {
    setState(() => _isLoading = true);
    try {
      final bytes = await widget.pdfService.generateBookingPdf(
        widget.booking,
        format: PdfPageFormat.a4,
      );

      final result = await widget.shareService.sharePdf(
        pdfBytes: bytes,
        fileName: widget.booking.suggestedPdfFileName,
        subject: 'TRAVELGO Booking Confirmation (${widget.booking.bookingReference})',
      );

      if (!mounted) return;
      if (result.isSuccess && result.savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved temporary document to: ${result.savedPath}'),
            backgroundColor: AppTheme.accentBlue,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We couldn\'t share your document. Please try again.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Document'),
        actions: [
          IconButton(
            tooltip: 'View PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _navigateToPreview,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Demo Banner
                if (booking.isDemo)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.science_outlined, size: 18, color: Color(0xFF92400E)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'DEMO / TEST BOOKING — Not a real airline or hotel reservation.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Digital Document Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.borderSubtle, width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentBlue,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'TG',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'TRAVELGO',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryNavy,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Travel Booking Confirmation',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: booking.status == BookingStatus.confirmed
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                booking.status.displayName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: booking.status == BookingStatus.confirmed
                                      ? const Color(0xFF065F46)
                                      : const Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: AppTheme.borderSubtle),

                        // Booking Reference & Verification QR
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Booking Reference', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                  const SizedBox(height: 2),
                                  SelectableText(
                                    booking.bookingReference,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryNavy,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Customer Name', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.customerName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  Text(booking.customerEmail, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                                  const SizedBox(height: 12),
                                  const Text('Booking Date', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                  Text(
                                    DateFormatter.formatDateFull(booking.createdAt),
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: QrCodeView(
                                  data: booking.bookingReference,
                                  size: 110,
                                  subtitle: 'Scan to verify',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Flight Info
                        if (booking.flightDetails != null) ...[
                          if (booking.flightDetails!.passengers.isNotEmpty)
                            PassengerInfoCard(
                              passengers: booking.flightDetails!.passengers,
                              ticketNumbers: booking.flightDetails!.ticketNumbers,
                            ),
                          FlightInfoCard(details: booking.flightDetails!),
                        ],

                        // Hotel Info
                        if (booking.hotelDetails != null)
                          HotelInfoCard(details: booking.hotelDetails!),

                        // Price Summary
                        PriceSummaryCard(price: booking.price),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                ActionButtonBar(
                  onViewPdf: _navigateToPreview,
                  onSavePdf: _handleSavePdf,
                  onPrint: _handlePrint,
                  onShare: _handleShare,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
