import 'booking_document.dart';
import 'customer_info.dart';
import 'flight_booking_details.dart';
import 'hotel_booking_details.dart';
import 'price_breakdown.dart';

enum BookingType {
  flight,
  hotel,
  flightAndHotel,
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  failed,
}

class Booking {
  final String bookingId;
  final String bookingReference;
  final BookingType bookingType;
  final BookingStatus status;
  final CustomerInfo customer;
  final String provider;
  final String? providerBookingReference;
  final PriceBreakdown priceBreakdown;
  final FlightBookingDetails? flightDetails;
  final HotelBookingDetails? hotelDetails;
  final DateTime createdAt;
  final BookingDocument document;
  final String? cancellationReason;

  const Booking({
    required this.bookingId,
    required this.bookingReference,
    required this.bookingType,
    required this.status,
    required this.customer,
    required this.provider,
    this.providerBookingReference,
    required this.priceBreakdown,
    this.flightDetails,
    this.hotelDetails,
    required this.createdAt,
    required this.document,
    this.cancellationReason,
  });

  // Backward compatibility getters for existing UI code
  String get id => bookingId;
  String get externalBookingReference => bookingReference;
  String get userId => customer.id;
  String get passengerOrGuestName => customer.fullName;
  String get contactEmail => customer.email;
  String get contactPhone => customer.phone;
  double get basePriceUSD => priceBreakdown.basePrice;
  double get serviceFeeUSD => priceBreakdown.serviceFee;
  double get taxesUSD => priceBreakdown.taxes;
  double get totalAmountUSD => priceBreakdown.totalAmount;
  String get currency => priceBreakdown.currency;

  String get itemName {
    if (bookingType == BookingType.flight && flightDetails != null) {
      return '${flightDetails!.originAirportName} to ${flightDetails!.destinationAirportName}';
    } else if (bookingType == BookingType.hotel && hotelDetails != null) {
      return hotelDetails!.hotelName;
    } else if (bookingType == BookingType.flightAndHotel) {
      final flightPart = flightDetails != null ? '${flightDetails!.originCode} → ${flightDetails!.destinationCode}' : 'Flight';
      final hotelPart = hotelDetails != null ? hotelDetails!.hotelName : 'Hotel';
      return '$flightPart + $hotelPart';
    }
    return 'Travel Booking';
  }

  String? get itemSubtitle {
    if (bookingType == BookingType.flight && flightDetails != null) {
      return '${flightDetails!.airlineName} • ${flightDetails!.flightNumber} • ${flightDetails!.cabinClass}';
    } else if (bookingType == BookingType.hotel && hotelDetails != null) {
      return '${hotelDetails!.roomType} • ${hotelDetails!.numberOfNights} night(s)';
    } else if (bookingType == BookingType.flightAndHotel) {
      return 'Combined Vacation Package';
    }
    return null;
  }

  String? get itemImageUrl => null;

  DateTime get startDate {
    if (bookingType == BookingType.flight && flightDetails != null) {
      return flightDetails!.departureDateTime;
    } else if (hotelDetails != null) {
      return hotelDetails!.checkInDate;
    }
    return createdAt;
  }

  DateTime? get endDate {
    if (bookingType == BookingType.flight && flightDetails != null) {
      return flightDetails!.arrivalDateTime;
    } else if (hotelDetails != null) {
      return hotelDetails!.checkOutDate;
    }
    return null;
  }

  String get typeLabel {
    switch (bookingType) {
      case BookingType.flight:
        return 'Flight';
      case BookingType.hotel:
        return 'Hotel';
      case BookingType.flightAndHotel:
        return 'Flight + Hotel';
    }
  }

  String get statusLabel {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.failed:
        return 'Failed';
    }
  }

  String get suggestedPdfFileName {
    switch (bookingType) {
      case BookingType.flight:
        return 'TRAVELGO_Booking_$bookingReference.pdf';
      case BookingType.hotel:
        return 'TRAVELGO_HotelVoucher_$bookingReference.pdf';
      case BookingType.flightAndHotel:
        return 'TRAVELGO_CombinedBooking_$bookingReference.pdf';
    }
  }

  Booking copyWith({
    String? bookingId,
    String? bookingReference,
    BookingType? bookingType,
    BookingStatus? status,
    CustomerInfo? customer,
    String? provider,
    String? providerBookingReference,
    PriceBreakdown? priceBreakdown,
    FlightBookingDetails? flightDetails,
    HotelBookingDetails? hotelDetails,
    DateTime? createdAt,
    BookingDocument? document,
    String? cancellationReason,
    DateTime? updatedAt,
  }) {
    return Booking(
      bookingId: bookingId ?? this.bookingId,
      bookingReference: bookingReference ?? this.bookingReference,
      bookingType: bookingType ?? this.bookingType,
      status: status ?? this.status,
      customer: customer ?? this.customer,
      provider: provider ?? this.provider,
      providerBookingReference: providerBookingReference ?? this.providerBookingReference,
      priceBreakdown: priceBreakdown ?? this.priceBreakdown,
      flightDetails: flightDetails ?? this.flightDetails,
      hotelDetails: hotelDetails ?? this.hotelDetails,
      createdAt: createdAt ?? this.createdAt,
      document: document ?? this.document,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['bookingId'] as String? ?? json['id'] as String? ?? 'TRV-000',
      bookingReference: json['bookingReference'] as String? ?? json['externalBookingReference'] as String? ?? 'TRV-REF',
      bookingType: BookingType.values.firstWhere(
        (e) => e.name == json['bookingType'],
        orElse: () => json['bookingType'] == 'hotel' ? BookingType.hotel : BookingType.flight,
      ),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      customer: json['customer'] != null
          ? CustomerInfo.fromJson(json['customer'] as Map<String, dynamic>)
          : CustomerInfo(
              id: json['userId'] as String? ?? '',
              fullName: json['passengerOrGuestName'] as String? ?? 'Customer',
              email: json['contactEmail'] as String? ?? '',
              phone: json['contactPhone'] as String? ?? '',
            ),
      provider: json['provider'] as String? ?? 'TRAVELGO Direct',
      providerBookingReference: json['providerBookingReference'] as String?,
      priceBreakdown: json['priceBreakdown'] != null
          ? PriceBreakdown.fromJson(json['priceBreakdown'] as Map<String, dynamic>)
          : PriceBreakdown(
              basePrice: (json['basePriceUSD'] as num?)?.toDouble() ?? 0.0,
              serviceFee: (json['serviceFeeUSD'] as num?)?.toDouble() ?? 1.0,
              taxes: (json['taxesUSD'] as num?)?.toDouble() ?? 0.0,
              totalAmount: (json['totalAmountUSD'] as num?)?.toDouble() ?? 0.0,
              currency: json['currency'] as String? ?? 'USD',
            ),
      flightDetails: json['flightDetails'] != null
          ? FlightBookingDetails.fromJson(json['flightDetails'] as Map<String, dynamic>)
          : null,
      hotelDetails: json['hotelDetails'] != null
          ? HotelBookingDetails.fromJson(json['hotelDetails'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      document: json['document'] != null
          ? BookingDocument.fromJson(json['document'] as Map<String, dynamic>)
          : BookingDocument(
              documentId: 'DOC-${json['bookingReference'] ?? '001'}',
              bookingReference: json['bookingReference'] as String? ?? 'TRV-REF',
              issuedAt: DateTime.now(),
              qrData: json['bookingReference'] as String? ?? 'TRV-REF',
            ),
      cancellationReason: json['cancellationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'bookingReference': bookingReference,
      'bookingType': bookingType.name,
      'status': status.name,
      'customer': customer.toJson(),
      'provider': provider,
      'providerBookingReference': providerBookingReference,
      'priceBreakdown': priceBreakdown.toJson(),
      'flightDetails': flightDetails?.toJson(),
      'hotelDetails': hotelDetails?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'document': document.toJson(),
      'cancellationReason': cancellationReason,
    };
  }
}

// Aliases for compatibility
typedef BookingEntity = Booking;
typedef BookingModel = Booking;
