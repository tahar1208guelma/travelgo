import '../../bookings/models/hotel_booking_details.dart';
import '../../bookings/models/price_breakdown.dart';

/// Represents a live hotel offer returned by Hotelbeds / TRAVELGO Accommodation Engine
class HotelOffer {
  final String hotelId;
  final String name;
  final String address;
  final String city;
  final String country;
  final int starRating;
  final double userRating; // e.g. 4.8 / 5.0
  final int reviewCount;
  final String? mainImageUrl;
  final List<String> amenities;
  final HotelRoom primaryRoom;
  final String mealPlan;
  final String cancellationPolicy;
  final PriceBreakdown price; // Total for stay including 0.75% TRAVELGO Fee
  final double pricePerNight;

  const HotelOffer({
    required this.hotelId,
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    this.starRating = 5,
    this.userRating = 4.8,
    this.reviewCount = 320,
    this.mainImageUrl,
    required this.amenities,
    required this.primaryRoom,
    required this.mealPlan,
    required this.cancellationPolicy,
    required this.price,
    required this.pricePerNight,
  });

  Map<String, dynamic> toMap() {
    return {
      'hotelId': hotelId,
      'name': name,
      'address': address,
      'city': city,
      'country': country,
      'starRating': starRating,
      'userRating': userRating,
      'reviewCount': reviewCount,
      'mainImageUrl': mainImageUrl,
      'amenities': amenities,
      'primaryRoom': primaryRoom.toMap(),
      'mealPlan': mealPlan,
      'cancellationPolicy': cancellationPolicy,
      'price': price.toMap(),
      'pricePerNight': pricePerNight,
    };
  }

  factory HotelOffer.fromMap(Map<String, dynamic> map) {
    return HotelOffer(
      hotelId: map['hotelId'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      country: map['country'] as String,
      starRating: map['starRating'] as int? ?? 5,
      userRating: (map['userRating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: map['reviewCount'] as int? ?? 100,
      mainImageUrl: map['mainImageUrl'] as String?,
      amenities: List<String>.from(map['amenities'] as List<dynamic>? ?? []),
      primaryRoom: HotelRoom.fromMap(map['primaryRoom'] as Map<String, dynamic>),
      mealPlan: map['mealPlan'] as String? ?? 'Room Only',
      cancellationPolicy: map['cancellationPolicy'] as String? ?? 'Non-refundable',
      price: PriceBreakdown.fromMap(map['price'] as Map<String, dynamic>),
      pricePerNight: (map['pricePerNight'] as num).toDouble(),
    );
  }
}
