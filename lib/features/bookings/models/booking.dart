import 'booking_status.dart';
import 'booking_type.dart';
import 'flight_booking_details.dart';
import 'hotel_booking_details.dart';
import 'price_breakdown.dart';

class Booking {
  final String bookingId;
  final String bookingReference;
  final BookingType bookingType;
  final BookingStatus status;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final String provider;
  final String? providerBookingReference;
  final PriceBreakdown price;
  final DateTime createdAt;
  final FlightBookingDetails? flightDetails;
  final HotelBookingDetails? hotelDetails;
  final bool isDemo;
  final String? notes;

  const Booking({
    required this.bookingId,
    required this.bookingReference,
    required this.bookingType,
    required this.status,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.provider,
    this.providerBookingReference,
    required this.price,
    required this.createdAt,
    this.flightDetails,
    this.hotelDetails,
    this.isDemo = true,
    this.notes,
  });

  String get summaryTitle {
    switch (bookingType) {
      case BookingType.flight:
        if (flightDetails != null && flightDetails!.segments.isNotEmpty) {
          final seg = flightDetails!.primarySegment;
          final origin = seg.departureCity ?? seg.departureAirportCode;
          final dest = seg.arrivalCity ?? seg.arrivalAirportCode;
          return '$origin → $dest';
        }
        return 'Flight Booking';
      case BookingType.hotel:
        return hotelDetails?.hotelName ?? 'Hotel Booking';
      case BookingType.flightAndHotel:
        final flightSummary = (flightDetails != null && flightDetails!.segments.isNotEmpty)
            ? '${flightDetails!.primarySegment.departureAirportCode} → ${flightDetails!.primarySegment.arrivalAirportCode}'
            : 'Flight';
        final hotelSummary = hotelDetails?.hotelName ?? 'Hotel';
        return '$flightSummary + $hotelSummary';
    }
  }

  String get suggestedPdfFileName {
    switch (bookingType) {
      case BookingType.flight:
      case BookingType.flightAndHotel:
        return 'TRAVELGO_Booking_$bookingReference.pdf';
      case BookingType.hotel:
        return 'TRAVELGO_HotelVoucher_$bookingReference.pdf';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'bookingReference': bookingReference,
      'bookingType': bookingType.name,
      'status': status.name,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'provider': provider,
      'providerBookingReference': providerBookingReference,
      'price': price.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'flightDetails': flightDetails?.toMap(),
      'hotelDetails': hotelDetails?.toMap(),
      'isDemo': isDemo,
      'notes': notes,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      bookingId: map['bookingId'] as String,
      bookingReference: map['bookingReference'] as String,
      bookingType: BookingType.values.firstWhere(
        (e) => e.name == map['bookingType'],
        orElse: () => BookingType.flight,
      ),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      customerName: map['customerName'] as String,
      customerEmail: map['customerEmail'] as String,
      customerPhone: map['customerPhone'] as String?,
      provider: map['provider'] as String,
      providerBookingReference: map['providerBookingReference'] as String?,
      price: PriceBreakdown.fromMap(map['price'] as Map<String, dynamic>),
      createdAt: DateTime.parse(map['createdAt'] as String),
      flightDetails: map['flightDetails'] != null
          ? FlightBookingDetails.fromMap(map['flightDetails'] as Map<String, dynamic>)
          : null,
      hotelDetails: map['hotelDetails'] != null
          ? HotelBookingDetails.fromMap(map['hotelDetails'] as Map<String, dynamic>)
          : null,
      isDemo: map['isDemo'] as bool? ?? true,
      notes: map['notes'] as String?,
    );
  }
}
