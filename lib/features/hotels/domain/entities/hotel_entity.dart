import '../../flights/domain/entities/flight_entity.dart';

class HotelRoomOption {
  final String id;
  final String nameEn;
  final String nameAr;
  final double pricePerNightUSD;
  final int maxGuests;
  final String bedType;
  final bool breakfastIncluded;
  final bool freeCancellation;
  final List<String> perks;

  const HotelRoomOption({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.pricePerNightUSD,
    required this.maxGuests,
    required this.bedType,
    this.breakfastIncluded = false,
    this.freeCancellation = true,
    this.perks = const [],
  });

  String getName({bool isArabic = false}) => isArabic ? nameAr : nameEn;
}

class HotelEntity {
  final String id;
  final String providerName; // e.g. "Booking.com", "Hotelbeds", "Direct"
  final BookingChannel bookingChannel; // direct vs affiliate
  final String? affiliateUrl;
  final String nameEn;
  final String nameAr;
  final String cityEn;
  final String cityAr;
  final String countryEn;
  final String countryAr;
  final String address;
  final int starRating; // 1-5
  final double userRating; // e.g. 9.2
  final int reviewCount;
  final String distanceToCenter;
  final double pricePerNightUSD;
  final double taxesPerNightUSD;
  final bool freeCancellation;
  final bool breakfastIncluded;
  final String mainImageUrl;
  final List<String> galleryImages;
  final List<String> amenities;
  final String descriptionEn;
  final String descriptionAr;
  final String checkInTime;
  final String checkOutTime;
  final String cancellationPolicyEn;
  final String cancellationPolicyAr;
  final double latitude;
  final double longitude;
  final List<HotelRoomOption> rooms;

  const HotelEntity({
    required this.id,
    required this.providerName,
    required this.bookingChannel,
    this.affiliateUrl,
    required this.nameEn,
    required this.nameAr,
    required this.cityEn,
    required this.cityAr,
    required this.countryEn,
    required this.countryAr,
    required this.address,
    required this.starRating,
    required this.userRating,
    required this.reviewCount,
    required this.distanceToCenter,
    required this.pricePerNightUSD,
    this.taxesPerNightUSD = 12.0,
    this.freeCancellation = true,
    this.breakfastIncluded = true,
    required this.mainImageUrl,
    this.galleryImages = const [],
    this.amenities = const [],
    required this.descriptionEn,
    required this.descriptionAr,
    this.checkInTime = '15:00',
    this.checkOutTime = '11:00',
    this.cancellationPolicyEn = 'Free cancellation up to 48 hours before check-in.',
    this.cancellationPolicyAr = 'إلغاء مجاني حتى 48 ساعة قبل موعد تسجيل الوصول.',
    this.latitude = 25.2048,
    this.longitude = 55.2708,
    this.rooms = const [],
  });

  String getName({bool isArabic = false}) => isArabic ? nameAr : nameEn;
  String getCity({bool isArabic = false}) => isArabic ? cityAr : cityEn;
  String getCountry({bool isArabic = false}) => isArabic ? countryAr : countryEn;
  String getDescription({bool isArabic = false}) => isArabic ? descriptionAr : descriptionEn;
  String getCancellationPolicy({bool isArabic = false}) => isArabic ? cancellationPolicyAr : cancellationPolicyEn;

  bool get isAffiliate => bookingChannel == BookingChannel.affiliate;
}
