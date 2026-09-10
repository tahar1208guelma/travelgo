import 'dart:typed_data';
import 'package:barcode/barcode.dart' as bc;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../features/bookings/models/booking.dart';
import '../../features/bookings/models/booking_status.dart';
import '../../features/bookings/models/booking_type.dart';
import '../../features/bookings/models/flight_booking_details.dart';
import '../../features/bookings/models/hotel_booking_details.dart';
import '../../features/bookings/models/passenger.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class PdfService {
  // Brand Colors - Luxury Executive Palette
  static const PdfColor primaryNavy = PdfColor.fromInt(0xFF0F172A);
  static const PdfColor secondaryNavy = PdfColor.fromInt(0xFF1E293B);
  static const PdfColor accentBlue = PdfColor.fromInt(0xFF2563EB);
  static const PdfColor electricCyan = PdfColor.fromInt(0xFF0284C7);
  static const PdfColor lightCyanBg = PdfColor.fromInt(0xFFF0F9FF);
  static const PdfColor slateBg = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor cardBorder = PdfColor.fromInt(0xFFE2E8F0);
  static const PdfColor borderDark = PdfColor.fromInt(0xFFCBD5E1);
  static const PdfColor textDark = PdfColor.fromInt(0xFF0F172A);
  static const PdfColor textMuted = PdfColor.fromInt(0xFF64748B);
  static const PdfColor successGreen = PdfColor.fromInt(0xFF059669);
  static const PdfColor successBg = PdfColor.fromInt(0xFFECFDF5);
  static const PdfColor warningAmber = PdfColor.fromInt(0xFFD97706);
  static const PdfColor warningBg = PdfColor.fromInt(0xFFFFFBEB);
  static const PdfColor errorRed = PdfColor.fromInt(0xFFDC2626);
  static const PdfColor errorBg = PdfColor.fromInt(0xFFFEF2F2);
  static const PdfColor goldAccent = PdfColor.fromInt(0xFFB45309);

  /// Generates the appropriate PDF document based on booking type
  Future<Uint8List> generateBookingPdf(
    Booking booking, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    switch (booking.bookingType) {
      case BookingType.flight:
        return generateFlightBookingPdf(booking, format: format);
      case BookingType.hotel:
        return generateHotelBookingPdf(booking, format: format);
      case BookingType.flightAndHotel:
        return generateCombinedBookingPdf(booking, format: format);
    }
  }

  /// Generates Flight Booking Confirmation PDF
  Future<Uint8List> generateFlightBookingPdf(
    Booking booking, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document(
      title: 'TRAVELGO - Flight Confirmation ${booking.bookingReference}',
      author: 'TRAVELGO Booking System',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        header: (context) => _buildPdfHeader(context, booking, 'ELECTRONIC FLIGHT TICKET & ITINERARY'),
        footer: (context) => _buildPdfFooter(context, booking),
        build: (context) => [
          if (booking.isDemo) _buildDemoNotice(),
          pw.SizedBox(height: 10),
          _buildCustomerSummary(booking),
          pw.SizedBox(height: 14),
          if (booking.flightDetails != null) ...[
            _buildPassengerSection(
              booking.flightDetails!.passengers,
              booking.flightDetails!.ticketNumbers,
            ),
            pw.SizedBox(height: 14),
            _buildFlightItinerarySection(
              booking.flightDetails!.segments,
              booking.flightDetails!.airlineBookingReference,
            ),
            pw.SizedBox(height: 14),
          ],
          _buildPriceSection(booking),
          pw.SizedBox(height: 14),
          _buildVerificationAndBarcodeSection(booking),
          pw.SizedBox(height: 14),
          _buildImportantInformation(booking),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generates Hotel Voucher PDF
  Future<Uint8List> generateHotelBookingPdf(
    Booking booking, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document(
      title: 'TRAVELGO - Hotel Voucher ${booking.bookingReference}',
      author: 'TRAVELGO Booking System',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        header: (context) => _buildPdfHeader(context, booking, 'OFFICIAL HOTEL RESERVATION VOUCHER'),
        footer: (context) => _buildPdfFooter(context, booking),
        build: (context) => [
          if (booking.isDemo) _buildDemoNotice(),
          pw.SizedBox(height: 10),
          _buildCustomerSummary(booking),
          pw.SizedBox(height: 14),
          if (booking.hotelDetails != null) ...[
            _buildHotelVoucherSection(booking.hotelDetails!),
            pw.SizedBox(height: 14),
          ],
          _buildPriceSection(booking),
          pw.SizedBox(height: 14),
          _buildVerificationAndBarcodeSection(booking),
          pw.SizedBox(height: 14),
          _buildImportantInformation(booking),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generates Combined Flight + Hotel Booking PDF
  Future<Uint8List> generateCombinedBookingPdf(
    Booking booking, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document(
      title: 'TRAVELGO - Package Confirmation ${booking.bookingReference}',
      author: 'TRAVELGO Booking System',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        header: (context) => _buildPdfHeader(context, booking, 'COMBINED FLIGHT & HOTEL PACKAGE VOUCHER'),
        footer: (context) => _buildPdfFooter(context, booking),
        build: (context) => [
          if (booking.isDemo) _buildDemoNotice(),
          pw.SizedBox(height: 10),
          _buildCustomerSummary(booking),
          pw.SizedBox(height: 14),
          if (booking.flightDetails != null) ...[
            _buildPassengerSection(
              booking.flightDetails!.passengers,
              booking.flightDetails!.ticketNumbers,
            ),
            pw.SizedBox(height: 14),
            _buildFlightItinerarySection(
              booking.flightDetails!.segments,
              booking.flightDetails!.airlineBookingReference,
            ),
            pw.SizedBox(height: 14),
          ],
          if (booking.hotelDetails != null) ...[
            _buildHotelVoucherSection(booking.hotelDetails!),
            pw.SizedBox(height: 14),
          ],
          _buildPriceSection(booking),
          pw.SizedBox(height: 14),
          _buildVerificationAndBarcodeSection(booking),
          pw.SizedBox(height: 14),
          _buildImportantInformation(booking),
        ],
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // LUXURY PDF WIDGET BUILDERS
  // ==========================================

  /// Header with Brand Emblem, Document Classification, and Status Chip
  pw.Widget _buildPdfHeader(pw.Context context, Booking booking, String documentTitle) {
    if (context.pageNumber > 1) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        padding: const pw.EdgeInsets.only(bottom: 4),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: primaryNavy, width: 1.0)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'TRAVELGO • $documentTitle',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryNavy),
            ),
            pw.Text(
              'Ref: ${booking.bookingReference}',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: accentBlue),
            ),
          ],
        ),
      );
    }

    PdfColor statusBg;
    PdfColor statusFg;
    switch (booking.status) {
      case BookingStatus.confirmed:
        statusBg = successGreen;
        statusFg = PdfColors.white;
        break;
      case BookingStatus.pending:
        statusBg = warningAmber;
        statusFg = PdfColors.white;
        break;
      case BookingStatus.cancelled:
        statusBg = errorRed;
        statusFg = PdfColors.white;
        break;
      case BookingStatus.failed:
        statusBg = textMuted;
        statusFg = PdfColors.white;
        break;
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: primaryNavy, width: 2.0),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Brand & Title
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 32,
                    height: 32,
                    decoration: pw.BoxDecoration(
                      color: primaryNavy,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'TG',
                      style: pw.TextStyle(
                        color: electricCyan,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TRAVELGO',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryNavy,
                          letterSpacing: 2.0,
                        ),
                      ),
                      pw.Text(
                        'Global Travel & Hospitality Network',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: lightCyanBg,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  documentTitle,
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: accentBlue,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),

          // Booking Reference & Status Badge
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'BOOKING REFERENCE',
                style: const pw.TextStyle(
                  fontSize: 7.5,
                  color: textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                booking.bookingReference,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryNavy,
                  letterSpacing: 1.0,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: statusBg,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  booking.status.displayName.toUpperCase(),
                  style: pw.TextStyle(
                    color: statusFg,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Subtle Demo / Test Booking Watermark Card
  pw.Widget _buildDemoNotice() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: warningBg,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFFDE68A), width: 0.8),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: pw.BoxDecoration(
              color: warningAmber,
              borderRadius: pw.BorderRadius.circular(2),
            ),
            child: pw.Text(
              'DEMO TEST MODE',
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              'System verification document. Issued by TRAVELGO sandbox environment.',
              style: const pw.TextStyle(
                fontSize: 7.5,
                color: warningAmber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Customer & Issue Details Bar
  pw.Widget _buildCustomerSummary(Booking booking) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: slateBg,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: cardBorder, width: 0.8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('LEAD PASSENGER / CUSTOMER', style: const pw.TextStyle(fontSize: 7, color: textMuted, letterSpacing: 0.5)),
              pw.SizedBox(height: 2),
              pw.Text(
                booking.customerName,
                style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: primaryNavy),
              ),
              if (booking.customerEmail.isNotEmpty)
                pw.Text(booking.customerEmail, style: const pw.TextStyle(fontSize: 8, color: textMuted)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('BOOKING ISSUE DATE', style: const pw.TextStyle(fontSize: 7, color: textMuted, letterSpacing: 0.5)),
              pw.SizedBox(height: 2),
              pw.Text(
                DateFormatter.formatDateFull(booking.createdAt),
                style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: primaryNavy),
              ),
              pw.Text(
                DateFormatter.formatTime(booking.createdAt),
                style: const pw.TextStyle(fontSize: 8, color: textMuted),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('SERVICE FULFILLMENT PROVIDER', style: const pw.TextStyle(fontSize: 7, color: textMuted, letterSpacing: 0.5)),
              pw.SizedBox(height: 2),
              pw.Text(
                booking.provider,
                style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: primaryNavy),
              ),
              if (booking.providerBookingReference != null)
                pw.Text(
                  'Partner Ref: ${booking.providerBookingReference}',
                  style: const pw.TextStyle(fontSize: 7.5, color: textMuted),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Passenger Information Table with E-Ticket numbers
  pw.Widget _buildPassengerSection(List<Passenger> passengers, Map<String, String>? ticketNumbers) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('PASSENGER MANIFEST & TICKET NUMBERS'),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: cardBorder, width: 0.7),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: primaryNavy),
              children: [
                _buildTableCell('Passenger Name', isHeader: true, headerColor: PdfColors.white),
                _buildTableCell('Category', isHeader: true, headerColor: PdfColors.white),
                _buildTableCell('Seat Assignment', isHeader: true, headerColor: PdfColors.white),
                _buildTableCell('Electronic Ticket # (13-Digit)', isHeader: true, headerColor: PdfColors.white),
              ],
            ),
            ...passengers.map((p) {
              final eTicket = ticketNumbers?[p.id] ?? 'Issued at check-in';
              return pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.white),
                children: [
                  _buildTableCell(p.fullName, isBold: true),
                  _buildTableCell(p.passengerType.displayName),
                  _buildTableCell(p.seatNumber != null ? 'Seat ${p.seatNumber}' : 'Auto-allocated'),
                  _buildTableCell(eTicket, isMonospace: true),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  /// Airline Itinerary Section with Route Flow Timeline
  pw.Widget _buildFlightItinerarySection(List<FlightSegment> segments, String? pnr) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('FLIGHT ITINERARY & ROUTE SCHEDULE'),
            if (pnr != null)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: lightCyanBg,
                  borderRadius: pw.BorderRadius.circular(4),
                  border: pw.Border.all(color: electricCyan, width: 0.6),
                ),
                child: pw.Text(
                  'AIRLINE PNR: $pnr',
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: accentBlue,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
          ],
        ),
        pw.SizedBox(height: 6),
        ...segments.map((segment) => _buildFlightSegmentCard(segment)),
      ],
    );
  }

  /// Boarding Pass Style Card for Each Flight Segment
  pw.Widget _buildFlightSegmentCard(FlightSegment segment) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: cardBorder, width: 1.0),
      ),
      child: pw.Column(
        children: [
          // Segment Top Banner
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const pw.BoxDecoration(
              color: slateBg,
              border: pw.Border(bottom: pw.BorderSide(color: cardBorder, width: 0.8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      segment.airline,
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryNavy),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: pw.BoxDecoration(
                        color: accentBlue,
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                      child: pw.Text(
                        segment.flightNumber,
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                      ),
                    ),
                  ],
                ),
                pw.Row(
                  children: [
                    if (segment.aircraftType != null) ...[
                      pw.Text(
                        segment.aircraftType!,
                        style: const pw.TextStyle(fontSize: 7.5, color: textMuted),
                      ),
                      pw.SizedBox(width: 8),
                    ],
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: pw.BoxDecoration(
                        color: lightCyanBg,
                        borderRadius: pw.BorderRadius.circular(3),
                        border: pw.Border.all(color: electricCyan, width: 0.5),
                      ),
                      child: pw.Text(
                        '${segment.cabinClass} Class',
                        style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: accentBlue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Flight Route Timeline Visual
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Departure Station
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        segment.departureAirportCode,
                        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: primaryNavy),
                      ),
                      pw.Text(
                        segment.departureCity ?? segment.departureAirport,
                        style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: secondaryNavy),
                      ),
                      pw.Text(
                        segment.departureAirport,
                        style: const pw.TextStyle(fontSize: 7.5, color: textMuted),
                        maxLines: 1,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        DateFormatter.formatDateFull(segment.departureDateTime),
                        style: const pw.TextStyle(fontSize: 8, color: textDark),
                      ),
                      pw.Text(
                        'Departure: ${DateFormatter.formatTime(segment.departureDateTime)}',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentBlue),
                      ),
                      if (segment.departureTerminal != null)
                        pw.Container(
                          margin: const pw.EdgeInsets.only(top: 2),
                          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: pw.BoxDecoration(color: slateBg, borderRadius: pw.BorderRadius.circular(3)),
                          child: pw.Text('Terminal ${segment.departureTerminal}', style: const pw.TextStyle(fontSize: 7, color: textMuted)),
                        ),
                    ],
                  ),
                ),

                // Middle Flight Track Graphic
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    children: [
                      pw.Text(
                        DateFormatter.formatDuration(segment.duration),
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textMuted),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Container(width: 4, height: 4, decoration: const pw.BoxDecoration(color: accentBlue, shape: pw.BoxShape.circle)),
                          pw.Expanded(
                            child: pw.Container(height: 1.5, color: accentBlue),
                          ),
                          pw.Text(' > ', style: pw.TextStyle(fontSize: 8, color: accentBlue, fontWeight: pw.FontWeight.bold)),
                          pw.Expanded(
                            child: pw.Container(height: 1.5, color: accentBlue),
                          ),
                          pw.Container(width: 4, height: 4, decoration: const pw.BoxDecoration(color: accentBlue, shape: pw.BoxShape.circle)),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: pw.BoxDecoration(
                          color: slateBg,
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                        child: pw.Text(
                          'NON-STOP FLIGHT',
                          style: const pw.TextStyle(fontSize: 6.5, color: textMuted, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrival Station
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        segment.arrivalAirportCode,
                        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: primaryNavy),
                      ),
                      pw.Text(
                        segment.arrivalCity ?? segment.arrivalAirport,
                        style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: secondaryNavy),
                      ),
                      pw.Text(
                        segment.arrivalAirport,
                        style: const pw.TextStyle(fontSize: 7.5, color: textMuted),
                        maxLines: 1,
                        textAlign: pw.TextAlign.right,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        DateFormatter.formatDateFull(segment.arrivalDateTime),
                        style: const pw.TextStyle(fontSize: 8, color: textDark),
                      ),
                      pw.Text(
                        'Arrival: ${DateFormatter.formatTime(segment.arrivalDateTime)}',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentBlue),
                      ),
                      if (segment.arrivalTerminal != null)
                        pw.Container(
                          margin: const pw.EdgeInsets.only(top: 2),
                          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: pw.BoxDecoration(color: slateBg, borderRadius: pw.BorderRadius.circular(3)),
                          child: pw.Text('Terminal ${segment.arrivalTerminal}', style: const pw.TextStyle(fontSize: 7, color: textMuted)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Baggage Allowance Footer
          if (segment.baggageAllowance != null)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: const pw.BoxDecoration(
                color: slateBg,
                border: pw.Border(top: pw.BorderSide(color: cardBorder, width: 0.8)),
              ),
              child: pw.Row(
                children: [
                  pw.Text('Included Baggage Allowance: ', style: const pw.TextStyle(fontSize: 7.5, color: textMuted)),
                  pw.Text(
                    segment.baggageAllowance!,
                    style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryNavy),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Luxury Hotel Voucher Presentation Section
  pw.Widget _buildHotelVoucherSection(HotelBookingDetails hotel) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('ACCOMMODATION & HOTEL VOUCHER'),
            if (hotel.hotelConfirmationNumber != null)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: lightCyanBg,
                  borderRadius: pw.BorderRadius.circular(4),
                  border: pw.Border.all(color: electricCyan, width: 0.6),
                ),
                child: pw.Text(
                  'CONFIRMATION #: ${hotel.hotelConfirmationNumber}',
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: accentBlue,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: cardBorder, width: 1.0),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Hotel Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: const pw.BoxDecoration(
                  color: slateBg,
                  border: pw.Border(bottom: pw.BorderSide(color: cardBorder, width: 0.8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            hotel.hotelName,
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryNavy),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            '${hotel.hotelAddress}, ${hotel.hotelCity ?? ''} ${hotel.hotelCountry ?? ''}',
                            style: const pw.TextStyle(fontSize: 8.5, color: textMuted),
                          ),
                          if (hotel.hotelPhone != null || hotel.hotelEmail != null)
                            pw.Text(
                              'Direct Contact: ${hotel.hotelPhone ?? ''} ${hotel.hotelEmail != null ? '| ${hotel.hotelEmail}' : ''}',
                              style: const pw.TextStyle(fontSize: 7.5, color: textMuted),
                            ),
                        ],
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: goldAccent,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'PREMIUM PROPERTY',
                        style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Check-In / Check-Out Timeline Ribbon
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('CHECK-IN DATE', style: const pw.TextStyle(fontSize: 7, color: textMuted, letterSpacing: 0.5)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          DateFormatter.formatDateFull(hotel.checkInDate),
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryNavy),
                        ),
                        pw.Text('Standard Check-in from 15:00', style: const pw.TextStyle(fontSize: 7.5, color: textMuted)),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: lightCyanBg,
                        borderRadius: pw.BorderRadius.circular(12),
                        border: pw.Border.all(color: electricCyan, width: 0.6),
                      ),
                      child: pw.Text(
                        '${hotel.numberOfNights} Nights • ${hotel.numberOfGuests} Guests',
                        style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: accentBlue),
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('CHECK-OUT DATE', style: const pw.TextStyle(fontSize: 7, color: textMuted, letterSpacing: 0.5)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          DateFormatter.formatDateFull(hotel.checkOutDate),
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryNavy),
                        ),
                        pw.Text('Check-out until 11:00 AM', style: const pw.TextStyle(fontSize: 7.5, color: textMuted)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12),
                child: pw.Divider(color: cardBorder, thickness: 0.7),
              ),

              // Room & Guest Specifications
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('PRIMARY GUEST', style: const pw.TextStyle(fontSize: 7, color: textMuted)),
                            pw.Text(hotel.guestName, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: primaryNavy)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('MEAL PLAN INCLUDED', style: const pw.TextStyle(fontSize: 7, color: textMuted)),
                            pw.Text(hotel.mealPlan, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: accentBlue)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('RESERVED ROOMS', style: const pw.TextStyle(fontSize: 7, color: textMuted)),
                            pw.Text('${hotel.rooms.length} Room(s)', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: primaryNavy)),
                          ],
                        ),
                      ],
                    ),
                    if (hotel.rooms.isNotEmpty) ...[
                      pw.SizedBox(height: 8),
                      pw.Text('Room Allocation Details:', style: const pw.TextStyle(fontSize: 7.5, color: textMuted)),
                      ...hotel.rooms.map(
                        (r) => pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 2),
                          child: pw.Text(
                            '• ${r.roomType} (${r.numberOfGuests} Guests${r.bedType != null ? ' | Bed Type: ${r.bedType}' : ''})',
                            style: pw.TextStyle(fontSize: 8, color: primaryNavy, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                    if (hotel.specialRequests != null) ...[
                      pw.SizedBox(height: 6),
                      pw.Text('Special Guest Requests: ${hotel.specialRequests}', style: const pw.TextStyle(fontSize: 7.5, color: textMuted, fontStyle: pw.FontStyle.italic)),
                    ],
                  ],
                ),
              ),

              // Cancellation Policy Protection Strip
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(
                  color: successBg,
                  border: pw.Border(top: pw.BorderSide(color: cardBorder, width: 0.8)),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Cancellation Terms: ', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: successGreen)),
                    pw.Expanded(
                      child: pw.Text(
                        hotel.cancellationPolicy,
                        style: const pw.TextStyle(fontSize: 7.5, color: textDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Transparent Itemized Price Breakdown Highlighting 0.75% TRAVELGO Fee
  pw.Widget _buildPriceSection(Booking booking) {
    final price = booking.price;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('PAYMENT & FINANCIAL BREAKDOWN'),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: cardBorder, width: 1.0),
          ),
          child: pw.Column(
            children: [
              _buildPriceRow('Base Service Fare / Rate', CurrencyFormatter.format(price.basePrice, currency: price.currency)),
              if (price.hasTaxesAndFees) ...[
                pw.SizedBox(height: 3),
                _buildPriceRow('Government Taxes & Airport Surcharges', CurrencyFormatter.format(price.taxesAndFees!, currency: price.currency)),
              ],
              if (price.hasServiceFee) ...[
                pw.SizedBox(height: 3),
                _buildPriceRow(
                  'TRAVELGO Platform Service Fee (0.75%)',
                  CurrencyFormatter.format(price.serviceFee!, currency: price.currency),
                  isHighlighted: true,
                ),
              ],
              if (price.hasDiscount) ...[
                pw.SizedBox(height: 3),
                _buildPriceRow(
                  'Promotional Discount / Voucher Applied',
                  '-${CurrencyFormatter.format(price.discount!, currency: price.currency)}',
                  textColor: successGreen,
                ),
              ],
              pw.SizedBox(height: 6),
              pw.Divider(color: cardBorder, thickness: 1),
              pw.SizedBox(height: 4),

                // QR Verification Code Mock for Hotel Voucher
                pw.Row(
                  children: [
                    pw.Container(
                      width: 50,
                      height: 50,
                      child: pw.BarcodeWidget(
                        color: pw.PdfColor.fromHex('#0F172A'),
                        barcode: pw.Barcode.qrCode(),
                        data: 'VOUCHER-${hotel.hotelConfirmationNumber ?? "PENDING"}-${hotel.guestName.replaceAll(" ", "")}',
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Digital Verification Code', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryNavy)),
                          pw.Text('Scan at reception for express check-in and room sequencing validation.', style: const pw.TextStyle(fontSize: 7, color: textMuted)),
                        ],
                      )
                    )
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Divider(color: AppTheme.cardBorder, thickness: 0.5),
                pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TOTAL AMOUNT PAID',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryNavy, letterSpacing: 0.5),
                      ),
                      pw.Text(
                        'Electronic Payment Confirmed • All Taxes Included',
                        style: const pw.TextStyle(fontSize: 7, color: textMuted),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: primaryNavy,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      CurrencyFormatter.format(price.totalAmount, currency: price.currency),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: electricCyan,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Dual Verification Matrix: Barcode (Code128) + QR Code with Digital Stamp
  pw.Widget _buildVerificationAndBarcodeSection(Booking booking) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: slateBg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: cardBorder, width: 0.8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Left: High-Density Barcode
          pw.Expanded(
            flex: 6,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'TRAVEL IDENTIFICATION BARCODE (IATA STANDARD)',
                  style: const pw.TextStyle(fontSize: 6.5, color: textMuted, letterSpacing: 0.5),
                ),
                pw.SizedBox(height: 4),
                pw.Container(
                  height: 32,
                  child: pw.BarcodeWidget(
                    barcode: bc.Barcode.code128(),
                    data: booking.bookingReference,
                    drawText: true,
                    textStyle: const pw.TextStyle(fontSize: 6.5, color: primaryNavy),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Digital Seal: SHA-256 Verified by TRAVELGO Secure Authority',
                  style: const pw.TextStyle(fontSize: 6, color: textMuted),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          // Right: QR Code for Direct Scan
          pw.Column(
            children: [
              pw.SizedBox(
                width: 48,
                height: 48,
                child: pw.BarcodeWidget(
                  barcode: bc.Barcode.qrCode(),
                  data: 'https://travelgo.example/verify/${booking.bookingReference}',
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text('Scan to Verify', style: const pw.TextStyle(fontSize: 6.5, color: textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  /// Important Travel Notices Box
  pw.Widget _buildImportantInformation(Booking booking) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: slateBg,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: cardBorder, width: 0.7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ESSENTIAL TRAVEL INFORMATION & REGULATIONS',
            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryNavy, letterSpacing: 0.5),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            '• Passport Validity: Ensure passport is valid for at least 6 months beyond travel dates for international journeys.',
            style: const pw.TextStyle(fontSize: 7, color: textMuted),
          ),
          pw.Text(
            '• Airport Check-in: Airport check-in counters close 60 minutes prior to scheduled departure. Gate closes 20 minutes prior.',
            style: const pw.TextStyle(fontSize: 7, color: textMuted),
          ),
          pw.Text(
            '• Hotel Check-in: A government-issued photo ID and credit card guarantee are required upon arrival at property.',
            style: const pw.TextStyle(fontSize: 7, color: textMuted),
          ),
        ],
      ),
    );
  }

  /// Professional Footer with 24/7 Support and Page Numbering
  pw.Widget _buildPdfFooter(pw.Context context, Booking booking) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: cardBorder, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'TRAVELGO 24/7 Global Concierge: support@travelgo.com | +1-800-TRAVELGO',
                style: const pw.TextStyle(fontSize: 6.5, color: textMuted),
              ),
              pw.Text(
                'Verification Ref: ${booking.bookingReference} • Issued by TRAVELGO Electronic Dispatcher',
                style: const pw.TextStyle(fontSize: 6, color: textMuted),
              ),
            ],
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: primaryNavy),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UTILITY HELPER WIDGETS
  // ==========================================

  pw.Widget _buildSectionHeader(String title) {
    return pw.Row(
      children: [
        pw.Container(width: 3, height: 10, color: accentBlue),
        pw.SizedBox(width: 4),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: primaryNavy,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPriceRow(
    String label,
    String value, {
    bool isHighlighted = false,
    PdfColor? textColor,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: isHighlighted ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHighlighted ? accentBlue : textMuted,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: isHighlighted ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: textColor ?? (isHighlighted ? accentBlue : primaryNavy),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    bool isMonospace = false,
    PdfColor? headerColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4.5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 7.5 : 8,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? (headerColor ?? PdfColors.white) : primaryNavy,
        ),
      ),
    );
  }

  /// Generates Official Merchant Payout & Withdrawal Receipt PDF
  Future<Uint8List> generateWithdrawalReceiptPdf({
    required String withdrawalId,
    required double amount,
    required String currency,
    required String status,
    required String bankName,
    required String accountHolderName,
    required String maskedIban,
    required String swiftBic,
    required String? bankTransferReference,
    required DateTime requestedAt,
    DateTime? processedAt,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document(
      title: 'TRAVELGO - Merchant Payout Receipt $withdrawalId',
      author: 'TravelGo Financial Settlement Engine',
    );

    final receiptNo = 'TG-WITHDRAW-${withdrawalId.length >= 8 ? withdrawalId.substring(0, 8).toUpperCase() : withdrawalId.toUpperCase()}';
    final qrPayload = 'https://travelgo.com/verify/receipt/$withdrawalId?amt=$amount&cur=$currency&ref=${bankTransferReference ?? "PENDING"}';

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: primaryNavy,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TRAVELGO',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Platform Owner Commission Payout Receipt',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey300),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: status.toLowerCase() == 'completed' ? successGreen : warningAmber,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        status.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Summary Box
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: slateBg,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: cardBorder),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('RECEIPT NUMBER', style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                        pw.SizedBox(height: 2),
                        pw.Text(receiptNo, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryNavy)),
                        pw.SizedBox(height: 10),
                        pw.Text('DATE REQUESTED', style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                        pw.SizedBox(height: 2),
                        pw.Text(DateFormatter.formatDateFull(requestedAt), style: const pw.TextStyle(fontSize: 10, color: primaryNavy)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('NET DISBURSED AMOUNT', style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '$currency ${amount.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: accentBlue),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text('TRANSFER REFERENCE', style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                        pw.SizedBox(height: 2),
                        pw.Text(bankTransferReference ?? 'PENDING PROCESSING', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: successGreen)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Beneficiary Bank Details
              pw.Text(
                'BENEFICIARY BANK DETAILS',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primaryNavy),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: cardBorder),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Account Holder:', style: const pw.TextStyle(fontSize: 9, color: textMuted)),
                        pw.Text(accountHolderName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Bank Name:', style: const pw.TextStyle(fontSize: 9, color: textMuted)),
                        pw.Text(bankName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('IBAN / Account:', style: const pw.TextStyle(fontSize: 9, color: textMuted)),
                        pw.Text(maskedIban, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentBlue)),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('SWIFT / BIC:', style: const pw.TextStyle(fontSize: 9, color: textMuted)),
                        pw.Text(swiftBic, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Financial Audit Verification & QR Code
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'AUDIT VERIFICATION & INTEGRITY',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryNavy),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'This document is an immutable cryptographic receipt generated from the TravelGo Double-Entry Financial Ledger. It certifies payout disbursement of accumulated 0.75% platform booking commissions.',
                          style: const pw.TextStyle(fontSize: 8, color: textMuted),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Platform Fee: 0.00% (No charge on platform owner payouts)\nStatus: ${status.toUpperCase()}',
                          style: const pw.TextStyle(fontSize: 8, color: primaryNavy),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Container(
                    width: 75,
                    height: 75,
                    child: pw.BarcodeWidget(
                      barcode: bc.Barcode.qrCode(),
                      data: qrPayload,
                      drawText: false,
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: cardBorder),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TravelGo Global Financial Settlement System • Confidential', style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                  pw.Text('Generated: ${DateFormatter.formatDateFull(DateTime.now())}', style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
