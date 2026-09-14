import '../features/flights/domain/entities/flight_entity.dart';
import '../features/flights/domain/entities/flight_search_params.dart';
import '../features/hotels/domain/entities/hotel_entity.dart';
import '../features/hotels/domain/entities/hotel_search_params.dart';
import '../features/booking/domain/entities/booking_entity.dart';
import '../features/booking/domain/entities/affiliate_click_entity.dart';

class DirectBookingRequest {
  final String userId;
  final String itemId;
  final BookingType bookingType;
  final String itemName;
  final String? itemSubtitle;
  final String? itemImageUrl;
  final DateTime startDate;
  final DateTime? endDate;
  final double basePriceUSD;
  final double taxesUSD;
  final double serviceFeeUSD; // $1.00 USD
  final double totalAmountUSD;
  final String passengerOrGuestName;
  final String contactEmail;
  final String contactPhone;
  final String paymentMethod;

  const DirectBookingRequest({
    required this.userId,
    required this.itemId,
    required this.bookingType,
    required this.itemName,
    this.itemSubtitle,
    this.itemImageUrl,
    required this.startDate,
    this.endDate,
    required this.basePriceUSD,
    required this.taxesUSD,
    required this.serviceFeeUSD,
    required this.totalAmountUSD,
    required this.passengerOrGuestName,
    required this.contactEmail,
    required this.contactPhone,
    required this.paymentMethod,
  });
}

abstract class TravelProvider {
  String get providerName;

  Future<List<FlightEntity>> searchFlights(FlightSearchParams params);
  Future<FlightEntity?> getFlightDetails(String flightId);

  Future<List<HotelEntity>> searchHotels(HotelSearchParams params);
  Future<HotelEntity?> getHotelDetails(String hotelId);

  Future<BookingEntity> createDirectBooking(DirectBookingRequest request);
  Future<AffiliateClickEntity> generateAffiliateLink({
    required String userId,
    required String productType,
    required String productId,
    required String rawTargetUrl,
  });
}
