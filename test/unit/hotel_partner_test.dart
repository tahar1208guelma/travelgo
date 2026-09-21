import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelgo/core/services/storage_service.dart';
import 'package:travelgo/features/flights/domain/entities/flight_entity.dart';
import 'package:travelgo/features/hotel_partner/data/repositories/hotel_partner_repository.dart';
import 'package:travelgo/features/hotel_partner/domain/entities/hotel_partner_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Hotel Partner Domain Entities Tests', () {
    test('PartnerAmenity default catalog has 16 items and supports Arabic/English', () {
      final catalog = PartnerAmenity.defaultCatalog;
      expect(catalog.length, 16);

      final wifi = catalog.firstWhere((a) => a.id == 'wifi');
      expect(wifi.getName(isArabic: false), 'Free High-Speed WiFi');
      expect(wifi.getName(isArabic: true), 'واي فاي مجاني فائق السرعة');
      expect(wifi.iconName, 'wifi');
    });

    test('PartnerRoomType serialization and toHotelRoomOption() conversion', () {
      const room = PartnerRoomType(
        id: 'rm_test_101',
        hotelId: 'ht_test',
        nameEn: 'Ocean View Suite',
        nameAr: 'جناح بإطلالة المحيط',
        pricePerNightUSD: 250.0,
        maxGuests: 3,
        bedType: '1 King Bed',
        breakfastIncluded: true,
        freeCancellation: true,
        totalUnits: 8,
        availableUnits: 6,
        perks: ['Ocean View', 'Balcony'],
      );

      final json = room.toJson();
      expect(json['id'], 'rm_test_101');
      expect(json['pricePerNightUSD'], 250.0);

      final fromJson = PartnerRoomType.fromJson(json);
      expect(fromJson.nameEn, 'Ocean View Suite');
      expect(fromJson.maxGuests, 3);
      expect(fromJson.perks.length, 2);

      final roomOption = room.toHotelRoomOption();
      expect(roomOption.id, 'rm_test_101');
      expect(roomOption.nameEn, 'Ocean View Suite');
      expect(roomOption.pricePerNightUSD, 250.0);
      expect(roomOption.breakfastIncluded, true);
    });

    test('PartnerHotelListing conversion to HotelEntity with direct booking channel', () {
      final listing = PartnerHotelListing(
        id: 'partner_test_palace',
        ownerPartnerId: 'host_001',
        nameEn: 'Algiers Luxury Palace',
        nameAr: 'قصر الجزائر الفاخر',
        cityEn: 'Algiers',
        cityAr: 'الجزائر العاصمة',
        countryEn: 'Algeria',
        countryAr: 'الجزائر',
        address: '10 Waterfront Road',
        starRating: 5,
        pricePerNightUSD: 180.0,
        mainCoverImageUrl: 'https://example.com/cover.jpg',
        amenities: ['wifi', 'pool', 'breakfast'],
        descriptionEn: 'Luxury hotel description',
        descriptionAr: 'وصف الفندق الفاخر',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(listing.isActive, true);
      expect(listing.getName(isArabic: false), 'Algiers Luxury Palace');
      expect(listing.getName(isArabic: true), 'قصر الجزائر الفاخر');

      final hotelEntity = listing.toHotelEntity();
      expect(hotelEntity.id, 'partner_test_palace');
      expect(hotelEntity.bookingChannel, BookingChannel.direct);
      expect(hotelEntity.providerName, 'TRAVELGO Direct Partner');
      expect(hotelEntity.isDirect, true);
      expect(hotelEntity.isAffiliate, false);
      expect(hotelEntity.breakfastIncluded, true);
    });

    test('PartnerReservation QR check-in status transitions and net payout math', () {
      final reservation = PartnerReservation(
        id: 'res_001',
        hotelId: 'ht_01',
        hotelName: 'Grand Hotel',
        roomName: 'Suite',
        guestName: 'Tahar Braknia',
        guestEmail: 'tahar@travelgo.app',
        guestPhone: '+213555000111',
        checkInDate: DateTime.now(),
        checkOutDate: DateTime.now().add(const Duration(days: 3)),
        numberOfNights: 3,
        numberOfGuests: 2,
        totalPriceUSD: 600.0,
        platformFeeUSD: 1.0,
        netHostPayoutUSD: 599.0,
        bookingReference: 'TRV-ALG-9999',
        bookedAt: DateTime.now(),
      );

      expect(reservation.status, PartnerReservationStatus.confirmed);
      expect(reservation.netHostPayoutUSD, 599.0);
      expect(reservation.totalPriceUSD - reservation.platformFeeUSD, 599.0);

      final json = reservation.toJson();
      final fromJson = PartnerReservation.fromJson(json);
      expect(fromJson.bookingReference, 'TRV-ALG-9999');
      expect(fromJson.guestName, 'Tahar Braknia');
    });
  });

  group('HotelPartnerRepository Integration & Storage Tests', () {
    late StorageService storageService;
    late HotelPartnerRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.init();
      repository = HotelPartnerRepository(storageService);
    });

    test('Loads initial mock profile and hotels when cache is empty', () async {
      final profile = await repository.getProfile();
      expect(profile.isVerified, true);
      expect(profile.totalEarningsUSD, greaterThan(0));

      final hotels = await repository.getPartnerHotels();
      expect(hotels.isNotEmpty, true);
      expect(hotels.first.starRating, 5);
    });

    test('Can save new hotel listing and retrieve it', () async {
      final newHotel = PartnerHotelListing(
        id: 'custom_new_ht_01',
        ownerPartnerId: 'host_001',
        nameEn: 'Constantine Sky Resort',
        nameAr: 'منتجع قسنطينة المعلق',
        cityEn: 'Constantine',
        cityAr: 'قسنطينة',
        countryEn: 'Algeria',
        countryAr: 'الجزائر',
        address: 'Gorges du Rhumel',
        starRating: 5,
        pricePerNightUSD: 220.0,
        mainCoverImageUrl: 'https://example.com/resort.jpg',
        descriptionEn: 'Stunning cliffside resort',
        descriptionAr: 'منتجع معلق على الصخور',
        createdAt: DateTime.now(),
      );

      await repository.saveHotel(newHotel);
      final hotels = await repository.getPartnerHotels();
      expect(hotels.any((h) => h.id == 'custom_new_ht_01'), true);

      final published = await repository.getPublishedHotelEntities();
      expect(published.any((h) => h.id == 'custom_new_ht_01'), true);
    });

    test('Can toggle hotel status and delete hotel', () async {
      final hotels = await repository.getPartnerHotels();
      final firstHotelId = hotels.first.id;

      final toggled = await repository.toggleHotelStatus(firstHotelId);
      expect(toggled?.status, PartnerListingStatus.paused);

      await repository.deleteHotel(firstHotelId);
      final afterDelete = await repository.getPartnerHotels();
      expect(afterDelete.any((h) => h.id == firstHotelId), false);
    });

    test('Verify check-in by booking reference code updates status to checkedIn', () async {
      final reservations = await repository.getReservations();
      expect(reservations.isNotEmpty, true);

      final confirmedRes = reservations.firstWhere((r) => r.status == PartnerReservationStatus.confirmed);
      final verified = await repository.verifyCheckInCode(confirmedRes.bookingReference);

      expect(verified, isNotNull);
      expect(verified!.status, PartnerReservationStatus.checkedIn);

      // Subsequent lookup should confirm the update in repository
      final updatedList = await repository.getReservations();
      final updatedRes = updatedList.firstWhere((r) => r.id == confirmedRes.id);
      expect(updatedRes.status, PartnerReservationStatus.checkedIn);
    });
  });
}
