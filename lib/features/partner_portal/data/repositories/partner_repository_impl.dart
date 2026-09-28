import '../../domain/entities/partner_entity.dart';

abstract class PartnerRepository {
  Future<PartnerUser?> loginPartner(String email, String password);
  Future<PartnerUser> registerPartner({
    required String businessName,
    required String contactName,
    required String email,
    required String phone,
    required PartnerType type,
  });
  Future<List<PartnerListingEntity>> getPartnerListings(String partnerId);
  Future<PartnerListingEntity> addListing(PartnerListingEntity listing);
  Future<List<PartnerBookingRequest>> getPartnerBookings(String partnerId);
  Future<void> updateBookingStatus(String bookingId, PartnerBookingStatus status);

  // Admin Panel Operations
  Future<List<PartnerListingEntity>> getAllPendingAdminListings();
  Future<void> approveListing(String listingId);
  Future<void> rejectListing(String listingId);
}

class PartnerRepositoryImpl implements PartnerRepository {
  PartnerUser? _currentPartner = PartnerUser(
    id: 'prt_001',
    businessName: 'Sahara Luxury Expeditions & Stays',
    contactName: 'Karim Benali',
    email: 'karim@saharatours.dz',
    phone: '+213 555 123 456',
    type: PartnerType.hotelOwner,
    isApprovedByAdmin: true,
    joinedAt: DateTime(2026, 1, 15),
  );

  final List<PartnerListingEntity> _listings = [
    PartnerListingEntity(
      id: 'lst_001',
      partnerId: 'prt_001',
      title: 'Tadrart Rouge Saharan Desert Lodge',
      titleAr: 'نزل تدرارت الحمراء الصحراوي الفاخر',
      description: 'Exclusive eco-luxury desert lodge surrounded by natural red sand arches and deep canyons.',
      category: 'Desert Camp',
      mainImageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=800&q=80',
      pricePerNightUSD: 140.0,
      latitude: 24.5000,
      longitude: 9.7500,
      address: 'Djanet, Tassili n\'Ajjer, Algeria',
      amenities: ['Private Berber Tent', 'Full Board Gourmet Meals', 'Solar Powered AC', 'Stargazing Guide'],
      status: ListingStatus.approved,
      createdAt: DateTime(2026, 3, 1),
    ),
    PartnerListingEntity(
      id: 'lst_002',
      partnerId: 'prt_001',
      title: 'Hoggar Panoramic Mountain Chalet',
      titleAr: 'شاليه جبال الهقار البانورامي',
      description: 'A mountain refuge chalet overlooking the Assekrem summit at 2,700m elevation.',
      category: 'Hotel',
      mainImageUrl: 'https://images.unsplash.com/photo-1547234935-80c7145ec969?w=800&q=80',
      pricePerNightUSD: 165.0,
      latitude: 23.2833,
      longitude: 5.5333,
      address: 'Tamanrasset, Algeria',
      amenities: ['Fireplace', 'Heated Rooms', 'Mountain Hiking Guide', 'Breakfast Included'],
      status: ListingStatus.pendingApproval,
      createdAt: DateTime.now(),
    ),
  ];

  final List<PartnerBookingRequest> _bookings = [
    PartnerBookingRequest(
      id: 'pbk_101',
      listingId: 'lst_001',
      listingTitle: 'Tadrart Rouge Saharan Desert Lodge',
      customerName: 'Sophie Laurent',
      customerEmail: 'sophie.laurent@paris.fr',
      customerPhone: '+33 6 12 34 56 78',
      checkIn: DateTime.now().add(const Duration(days: 12)),
      checkOut: DateTime.now().add(const Duration(days: 15)),
      grossTotalUSD: 420.0, // 3 nights @ $140
      status: PartnerBookingStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    PartnerBookingRequest(
      id: 'pbk_102',
      listingId: 'lst_001',
      listingTitle: 'Tadrart Rouge Saharan Desert Lodge',
      customerName: 'Marcus Vance',
      customerEmail: 'marcus.vance@tech.co.uk',
      customerPhone: '+44 7700 900077',
      checkIn: DateTime.now().add(const Duration(days: 20)),
      checkOut: DateTime.now().add(const Duration(days: 22)),
      grossTotalUSD: 280.0, // 2 nights @ $140
      status: PartnerBookingStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<PartnerUser?> loginPartner(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentPartner;
  }

  @override
  Future<PartnerUser> registerPartner({
    required String businessName,
    required String contactName,
    required String email,
    required String phone,
    required PartnerType type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentPartner = PartnerUser(
      id: 'prt_${DateTime.now().millisecondsSinceEpoch}',
      businessName: businessName,
      contactName: contactName,
      email: email,
      phone: phone,
      type: type,
      isApprovedByAdmin: true,
      joinedAt: DateTime.now(),
    );
    return _currentPartner!;
  }

  @override
  Future<List<PartnerListingEntity>> getPartnerListings(String partnerId) async {
    return _listings.where((l) => l.partnerId == partnerId).toList();
  }

  @override
  Future<PartnerListingEntity> addListing(PartnerListingEntity listing) async {
    _listings.insert(0, listing);
    return listing;
  }

  @override
  Future<List<PartnerBookingRequest>> getPartnerBookings(String partnerId) async {
    return List.unmodifiable(_bookings);
  }

  @override
  Future<void> updateBookingStatus(String bookingId, PartnerBookingStatus status) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: status);
    }
  }

  @override
  Future<List<PartnerListingEntity>> getAllPendingAdminListings() async {
    return _listings.where((l) => l.status == ListingStatus.pendingApproval).toList();
  }

  @override
  Future<void> approveListing(String listingId) async {
    final index = _listings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      _listings[index] = _listings[index].copyWith(status: ListingStatus.approved);
    }
  }

  @override
  Future<void> rejectListing(String listingId) async {
    final index = _listings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      _listings[index] = _listings[index].copyWith(status: ListingStatus.rejected);
    }
  }
}
