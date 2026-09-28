enum PartnerType { hotelOwner, travelAgency }
enum ListingStatus { pendingApproval, approved, rejected }
enum PartnerBookingStatus { pending, accepted, rejected, completed }

class PartnerListingEntity {
  final String id;
  final String partnerId;
  final String title;
  final String titleAr;
  final String description;
  final String category; // 'Hotel', 'Desert Camp', 'Apartment', 'Tour Package'
  final String mainImageUrl;
  final List<String> images;
  final double pricePerNightUSD;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> amenities;
  final ListingStatus status;
  final DateTime createdAt;

  const PartnerListingEntity({
    required this.id,
    required this.partnerId,
    required this.title,
    this.titleAr = '',
    required this.description,
    required this.category,
    required this.mainImageUrl,
    this.images = const [],
    required this.pricePerNightUSD,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.amenities = const [],
    this.status = ListingStatus.pendingApproval,
    required this.createdAt,
  });

  PartnerListingEntity copyWith({ListingStatus? status}) {
    return PartnerListingEntity(
      id: id,
      partnerId: partnerId,
      title: title,
      titleAr: titleAr,
      description: description,
      category: category,
      mainImageUrl: mainImageUrl,
      images: images,
      pricePerNightUSD: pricePerNightUSD,
      latitude: latitude,
      longitude: longitude,
      address: address,
      amenities: amenities,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

class PartnerBookingRequest {
  final String id;
  final String listingId;
  final String listingTitle;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final DateTime checkIn;
  final DateTime checkOut;
  final double grossTotalUSD;
  final PartnerBookingStatus status;
  final DateTime createdAt;

  const PartnerBookingRequest({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.checkIn,
    required this.checkOut,
    required this.grossTotalUSD,
    this.status = PartnerBookingStatus.pending,
    required this.createdAt,
  });

  // Commission calculations (12% TRAVELGO platform fee)
  double get travelgoCommissionUSD => grossTotalUSD * 0.12;
  double get partnerNetEarningsUSD => grossTotalUSD * 0.88;

  PartnerBookingRequest copyWith({PartnerBookingStatus? status}) {
    return PartnerBookingRequest(
      id: id,
      listingId: listingId,
      listingTitle: listingTitle,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      checkIn: checkIn,
      checkOut: checkOut,
      grossTotalUSD: grossTotalUSD,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

class PartnerUser {
  final String id;
  final String businessName;
  final String contactName;
  final String email;
  final String phone;
  final PartnerType type;
  final bool isApprovedByAdmin;
  final DateTime joinedAt;

  const PartnerUser({
    required this.id,
    required this.businessName,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.type,
    this.isApprovedByAdmin = true,
    required this.joinedAt,
  });
}
