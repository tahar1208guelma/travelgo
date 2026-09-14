import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.provider,
    required super.bookingType,
    required super.status,
    required super.externalBookingReference,
    required super.itemName,
    super.itemSubtitle,
    super.itemImageUrl,
    required super.startDate,
    super.endDate,
    required super.basePriceUSD,
    required super.taxesUSD,
    required super.serviceFeeUSD,
    required super.totalAmountUSD,
    super.currency,
    required super.passengerOrGuestName,
    required super.contactEmail,
    required super.contactPhone,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      provider: json['provider'] as String? ?? 'Direct',
      bookingType: json['bookingType'] == 'hotel' ? BookingType.hotel : BookingType.flight,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      externalBookingReference: json['externalBookingReference'] as String? ?? 'TG-REF',
      itemName: json['itemName'] as String? ?? 'Trip Item',
      itemSubtitle: json['itemSubtitle'] as String?,
      itemImageUrl: json['itemImageUrl'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      basePriceUSD: (json['basePriceUSD'] as num).toDouble(),
      taxesUSD: (json['taxesUSD'] as num).toDouble(),
      serviceFeeUSD: (json['serviceFeeUSD'] as num).toDouble(),
      totalAmountUSD: (json['totalAmountUSD'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      passengerOrGuestName: json['passengerOrGuestName'] as String? ?? 'Passenger',
      contactEmail: json['contactEmail'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'provider': provider,
      'bookingType': bookingType.name,
      'status': status.name,
      'externalBookingReference': externalBookingReference,
      'itemName': itemName,
      'itemSubtitle': itemSubtitle,
      'itemImageUrl': itemImageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'basePriceUSD': basePriceUSD,
      'taxesUSD': taxesUSD,
      'serviceFeeUSD': serviceFeeUSD,
      'totalAmountUSD': totalAmountUSD,
      'currency': currency,
      'passengerOrGuestName': passengerOrGuestName,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BookingModel.fromEntity(BookingEntity entity) {
    return BookingModel(
      id: entity.id,
      userId: entity.userId,
      provider: entity.provider,
      bookingType: entity.bookingType,
      status: entity.status,
      externalBookingReference: entity.externalBookingReference,
      itemName: entity.itemName,
      itemSubtitle: entity.itemSubtitle,
      itemImageUrl: entity.itemImageUrl,
      startDate: entity.startDate,
      endDate: entity.endDate,
      basePriceUSD: entity.basePriceUSD,
      taxesUSD: entity.taxesUSD,
      serviceFeeUSD: entity.serviceFeeUSD,
      totalAmountUSD: entity.totalAmountUSD,
      currency: entity.currency,
      passengerOrGuestName: entity.passengerOrGuestName,
      contactEmail: entity.contactEmail,
      contactPhone: entity.contactPhone,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
