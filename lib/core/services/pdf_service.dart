import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../features/bookings/models/booking_document.dart';
import '../../features/bookings/models/booking_model.dart';
import '../../features/bookings/models/customer_info.dart';
import '../../features/bookings/models/flight_booking_details.dart';
import '../../features/bookings/models/hotel_booking_details.dart';
import '../../features/bookings/models/price_breakdown.dart';

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

class PdfService {
  // Brand Colors for PDF
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF1E88E5); // #1E88E5
  static const PdfColor primaryDarkColor = PdfColor.fromInt(0xFF0D47A1); // #0D47A1
  static const PdfColor primaryLightColor = PdfColor.fromInt(0xFFE3F2FD); // #E3F2FD
  static const PdfColor darkTextColor = PdfColor.fromInt(0xFF1A1A1A);
  static const PdfColor mutedTextColor = PdfColor.fromInt(0xFF666666);
  static const PdfColor lightBgColor = PdfColor.fromInt(0xFFF8F9FA);
  static const PdfColor borderColor = PdfColor.fromInt(0xFFE0E0E0);
  static const PdfColor successColor = PdfColor.fromInt(0xFF2E7D32);
  static const PdfColor warningColor = PdfColor.fromInt(0xFFE65100);
  static const PdfColor demoBadgeColor = PdfColor.fromInt(0xFFD32F2F);

  /// Main dispatcher method for generating booking PDF
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

  /// Generate Flight Booking Confirmation PDF
  Future<Uint8List> generateFlightBookingPdf(
    Booking booking, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document(
      title: 'TRAVELGO Flight Confirmation - ${booking.bookingReference}',
      author: 'TRAVELGO Travel Platform',
      subject: 'Flight Booking Confirmation ${booking.bookingReference}',
      keywords: 'travelgo, flight, booking, ${booking.bookingReference}',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPdfHeader(
          booking: booking,
          title: 'TRAVEL BOOKING CONFIRMATION',
          subtitle: 'Official Flight Reservation Confirmation',
        ),
        footer: (context) => _buildPdfFooter(context, booking.document),
        build: (context) => [
          _buildReferenceAndQrCard(booking),
          pw.SizedBox(height: 16),
          if (booking.document.isDemo) _buildDemoNoticeBanner(),
          if (booking.document.isDemo) pw.SizedBox(height: 16),
          _buildPassengerSection(booking.customer, booking.flightDetails),
          pw.SizedBox(height: 16),
          _buildFlightDetailsSection(booking.flightDetails),
          pw.SizedBox(height: 16),
          _buildPriceBreakdownSection(booking.priceBreakdown),
          pw.SizedBox(height: 16),
          _buildTermsAndSupportSection(booking.document),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generate Hotel Booking Voucher PDF
  Future<Uint8List> generateHotelBookingPdf(
    Booking booking, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document(
      title: 'TRAVELGO Hotel Voucher - ${booking.bookingReference}',
      author: 'TRAVELGO Travel Platform',
      subject: 'Hotel Reservation Voucher ${booking.bookingReference}',
      keywords: 'travelgo, hotel, voucher, ${booking.bookingReference}',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPdfHeader(
          booking: booking,
          title: 'HOTEL VOUCHER',
          subtitle: 'Official Accommodation Reservation Voucher',
        ),
        footer: (context) => _buildPdfFooter(context, booking.document),
        build: (context) => [
          _buildReferenceAndQrCard(booking),
          pw.SizedBox(height: 16),
          if (booking.document.isDemo) _buildDemoNoticeBanner(),
          if (booking.document.isDemo) pw.SizedBox(height: 16),
          _buildGuestSection(booking.customer),
          pw.SizedBox(height: 16),
          _buildHotelDetailsSection(booking.hotelDetails),
          pw.SizedBox(height: 16),
          _buildPriceBreakdownSection(booking.priceBreakdown),
          pw.SizedBox(height: 16),
          _buildTermsAndSupportSection(booking.document),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generate Combined Flight + Hotel Booking PDF
  Future<Uint8List> generateCombinedBookingPdf(
    Booking booking, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document(
      title: 'TRAVELGO Booking Confirmation - ${booking.bookingReference}',
      author: 'TRAVELGO Travel Platform',
      subject: 'Flight & Hotel Booking Confirmation ${booking.bookingReference}',
      keywords: 'travelgo, flight, hotel, package, ${booking.bookingReference}',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPdfHeader(
          booking: booking,
          title: 'TRAVEL CONFIRMATION & VOUCHER',
          subtitle: 'Combined Flight & Hotel Vacation Package',
        ),
        footer: (context) => _buildPdfFooter(context, booking.document),
        build: (context) => [
          _buildReferenceAndQrCard(booking),
          pw.SizedBox(height: 16),
          if (booking.document.isDemo) _buildDemoNoticeBanner(),
          if (booking.document.isDemo) pw.SizedBox(height: 16),
          _buildPassengerSection(booking.customer, booking.flightDetails),
          pw.SizedBox(height: 16),
          _buildFlightDetailsSection(booking.flightDetails),
          pw.SizedBox(height: 16),
          _buildHotelDetailsSection(booking.hotelDetails),
          pw.SizedBox(height: 16),
          _buildPriceBreakdownSection(booking.priceBreakdown),
          pw.SizedBox(height: 16),
          _buildTermsAndSupportSection(booking.document),
        ],
      ),
    );

    return pdf.save();
  }

  // --- PDF Header Component ---
  pw.Widget _buildPdfHeader({
    required Booking booking,
    required String title,
    required String subtitle,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: primaryColor, width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 24,
                    height: 24,
                    decoration: const pw.BoxDecoration(
                      color: primaryColor,
                      shape: pw.BoxShape.circle,
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '✈',
                      style: const pw.TextStyle(color: PdfColors.white, fontSize: 13),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'TRAVELGO',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryDarkColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Your Gateway to the World',
                style: const pw.TextStyle(
                  fontSize: 8.5,
                  color: mutedTextColor,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: darkTextColor,
                  letterSpacing: 0.8,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                subtitle,
                style: const pw.TextStyle(fontSize: 8.5, color: mutedTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Reference & QR Card ---
  pw.Widget _buildReferenceAndQrCard(Booking booking) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final issueDate = dateFormat.format(booking.document.issuedAt);
    final statusColor = booking.status == BookingStatus.confirmed
        ? successColor
        : (booking.status == BookingStatus.pending ? warningColor : demoBadgeColor);

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: lightBgColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: borderColor, width: 1),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      'BOOKING REFERENCE: ',
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        color: mutedTextColor,
                      ),
                    ),
                    pw.Text(
                      booking.bookingReference,
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryDarkColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    _buildBadge('STATUS: ${booking.statusLabel.toUpperCase()}', statusColor),
                    pw.SizedBox(width: 8),
                    _buildBadge('TYPE: ${booking.typeLabel.toUpperCase()}', primaryColor),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Issued On: $issueDate • Provider: ${booking.provider}',
                  style: const pw.TextStyle(fontSize: 8.5, color: mutedTextColor),
                ),
                if (booking.providerBookingReference != null)
                  pw.Text(
                    'Partner Confirmation Code: ${booking.providerBookingReference}',
                    style: const pw.TextStyle(fontSize: 8.5, color: mutedTextColor),
                  ),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          // Safe QR Code for booking verification
          pw.Column(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: booking.document.qrData,
                  width: 58,
                  height: 58,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Scan to Verify',
                style: const pw.TextStyle(fontSize: 6.5, color: mutedTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Demo Notice Banner ---
  pw.Widget _buildDemoNoticeBanner() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFFEBEE),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: demoBadgeColor, width: 0.8),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: const pw.BoxDecoration(
              color: demoBadgeColor,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
            ),
            child: pw.Text(
              'DEMO / TEST BOOKING',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 7.5,
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              'This is a demonstration booking document generated for testing purposes. Not valid for actual boarding or lodging.',
              style: const pw.TextStyle(fontSize: 7.5, color: demoBadgeColor),
            ),
          ),
        ],
      ),
    );
  }

  // --- Passenger Section ---
  pw.Widget _buildPassengerSection(CustomerInfo customer, FlightBookingDetails? flightDetails) {
    final passengers = flightDetails?.passengers.isNotEmpty == true
        ? flightDetails!.passengers
        : (customer.passengers.isNotEmpty
            ? customer.passengers
            : [
                PassengerInfo(
                  fullName: customer.fullName,
                  passengerType: PassengerType.adult,
                )
              ]);

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PASSENGER INFORMATION'),
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              children: [
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1.5),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: lightBgColor),
                      children: [
                        _buildTableCell('Passenger Name', isHeader: true),
                        _buildTableCell('Type', isHeader: true),
                        _buildTableCell('Ticket / e-Ticket #', isHeader: true),
                        _buildTableCell('Seat', isHeader: true),
                      ],
                    ),
                    ...passengers.map((p) {
                      return pw.TableRow(
                        children: [
                          _buildTableCell(p.fullName),
                          _buildTableCell(p.typeLabel),
                          _buildTableCell(p.ticketNumber ?? flightDetails?.ticketNumber ?? 'Confirmed'),
                          _buildTableCell(p.seatNumber ?? 'Assigned at Check-in'),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Primary Contact: ${customer.fullName} • ${customer.email}',
                      style: const pw.TextStyle(fontSize: 8, color: mutedTextColor),
                    ),
                    if (customer.phone.isNotEmpty)
                      pw.Text(
                        'Phone: ${customer.phone}',
                        style: const pw.TextStyle(fontSize: 8, color: mutedTextColor),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Guest Section (Hotel) ---
  pw.Widget _buildGuestSection(CustomerInfo customer) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('GUEST INFORMATION'),
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildLabelValue('Lead Guest Name', customer.fullName),
                    pw.SizedBox(height: 4),
                    _buildLabelValue('Email Address', customer.email),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildLabelValue('Contact Phone', customer.phone.isNotEmpty ? customer.phone : 'Not provided'),
                    pw.SizedBox(height: 4),
                    _buildLabelValue('Guest ID', customer.id),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Flight Details Section ---
  pw.Widget _buildFlightDetailsSection(FlightBookingDetails? flightDetails) {
    if (flightDetails == null || flightDetails.segments.isEmpty) {
      return pw.SizedBox();
    }

    final dateFormat = DateFormat('EEE, dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('FLIGHT ITINERARY'),
          ...flightDetails.segments.asMap().entries.map((entry) {
            final index = entry.key;
            final seg = entry.value;
            final isLast = index == flightDetails.segments.length - 1;

            return pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: isLast ? null : const pw.Border(bottom: pw.BorderSide(color: borderColor, width: 0.8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Flight ${index + 1}: ${seg.airline} (${seg.flightNumber})',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10.5,
                          color: primaryDarkColor,
                        ),
                      ),
                      pw.Text(
                        'Cabin: ${seg.cabinClass} • Duration: ${seg.flightDuration}',
                        style: const pw.TextStyle(fontSize: 8.5, color: mutedTextColor),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Departure
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'DEPARTURE',
                              style: const pw.TextStyle(fontSize: 7.5, color: mutedTextColor),
                            ),
                            pw.Text(
                              seg.departureAirportCode,
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: darkTextColor,
                              ),
                            ),
                            pw.Text(
                              seg.departureAirport,
                              style: const pw.TextStyle(fontSize: 8.5),
                            ),
                            if (seg.departureTerminal != null)
                              pw.Text(
                                seg.departureTerminal!,
                                style: const pw.TextStyle(fontSize: 7.5, color: mutedTextColor),
                              ),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              '${dateFormat.format(seg.departureDateTime)} • ${timeFormat.format(seg.departureDateTime)}',
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrow
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              '✈ ➔',
                              style: const pw.TextStyle(fontSize: 14, color: primaryColor),
                            ),
                            if (flightDetails.baggageAllowance != null)
                              pw.Text(
                                '🧳 ${flightDetails.baggageAllowance}',
                                style: const pw.TextStyle(fontSize: 6.5, color: mutedTextColor),
                              ),
                          ],
                        ),
                      ),
                      // Arrival
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'ARRIVAL',
                              style: const pw.TextStyle(fontSize: 7.5, color: mutedTextColor),
                            ),
                            pw.Text(
                              seg.arrivalAirportCode,
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: darkTextColor,
                              ),
                            ),
                            pw.Text(
                              seg.arrivalAirport,
                              textAlign: pw.TextAlign.right,
                              style: const pw.TextStyle(fontSize: 8.5),
                            ),
                            if (seg.arrivalTerminal != null)
                              pw.Text(
                                seg.arrivalTerminal!,
                                textAlign: pw.TextAlign.right,
                                style: const pw.TextStyle(fontSize: 7.5, color: mutedTextColor),
                              ),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              '${dateFormat.format(seg.arrivalDateTime)} • ${timeFormat.format(seg.arrivalDateTime)}',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (seg.aircraft != null) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Aircraft: ${seg.aircraft}',
                      style: const pw.TextStyle(fontSize: 7.5, color: mutedTextColor),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Hotel Details Section ---
  pw.Widget _buildHotelDetailsSection(HotelBookingDetails? hotelDetails) {
    if (hotelDetails == null) return pw.SizedBox();

    final dateFormat = DateFormat('EEE, dd MMM yyyy');

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('HOTEL & STAY DETAILS'),
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        hotelDetails.hotelName,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryDarkColor,
                        ),
                      ),
                    ),
                    if (hotelDetails.hotelRating != null)
                      pw.Text(
                        '★ ${hotelDetails.hotelRating!.toStringAsFixed(1)} / 5.0',
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFFF57F17),
                        ),
                      ),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Address: ${hotelDetails.hotelAddress}',
                  style: const pw.TextStyle(fontSize: 8.5, color: darkTextColor),
                ),
                if (hotelDetails.hotelPhone != null)
                  pw.Text(
                    'Hotel Phone: ${hotelDetails.hotelPhone} • Confirmation: ${hotelDetails.hotelConfirmationNumber}',
                    style: const pw.TextStyle(fontSize: 8, color: mutedTextColor),
                  ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: const pw.BoxDecoration(
                    color: lightBgColor,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('CHECK-IN', style: const pw.TextStyle(fontSize: 7.5, color: mutedTextColor)),
                          pw.Text(
                            dateFormat.format(hotelDetails.checkInDate),
                            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text('From ${hotelDetails.checkInTime}', style: const pw.TextStyle(fontSize: 7.5)),
                        ],
                      ),
                      pw.Container(width: 1, height: 28, color: borderColor),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('CHECK-OUT', style: const pw.TextStyle(fontSize: 7.5, color: mutedTextColor)),
                          pw.Text(
                            dateFormat.format(hotelDetails.checkOutDate),
                            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text('Until ${hotelDetails.checkOutTime}', style: const pw.TextStyle(fontSize: 7.5)),
                        ],
                      ),
                      pw.Container(width: 1, height: 28, color: borderColor),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('DURATION', style: const pw.TextStyle(fontSize: 7.5, color: mutedTextColor)),
                          pw.Text(
                            '${hotelDetails.numberOfNights} Nights',
                            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text('${hotelDetails.numberOfGuests} Guests, ${hotelDetails.numberOfRooms} Room(s)',
                              style: const pw.TextStyle(fontSize: 7.5)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    _buildLabelValue('Room Type', hotelDetails.roomType),
                    pw.SizedBox(width: 24),
                    _buildLabelValue('Meal Plan', hotelDetails.mealPlan),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFE8F5E9),
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text(
                        'Policy: ',
                        style: pw.TextStyle(
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                          color: successColor,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          hotelDetails.cancellationPolicy,
                          style: const pw.TextStyle(fontSize: 7.5, color: successColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Price Summary Section ---
  pw.Widget _buildPriceBreakdownSection(PriceBreakdown pricing) {
    final currency = pricing.currency;

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PRICE BREAKDOWN & PAYMENT SUMMARY'),
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              children: [
                _buildPriceRow('Base Price', '\$${pricing.basePrice.toStringAsFixed(2)} $currency'),
                if (pricing.taxes > 0)
                  _buildPriceRow('Taxes & Airport / Local Fees', '\$${pricing.taxes.toStringAsFixed(2)} $currency'),
                if (pricing.isServiceFeeLegallySupported && pricing.serviceFee > 0)
                  _buildPriceRow('TRAVELGO Booking Guarantee & Support Fee', '\$${pricing.serviceFee.toStringAsFixed(2)} $currency'),
                if (pricing.discount > 0)
                  _buildPriceRow('Discount Applied', '-\$${pricing.discount.toStringAsFixed(2)} $currency', isDiscount: true),
                pw.Divider(color: borderColor, thickness: 1),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL AMOUNT PAID',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryDarkColor,
                      ),
                    ),
                    pw.Text(
                      '\$${pricing.totalAmount.toStringAsFixed(2)} $currency',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryDarkColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Terms & Support Footer Section ---
  pw.Widget _buildTermsAndSupportSection(BookingDocument document) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: const pw.BoxDecoration(
        color: lightBgColor,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'IMPORTANT NOTICE & TERMS',
            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: darkTextColor),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            document.termsAndConditions,
            style: const pw.TextStyle(fontSize: 7, color: mutedTextColor),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Customer Care: ${document.supportEmail} • Hotline: ${document.supportPhone}',
                style: const pw.TextStyle(fontSize: 7, color: mutedTextColor),
              ),
              pw.Text(
                document.supportWebsite,
                style: const pw.TextStyle(fontSize: 7, color: primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Page Footer with Page Number ---
  pw.Widget _buildPdfFooter(pw.Context context, BookingDocument document) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: borderColor, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'TRAVELGO Booking Document • Ref: ${document.bookingReference}',
            style: const pw.TextStyle(fontSize: 7, color: mutedTextColor),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 7, color: mutedTextColor),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const pw.BoxDecoration(
        color: lightBgColor,
        borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(3)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: primaryDarkColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  pw.Widget _buildBadge(String label, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 7.5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildLabelValue(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 7.5, color: mutedTextColor)),
        pw.SizedBox(height: 1),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: darkTextColor),
        ),
      ],
    );
  }

  pw.Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8.5,
              color: isDiscount ? successColor : darkTextColor,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: isDiscount ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isDiscount ? successColor : darkTextColor,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 8 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? darkTextColor : darkTextColor,
        ),
      ),
    );
  }
}
