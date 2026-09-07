import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/print_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../models/booking.dart';
import '../../models/booking_status.dart';
import '../widgets/action_button_bar.dart';
import '../widgets/flight_info_card.dart';
import '../widgets/hotel_info_card.dart';
import '../widgets/passenger_info_card.dart';
import '../widgets/price_summary_card.dart';
import '../widgets/qr_code_view.dart';
import 'booking_document_screen.dart';
import 'pdf_preview_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Booking booking;
  final PdfService pdfService;
  final PrintService printService;
  final ShareService shareService;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
    required this.pdfService,
    required this.printService,
    required this.shareService,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
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

  void _navigateToDocument() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingDocumentScreen(
          booking: widget.booking,
          pdfService: widget.pdfService,
          printService: widget.printService,
          shareService: widget.shareService,
        ),
      ),
    );
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
          content: Text('We couldn\'t initiate printing. Please try again.'),
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
      );

      if (!mounted) return;
      if (result.isSuccess && result.savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document ready: ${result.savedPath}'),
            backgroundColor: AppTheme.accentBlue,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We couldn\'t share the document. Please try again.'),
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
        title: Text('Booking ${booking.bookingReference}'),
        actions: [
          IconButton(
            tooltip: 'View Document Voucher',
            icon: const Icon(Icons.receipt_outlined),
            onPressed: _navigateToDocument,
          ),
          IconButton(
            tooltip: 'Preview PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _navigateToPreview,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          if (isWide) {
            return ResponsiveContainer(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Details & Itinerary
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTopHeaderCard(booking),
                          const SizedBox(height: 12),
                          if (booking.flightDetails != null) ...[
                            if (booking.flightDetails!.passengers.isNotEmpty)
                              PassengerInfoCard(
                                passengers: booking.flightDetails!.passengers,
                                ticketNumbers: booking.flightDetails!.ticketNumbers,
                              ),
                            FlightInfoCard(details: booking.flightDetails!),
                          ],
                          if (booking.hotelDetails != null)
                            HotelInfoCard(details: booking.hotelDetails!),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right Column: Price Summary & Actions
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PriceSummaryCard(price: booking.price),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: AppTheme.cardBorder),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  QrCodeView(
                                    data: booking.bookingReference,
                                    subtitle: 'Scan for booking verification identifier',
                                  ),
                                  const SizedBox(height: 16),
                                  ActionButtonBar(
                                    onViewPdf: _navigateToPreview,
                                    onSavePdf: _navigateToDocument,
                                    onPrint: _handlePrint,
                                    onShare: _handleShare,
                                    isLoading: _isLoading,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Mobile single-column layout
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopHeaderCard(booking),
                    const SizedBox(height: 12),
                    if (booking.flightDetails != null) ...[
                      if (booking.flightDetails!.passengers.isNotEmpty)
                        PassengerInfoCard(
                          passengers: booking.flightDetails!.passengers,
                          ticketNumbers: booking.flightDetails!.ticketNumbers,
                        ),
                      FlightInfoCard(details: booking.flightDetails!),
                    ],
                    if (booking.hotelDetails != null)
                      HotelInfoCard(details: booking.hotelDetails!),
                    PriceSummaryCard(price: booking.price),
                    const SizedBox(height: 8),
                    Center(
                      child: QrCodeView(
                        data: booking.bookingReference,
                        subtitle: 'Scan for booking verification identifier',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ActionButtonBar(
                      onViewPdf: _navigateToPreview,
                      onSavePdf: _navigateToDocument,
                      onPrint: _handlePrint,
                      onShare: _handleShare,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopHeaderCard(Booking booking) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.summaryTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created: ${DateFormatter.formatDateTime(booking.createdAt)}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  Text(
                    'Provider: ${booking.provider}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(booking.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case BookingStatus.confirmed:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;
      case BookingStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        break;
      case BookingStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
      case BookingStatus.failed:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF4B5563);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
