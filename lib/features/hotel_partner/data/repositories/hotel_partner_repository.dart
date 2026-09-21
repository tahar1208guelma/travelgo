import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../../../hotels/domain/entities/hotel_entity.dart';
import '../../domain/entities/hotel_partner_entity.dart';

final hotelPartnerRepositoryProvider = Provider<HotelPartnerRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return HotelPartnerRepository(storage);
});

class HotelPartnerRepository {
  final StorageService _storage;

  static const String _partnerHotelsKey = 'partner_hotels_cache_v1';
  static const String _partnerProfileKey = 'partner_profile_cache_v1';
  static const String _partnerReservationsKey = 'partner_reservations_cache_v1';

  HotelPartnerRepository(this._storage);

  // Initial Mock Partner Profile
  HotelPartnerProfile _getInitialProfile() {
    return HotelPartnerProfile(
      id: 'host_braknia_001',
      ownerName: 'Tahar Braknia',
      businessName: 'Braknia Hospitality & Resorts',
      email: 'partner.hospitality@travelgo.app',
      phone: '+213 555 789 012',
      isVerified: true,
      totalEarningsUSD: 2450.0,
      pendingPayoutUSD: 780.0,
      joinedAt: DateTime(2025, 11, 15),
    );
  }

  // Initial Mock Partner Hotels
  List<PartnerHotelListing> _getInitialHotels() {
    return [
      PartnerHotelListing(
        id: 'partner_ht_001',
        ownerPartnerId: 'host_braknia_001',
        nameEn: 'El Aurassi Panoramic Palace & Resort',
        nameAr: 'قصر ومنتجع الأوراسي البانورامي',
        cityEn: 'Algiers',
        cityAr: 'الجزائر العاصمة',
        countryEn: 'Algeria',
        countryAr: 'الجزائر',
        address: '2 Boulevard Frantz Fanon, Algiers',
        starRating: 5,
        userRating: 9.6,
        reviewCount: 42,
        distanceToCenter: '0.6 km from center',
        pricePerNightUSD: 195.0,
        taxesPerNightUSD: 15.0,
        mainCoverImageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1000&auto=format&fit=crop',
        galleryImages: const [
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1000&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=1000&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?q=80&w=1000&auto=format&fit=crop',
        ],
        amenities: const [
          'wifi', 'pool', 'breakfast', 'parking', 'gym', 'spa', 'seaview', 'restaurant', 'ac', 'room_service',
        ],
        descriptionEn: 'Perched on the hills overlooking the Mediterranean Bay of Algiers, this 5-star partner palace offers luxury suites, infinity pool, luxury wellness spa, and fine Algerian and international gastronomy.',
        descriptionAr: 'مطل على خليج الجزائر الساحر، يقدم قصر الشريك فئة 5 نجوم أجنحة فخمة، مسبحاً بانورامياً، سبا للاسترخاء وأرقى فنون الطهي الجزائرية والعالمية مع حجز مباشر فوري.',
        checkInTime: '14:00',
        checkOutTime: '12:00',
        cancellationPolicyEn: 'Free cancellation up to 24 hours prior to arrival.',
        cancellationPolicyAr: 'إلغاء مجاني حتى 24 ساعة قبل موعد الوصول.',
        latitude: 36.7725,
        longitude: 3.0543,
        rooms: const [
          PartnerRoomType(
            id: 'rm_aurassi_01',
            hotelId: 'partner_ht_001',
            nameEn: 'Executive Mediterranean Suite',
            nameAr: 'جناح تنفيذي بإطلالة البحر الأبيض المتوسط',
            pricePerNightUSD: 240.0,
            maxGuests: 3,
            bedType: '1 King Bed + 1 Sofa Bed',
            breakfastIncluded: true,
            freeCancellation: true,
            totalUnits: 6,
            availableUnits: 4,
            perks: ['Panoramic Sea View', 'Free VIP Lounge Access', 'Jacuzzi'],
            photos: ['https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=1000&auto=format&fit=crop'],
          ),
          PartnerRoomType(
            id: 'rm_aurassi_02',
            hotelId: 'partner_ht_001',
            nameEn: 'Deluxe City View Room',
            nameAr: 'غرفة ديلوكس بإطلالة المدينة',
            pricePerNightUSD: 195.0,
            maxGuests: 2,
            bedType: '1 King Bed',
            breakfastIncluded: true,
            freeCancellation: true,
            totalUnits: 10,
            availableUnits: 8,
            perks: ['High Floor', 'Free High-Speed WiFi', 'Espresso Machine'],
            photos: ['https://images.unsplash.com/photo-1590490360182-c33d57733427?q=80&w=1000&auto=format&fit=crop'],
          ),
        ],
        status: PartnerListingStatus.active,
        createdAt: DateTime(2025, 12, 1),
      ),
      PartnerHotelListing(
        id: 'partner_ht_002',
        ownerPartnerId: 'host_braknia_001',
        nameEn: 'Les Andalouses Coastal Beach Resort',
        nameAr: 'منتجع شاطئ الأندلسيات الساحلي',
        cityEn: 'Oran',
        cityAr: 'وهران',
        countryEn: 'Algeria',
        countryAr: 'الجزائر',
        address: 'Plage des Andalouses, Oran',
        starRating: 4,
        userRating: 9.3,
        reviewCount: 29,
        distanceToCenter: '18 km from city center',
        pricePerNightUSD: 145.0,
        taxesPerNightUSD: 10.0,
        mainCoverImageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?q=80&w=1000&auto=format&fit=crop',
        galleryImages: const [
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?q=80&w=1000&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?q=80&w=1000&auto=format&fit=crop',
        ],
        amenities: const [
          'wifi', 'pool', 'breakfast', 'parking', 'beach', 'restaurant', 'ac', 'kids_club',
        ],
        descriptionEn: 'Direct beachfront resort in Oran offering golden sand beach access, swimming pools, watersports and family-friendly bungalows.',
        descriptionAr: 'منتجع شاطئي مباشر في وهران يوفر منفذاً خاصاً للرمال الذهبية، مسابح، أنشطة بحرية وشاليهات عائلية مجهزة.',
        checkInTime: '15:00',
        checkOutTime: '11:00',
        cancellationPolicyEn: 'Free cancellation up to 48 hours prior to arrival.',
        cancellationPolicyAr: 'إلغاء مجاني حتى 48 ساعة قبل موعد الوصول.',
        latitude: 35.7350,
        longitude: -0.8667,
        rooms: const [
          PartnerRoomType(
            id: 'rm_oran_01',
            hotelId: 'partner_ht_002',
            nameEn: 'Beachfront Bungalow',
            nameAr: 'شاليه مواجه للشاطئ',
            pricePerNightUSD: 145.0,
            maxGuests: 4,
            bedType: '1 Queen Bed + 2 Twin Beds',
            breakfastIncluded: true,
            freeCancellation: true,
            totalUnits: 8,
            availableUnits: 5,
            perks: ['Direct Beach Access', 'Private Terrace', 'Kitchenette'],
          ),
        ],
        status: PartnerListingStatus.active,
        createdAt: DateTime(2026, 1, 10),
      ),
    ];
  }

  // Initial Mock Reservations
  List<PartnerReservation> _getInitialReservations() {
    final now = DateTime.now();
    return [
      PartnerReservation(
        id: 'res_001',
        hotelId: 'partner_ht_001',
        hotelName: 'El Aurassi Panoramic Palace & Resort',
        roomName: 'Executive Mediterranean Suite',
        guestName: 'Dr. Sarah Amrani',
        guestEmail: 'sarah.amrani@algeriatravel.com',
        guestPhone: '+213 661 234 567',
        checkInDate: now.add(const Duration(days: 1)),
        checkOutDate: now.add(const Duration(days: 4)),
        numberOfNights: 3,
        numberOfGuests: 2,
        totalPriceUSD: 720.0,
        platformFeeUSD: 1.0,
        netHostPayoutUSD: 719.0,
        status: PartnerReservationStatus.confirmed,
        bookingReference: 'TRV-ALG-8891',
        bookedAt: now.subtract(const Duration(days: 2)),
      ),
      PartnerReservation(
        id: 'res_002',
        hotelId: 'partner_ht_001',
        hotelName: 'El Aurassi Panoramic Palace & Resort',
        roomName: 'Deluxe City View Room',
        guestName: 'Karim Mansouri',
        guestEmail: 'k.mansouri@techhub.dz',
        guestPhone: '+213 550 987 654',
        checkInDate: now.subtract(const Duration(days: 1)),
        checkOutDate: now.add(const Duration(days: 2)),
        numberOfNights: 3,
        numberOfGuests: 1,
        totalPriceUSD: 585.0,
        platformFeeUSD: 1.0,
        netHostPayoutUSD: 584.0,
        status: PartnerReservationStatus.checkedIn,
        bookingReference: 'TRV-ALG-4420',
        bookedAt: now.subtract(const Duration(days: 5)),
      ),
      PartnerReservation(
        id: 'res_003',
        hotelId: 'partner_ht_002',
        hotelName: 'Les Andalouses Coastal Beach Resort',
        roomName: 'Beachfront Bungalow',
        guestName: 'Yassine & Amina Benali',
        guestEmail: 'yassine.benali@outlook.com',
        guestPhone: '+213 770 112 233',
        checkInDate: now.add(const Duration(days: 7)),
        checkOutDate: now.add(const Duration(days: 10)),
        numberOfNights: 3,
        numberOfGuests: 4,
        totalPriceUSD: 435.0,
        platformFeeUSD: 1.0,
        netHostPayoutUSD: 434.0,
        status: PartnerReservationStatus.confirmed,
        bookingReference: 'TRV-ORN-1204',
        bookedAt: now.subtract(const Duration(hours: 12)),
      ),
    ];
  }

  // Profile Methods
  Future<HotelPartnerProfile> getProfile() async {
    final raw = _storage.getPartnerProfileJson();
    if (raw == null) {
      final initial = _getInitialProfile();
      await saveProfile(initial);
      return initial;
    }
    try {
      return HotelPartnerProfile.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return _getInitialProfile();
    }
  }

  Future<void> saveProfile(HotelPartnerProfile profile) async {
    await _storage.savePartnerProfileJson(json.encode(profile.toJson()));
  }

  // Hotels Methods
  Future<List<PartnerHotelListing>> getPartnerHotels() async {
    final rawList = _storage.getPartnerHotelsJson();
    if (rawList == null || rawList.isEmpty) {
      final initial = _getInitialHotels();
      await _savePartnerHotels(initial);
      return initial;
    }
    try {
      return rawList.map((e) => PartnerHotelListing.fromJson(json.decode(e) as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getInitialHotels();
    }
  }

  Future<void> _savePartnerHotels(List<PartnerHotelListing> list) async {
    final raw = list.map((e) => json.encode(e.toJson())).toList();
    await _storage.savePartnerHotelsJson(raw);
  }

  Future<void> saveHotel(PartnerHotelListing hotel) async {
    final list = await getPartnerHotels();
    final index = list.indexWhere((h) => h.id == hotel.id);
    if (index >= 0) {
      list[index] = hotel;
    } else {
      list.insert(0, hotel);
    }
    await _savePartnerHotels(list);
  }

  Future<void> deleteHotel(String hotelId) async {
    final list = await getPartnerHotels();
    list.removeWhere((h) => h.id == hotelId);
    await _savePartnerHotels(list);
  }

  Future<PartnerHotelListing?> toggleHotelStatus(String hotelId) async {
    final list = await getPartnerHotels();
    final index = list.indexWhere((h) => h.id == hotelId);
    if (index >= 0) {
      final current = list[index];
      final newStatus = current.status == PartnerListingStatus.active
          ? PartnerListingStatus.paused
          : PartnerListingStatus.active;
      
      final updated = PartnerHotelListing(
        id: current.id,
        ownerPartnerId: current.ownerPartnerId,
        nameEn: current.nameEn,
        nameAr: current.nameAr,
        cityEn: current.cityEn,
        cityAr: current.cityAr,
        countryEn: current.countryEn,
        countryAr: current.countryAr,
        address: current.address,
        starRating: current.starRating,
        userRating: current.userRating,
        reviewCount: current.reviewCount,
        distanceToCenter: current.distanceToCenter,
        pricePerNightUSD: current.pricePerNightUSD,
        taxesPerNightUSD: current.taxesPerNightUSD,
        mainCoverImageUrl: current.mainCoverImageUrl,
        galleryImages: current.galleryImages,
        amenities: current.amenities,
        descriptionEn: current.descriptionEn,
        descriptionAr: current.descriptionAr,
        checkInTime: current.checkInTime,
        checkOutTime: current.checkOutTime,
        cancellationPolicyEn: current.cancellationPolicyEn,
        cancellationPolicyAr: current.cancellationPolicyAr,
        latitude: current.latitude,
        longitude: current.longitude,
        rooms: current.rooms,
        status: newStatus,
        createdAt: current.createdAt,
      );
      list[index] = updated;
      await _savePartnerHotels(list);
      return updated;
    }
    return null;
  }

  // Published hotel entities for search engine
  Future<List<HotelEntity>> getPublishedHotelEntities() async {
    final hotels = await getPartnerHotels();
    return hotels
        .where((h) => h.status == PartnerListingStatus.active)
        .map((h) => h.toHotelEntity())
        .toList();
  }

  // Reservations Methods
  Future<List<PartnerReservation>> getReservations() async {
    final rawList = _storage.getPartnerReservationsJson();
    if (rawList == null || rawList.isEmpty) {
      final initial = _getInitialReservations();
      await _saveReservations(initial);
      return initial;
    }
    try {
      return rawList.map((e) => PartnerReservation.fromJson(json.decode(e) as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getInitialReservations();
    }
  }

  Future<void> _saveReservations(List<PartnerReservation> list) async {
    final raw = list.map((e) => json.encode(e.toJson())).toList();
    await _storage.savePartnerReservationsJson(raw);
  }

  Future<void> addReservation(PartnerReservation reservation) async {
    final list = await getReservations();
    list.insert(0, reservation);
    await _saveReservations(list);
  }

  Future<PartnerReservation?> updateReservationStatus(String reservationId, PartnerReservationStatus newStatus) async {
    final list = await getReservations();
    final index = list.indexWhere((r) => r.id == reservationId);
    if (index >= 0) {
      final current = list[index];
      final updated = PartnerReservation(
        id: current.id,
        hotelId: current.hotelId,
        hotelName: current.hotelName,
        roomName: current.roomName,
        guestName: current.guestName,
        guestEmail: current.guestEmail,
        guestPhone: current.guestPhone,
        checkInDate: current.checkInDate,
        checkOutDate: current.checkOutDate,
        numberOfNights: current.numberOfNights,
        numberOfGuests: current.numberOfGuests,
        totalPriceUSD: current.totalPriceUSD,
        platformFeeUSD: current.platformFeeUSD,
        netHostPayoutUSD: current.netHostPayoutUSD,
        status: newStatus,
        bookingReference: current.bookingReference,
        bookedAt: current.bookedAt,
      );
      list[index] = updated;
      await _saveReservations(list);
      return updated;
    }
    return null;
  }

  // QR / Code Check-in Verification
  Future<PartnerReservation?> verifyCheckInCode(String reference) async {
    final cleanRef = reference.trim().toUpperCase();
    final list = await getReservations();
    final index = list.indexWhere((r) => r.bookingReference.toUpperCase() == cleanRef || r.id.toUpperCase() == cleanRef);
    if (index >= 0) {
      final reservation = list[index];
      if (reservation.status == PartnerReservationStatus.confirmed) {
        return await updateReservationStatus(reservation.id, PartnerReservationStatus.checkedIn);
      }
      return reservation;
    }
    return null;
  }
}
