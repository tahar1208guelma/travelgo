import 'package:travelgo/features/flights/domain/entities/flight_entity.dart';
import 'package:travelgo/features/hotels/domain/entities/hotel_entity.dart';

enum PartnerListingStatus { active, paused, pendingReview, rejected }

enum PartnerDocumentType {
  commercialRegister,
  tourismLicense,
  taxCertificate,
  propertyDeed,
  legalRepresentativeId,
  liabilityInsurance,
}

enum PartnerRoomCategory {
  standard,
  deluxe,
  executiveSuite,
  familySuite,
  presidentialSuite,
  beachBungalow,
  desertLuxuryCamp,
  privateVilla,
}

extension PartnerRoomCategoryX on PartnerRoomCategory {
  String getDisplayName({bool isArabic = false}) {
    switch (this) {
      case PartnerRoomCategory.standard:
        return isArabic ? 'غرفة قياسية (Standard)' : 'Standard Room';
      case PartnerRoomCategory.deluxe:
        return isArabic ? 'غرفة ديلوكس (Deluxe)' : 'Deluxe Room';
      case PartnerRoomCategory.executiveSuite:
        return isArabic ? 'جناح تنفيذي (Executive Suite)' : 'Executive Suite';
      case PartnerRoomCategory.familySuite:
        return isArabic ? 'جناح عائلي (Family Suite)' : 'Family Suite';
      case PartnerRoomCategory.presidentialSuite:
        return isArabic ? 'جناح رئاسي (Presidential)' : 'Presidential Suite';
      case PartnerRoomCategory.beachBungalow:
        return isArabic ? 'شاليه شاطئي (Beach Bungalow)' : 'Beachfront Bungalow';
      case PartnerRoomCategory.desertLuxuryCamp:
        return isArabic ? 'خيمة صحراوية فاخرة (Desert Camp)' : 'Desert Luxury Tent';
      case PartnerRoomCategory.privateVilla:
        return isArabic ? 'فيلا خاصة مستقلة (Private Villa)' : 'Private Luxury Villa';
    }
  }
}

class PartnerBedTypeCatalog {
  static const List<String> standardBedTypes = [
    '1 King Bed',
    '1 Queen Bed',
    '2 Twin Beds',
    '1 Single Bed',
    '1 King Bed + 1 Sofa Bed',
    '1 Queen Bed + 2 Twin Beds',
    '2 Double Beds',
    'Bunk Beds (4 Guests)',
  ];
}

class PartnerVerificationDocument {
  final String id;
  final PartnerDocumentType type;
  final String documentNumber;
  final String fileName;
  final String? fileUrl;
  final DateTime? expiryDate;
  final DateTime uploadedAt;
  final bool isVerified;
  final String? verificationNote;

  const PartnerVerificationDocument({
    required this.id,
    required this.type,
    required this.documentNumber,
    required this.fileName,
    this.fileUrl,
    this.expiryDate,
    required this.uploadedAt,
    this.isVerified = false,
    this.verificationNote,
  });

  String getDocumentTitle({bool isArabic = false}) {
    switch (type) {
      case PartnerDocumentType.commercialRegister:
        return isArabic ? 'السجل التجاري (Registre de Commerce)' : 'Commercial Registry / Trade License';
      case PartnerDocumentType.tourismLicense:
        return isArabic ? 'رخصة وزارة السياحة والتصنيف' : 'Tourism Ministry Classification License';
      case PartnerDocumentType.taxCertificate:
        return isArabic ? 'شهادة التعريف الجبائي (NIF / TIN)' : 'Tax Identification Number (NIF / TIN)';
      case PartnerDocumentType.propertyDeed:
        return isArabic ? 'عقد الملكية أو عقد الإيجار التجاري' : 'Property Deed or Commercial Lease Contract';
      case PartnerDocumentType.legalRepresentativeId:
        return isArabic ? 'بطاقة هوية / جواز سفر الممثل القانوني' : 'Government ID / Passport of Representative';
      case PartnerDocumentType.liabilityInsurance:
        return isArabic ? 'تأمين المسؤولية المدنية المهنية' : 'Commercial Liability Insurance';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'documentNumber': documentNumber,
    'fileName': fileName,
    'fileUrl': fileUrl,
    'expiryDate': expiryDate?.toIso8601String(),
    'uploadedAt': uploadedAt.toIso8601String(),
    'isVerified': isVerified,
    'verificationNote': verificationNote,
  };

  factory PartnerVerificationDocument.fromJson(Map<String, dynamic> json) => PartnerVerificationDocument(
    id: json['id'] as String? ?? 'doc_${DateTime.now().millisecondsSinceEpoch}',
    type: PartnerDocumentType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => PartnerDocumentType.commercialRegister,
    ),
    documentNumber: json['documentNumber'] as String? ?? '',
    fileName: json['fileName'] as String? ?? 'document.pdf',
    fileUrl: json['fileUrl'] as String?,
    expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate'] as String) : null,
    uploadedAt: json['uploadedAt'] != null ? DateTime.tryParse(json['uploadedAt'] as String) ?? DateTime.now() : DateTime.now(),
    isVerified: json['isVerified'] as bool? ?? false,
    verificationNote: json['verificationNote'] as String?,
  );
}

class SeasonalPriceRule {
  final String id;
  final String hotelId;
  final String nameEn;
  final String nameAr;
  final DateTime startDate;
  final DateTime endDate;
  final double priceMultiplier; // e.g. 1.25 (+25%) or 0.85 (-15%)
  final double? overrideNightlyRateUSD;
  final int minimumStayNights;
  final bool isWeekendSurchargeEnabled;
  final double weekendSurchargePercentage; // e.g. 15.0 for 15%
  final bool isActive;

  const SeasonalPriceRule({
    required this.id,
    required this.hotelId,
    required this.nameEn,
    required this.nameAr,
    required this.startDate,
    required this.endDate,
    this.priceMultiplier = 1.25,
    this.overrideNightlyRateUSD,
    this.minimumStayNights = 1,
    this.isWeekendSurchargeEnabled = true,
    this.weekendSurchargePercentage = 15.0,
    this.isActive = true,
  });

  String getName({bool isArabic = false}) => isArabic ? nameAr : nameEn;

  bool isDateApplicable(DateTime date) {
    if (!isActive) return false;
    final target = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return !target.isBefore(start) && !target.isAfter(end);
  }

  double calculateRateForDate(DateTime date, double basePrice) {
    if (!isDateApplicable(date)) return basePrice;
    double rate = overrideNightlyRateUSD ?? (basePrice * priceMultiplier);
    // Friday (5) or Saturday (6) in weekend models
    if (isWeekendSurchargeEnabled && (date.weekday == DateTime.friday || date.weekday == DateTime.saturday)) {
      rate *= (1.0 + (weekendSurchargePercentage / 100.0));
    }
    return rate;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'hotelId': hotelId,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'priceMultiplier': priceMultiplier,
    'overrideNightlyRateUSD': overrideNightlyRateUSD,
    'minimumStayNights': minimumStayNights,
    'isWeekendSurchargeEnabled': isWeekendSurchargeEnabled,
    'weekendSurchargePercentage': weekendSurchargePercentage,
    'isActive': isActive,
  };

  factory SeasonalPriceRule.fromJson(Map<String, dynamic> json) => SeasonalPriceRule(
    id: json['id'] as String? ?? 'season_${DateTime.now().millisecondsSinceEpoch}',
    hotelId: json['hotelId'] as String? ?? '',
    nameEn: json['nameEn'] as String? ?? 'Peak High Season',
    nameAr: json['nameAr'] as String? ?? 'موسم الذروة الصيفي',
    startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) ?? DateTime.now() : DateTime.now(),
    endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) ?? DateTime.now().add(const Duration(days: 60)) : DateTime.now().add(const Duration(days: 60)),
    priceMultiplier: (json['priceMultiplier'] as num?)?.toDouble() ?? 1.25,
    overrideNightlyRateUSD: (json['overrideNightlyRateUSD'] as num?)?.toDouble(),
    minimumStayNights: json['minimumStayNights'] as int? ?? 1,
    isWeekendSurchargeEnabled: json['isWeekendSurchargeEnabled'] as bool? ?? true,
    weekendSurchargePercentage: (json['weekendSurchargePercentage'] as num?)?.toDouble() ?? 15.0,
    isActive: json['isActive'] as bool? ?? true,
  );
}

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
  final PartnerRoomCategory category;
  final double pricePerNightUSD;
  final int maxGuests;
  final String bedType;
  final bool breakfastIncluded;
  final bool freeCancellation;
  final int totalUnits;
  final int availableUnits;
  final int bookedUnits;
  final List<String> perks;
  final List<String> photos;

  const PartnerRoomType({
    required this.id,
    required this.hotelId,
    required this.nameEn,
    required this.nameAr,
    this.category = PartnerRoomCategory.standard,
    required this.pricePerNightUSD,
    required this.maxGuests,
    required this.bedType,
    this.breakfastIncluded = true,
    this.freeCancellation = true,
    this.totalUnits = 5,
    this.availableUnits = 5,
    this.bookedUnits = 0,
    this.perks = const [],
    this.photos = const [],
  });

  String getName({bool isArabic = false}) => isArabic ? nameAr : nameEn;

  int get remainingAvailableUnits => (totalUnits - bookedUnits).clamp(0, totalUnits);

  Map<String, dynamic> toJson() => {
    'id': id,
    'hotelId': hotelId,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'category': category.name,
    'pricePerNightUSD': pricePerNightUSD,
    'maxGuests': maxGuests,
    'bedType': bedType,
    'breakfastIncluded': breakfastIncluded,
    'freeCancellation': freeCancellation,
    'totalUnits': totalUnits,
    'availableUnits': availableUnits,
    'bookedUnits': bookedUnits,
    'perks': perks,
    'photos': photos,
  };

  factory PartnerRoomType.fromJson(Map<String, dynamic> json) => PartnerRoomType(
    id: json['id'] as String? ?? 'rm_${DateTime.now().millisecondsSinceEpoch}',
    hotelId: json['hotelId'] as String? ?? '',
    nameEn: json['nameEn'] as String? ?? 'Standard Room',
    nameAr: json['nameAr'] as String? ?? 'غرفة قياسية',
    category: PartnerRoomCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => PartnerRoomCategory.standard,
    ),
    pricePerNightUSD: (json['pricePerNightUSD'] as num?)?.toDouble() ?? 100.0,
    maxGuests: json['maxGuests'] as int? ?? 2,
    bedType: json['bedType'] as String? ?? '1 King Bed',
    breakfastIncluded: json['breakfastIncluded'] as bool? ?? true,
    freeCancellation: json['freeCancellation'] as bool? ?? true,
    totalUnits: json['totalUnits'] as int? ?? 5,
    availableUnits: json['availableUnits'] as int? ?? 5,
    bookedUnits: json['bookedUnits'] as int? ?? 0,
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
  final List<SeasonalPriceRule> seasonalRules;
  final List<PartnerVerificationDocument> documents;
  final PartnerListingStatus status;
  final String? adminFeedback;
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
    this.seasonalRules = const [],
    this.documents = const [],
    this.status = PartnerListingStatus.active,
    this.adminFeedback,
    required this.createdAt,
  });

  String getName({bool isArabic = false}) => isArabic ? nameAr : nameEn;
  String getCity({bool isArabic = false}) => isArabic ? cityAr : cityEn;
  String getCountry({bool isArabic = false}) => isArabic ? countryAr : countryEn;
  String getDescription({bool isArabic = false}) => isArabic ? descriptionAr : descriptionEn;

  bool get isActive => status == PartnerListingStatus.active;
  bool get isPendingReview => status == PartnerListingStatus.pendingReview;
  bool get isRejected => status == PartnerListingStatus.rejected;
  bool get isPaused => status == PartnerListingStatus.paused;

  double getEffectivePriceForDate(DateTime date) {
    for (final rule in seasonalRules) {
      if (rule.isDateApplicable(date)) {
        return rule.calculateRateForDate(date, pricePerNightUSD);
      }
    }
    return pricePerNightUSD;
  }

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
    'seasonalRules': seasonalRules.map((s) => s.toJson()).toList(),
    'documents': documents.map((d) => d.toJson()).toList(),
    'status': status.name,
    'adminFeedback': adminFeedback,
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
    seasonalRules: (json['seasonalRules'] as List<dynamic>?)?.map((s) => SeasonalPriceRule.fromJson(s as Map<String, dynamic>)).toList() ?? [],
    documents: (json['documents'] as List<dynamic>?)?.map((d) => PartnerVerificationDocument.fromJson(d as Map<String, dynamic>)).toList() ?? [],
    status: PartnerListingStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => PartnerListingStatus.active,
    ),
    adminFeedback: json['adminFeedback'] as String?,
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now() : DateTime.now(),
  );

  PartnerHotelListing copyWith({
    String? nameEn,
    String? nameAr,
    String? cityEn,
    String? cityAr,
    String? countryEn,
    String? countryAr,
    String? address,
    int? starRating,
    double? pricePerNightUSD,
    double? taxesPerNightUSD,
    String? mainCoverImageUrl,
    List<String>? galleryImages,
    List<String>? amenities,
    String? descriptionEn,
    String? descriptionAr,
    String? checkInTime,
    String? checkOutTime,
    String? cancellationPolicyEn,
    String? cancellationPolicyAr,
    List<PartnerRoomType>? rooms,
    List<SeasonalPriceRule>? seasonalRules,
    List<PartnerVerificationDocument>? documents,
    PartnerListingStatus? status,
    String? adminFeedback,
  }) {
    return PartnerHotelListing(
      id: id,
      ownerPartnerId: ownerPartnerId,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      cityEn: cityEn ?? this.cityEn,
      cityAr: cityAr ?? this.cityAr,
      countryEn: countryEn ?? this.countryEn,
      countryAr: countryAr ?? this.countryAr,
      address: address ?? this.address,
      starRating: starRating ?? this.starRating,
      userRating: userRating,
      reviewCount: reviewCount,
      distanceToCenter: distanceToCenter,
      pricePerNightUSD: pricePerNightUSD ?? this.pricePerNightUSD,
      taxesPerNightUSD: taxesPerNightUSD ?? this.taxesPerNightUSD,
      mainCoverImageUrl: mainCoverImageUrl ?? this.mainCoverImageUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      amenities: amenities ?? this.amenities,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      cancellationPolicyEn: cancellationPolicyEn ?? this.cancellationPolicyEn,
      cancellationPolicyAr: cancellationPolicyAr ?? this.cancellationPolicyAr,
      latitude: latitude,
      longitude: longitude,
      rooms: rooms ?? this.rooms,
      seasonalRules: seasonalRules ?? this.seasonalRules,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      adminFeedback: adminFeedback ?? this.adminFeedback,
      createdAt: createdAt,
    );
  }

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

enum PartnerPayoutMethod {
  bankWire,
  stripeConnect,
  payPal,
  algeriaPostCcp,
}

enum PartnerPayoutStatus {
  pending,
  processed,
  failed,
}

class PartnerPayoutAccount {
  final PartnerPayoutMethod method;
  final String accountHolderName;
  final String accountNumberOrIban;
  final String? bankName;
  final String? swiftBic;
  final String? routingOrCle;

  const PartnerPayoutAccount({
    required this.method,
    required this.accountHolderName,
    required this.accountNumberOrIban,
    this.bankName,
    this.swiftBic,
    this.routingOrCle,
  });

  String getMethodLabel({bool isArabic = false}) {
    switch (method) {
      case PartnerPayoutMethod.bankWire:
        return isArabic ? 'تحويل بنكي مباشر (SWIFT / IBAN)' : 'Direct Bank Wire (IBAN/SWIFT)';
      case PartnerPayoutMethod.stripeConnect:
        return 'Stripe Express Payout';
      case PartnerPayoutMethod.payPal:
        return 'PayPal Business Account';
      case PartnerPayoutMethod.algeriaPostCcp:
        return isArabic ? 'بريد الجزائر (حساب جاري بريدي CCP)' : 'Algerie Poste (CCP Account)';
    }
  }

  Map<String, dynamic> toJson() => {
    'method': method.name,
    'accountHolderName': accountHolderName,
    'accountNumberOrIban': accountNumberOrIban,
    'bankName': bankName,
    'swiftBic': swiftBic,
    'routingOrCle': routingOrCle,
  };

  factory PartnerPayoutAccount.fromJson(Map<String, dynamic> json) => PartnerPayoutAccount(
    method: PartnerPayoutMethod.values.firstWhere(
      (m) => m.name == json['method'],
      orElse: () => PartnerPayoutMethod.bankWire,
    ),
    accountHolderName: json['accountHolderName'] as String? ?? '',
    accountNumberOrIban: json['accountNumberOrIban'] as String? ?? '',
    bankName: json['bankName'] as String?,
    swiftBic: json['swiftBic'] as String?,
    routingOrCle: json['routingOrCle'] as String?,
  );
}

class PartnerPayoutRecord {
  final String id;
  final String partnerId;
  final double amountUSD;
  final PartnerPayoutMethod method;
  final String destinationAccountMasked;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final PartnerPayoutStatus status;
  final String? transactionReference;

  const PartnerPayoutRecord({
    required this.id,
    required this.partnerId,
    required this.amountUSD,
    required this.method,
    required this.destinationAccountMasked,
    required this.requestedAt,
    this.processedAt,
    this.status = PartnerPayoutStatus.pending,
    this.transactionReference,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'partnerId': partnerId,
    'amountUSD': amountUSD,
    'method': method.name,
    'destinationAccountMasked': destinationAccountMasked,
    'requestedAt': requestedAt.toIso8601String(),
    'processedAt': processedAt?.toIso8601String(),
    'status': status.name,
    'transactionReference': transactionReference,
  };

  factory PartnerPayoutRecord.fromJson(Map<String, dynamic> json) => PartnerPayoutRecord(
    id: json['id'] as String? ?? 'pay_${DateTime.now().millisecondsSinceEpoch}',
    partnerId: json['partnerId'] as String? ?? 'host_001',
    amountUSD: (json['amountUSD'] as num?)?.toDouble() ?? 0.0,
    method: PartnerPayoutMethod.values.firstWhere(
      (m) => m.name == json['method'],
      orElse: () => PartnerPayoutMethod.bankWire,
    ),
    destinationAccountMasked: json['destinationAccountMasked'] as String? ?? '****',
    requestedAt: json['requestedAt'] != null ? DateTime.tryParse(json['requestedAt'] as String) ?? DateTime.now() : DateTime.now(),
    processedAt: json['processedAt'] != null ? DateTime.tryParse(json['processedAt'] as String) : null,
    status: PartnerPayoutStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => PartnerPayoutStatus.pending,
    ),
    transactionReference: json['transactionReference'] as String?,
  );
}

class HotelPartnerProfile {
  final String id;
  final String ownerName;
  final String businessName;
  final String email;
  final String phone;
  final bool isVerified;
  final bool isKycSubmitted;
  final double totalEarningsUSD;
  final double pendingPayoutUSD;
  final PartnerPayoutAccount? payoutAccount;
  final DateTime joinedAt;

  const HotelPartnerProfile({
    required this.id,
    required this.ownerName,
    required this.businessName,
    required this.email,
    required this.phone,
    this.isVerified = true,
    this.isKycSubmitted = true,
    this.totalEarningsUSD = 1840.0,
    this.pendingPayoutUSD = 620.0,
    this.payoutAccount,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerName': ownerName,
    'businessName': businessName,
    'email': email,
    'phone': phone,
    'isVerified': isVerified,
    'isKycSubmitted': isKycSubmitted,
    'totalEarningsUSD': totalEarningsUSD,
    'pendingPayoutUSD': pendingPayoutUSD,
    'payoutAccount': payoutAccount?.toJson(),
    'joinedAt': joinedAt.toIso8601String(),
  };

  factory HotelPartnerProfile.fromJson(Map<String, dynamic> json) => HotelPartnerProfile(
    id: json['id'] as String? ?? 'host_001',
    ownerName: json['ownerName'] as String? ?? 'Tahar Braknia',
    businessName: json['businessName'] as String? ?? 'Braknia Hospitality Group',
    email: json['email'] as String? ?? 'partner@travelgo.app',
    phone: json['phone'] as String? ?? '+213 555 123 456',
    isVerified: json['isVerified'] as bool? ?? true,
    isKycSubmitted: json['isKycSubmitted'] as bool? ?? true,
    totalEarningsUSD: (json['totalEarningsUSD'] as num?)?.toDouble() ?? 1840.0,
    pendingPayoutUSD: (json['pendingPayoutUSD'] as num?)?.toDouble() ?? 620.0,
    payoutAccount: json['payoutAccount'] != null ? PartnerPayoutAccount.fromJson(json['payoutAccount'] as Map<String, dynamic>) : null,
    joinedAt: json['joinedAt'] != null ? DateTime.tryParse(json['joinedAt'] as String) ?? DateTime.now() : DateTime.now(),
  );

  HotelPartnerProfile copyWith({
    String? ownerName,
    String? businessName,
    String? email,
    String? phone,
    bool? isVerified,
    bool? isKycSubmitted,
    double? totalEarningsUSD,
    double? pendingPayoutUSD,
    PartnerPayoutAccount? payoutAccount,
  }) {
    return HotelPartnerProfile(
      id: id,
      ownerName: ownerName ?? this.ownerName,
      businessName: businessName ?? this.businessName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isVerified: isVerified ?? this.isVerified,
      isKycSubmitted: isKycSubmitted ?? this.isKycSubmitted,
      totalEarningsUSD: totalEarningsUSD ?? this.totalEarningsUSD,
      pendingPayoutUSD: pendingPayoutUSD ?? this.pendingPayoutUSD,
      payoutAccount: payoutAccount ?? this.payoutAccount,
      joinedAt: joinedAt,
    );
  }
}

enum PartnerReservationStatus { pending, confirmed, checkedIn, completed, cancelled, rejected }

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
  final String? rejectionReason;
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
    this.rejectionReason,
    required this.bookingReference,
    required this.bookedAt,
  });

  bool get isPending => status == PartnerReservationStatus.pending;
  bool get isConfirmed => status == PartnerReservationStatus.confirmed;
  bool get isCheckedIn => status == PartnerReservationStatus.checkedIn;
  bool get isCompleted => status == PartnerReservationStatus.completed;
  bool get isRejected => status == PartnerReservationStatus.rejected;
  bool get isCancelled => status == PartnerReservationStatus.cancelled;

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
    'rejectionReason': rejectionReason,
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
    rejectionReason: json['rejectionReason'] as String?,
    bookingReference: json['bookingReference'] as String? ?? 'TRV-HTL-001',
    bookedAt: json['bookedAt'] != null ? DateTime.tryParse(json['bookedAt'] as String) ?? DateTime.now() : DateTime.now(),
  );

  PartnerReservation copyWith({
    PartnerReservationStatus? status,
    String? rejectionReason,
  }) {
    return PartnerReservation(
      id: id,
      hotelId: hotelId,
      hotelName: hotelName,
      roomName: roomName,
      guestName: guestName,
      guestEmail: guestEmail,
      guestPhone: guestPhone,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      numberOfNights: numberOfNights,
      numberOfGuests: numberOfGuests,
      totalPriceUSD: totalPriceUSD,
      platformFeeUSD: platformFeeUSD,
      netHostPayoutUSD: netHostPayoutUSD,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      bookingReference: bookingReference,
      bookedAt: bookedAt,
    );
  }
}
