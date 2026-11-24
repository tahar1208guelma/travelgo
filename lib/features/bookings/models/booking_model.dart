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
  initiated,
  pending,
  confirmed,
  cancelled,
  failed,
}

enum PaymentStatus {
  pending,
  authorized,
  paid,
  failed,
  refunded,
  partiallyRefunded,
}

enum RefundStatus {
  none,
  requested,
  processing,
  refunded,
  rejected,
}

class RefundDetails {
  final RefundStatus status;
  final double refundAmount;
  final String currency;
  final String? refundTransactionId;
  final String? reason;
  final DateTime? requestedAt;
  final DateTime? processedAt;
  final String? notes;

  const RefundDetails({
    this.status = RefundStatus.none,
    this.refundAmount = 0.0,
    this.currency = 'USD',
    this.refundTransactionId,
    this.reason,
    this.requestedAt,
    this.processedAt,
    this.notes,
  });

  String get statusLabel {
    switch (status) {
      case RefundStatus.none:
        return 'No Refund';
      case RefundStatus.requested:
        return 'Refund Requested';
      case RefundStatus.processing:
        return 'Refund Processing';
      case RefundStatus.refunded:
        return 'Refunded';
      case RefundStatus.rejected:
        return 'Refund Rejected';
    }
  }

  RefundDetails copyWith({
    RefundStatus? status,
    double? refundAmount,
    String? currency,
    String? refundTransactionId,
    String? reason,
    DateTime? requestedAt,
    DateTime? processedAt,
    String? notes,
  }) {
    return RefundDetails(
      status: status ?? this.status,
      refundAmount: refundAmount ?? this.refundAmount,
      currency: currency ?? this.currency,
      refundTransactionId: refundTransactionId ?? this.refundTransactionId,
      reason: reason ?? this.reason,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt ?? this.processedAt,
      notes: notes ?? this.notes,
    );
  }

  factory RefundDetails.fromJson(Map<String, dynamic> json) {
    return RefundDetails(
      status: RefundStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RefundStatus.none,
      ),
      refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      refundTransactionId: json['refundTransactionId'] as String?,
      reason: json['reason'] as String?,
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'] as String)
          : null,
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'refundAmount': refundAmount,
      'currency': currency,
      if (refundTransactionId != null) 'refundTransactionId': refundTransactionId,
      if (reason != null) 'reason': reason,
      if (requestedAt != null) 'requestedAt': requestedAt!.toIso8601String(),
      if (processedAt != null) 'processedAt': processedAt!.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }
}

class Booking {
  final String bookingId;
  final String bookingReference;
  final BookingType bookingType;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final CustomerInfo customer;
  final String provider;
  final String? providerBookingReference;
  final PriceBreakdown priceBreakdown;
  final FlightBookingDetails? flightDetails;
  final HotelBookingDetails? hotelDetails;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final BookingDocument document;
  final String? cancellationReason;
  final String? paymentMethod;
  final String? paymentTransactionId;
  final RefundDetails? refundDetails;
  final String? customItemName;
  final String? customItemSubtitle;
  final String? customItemImageUrl;

  const Booking({
    required this.bookingId,
    required this.bookingReference,
    required this.bookingType,
    required this.status,
    this.paymentStatus = PaymentStatus.paid,
    required this.customer,
    required this.provider,
    this.providerBookingReference,
    required this.priceBreakdown,
    this.flightDetails,
    this.hotelDetails,
    required this.createdAt,
    this.updatedAt,
    required this.document,
    this.cancellationReason,
    this.paymentMethod,
    this.paymentTransactionId,
    this.refundDetails,
    this.customItemName,
    this.customItemSubtitle,
    this.customItemImageUrl,
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

  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get hasRefund =>
      refundDetails != null && refundDetails!.status != RefundStatus.none;

  String get itemName {
    if (customItemName != null && customItemName!.isNotEmpty) {
      return customItemName!;
    }
    if (bookingType == BookingType.flight && flightDetails != null) {
      return '${flightDetails!.originAirportName} to ${flightDetails!.destinationAirportName}';
    } else if (bookingType == BookingType.hotel && hotelDetails != null) {
      return hotelDetails!.hotelName;
    } else if (bookingType == BookingType.flightAndHotel) {
      final flightPart = flightDetails != null
          ? '${flightDetails!.originCode} → ${flightDetails!.destinationCode}'
          : 'Flight';
      final hotelPart =
          hotelDetails != null ? hotelDetails!.hotelName : 'Hotel';
      return '$flightPart + $hotelPart';
    }
    return 'Travel Booking';
  }

  String? get itemSubtitle {
    if (customItemSubtitle != null && customItemSubtitle!.isNotEmpty) {
      return customItemSubtitle;
    }
    if (bookingType == BookingType.flight && flightDetails != null) {
      return '${flightDetails!.airlineName} • ${flightDetails!.flightNumber} • ${flightDetails!.cabinClass}';
    } else if (bookingType == BookingType.hotel && hotelDetails != null) {
      return '${hotelDetails!.roomType} • ${hotelDetails!.numberOfNights} night(s)';
    } else if (bookingType == BookingType.flightAndHotel) {
      return 'Combined Vacation Package';
    }
    return null;
  }

  String? get itemImageUrl => customItemImageUrl;

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
      case BookingStatus.initiated:
        return 'Initiated';
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

  String get paymentStatusLabel {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.authorized:
        return 'Authorized';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
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
    PaymentStatus? paymentStatus,
    CustomerInfo? customer,
    String? provider,
    String? providerBookingReference,
    PriceBreakdown? priceBreakdown,
    FlightBookingDetails? flightDetails,
    HotelBookingDetails? hotelDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
    BookingDocument? document,
    String? cancellationReason,
    String? paymentMethod,
    String? paymentTransactionId,
    RefundDetails? refundDetails,
    String? customItemName,
    String? customItemSubtitle,
    String? customItemImageUrl,
  }) {
    return Booking(
      bookingId: bookingId ?? this.bookingId,
      bookingReference: bookingReference ?? this.bookingReference,
      bookingType: bookingType ?? this.bookingType,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      customer: customer ?? this.customer,
      provider: provider ?? this.provider,
      providerBookingReference:
          providerBookingReference ?? this.providerBookingReference,
      priceBreakdown: priceBreakdown ?? this.priceBreakdown,
      flightDetails: flightDetails ?? this.flightDetails,
      hotelDetails: hotelDetails ?? this.hotelDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      document: document ?? this.document,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      refundDetails: refundDetails ?? this.refundDetails,
      customItemName: customItemName ?? this.customItemName,
      customItemSubtitle: customItemSubtitle ?? this.customItemSubtitle,
      customItemImageUrl: customItemImageUrl ?? this.customItemImageUrl,
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId:
          json['bookingId'] as String? ?? json['id'] as String? ?? 'TRV-000',
      bookingReference: json['bookingReference'] as String? ??
          json['externalBookingReference'] as String? ??
          'TRV-REF',
      bookingType: BookingType.values.firstWhere(
        (e) => e.name == json['bookingType'],
        orElse: () => json['bookingType'] == 'hotel'
            ? BookingType.hotel
            : BookingType.flight,
      ),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => json['status'] == 'cancelled'
            ? PaymentStatus.refunded
            : PaymentStatus.paid,
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
          ? PriceBreakdown.fromJson(
              json['priceBreakdown'] as Map<String, dynamic>)
          : PriceBreakdown(
              basePrice: (json['basePriceUSD'] as num?)?.toDouble() ?? 0.0,
              serviceFee: (json['serviceFeeUSD'] as num?)?.toDouble() ?? 1.0,
              taxes: (json['taxesUSD'] as num?)?.toDouble() ?? 0.0,
              totalAmount: (json['totalAmountUSD'] as num?)?.toDouble() ?? 0.0,
              currency: json['currency'] as String? ?? 'USD',
            ),
      flightDetails: json['flightDetails'] != null
          ? FlightBookingDetails.fromJson(
              json['flightDetails'] as Map<String, dynamic>)
          : null,
      hotelDetails: json['hotelDetails'] != null
          ? HotelBookingDetails.fromJson(
              json['hotelDetails'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      document: json['document'] != null
          ? BookingDocument.fromJson(json['document'] as Map<String, dynamic>)
          : BookingDocument(
              documentId: 'DOC-${json['bookingReference'] ?? '001'}',
              bookingReference: json['bookingReference'] as String? ?? 'TRV-REF',
              issuedAt: DateTime.now(),
              qrData: json['bookingReference'] as String? ?? 'TRV-REF',
            ),
      cancellationReason: json['cancellationReason'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      paymentTransactionId: json['paymentTransactionId'] as String?,
      refundDetails: json['refundDetails'] != null
          ? RefundDetails.fromJson(
              json['refundDetails'] as Map<String, dynamic>)
          : null,
      customItemName: json['customItemName'] as String?,
      customItemSubtitle: json['customItemSubtitle'] as String?,
      customItemImageUrl: json['customItemImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'bookingReference': bookingReference,
      'bookingType': bookingType.name,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'customer': customer.toJson(),
      'provider': provider,
      if (providerBookingReference != null)
        'providerBookingReference': providerBookingReference,
      'priceBreakdown': priceBreakdown.toJson(),
      if (flightDetails != null) 'flightDetails': flightDetails!.toJson(),
      if (hotelDetails != null) 'hotelDetails': hotelDetails!.toJson(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'document': document.toJson(),
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (paymentTransactionId != null)
        'paymentTransactionId': paymentTransactionId,
      if (refundDetails != null) 'refundDetails': refundDetails!.toJson(),
      if (customItemName != null) 'customItemName': customItemName,
      if (customItemSubtitle != null) 'customItemSubtitle': customItemSubtitle,
      if (customItemImageUrl != null) 'customItemImageUrl': customItemImageUrl,
    };
  }
}

// Aliases for compatibility
typedef BookingEntity = Booking;
typedef BookingModel = Booking;
