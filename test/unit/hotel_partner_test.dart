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

    test('PartnerRoomCategory and BedType catalog verification', () {
      expect(PartnerRoomCategory.values.length, 8);
      expect(PartnerRoomCategory.executiveSuite.getDisplayName(isArabic: false), 'Executive Suite');
      expect(PartnerRoomCategory.executiveSuite.getDisplayName(isArabic: true), 'جناح تنفيذي (Executive Suite)');

      expect(PartnerBedTypeCatalog.standardBedTypes.contains('1 King Bed'), true);
      expect(PartnerBedTypeCatalog.standardBedTypes.contains('1 Queen Bed'), true);
    });

    test('PartnerVerificationDocument serialization and localized titles', () {
      final doc = PartnerVerificationDocument(
        id: 'doc_cr_test',
        type: PartnerDocumentType.commercialRegister,
        documentNumber: 'RC-16/00-12345B',
        fileName: 'commerce_license.pdf',
        uploadedAt: DateTime(2026, 1, 1),
        isVerified: true,
        verificationNote: 'Validated against CNRC database',
      );

      expect(doc.getDocumentTitle(isArabic: false), 'Commercial Registry / Trade License');
      expect(doc.getDocumentTitle(isArabic: true), 'السجل التجاري (Registre de Commerce)');

      final json = doc.toJson();
      expect(json['id'], 'doc_cr_test');
      expect(json['type'], 'commercialRegister');

      final fromJson = PartnerVerificationDocument.fromJson(json);
      expect(fromJson.documentNumber, 'RC-16/00-12345B');
      expect(fromJson.isVerified, true);
    });

    test('SeasonalPriceRule dynamic calculation with date ranges and weekend surcharges', () {
      final rule = SeasonalPriceRule(
        id: 'season_summer',
        hotelId: 'ht_001',
        nameEn: 'Peak Summer Season',
        nameAr: 'موسم الصيف السياحي',
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 8, 31),
        priceMultiplier: 1.30, // +30%
        minimumStayNights: 3,
        isWeekendSurchargeEnabled: true,
        weekendSurchargePercentage: 10.0, // +10% on weekends
        isActive: true,
      );

      // Wednesday in July (weekday rate with 30% season multiplier)
      final midWeekDate = DateTime(2026, 7, 15); // Wednesday
      expect(rule.isDateApplicable(midWeekDate), true);
      final midWeekRate = rule.calculateRateForDate(midWeekDate, 100.0);
      expect(midWeekRate, closeTo(130.0, 0.01));

      // Friday in July (weekend rate with 30% multiplier + 10% surcharge)
      final weekendDate = DateTime(2026, 7, 17); // Friday
      expect(rule.isDateApplicable(weekendDate), true);
      final weekendRate = rule.calculateRateForDate(weekendDate, 100.0);
      expect(weekendRate, closeTo(143.0, 0.01)); // 130 * 1.10 = 143

      // Date outside season (November)
      final offSeasonDate = DateTime(2026, 11, 15);
      expect(rule.isDateApplicable(offSeasonDate), false);
      expect(rule.calculateRateForDate(offSeasonDate, 100.0), 100.0);
    });

    test('PartnerRoomType serialization and toHotelRoomOption() conversion', () {
      const room = PartnerRoomType(
        id: 'rm_test_101',
        hotelId: 'ht_test',
        nameEn: 'Ocean View Suite',
        nameAr: 'جناح بإطلالة المحيط',
        category: PartnerRoomCategory.executiveSuite,
        pricePerNightUSD: 250.0,
        maxGuests: 3,
        bedType: '1 King Bed',
        breakfastIncluded: true,
        freeCancellation: true,
        totalUnits: 8,
        availableUnits: 6,
        bookedUnits: 2,
        perks: ['Ocean View', 'Balcony'],
      );

      final json = room.toJson();
      expect(json['id'], 'rm_test_101');
      expect(json['pricePerNightUSD'], 250.0);
      expect(json['category'], 'executiveSuite');

      final fromJson = PartnerRoomType.fromJson(json);
      expect(fromJson.nameEn, 'Ocean View Suite');
      expect(fromJson.maxGuests, 3);
      expect(fromJson.remainingAvailableUnits, 6);
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
        seasonalRules: [
          SeasonalPriceRule(
            id: 'season_1',
            hotelId: 'partner_test_palace',
            nameEn: 'High Season',
            nameAr: 'الموسم المرتفع',
            startDate: DateTime(2026, 7, 1),
            endDate: DateTime(2026, 7, 31),
            priceMultiplier: 1.25,
            isWeekendSurchargeEnabled: false,
          ),
        ],
        documents: [
          PartnerVerificationDocument(
            id: 'doc_1',
            type: PartnerDocumentType.commercialRegister,
            documentNumber: 'RC-123',
            fileName: 'cr.pdf',
            uploadedAt: DateTime.now(),
          ),
        ],
        status: PartnerListingStatus.active,
        createdAt: DateTime(2026, 1, 1),
      );

      expect(listing.isActive, true);
      expect(listing.getName(isArabic: false), 'Algiers Luxury Palace');
      expect(listing.getName(isArabic: true), 'قصر الجزائر الفاخر');
      expect(listing.documents.length, 1);
      expect(listing.seasonalRules.length, 1);

      // Verify dynamic rate resolution
      final peakDate = DateTime(2026, 7, 15);
      expect(listing.getEffectivePriceForDate(peakDate), 225.0); // 180 * 1.25

      final hotelEntity = listing.toHotelEntity();
      expect(hotelEntity.id, 'partner_test_palace');
      expect(hotelEntity.bookingChannel, BookingChannel.direct);
      expect(hotelEntity.providerName, 'TRAVELGO Direct Partner');
      expect(hotelEntity.isDirect, true);
      expect(hotelEntity.isAffiliate, false);
      expect(hotelEntity.breakfastIncluded, true);
    });

    test('PartnerReservation acceptance, rejection, and net payout math', () {
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
        status: PartnerReservationStatus.pending,
        bookingReference: 'TRV-ALG-9999',
        bookedAt: DateTime.now(),
      );

      expect(reservation.isPending, true);
      expect(reservation.netHostPayoutUSD, 599.0);
      expect(reservation.totalPriceUSD - reservation.platformFeeUSD, 599.0);

      // Acceptance
      final accepted = reservation.copyWith(status: PartnerReservationStatus.confirmed);
      expect(accepted.isConfirmed, true);

      // Rejection
      final rejected = reservation.copyWith(
        status: PartnerReservationStatus.rejected,
        rejectionReason: 'Fully booked',
      );
      expect(rejected.isRejected, true);
      expect(rejected.rejectionReason, 'Fully booked');

      final json = reservation.toJson();
      final fromJson = PartnerReservation.fromJson(json);
      expect(fromJson.bookingReference, 'TRV-ALG-9999');
      expect(fromJson.guestName, 'Tahar Braknia');
    });

    test('PartnerPayoutRecord creation and serialization', () {
      final payout = PartnerPayoutRecord(
        id: 'pay_001',
        partnerId: 'host_001',
        amountUSD: 500.0,
        method: PartnerPayoutMethod.algeriaPostCcp,
        destinationAccountMasked: 'CCP ****-82',
        requestedAt: DateTime(2026, 2, 1),
        status: PartnerPayoutStatus.pending,
        transactionReference: 'TRV-CCP-1002',
      );

      final json = payout.toJson();
      expect(json['id'], 'pay_001');
      expect(json['amountUSD'], 500.0);
      expect(json['method'], 'algeriaPostCcp');

      final fromJson = PartnerPayoutRecord.fromJson(json);
      expect(fromJson.transactionReference, 'TRV-CCP-1002');
      expect(fromJson.status, PartnerPayoutStatus.pending);
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

    test('Loads initial mock profile, hotels, and payout records when cache is empty', () async {
      final profile = await repository.getProfile();
      expect(profile.isVerified, true);
      expect(profile.totalEarningsUSD, greaterThan(0));
      expect(profile.payoutAccount, isNotNull);

      final hotels = await repository.getPartnerHotels();
      expect(hotels.isNotEmpty, true);
      expect(hotels.first.starRating, 5);
      expect(hotels.first.documents.isNotEmpty, true);

      final payouts = await repository.getPayoutHistory();
      expect(payouts.isNotEmpty, true);
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
        status: PartnerListingStatus.active,
        createdAt: DateTime.now(),
      );

      await repository.saveHotel(newHotel);
      final hotels = await repository.getPartnerHotels();
      expect(hotels.any((h) => h.id == 'custom_new_ht_01'), true);

      final published = await repository.getPublishedHotelEntities();
      expect(published.any((h) => h.id == 'custom_new_ht_01'), true);
    });

    test('Admin approval workflow: pendingReview -> approved / rejected with feedback', () async {
      final pendingHotel = PartnerHotelListing(
        id: 'ht_pending_approval_01',
        ownerPartnerId: 'host_002',
        nameEn: 'Pending Sahara Lodge',
        nameAr: 'نزل الصحراء للمراجعة',
        cityEn: 'Timimoun',
        cityAr: 'تيميمون',
        countryEn: 'Algeria',
        countryAr: 'الجزائر',
        address: 'Oasis District',
        starRating: 4,
        pricePerNightUSD: 160.0,
        mainCoverImageUrl: 'https://example.com/lodge.jpg',
        descriptionEn: 'Red oasis desert lodge',
        descriptionAr: 'نزل واحة تيميمون الحمراء',
        status: PartnerListingStatus.pendingReview,
        createdAt: DateTime.now(),
      );

      await repository.saveHotel(pendingHotel);

      // Verify it appears in pending approval list
      final pendingList = await repository.getPendingApprovalHotels();
      expect(pendingList.any((h) => h.id == 'ht_pending_approval_01'), true);

      // Reject with feedback
      final rejected = await repository.rejectHotel('ht_pending_approval_01', 'Please provide valid trade license');
      expect(rejected?.status, PartnerListingStatus.rejected);
      expect(rejected?.adminFeedback, 'Please provide valid trade license');

      // Now approve
      final approved = await repository.approveHotel('ht_pending_approval_01');
      expect(approved?.status, PartnerListingStatus.active);
      expect(approved?.adminFeedback, isNull);

      // Now it should be published to search
      final published = await repository.getPublishedHotelEntities();
      expect(published.any((h) => h.id == 'ht_pending_approval_01'), true);
    });

    test('Seasonal rules and document submission integration', () async {
      final hotels = await repository.getPartnerHotels();
      final hotelId = hotels.first.id;

      // Add seasonal rule
      final rule = SeasonalPriceRule(
        id: 'season_autumn_test',
        hotelId: hotelId,
        nameEn: 'Autumn Festival',
        nameAr: 'مهرجان الخريف',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 15),
        priceMultiplier: 1.20,
      );
      await repository.saveSeasonalRule(hotelId, rule);

      final updatedHotels = await repository.getPartnerHotels();
      final target = updatedHotels.firstWhere((h) => h.id == hotelId);
      expect(target.seasonalRules.any((r) => r.id == 'season_autumn_test'), true);

      // Delete seasonal rule
      await repository.deleteSeasonalRule(hotelId, 'season_autumn_test');
      final afterDelete = await repository.getPartnerHotels();
      final targetAfter = afterDelete.firstWhere((h) => h.id == hotelId);
      expect(targetAfter.seasonalRules.any((r) => r.id == 'season_autumn_test'), false);

      // Submit verification document
      final doc = PartnerVerificationDocument(
        id: 'doc_tax_cert',
        type: PartnerDocumentType.taxCertificate,
        documentNumber: 'NIF-001239994',
        fileName: 'Tax_Cert_2026.pdf',
        uploadedAt: DateTime.now(),
      );
      await repository.submitDocument(hotelId, doc);
      final afterDoc = await repository.getPartnerHotels();
      final targetDoc = afterDoc.firstWhere((h) => h.id == hotelId);
      expect(targetDoc.documents.any((d) => d.id == 'doc_tax_cert'), true);
    });

    test('Reservation accept, reject, complete, and QR check-in workflows', () async {
      final reservations = await repository.getReservations();
      expect(reservations.isNotEmpty, true);

      // Accept a pending reservation
      final pendingRes = reservations.firstWhere((r) => r.status == PartnerReservationStatus.pending);
      final accepted = await repository.acceptReservation(pendingRes.id);
      expect(accepted?.status, PartnerReservationStatus.confirmed);

      // Reject a reservation with reason
      final rejected = await repository.rejectReservation(pendingRes.id, 'Overbooked');
      expect(rejected?.status, PartnerReservationStatus.rejected);
      expect(rejected?.rejectionReason, 'Overbooked');

      // Verify QR check-in
      final confirmedRes = reservations.firstWhere((r) => r.status == PartnerReservationStatus.confirmed);
      final verified = await repository.verifyCheckInCode(confirmedRes.bookingReference);
      expect(verified?.status, PartnerReservationStatus.checkedIn);

      // Complete stay & settle host payout
      final initialProfile = await repository.getProfile();
      final initialPendingPayout = initialProfile.pendingPayoutUSD;

      final completed = await repository.completeReservation(confirmedRes.id);
      expect(completed?.status, PartnerReservationStatus.completed);

      final updatedProfile = await repository.getProfile();
      expect(updatedProfile.pendingPayoutUSD, initialPendingPayout + confirmedRes.netHostPayoutUSD);
    });

    test('Payout request reduces pending balance and logs to transaction ledger', () async {
      final profile = await repository.getProfile();
      expect(profile.pendingPayoutUSD, greaterThan(0));

      const account = PartnerPayoutAccount(
        method: PartnerPayoutMethod.algeriaPostCcp,
        accountHolderName: 'Tahar Braknia',
        accountNumberOrIban: '0019283746',
      );

      final record = await repository.requestPayout(
        amountUSD: 200.0,
        account: account,
      );

      expect(record.amountUSD, 200.0);
      expect(record.status, PartnerPayoutStatus.pending);

      final updatedProfile = await repository.getProfile();
      expect(updatedProfile.pendingPayoutUSD, profile.pendingPayoutUSD - 200.0);

      final history = await repository.getPayoutHistory();
      expect(history.any((p) => p.id == record.id), true);
    });
  });
}
