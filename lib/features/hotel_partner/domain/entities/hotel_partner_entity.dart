import 'package:travelgo/features/flights/domain/entities/flight_entity.dart';
import 'package:travelgo/features/hotels/domain/entities/hotel_entity.dart';

enum PartnerListingStatus { active, paused, pendingReview }

class PartnerAmenity {
  final String id;
  final String nameEn;
  final String nameAr;
  final String iconName;

  const PartnerAmenity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.iconName,
  });

  String getName({bool isArabic = false}) => isArabic ? nameAr : nameEn;

  static const List<PartnerAmenity> defaultCatalog = [
    PartnerAmenity(id: 'wifi', nameEn: 'Free High-Speed WiFi', nameAr: 'واي فاي مجاني فائق السرعة', iconName: 'wifi'),
    PartnerAmenity(id: 'pool', nameEn: 'Swimming Pool', nameAr: 'مسبح خارجي/داخلي', iconName: 'pool'),
    PartnerAmenity(id: 'breakfast', nameEn: 'Free Breakfast Buffet', nameAr: 'بوفيه إفطار مجاني', iconName: 'restaurant'),
    PartnerAmenity(id: 'parking', nameEn: 'Free Private Parking', nameAr: 'موقف سيارات مجاني', iconName: 'local_parking'),
    PartnerAmenity(id: 'gym', nameEn: 'Fitness Center / Gym', nameAr: 'مركز لياقة بدنية / جيم', iconName: 'fitness_center'),
    PartnerAmenity(id: 'spa', nameEn: 'Luxury Spa & Wellness', nameAr: 'سبا ومركز استرخاء', iconName: 'spa'),
    PartnerAmenity(id: 'seaview', nameEn: 'Panoramic Sea View', nameAr: 'إطلالة بحرية بانورامية', iconName: 'waves'),
    PartnerAmenity(id: 'shuttle', nameEn: 'Airport Shuttle Service', nameAr: 'خدمة نقل المطار', iconName: 'airport_shuttle'),
    PartnerAmenity(id: 'restaurant', nameEn: 'Gourmet Restaurant', nameAr: 'مطعم فاخر', iconName: 'restaurant_menu'),
    PartnerAmenity(id: 'ac', nameEn: 'Air Conditioning', nameAr: 'تكييف مركزي', iconName: 'ac_unit'),
    PartnerAmenity(id: 'room_service', nameEn: '24/7 Room Service', nameAr: 'خدمة غرف على مدار 24 ساعة', iconName: 'room_service'),
    PartnerAmenity(id: 'beach', nameEn: 'Private Beach Access', nameAr: 'شاطئ خاص مباشر', iconName: 'beach_access'),
    PartnerAmenity(id: 'business', nameEn: 'Business Meeting Center', nameAr: 'مركز أعمال واجتماعات', iconName: 'business_center'),
    PartnerAmenity(id: 'kids_club', nameEn: 'Kids Play Club', nameAr: 'نادي ألعاب أطفال', iconName: 'child_care'),
    PartnerAmenity(id: 'pet_friendly', nameEn: 'Pet Friendly', nameAr: 'يسمح باصطحاب الحيوانات الأليفة', iconName: 'pets'),
    PartnerAmenity(id: 'ev_charger', nameEn: 'EV Charging Station', nameAr: 'محطة شحن سيارات كهربائية', iconName: 'ev_station'),
  ];
}

class PartnerRoomType {
  final String id;
  final String hotelId;
  final String nameEn;
  final String nameAr;
  final double pricePerNightUSD;
  final int maxGuests;
  final String bedType;
  final bool breakfastIncluded;
  final bool freeCancellation;
  final int totalUnits;
  final int availableUnits;
  final List<String> perks;
  final List<String> photos;

  const PartnerRoomType({
    required this.id,
    required this.hotelId,
    required this.nameEn,
    required this.nameAr,
    required this.pricePerNightUSD,
    required this.maxGuests,
    required this.bedType,
    this.breakfastIncluded = true,
    this.freeCancellation = true,
    this.totalUnits = 5,
    this.availableUnits = 5,
    this.perks = const [],
    this.photos = const [],
  });

  String getName({bool isArabic = false}) => isArabic ? nameAr : nameEn;

  Map<String, dynamic> toJson() => {
    'id': id,
    'hotelId': hotelId,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'pricePerNightUSD': pricePerNightUSD,
    'maxGuests': maxGuests,
    'bedType': bedType,
    'breakfastIncluded': breakfastIncluded,
    'freeCancellation': freeCancellation,
    'totalUnits': totalUnits,
    'availableUnits': availableUnits,
    'perks': perks,
    'photos': photos,
  };

  factory PartnerRoomType.fromJson(Map<String, dynamic> json) => PartnerRoomType(
    id: json['id'] as String? ?? 'rm_${DateTime.now().millisecondsSinceEpoch}',
    hotelId: json['hotelId'] as String? ?? '',
    nameEn: json['nameEn'] as String? ?? 'Standard Room',
    nameAr: json['nameAr'] as String? ?? 'غرفة قياسية',
    pricePerNightUSD: (json['pricePerNightUSD'] as num?)?.toDouble() ?? 100.0,
    maxGuests: json['maxGuests'] as int? ?? 2,
    bedType: json['bedType'] as String? ?? '1 King Bed',
    breakfastIncluded: json['breakfastIncluded'] as bool? ?? true,
    freeCancellation: json['freeCancellation'] as bool? ?? true,
    totalUnits: json['totalUnits'] as int? ?? 5,
    availableUnits: json['availableUnits'] as int? ?? 5,
    perks: (json['perks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    photos: (json['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
  );

  HotelRoomOption toHotelRoomOption() => HotelRoomOption(
    id: id,
    nameEn: nameEn,
    nameAr: nameAr,
    pricePerNightUSD: pricePerNightUSD,
    maxGuests: maxGuests,
    bedType: bedType,
    breakfastIncluded: breakfastIncluded,
    freeCancellation: freeCancellation,
    perks: perks,
  );
}

class PartnerHotelListing {
  final String id;
  final String ownerPartnerId;
  final String nameEn;
  final String nameAr;
  final String cityEn;
  final String cityAr;
  final String countryEn;
  final String countryAr;
  final String address;
  final int starRating;
  final double userRating;
  final int reviewCount;
  final String distanceToCenter;
  final double pricePerNightUSD;
  final double taxesPerNightUSD;
  final String mainCoverImageUrl;
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
  final List<PartnerRoomType> rooms;
  final PartnerListingStatus status;
  final DateTime createdAt;

  const PartnerHotelListing({
    required this.id,
    required this.ownerPartnerId,
    required this.nameEn,
    required this.nameAr,
    required this.cityEn,
    required this.cityAr,
    required this.countryEn,
    required this.countryAr,
    required this.address,
    required this.starRating,
    this.userRating = 9.4,
    this.reviewCount = 18,
    this.distanceToCenter = '0.5 km from center',
    required this.pricePerNightUSD,
    this.taxesPerNightUSD = 10.0,
    required this.mainCoverImageUrl,
    this.galleryImages = const [],
    this.amenities = const [],
    required this.descriptionEn,
    required this.descriptionAr,
    this.checkInTime = '14:00',
    this.checkOutTime = '12:00',
    this.cancellationPolicyEn = 'Free cancellation up to 24h prior to check-in.',
    this.cancellationPolicyAr = 'إلغاء مجاني حتى 24 ساعة قبل موعد الوصول.',
    this.latitude = 36.7538,
    this.longitude = 3.0588,
    this.rooms = const [],
    this.status = PartnerListingStatus.active,
    required this.createdAt,
  });

  String getName({bool isArabic = false}) => isArabic ? nameAr : nameEn;
  String getCity({bool isArabic = false}) => isArabic ? cityAr : cityEn;
  String getCountry({bool isArabic = false}) => isArabic ? countryAr : countryEn;
  String getDescription({bool isArabic = false}) => isArabic ? descriptionAr : descriptionEn;

  bool get isActive => status == PartnerListingStatus.active;

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerPartnerId': ownerPartnerId,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'cityEn': cityEn,
    'cityAr': cityAr,
    'countryEn': countryEn,
    'countryAr': countryAr,
    'address': address,
    'starRating': starRating,
    'userRating': userRating,
    'reviewCount': reviewCount,
    'distanceToCenter': distanceToCenter,
    'pricePerNightUSD': pricePerNightUSD,
    'taxesPerNightUSD': taxesPerNightUSD,
    'mainCoverImageUrl': mainCoverImageUrl,
    'galleryImages': galleryImages,
    'amenities': amenities,
    'descriptionEn': descriptionEn,
    'descriptionAr': descriptionAr,
    'checkInTime': checkInTime,
    'checkOutTime': checkOutTime,
    'cancellationPolicyEn': cancellationPolicyEn,
    'cancellationPolicyAr': cancellationPolicyAr,
    'latitude': latitude,
    'longitude': longitude,
    'rooms': rooms.map((r) => r.toJson()).toList(),
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PartnerHotelListing.fromJson(Map<String, dynamic> json) => PartnerHotelListing(
    id: json['id'] as String? ?? 'ht_partner_${DateTime.now().millisecondsSinceEpoch}',
    ownerPartnerId: json['ownerPartnerId'] as String? ?? 'host_default',
    nameEn: json['nameEn'] as String? ?? 'Partner Boutique Hotel',
    nameAr: json['nameAr'] as String? ?? 'فندق الشريك المميز',
    cityEn: json['cityEn'] as String? ?? 'Algiers',
    cityAr: json['cityAr'] as String? ?? 'الجزائر العاصمة',
    countryEn: json['countryEn'] as String? ?? 'Algeria',
    countryAr: json['countryAr'] as String? ?? 'الجزائر',
    address: json['address'] as String? ?? '',
    starRating: json['starRating'] as int? ?? 5,
    userRating: (json['userRating'] as num?)?.toDouble() ?? 9.4,
    reviewCount: json['reviewCount'] as int? ?? 18,
    distanceToCenter: json['distanceToCenter'] as String? ?? '0.5 km from center',
    pricePerNightUSD: (json['pricePerNightUSD'] as num?)?.toDouble() ?? 120.0,
    taxesPerNightUSD: (json['taxesPerNightUSD'] as num?)?.toDouble() ?? 10.0,
    mainCoverImageUrl: json['mainCoverImageUrl'] as String? ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=800&auto=format&fit=crop',
    galleryImages: (json['galleryImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['wifi', 'pool', 'breakfast'],
    descriptionEn: json['descriptionEn'] as String? ?? '',
    descriptionAr: json['descriptionAr'] as String? ?? '',
    checkInTime: json['checkInTime'] as String? ?? '14:00',
    checkOutTime: json['checkOutTime'] as String? ?? '12:00',
    cancellationPolicyEn: json['cancellationPolicyEn'] as String? ?? 'Free cancellation up to 24h prior to check-in.',
    cancellationPolicyAr: json['cancellationPolicyAr'] as String? ?? 'إلغاء مجاني حتى 24 ساعة قبل موعد الوصول.',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 36.7538,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 3.0588,
    rooms: (json['rooms'] as List<dynamic>?)?.map((r) => PartnerRoomType.fromJson(r as Map<String, dynamic>)).toList() ?? [],
    status: PartnerListingStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => PartnerListingStatus.active,
    ),
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now() : DateTime.now(),
  );

  HotelEntity toHotelEntity() {
    return HotelEntity(
      id: id,
      providerName: 'TRAVELGO Direct Partner',
      bookingChannel: BookingChannel.direct,
      nameEn: nameEn,
      nameAr: nameAr,
      cityEn: cityEn,
      cityAr: cityAr,
      countryEn: countryEn,
      countryAr: countryAr,
      address: address,
      starRating: starRating,
      userRating: userRating,
      reviewCount: reviewCount,
      distanceToCenter: distanceToCenter,
      pricePerNightUSD: pricePerNightUSD,
      taxesPerNightUSD: taxesPerNightUSD,
      freeCancellation: true,
      breakfastIncluded: amenities.contains('breakfast'),
      mainImageUrl: mainCoverImageUrl,
      galleryImages: galleryImages.isNotEmpty ? galleryImages : [mainCoverImageUrl],
      amenities: amenities,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      cancellationPolicyEn: cancellationPolicyEn,
      cancellationPolicyAr: cancellationPolicyAr,
      latitude: latitude,
      longitude: longitude,
      rooms: rooms.isNotEmpty
          ? rooms.map((r) => r.toHotelRoomOption()).toList()
          : [
              HotelRoomOption(
                id: '${id}_standard',
                nameEn: 'Deluxe Room',
                nameAr: 'غرفة ديلوكس فاخرة',
                pricePerNightUSD: pricePerNightUSD,
                maxGuests: 2,
                bedType: '1 King Bed',
                breakfastIncluded: amenities.contains('breakfast'),
                freeCancellation: true,
                perks: const ['High Floor View', 'Free WiFi'],
              ),
            ],
    );
  }
}

class HotelPartnerProfile {
  final String id;
  final String ownerName;
  final String businessName;
  final String email;
  final String phone;
  final bool isVerified;
  final double totalEarningsUSD;
  final double pendingPayoutUSD;
  final DateTime joinedAt;

  const HotelPartnerProfile({
    required this.id,
    required this.ownerName,
    required this.businessName,
    required this.email,
    required this.phone,
    this.isVerified = true,
    this.totalEarningsUSD = 1840.0,
    this.pendingPayoutUSD = 620.0,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerName': ownerName,
    'businessName': businessName,
    'email': email,
    'phone': phone,
    'isVerified': isVerified,
    'totalEarningsUSD': totalEarningsUSD,
    'pendingPayoutUSD': pendingPayoutUSD,
    'joinedAt': joinedAt.toIso8601String(),
  };

  factory HotelPartnerProfile.fromJson(Map<String, dynamic> json) => HotelPartnerProfile(
    id: json['id'] as String? ?? 'host_001',
    ownerName: json['ownerName'] as String? ?? 'Tahar Braknia',
    businessName: json['businessName'] as String? ?? 'Braknia Hospitality Group',
    email: json['email'] as String? ?? 'partner@travelgo.app',
    phone: json['phone'] as String? ?? '+213 555 123 456',
    isVerified: json['isVerified'] as bool? ?? true,
    totalEarningsUSD: (json['totalEarningsUSD'] as num?)?.toDouble() ?? 1840.0,
    pendingPayoutUSD: (json['pendingPayoutUSD'] as num?)?.toDouble() ?? 620.0,
    joinedAt: json['joinedAt'] != null ? DateTime.tryParse(json['joinedAt'] as String) ?? DateTime.now() : DateTime.now(),
  );
}

enum PartnerReservationStatus { confirmed, checkedIn, completed, cancelled }

class PartnerReservation {
  final String id;
  final String hotelId;
  final String hotelName;
  final String roomName;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfNights;
  final int numberOfGuests;
  final double totalPriceUSD;
  final double platformFeeUSD;
  final double netHostPayoutUSD;
  final PartnerReservationStatus status;
  final String bookingReference;
  final DateTime bookedAt;

  const PartnerReservation({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.roomName,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfNights,
    required this.numberOfGuests,
    required this.totalPriceUSD,
    this.platformFeeUSD = 1.0,
    required this.netHostPayoutUSD,
    this.status = PartnerReservationStatus.confirmed,
    required this.bookingReference,
    required this.bookedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'hotelId': hotelId,
    'hotelName': hotelName,
    'roomName': roomName,
    'guestName': guestName,
    'guestEmail': guestEmail,
    'guestPhone': guestPhone,
    'checkInDate': checkInDate.toIso8601String(),
    'checkOutDate': checkOutDate.toIso8601String(),
    'numberOfNights': numberOfNights,
    'numberOfGuests': numberOfGuests,
    'totalPriceUSD': totalPriceUSD,
    'platformFeeUSD': platformFeeUSD,
    'netHostPayoutUSD': netHostPayoutUSD,
    'status': status.name,
    'bookingReference': bookingReference,
    'bookedAt': bookedAt.toIso8601String(),
  };

  factory PartnerReservation.fromJson(Map<String, dynamic> json) => PartnerReservation(
    id: json['id'] as String? ?? 'res_${DateTime.now().millisecondsSinceEpoch}',
    hotelId: json['hotelId'] as String? ?? '',
    hotelName: json['hotelName'] as String? ?? 'Partner Hotel',
    roomName: json['roomName'] as String? ?? 'Deluxe Room',
    guestName: json['guestName'] as String? ?? 'Guest Traveler',
    guestEmail: json['guestEmail'] as String? ?? 'traveler@example.com',
    guestPhone: json['guestPhone'] as String? ?? '+213 661 000 000',
    checkInDate: json['checkInDate'] != null ? DateTime.tryParse(json['checkInDate'] as String) ?? DateTime.now() : DateTime.now(),
    checkOutDate: json['checkOutDate'] != null ? DateTime.tryParse(json['checkOutDate'] as String) ?? DateTime.now().add(const Duration(days: 2)) : DateTime.now().add(const Duration(days: 2)),
    numberOfNights: json['numberOfNights'] as int? ?? 2,
    numberOfGuests: json['numberOfGuests'] as int? ?? 2,
    totalPriceUSD: (json['totalPriceUSD'] as num?)?.toDouble() ?? 240.0,
    platformFeeUSD: (json['platformFeeUSD'] as num?)?.toDouble() ?? 1.0,
    netHostPayoutUSD: (json['netHostPayoutUSD'] as num?)?.toDouble() ?? 239.0,
    status: PartnerReservationStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => PartnerReservationStatus.confirmed,
    ),
    bookingReference: json['bookingReference'] as String? ?? 'TRV-HTL-001',
    bookedAt: json['bookedAt'] != null ? DateTime.tryParse(json['bookedAt'] as String) ?? DateTime.now() : DateTime.now(),
  );
}
