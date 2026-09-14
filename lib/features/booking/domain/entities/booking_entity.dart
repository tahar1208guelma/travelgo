enum BookingType { flight, hotel }
enum BookingStatus { initiated, pending, confirmed, cancelled, failed }

class BookingEntity {
  final String id;
  final String userId;
  final String provider; // e.g. "Amadeus", "Direct", "Booking.com"
  final BookingType bookingType;
  final BookingStatus status;
  final String externalBookingReference; // PNR or Reservation Code
  final String itemName;
  final String? itemSubtitle;
  final String? itemImageUrl;
  final DateTime startDate;
  final DateTime? endDate;
  final double basePriceUSD;
  final double taxesUSD;
  final double serviceFeeUSD; // $1.00 USD standard commission
  final double totalAmountUSD;
  final String currency;
  final String passengerOrGuestName;
  final String contactEmail;
  final String contactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.provider,
    required this.bookingType,
    required this.status,
    required this.externalBookingReference,
    required this.itemName,
    this.itemSubtitle,
    this.itemImageUrl,
    required this.startDate,
    this.endDate,
    required this.basePriceUSD,
    required this.taxesUSD,
    required this.serviceFeeUSD,
    required this.totalAmountUSD,
    this.currency = 'USD',
    required this.passengerOrGuestName,
    required this.contactEmail,
    required this.contactPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  BookingEntity copyWith({
    BookingStatus? status,
    DateTime? updatedAt,
  }) {
    return BookingEntity(
      id: id,
      userId: userId,
      provider: provider,
      bookingType: bookingType,
      status: status ?? this.status,
      externalBookingReference: externalBookingReference,
      itemName: itemName,
      itemSubtitle: itemSubtitle,
      itemImageUrl: itemImageUrl,
      startDate: startDate,
      endDate: endDate,
      basePriceUSD: basePriceUSD,
      taxesUSD: taxesUSD,
      serviceFeeUSD: serviceFeeUSD,
      totalAmountUSD: totalAmountUSD,
      currency: currency,
      passengerOrGuestName: passengerOrGuestName,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

