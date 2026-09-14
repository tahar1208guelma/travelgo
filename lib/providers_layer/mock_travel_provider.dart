import 'dart:math';
import 'package:uuid/uuid.dart';
import '../core/constants/app_assets.dart';
import '../features/booking/domain/entities/affiliate_click_entity.dart';
import '../features/booking/domain/entities/booking_entity.dart';
import '../features/flights/domain/entities/flight_entity.dart';
import '../features/flights/domain/entities/flight_search_params.dart';
import '../features/hotels/domain/entities/hotel_entity.dart';
import '../features/hotels/domain/entities/hotel_search_params.dart';
import 'travel_provider.dart';

class MockTravelProvider implements TravelProvider {
  final _uuid = const Uuid();

  @override
  String get providerName => 'TRAVELGO Mock Engine (Sandbox)';

  @override
  Future<List<FlightEntity>> searchFlights(FlightSearchParams params) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final baseFlights = [
      FlightEntity(
        id: 'fl_ek_001',
        providerName: 'Emirates Direct API',
        bookingChannel: BookingChannel.direct,
        airlineName: 'Emirates',
        airlineCode: 'EK',
        airlineLogo: AppAssets.airlineEmirates,
        departureAirportCode: params.originCode,
        departureCity: params.originCity,
        departureTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day, 8, 30),
        arrivalAirportCode: params.destinationCode,
        arrivalCity: params.destinationCity,
        arrivalTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day, 16, 45),
        totalDuration: const Duration(hours: 6, minutes: 15),
        stops: 0,
        basePriceUSD: 320.0 * params.totalPassengers,
        taxesUSD: 45.0 * params.totalPassengers,
        totalUSD: 365.0 * params.totalPassengers,
        baggageIncluded: true,
        remainingSeats: 5,
        segments: [
          FlightSegment(
            flightNumber: 'EK-758',
            airlineCode: 'EK',
            airlineName: 'Emirates',
            airlineLogoUrl: AppAssets.airlineEmirates,
            departureAirportCode: params.originCode,
            departureAirportName: '${params.originCity} Intl Airport',
            departureCity: params.originCity,
            departureTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day, 8, 30),
            arrivalAirportCode: params.destinationCode,
            arrivalAirportName: '${params.destinationCity} Intl Airport',
            arrivalCity: params.destinationCity,
            arrivalTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day, 16, 45),
            duration: const Duration(hours: 6, minutes: 15),
            aircraftType: 'Boeing 777-300ER',
            cabinClass: params.cabinClass.name.toUpperCase(),
          ),
        ],
      ),
      FlightEntity(
        id: 'fl_qr_002',
        providerName: 'Qatar Airways Partner Portal',
        bookingChannel: BookingChannel.affiliate,
        affiliateUrl: 'https://www.qatarairways.com/en/booking.html?aff_id=travelgo_aff_9982',
        airlineName: 'Qatar Airways',
        airlineCode: 'QR',
        airlineLogo: AppAssets.airlineQatar,
        departureAirportCode: params.originCode,
        departureCity: params.originCity,
        departureTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day, 14, 15),
        arrivalAirportCode: params.destinationCode,
        arrivalCity: params.destinationCity,
        arrivalTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day, 23, 30),
        totalDuration: const Duration(hours: 7, minutes: 15),
        stops: 1,
        layoverInfo: '1h 30m at Hamad Intl (DOH)',
        basePriceUSD: 280.0 * params.totalPassengers,
        taxesUSD: 38.0 * params.totalPassengers,
        totalUSD: 318.0 * params.totalPassengers,
        baggageIncluded: true,
        remainingSeats: 9,
      ),
      FlightEntity(
        id: 'fl_tk_003',
        providerName: 'Turkish Airlines Direct',
        bookingChannel: BookingChannel.direct,
        airlineName: 'Turkish Airlines',
        airlineCode: 'TK',
        airlineLogo: AppAssets.airlineTurkish,
        departureAirportCode: params.originCode,
        departureCity: params.originCity,
        departureTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day, 10, 00),
        arrivalAirportCode: params.destinationCode,
        arrivalCity: params.destinationCity,
        arrivalTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day, 18, 20),
        totalDuration: const Duration(hours: 6, minutes: 20),
        stops: 1,
        layoverInfo: '1h 45m at Istanbul (IST)',
        basePriceUSD: 260.0 * params.totalPassengers,
        taxesUSD: 35.0 * params.totalPassengers,
        totalUSD: 295.0 * params.totalPassengers,
        baggageIncluded: true,
        remainingSeats: 4,
      ),
      FlightEntity(
        id: 'fl_ah_004',
        providerName: 'Air Algérie Direct Connect',
        bookingChannel: BookingChannel.direct,
        airlineName: 'Air Algérie',
        airlineCode: 'AH',
        airlineLogo: AppAssets.airlineAirAlgerie,
        departureAirportCode: params.originCode,
        departureCity: params.originCity,
        departureTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day, 19, 00),
        arrivalAirportCode: params.destinationCode,
        arrivalCity: params.destinationCity,
        arrivalTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day, 23, 50),
        totalDuration: const Duration(hours: 4, minutes: 50),
        stops: 0,
        basePriceUSD: 210.0 * params.totalPassengers,
        taxesUSD: 25.0 * params.totalPassengers,
        totalUSD: 235.0 * params.totalPassengers,
        baggageIncluded: true,
        remainingSeats: 12,
      ),
      FlightEntity(
        id: 'fl_sv_005',
        providerName: 'Saudia Partner Network',
        bookingChannel: BookingChannel.affiliate,
        affiliateUrl: 'https://www.saudia.com/?partner=travelgo_aff_sv',
        airlineName: 'Saudia',
        airlineCode: 'SV',
        airlineLogo: AppAssets.airlineSaudia,
        departureAirportCode: params.originCode,
        departureCity: params.originCity,
        departureTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day, 22, 30),
        arrivalAirportCode: params.destinationCode,
        arrivalCity: params.destinationCity,
        arrivalTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day + 1, 7, 10),
        totalDuration: const Duration(hours: 6, minutes: 40),
        stops: 0,
        basePriceUSD: 295.0 * params.totalPassengers,
        taxesUSD: 40.0 * params.totalPassengers,
        totalUSD: 335.0 * params.totalPassengers,
        baggageIncluded: true,
        remainingSeats: 8,
      ),
      FlightEntity(
        id: 'fl_ba_006',
        providerName: 'British Airways Direct',
        bookingChannel: BookingChannel.direct,
        airlineName: 'British Airways',
        airlineCode: 'BA',
        airlineLogo: AppAssets.airlineBritishAirways,
        departureAirportCode: params.originCode,
        departureCity: params.originCity,
        departureTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day, 6, 15),
        arrivalAirportCode: params.destinationCode,
        arrivalCity: params.destinationCity,
        arrivalTime: DateTime(params.departureDate.year, params.departureDate.month, params.departureDate.day, 13, 30),
        totalDuration: const Duration(hours: 7, minutes: 15),
        stops: 1,
        layoverInfo: '2h 10m at London Heathrow (LHR)',
        basePriceUSD: 390.0 * params.totalPassengers,
        taxesUSD: 52.0 * params.totalPassengers,
        totalUSD: 442.0 * params.totalPassengers,
        baggageIncluded: true,
        remainingSeats: 3,
      ),
    ];

    if (params.directOnly) {
      return baseFlights.where((f) => f.stops == 0).toList();
    }

    return baseFlights;
  }

  @override
  Future<FlightEntity?> getFlightDetails(String flightId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final sampleParams = FlightSearchParams(
      originCode: 'ALG',
      originCity: 'Algiers',
      destinationCode: 'DXB',
      destinationCity: 'Dubai',
      departureDate: DateTime.now().add(const Duration(days: 7)),
    );
    final flights = await searchFlights(sampleParams);
    return flights.firstWhere((f) => f.id == flightId, orElse: () => flights.first);
  }

  @override
  Future<List<HotelEntity>> searchHotels(HotelSearchParams params) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final mockHotels = [
      HotelEntity(
        id: 'ht_dubai_001',
        providerName: 'Direct Luxury Gateway',
        bookingChannel: BookingChannel.direct,
        nameEn: 'Burj Al Arab Jumeirah',
        nameAr: 'برج العرب جميرا',
        cityEn: 'Dubai',
        cityAr: 'دبي',
        countryEn: 'United Arab Emirates',
        countryAr: 'الإمارات العربية المتحدة',
        address: 'Jumeirah Beach Road, Dubai',
        starRating: 5,
        userRating: 9.6,
        reviewCount: 2480,
        distanceToCenter: '2.5 km',
        pricePerNightUSD: 850.0,
        taxesPerNightUSD: 45.0,
        freeCancellation: true,
        breakfastIncluded: true,
        mainImageUrl: AppAssets.hotelBurjAlArab,
        galleryImages: [
          AppAssets.hotelBurjAlArab,
          AppAssets.destDubai,
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?q=80&w=800&auto=format&fit=crop',
        ],
        amenities: ['Free High-Speed WiFi', 'Private Beach', 'Infinity Pool', 'Luxury Spa', 'Fine Dining', 'Helipad', 'Butler Service'],
        descriptionEn: 'An icon of Arabian luxury, featuring ultra-luxurious duplex suites with private check-in, private beach, and world-renowned dining.',
        descriptionAr: 'أيقونة الفخامة العربية العالمية، يوفر أجنحة فاخرة دوبلكس مع خدمة تسجيل وصول خاصة، شاطئ خاص، وأرقى المطاعم العالمية.',
        rooms: [
          const HotelRoomOption(
            id: 'room_01',
            nameEn: 'Deluxe One-Bedroom Suite',
            nameAr: 'جناح ديلوكس بغرفة نوم واحدة',
            pricePerNightUSD: 850.0,
            maxGuests: 3,
            bedType: '1 King Bed',
            breakfastIncluded: true,
            freeCancellation: true,
            perks: ['Ocean View', 'Hermès Amenities', 'Jacuzzi'],
          ),
          const HotelRoomOption(
            id: 'room_02',
            nameEn: 'Panoramic Suite',
            nameAr: 'جناح بانورامي فاخر',
            pricePerNightUSD: 1200.0,
            maxGuests: 4,
            bedType: '2 King Beds',
            breakfastIncluded: true,
            freeCancellation: true,
            perks: ['360 Arabian Sea View', 'Private Bar', 'Airport Chauffeur'],
          ),
        ],
      ),
      HotelEntity(
        id: 'ht_paris_002',
        providerName: 'Booking.com Affiliate Network',
        bookingChannel: BookingChannel.affiliate,
        affiliateUrl: 'https://www.booking.com/hotel/fr/ritz-paris.html?aid=travelgo_aff_2026',
        nameEn: 'Ritz Paris Hotel & Spa',
        nameAr: 'فندق ريتز باريس والسبا',
        cityEn: 'Paris',
        cityAr: 'باريس',
        countryEn: 'France',
        countryAr: 'فرنسا',
        address: '15 Place Vendôme, 75001 Paris',
        starRating: 5,
        userRating: 9.5,
        reviewCount: 1890,
        distanceToCenter: '0.8 km',
        pricePerNightUSD: 680.0,
        taxesPerNightUSD: 35.0,
        freeCancellation: true,
        breakfastIncluded: true,
        mainImageUrl: AppAssets.hotelRitzParis,
        galleryImages: [
          AppAssets.hotelRitzParis,
          AppAssets.destParis,
        ],
        amenities: ['Free WiFi', 'Indoor Heated Pool', 'Chanel Spa', 'Michelin Restaurant', 'Concierge 24/7'],
        descriptionEn: 'Located in the heart of Paris on Place Vendôme, the Ritz Paris offers neoclassical elegance and unparalleled French hospitality.',
        descriptionAr: 'يقع في قلب ساحة فاندوم الأسطورية، ويقدم أرقى درجات الفخامة الكلاسيكية والضيافة الفرنسية الأصيلة.',
      ),
      HotelEntity(
        id: 'ht_ist_003',
        providerName: 'Direct Luxury Gateway',
        bookingChannel: BookingChannel.direct,
        nameEn: 'Çırağan Palace Kempinski',
        nameAr: 'قصر شيراغان كمبينسكي',
        cityEn: 'Istanbul',
        cityAr: 'إسطنبول',
        countryEn: 'Turkey',
        countryAr: 'تركيا',
        address: 'Çırağan Cd. No:32, Beşiktaş, Istanbul',
        starRating: 5,
        userRating: 9.4,
        reviewCount: 3120,
        distanceToCenter: '3.2 km',
        pricePerNightUSD: 390.0,
        taxesPerNightUSD: 20.0,
        freeCancellation: true,
        breakfastIncluded: true,
        mainImageUrl: AppAssets.hotelCiraganPalace,
        galleryImages: [
          AppAssets.hotelCiraganPalace,
          AppAssets.destIstanbul,
        ],
        amenities: ['Bosphorus View', 'Infinity Pool', 'Ottoman Spa', 'Helicopter Transfer', 'Free Valet'],
        descriptionEn: 'A restored 19th-century Ottoman palace on the Bosphorus Strait offering majestic waterside rooms and regal service.',
        descriptionAr: 'قصر عثماني تاريخي مرمم يعود للقرن التاسع عشر على ضفاف مضيق البوسفور، يقدم إطلالات ساحرة وخدمة ملكية.',
        rooms: [
          const HotelRoomOption(
            id: 'room_ist_01',
            nameEn: 'Superior Bosphorus View Room',
            nameAr: 'غرفة سوبيريور بإطلالة على البوسفور',
            pricePerNightUSD: 390.0,
            maxGuests: 2,
            bedType: '1 King or 2 Twin',
            breakfastIncluded: true,
            freeCancellation: true,
            perks: ['Balcony', 'Marble Bathroom', 'Complimentary Tea Service'],
          ),
        ],
      ),
      HotelEntity(
        id: 'ht_alg_004',
        providerName: 'Direct Booking Partner',
        bookingChannel: BookingChannel.direct,
        nameEn: 'Hotel El Aurassi',
        nameAr: 'فندق الأوراسي',
        cityEn: 'Algiers',
        cityAr: 'الجزائر العاصمة',
        countryEn: 'Algeria',
        countryAr: 'الجزائر',
        address: '2 Boulevard Frantz Fanon, Algiers',
        starRating: 5,
        userRating: 8.9,
        reviewCount: 1450,
        distanceToCenter: '1.0 km',
        pricePerNightUSD: 165.0,
        taxesPerNightUSD: 10.0,
        freeCancellation: true,
        breakfastIncluded: true,
        mainImageUrl: AppAssets.hotelElAurassi,
        galleryImages: [
          AppAssets.hotelElAurassi,
          AppAssets.destAlgiers,
        ],
        amenities: ['Bay of Algiers View', 'Outdoor Pool', 'Tennis Courts', 'Conference Center', 'Free Airport Shuttle'],
        descriptionEn: 'Perched over the Mediterranean with sweeping panoramic views of the Bay of Algiers and premium business hospitality.',
        descriptionAr: 'يتميز بإطلالة بانورامية رائعة على خليج الجزائر والبحر الأبيض المتوسط، مع خدمات فندقية راقية ومرافق متكاملة.',
        rooms: [
          const HotelRoomOption(
            id: 'room_alg_01',
            nameEn: 'Executive Sea View Room',
            nameAr: 'غرفة تنفيذية مطلة على البحر',
            pricePerNightUSD: 165.0,
            maxGuests: 2,
            bedType: '1 King Bed',
            breakfastIncluded: true,
            freeCancellation: true,
            perks: ['Sea View Balcony', 'High-Speed WiFi', 'Buffet Breakfast'],
          ),
        ],
      ),
      HotelEntity(
        id: 'ht_ruh_005',
        providerName: 'Four Seasons Direct Connect',
        bookingChannel: BookingChannel.direct,
        nameEn: 'Four Seasons Hotel Riyadh',
        nameAr: 'فندق فور سيزونز الرياض',
        cityEn: 'Riyadh',
        cityAr: 'الرياض',
        countryEn: 'Saudi Arabia',
        countryAr: 'المملكة العربية السعودية',
        address: 'Kingdom Tower, Olaya, Riyadh',
        starRating: 5,
        userRating: 9.3,
        reviewCount: 2200,
        distanceToCenter: '1.5 km',
        pricePerNightUSD: 460.0,
        taxesPerNightUSD: 30.0,
        freeCancellation: true,
        breakfastIncluded: true,
        mainImageUrl: AppAssets.hotelFourSeasonsRiyadh,
        galleryImages: [
          AppAssets.hotelFourSeasonsRiyadh,
          AppAssets.destRiyadh,
        ],
        amenities: ['Kingdom Center View', 'Luxury Spa', 'Outdoor Pool', 'Squash Courts', 'Valet Parking'],
        descriptionEn: 'Located inside the Kingdom Tower with breathtaking skyline views and world-class luxury in the heart of Riyadh.',
        descriptionAr: 'يقع داخل برج المملكة الشهير ويوفر إطلالات خلابة على أفق مدينة الرياض مع أرقى معايير الضيافة العالمية.',
        rooms: [
          const HotelRoomOption(
            id: 'room_ruh_01',
            nameEn: 'Premier Room',
            nameAr: 'غرفة بريميير فاخرة',
            pricePerNightUSD: 460.0,
            maxGuests: 2,
            bedType: '1 King Bed',
            breakfastIncluded: true,
            freeCancellation: true,
            perks: ['High Floor Skyline View', 'Marble Bath', '24h Room Service'],
          ),
        ],
      ),
    ];

    return mockHotels;
  }

  @override
  Future<HotelEntity?> getHotelDetails(String hotelId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final sampleParams = HotelSearchParams(
      destination: 'Dubai',
      checkInDate: DateTime.now().add(const Duration(days: 5)),
      checkOutDate: DateTime.now().add(const Duration(days: 9)),
    );
    final hotels = await searchHotels(sampleParams);
    return hotels.firstWhere((h) => h.id == hotelId, orElse: () => hotels.first);
  }

  @override
  Future<BookingEntity> createDirectBooking(DirectBookingRequest request) async {
    await Future.delayed(const Duration(milliseconds: 1200)); // Simulate payment gateway & PNR creation

    final pnr = 'TG${(100000 + Random().nextInt(900000))}';
    return BookingEntity(
      id: 'bk_${_uuid.v4().substring(0, 8)}',
      userId: request.userId,
      provider: providerName,
      bookingType: request.bookingType,
      status: BookingStatus.confirmed,
      externalBookingReference: pnr,
      itemName: request.itemName,
      itemSubtitle: request.itemSubtitle,
      itemImageUrl: request.itemImageUrl,
      startDate: request.startDate,
      endDate: request.endDate,
      basePriceUSD: request.basePriceUSD,
      taxesUSD: request.taxesUSD,
      serviceFeeUSD: request.serviceFeeUSD, // $1.00 USD
      totalAmountUSD: request.totalAmountUSD,
      passengerOrGuestName: request.passengerOrGuestName,
      contactEmail: request.contactEmail,
      contactPhone: request.contactPhone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<AffiliateClickEntity> generateAffiliateLink({
    required String userId,
    required String productType,
    required String productId,
    required String rawTargetUrl,
  }) async {
    final trackingId = 'trk_${_uuid.v4().substring(0, 10)}';
    final affiliateUrl = '$rawTargetUrl&travelgo_click_id=$trackingId&ts=${DateTime.now().millisecondsSinceEpoch}';

    return AffiliateClickEntity(
      id: 'aff_${_uuid.v4().substring(0, 8)}',
      userId: userId,
      provider: 'Official Affiliate Partner',
      productType: productType,
      productId: productId,
      trackingId: trackingId,
      targetUrl: affiliateUrl,
      clickedAt: DateTime.now(),
    );
  }
}
