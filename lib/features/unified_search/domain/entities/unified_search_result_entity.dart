import 'dart:math';

enum AccommodationType {
  all,
  hotel,
  apartment,
  desertCamp,
  hostel,
  luxuryVilla,
  flight,
  package,
}

enum SearchSortBy {
  relevance,
  priceLowToHigh,
  priceHighToLow,
  rating,
}

class GeoCoordinates {
  final double latitude;
  final double longitude;

  const GeoCoordinates({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() => {'lat': latitude, 'lng': longitude};

  factory GeoCoordinates.fromJson(Map<String, dynamic> json) => GeoCoordinates(
        latitude: (json['lat'] as num).toDouble(),
        longitude: (json['lng'] as num).toDouble(),
      );

  /// Calculates distance in meters using Haversine formula
  double distanceTo(GeoCoordinates other) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((other.latitude - latitude) * p) / 2 +
        cos(latitude * p) *
            cos(other.latitude * p) *
            (1 - cos((other.longitude - longitude) * p)) /
            2;
    return 12742000 * asin(sqrt(a)); // 2 * R * 1000 meters
  }
}

class UnifiedSearchResultEntity {
  final String id;
  final String title;
  final String titleAr;
  final String subtitle;
  final String subtitleAr;
  final String imageUrl;
  final List<String> galleryImages;
  final double price;
  final String currency;
  final double rating;
  final int reviewCount;
  final String source; // 'local_database' | 'amadeus_api' | 'booking_com_affiliate' | 'partner_direct'
  final AccommodationType type;
  final GeoCoordinates coordinates;
  final List<String> amenities;
  final bool freeCancellation;
  final bool breakfastIncluded;
  final double commissionRate; // e.g., 0.12 (12%)
  final String? commissionLink;
  final int loyaltyPointsEarned; // "احجز واكسب نقاط"
  final bool isPartnerVerified;
  final String? providerBookingReference;

  const UnifiedSearchResultEntity({
    required this.id,
    required this.title,
    this.titleAr = '',
    required this.subtitle,
    this.subtitleAr = '',
    required this.imageUrl,
    this.galleryImages = const [],
    required this.price,
    this.currency = 'USD',
    required this.rating,
    this.reviewCount = 0,
    required this.source,
    required this.type,
    required this.coordinates,
    this.amenities = const [],
    this.freeCancellation = true,
    this.breakfastIncluded = false,
    this.commissionRate = 0.12,
    this.commissionLink,
    this.loyaltyPointsEarned = 100,
    this.isPartnerVerified = false,
    this.providerBookingReference,
  });

  String getDisplayTitle(bool isArabic) => (isArabic && titleAr.isNotEmpty) ? titleAr : title;
  String getDisplaySubtitle(bool isArabic) => (isArabic && subtitleAr.isNotEmpty) ? subtitleAr : subtitle;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'titleAr': titleAr,
        'subtitle': subtitle,
        'subtitleAr': subtitleAr,
        'imageUrl': imageUrl,
        'galleryImages': galleryImages,
        'price': price,
        'currency': currency,
        'rating': rating,
        'reviewCount': reviewCount,
        'source': source,
        'type': type.name,
        'coordinates': coordinates.toJson(),
        'amenities': amenities,
        'freeCancellation': freeCancellation,
        'breakfastIncluded': breakfastIncluded,
        'commissionRate': commissionRate,
        'commissionLink': commissionLink,
        'loyaltyPointsEarned': loyaltyPointsEarned,
        'isPartnerVerified': isPartnerVerified,
      };

  factory UnifiedSearchResultEntity.fromJson(Map<String, dynamic> json) => UnifiedSearchResultEntity(
        id: json['id'] as String,
        title: json['title'] as String,
        titleAr: json['titleAr'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        subtitleAr: json['subtitleAr'] as String? ?? '',
        imageUrl: json['imageUrl'] as String,
        galleryImages: (json['galleryImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        price: (json['price'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'USD',
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['reviewCount'] as int? ?? 0,
        source: json['source'] as String? ?? 'local_database',
        type: AccommodationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => AccommodationType.hotel,
        ),
        coordinates: json['coordinates'] != null
            ? GeoCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>)
            : const GeoCoordinates(latitude: 0, longitude: 0),
        amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        freeCancellation: json['freeCancellation'] as bool? ?? true,
        breakfastIncluded: json['breakfastIncluded'] as bool? ?? false,
        commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0.12,
        commissionLink: json['commissionLink'] as String?,
        loyaltyPointsEarned: json['loyaltyPointsEarned'] as int? ?? 100,
        isPartnerVerified: json['isPartnerVerified'] as bool? ?? false,
      );
}

class UnifiedSearchFilters {
  final String query;
  final String destination;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guests;
  final double minPrice;
  final double maxPrice;
  final double minRating;
  final AccommodationType accommodationType;
  final List<String> requiredAmenities;
  final bool freeCancellationOnly;
  final bool breakfastIncludedOnly;
  final SearchSortBy sortBy;

  const UnifiedSearchFilters({
    this.query = '',
    this.destination = '',
    this.checkInDate,
    this.checkOutDate,
    this.guests = 1,
    this.minPrice = 0,
    this.maxPrice = 2000,
    this.minRating = 0,
    this.accommodationType = AccommodationType.all,
    this.requiredAmenities = const [],
    this.freeCancellationOnly = false,
    this.breakfastIncludedOnly = false,
    this.sortBy = SearchSortBy.relevance,
  });

  UnifiedSearchFilters copyWith({
    String? query,
    String? destination,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guests,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    AccommodationType? accommodationType,
    List<String>? requiredAmenities,
    bool? freeCancellationOnly,
    bool? breakfastIncludedOnly,
    SearchSortBy? sortBy,
  }) {
    return UnifiedSearchFilters(
      query: query ?? this.query,
      destination: destination ?? this.destination,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guests: guests ?? this.guests,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      accommodationType: accommodationType ?? this.accommodationType,
      requiredAmenities: requiredAmenities ?? this.requiredAmenities,
      freeCancellationOnly: freeCancellationOnly ?? this.freeCancellationOnly,
      breakfastIncludedOnly: breakfastIncludedOnly ?? this.breakfastIncludedOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  String toCacheKey() {
    return '${query.trim().toLowerCase()}_${destination.trim().toLowerCase()}_${checkInDate?.toIso8601String()}_${checkOutDate?.toIso8601String()}_${guests}_${minPrice}_${maxPrice}_${minRating}_${accommodationType.name}_${freeCancellationOnly}_${breakfastIncludedOnly}_${sortBy.name}';
  }
}
