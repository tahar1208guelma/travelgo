import '../../../features/flights/domain/entities/flight_entity.dart';
import '../../../features/flights/domain/entities/flight_search_params.dart';
import '../../../features/hotels/domain/entities/hotel_entity.dart';
import '../../../features/hotels/domain/entities/hotel_search_params.dart';
import '../../../shared/models/airport.dart';
import '../domain/flight_search_provider.dart';
import '../domain/hotel_search_provider.dart';
import '../domain/revalidation_result.dart';

/// SandboxTravelProvider creates realistic, dynamically calculated travel inventory
/// based on genuine Great-Circle airport coordinates, real airlines, realistic flight durations,
/// and legitimate destination hotel properties.
class SandboxTravelProvider implements FlightSearchProvider, HotelSearchProvider {
  @override
  String get providerId => 'sandbox_provider';

  @override
  String get providerName => 'TRAVELGO Global Inventory [Demo/Sandbox]';

  @override
  Duration get timeout => const Duration(seconds: 5);

  static const List<Map<String, String>> _airlines = [
    {
      'code': 'AH',
      'name': 'Air Algérie',
      'logo': 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?q=80&w=200&auto=format&fit=crop',
    },
    {
      'code': 'EK',
      'name': 'Emirates',
      'logo': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?q=80&w=200&auto=format&fit=crop',
    },
    {
      'code': 'TK',
      'name': 'Turkish Airlines',
      'logo': 'https://images.unsplash.com/photo-1520437358207-323b43b50729?q=80&w=200&auto=format&fit=crop',
    },
    {
      'code': 'AF',
      'name': 'Air France',
      'logo': 'https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?q=80&w=200&auto=format&fit=crop',
    },
    {
      'code': 'BA',
      'name': 'British Airways',
      'logo': 'https://images.unsplash.com/photo-1569154941061-e231b4725ef1?q=80&w=200&auto=format&fit=crop',
    },
    {
      'code': 'QR',
      'name': 'Qatar Airways',
      'logo': 'https://images.unsplash.com/photo-1508873696983-2df5293cb395?q=80&w=200&auto=format&fit=crop',
    },
    {
      'code': 'SV',
      'name': 'Saudia',
      'logo': 'https://images.unsplash.com/photo-1583416750470-965b2707b355?q=80&w=200&auto=format&fit=crop',
    },
  ];

  @override
  Future<List<FlightEntity>> searchFlights(FlightSearchParams params) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final origin = Airport.findByCode(params.originCode) ??
        Airport(
          code: params.originCode,
          nameEn: '${params.originCity} Airport',
          nameAr: 'مطار ${params.originCity}',
          cityEn: params.originCity,
          cityAr: params.originCity,
          countryEn: 'International',
          countryAr: 'دولي',
          latitude: 36.69,
          longitude: 3.21,
        );

    final destination = Airport.findByCode(params.destinationCode) ??
        Airport(
          code: params.destinationCode,
          nameEn: '${params.destinationCity} Airport',
          nameAr: 'مطار ${params.destinationCity}',
          cityEn: params.destinationCity,
          cityAr: params.destinationCity,
          countryEn: 'International',
          countryAr: 'دولي',
          latitude: 25.25,
          longitude: 55.36,
        );

    final distanceKm = origin.distanceTo(destination);
    final baseDistance = distanceKm > 0 ? distanceKm : 3000.0;

    // Approximate flight time: ~800 km/h cruising + 40 mins takeoff/landing
    final directMinutes = (baseDistance / 800.0 * 60.0).round() + 40;
    final directDuration = Duration(minutes: directMinutes.clamp(60, 1200));

    // Base price formula: ~$0.08 per km + base fees
    final baseFare = (baseDistance * 0.082).clamp(120.0, 1850.0);
    final taxes = (baseFare * 0.14).roundToDouble();

    final List<FlightEntity> results = [];

    for (var i = 0; i < _airlines.length; i++) {
      final airline = _airlines[i];
      final isDirect = (i % 2 == 0) || (params.directOnly);
      final stops = isDirect ? 0 : 1;
      final duration = isDirect
          ? directDuration
          : Duration(minutes: directDuration.inMinutes + 120 + (i * 15));
      final priceMultiplier = (1.0 + (i * 0.07) - (stops * 0.04));
      final flightBasePrice = (baseFare * priceMultiplier).roundToDouble();
      final flightTotal = flightBasePrice + taxes;

      final depHour = 6 + (i * 2);
      final depTime = DateTime(
        params.departureDate.year,
        params.departureDate.month,
        params.departureDate.day,
        depHour % 24,
        (i * 15) % 60,
      );
      final arrTime = depTime.add(duration);

      final segments = <FlightSegment>[];
      if (stops == 0) {
        segments.add(FlightSegment(
          flightNumber: '${airline['code']}${100 + i * 11}',
          airlineCode: airline['code']!,
          airlineName: airline['name']!,
          airlineLogoUrl: airline['logo']!,
          departureAirportCode: origin.code,
          departureAirportName: origin.nameEn,
          departureCity: origin.cityEn,
          departureTime: depTime,
          arrivalAirportCode: destination.code,
          arrivalAirportName: destination.nameEn,
          arrivalCity: destination.cityEn,
          arrivalTime: arrTime,
          duration: duration,
          aircraftType: i % 2 == 0 ? 'Boeing 787-9' : 'Airbus A350-900',
          cabinClass: params.cabinClass.name,
        ));
      } else {
        final hubCode = airline['code'] == 'TK'
            ? 'IST'
            : airline['code'] == 'EK'
                ? 'DXB'
                : airline['code'] == 'QR'
                    ? 'DOH'
                    : airline['code'] == 'AF'
                        ? 'CDG'
                        : airline['code'] == 'BA'
                            ? 'LHR'
                            : 'ALG';
        final midDuration = Duration(minutes: (duration.inMinutes / 2 - 45).round());
        final layoverDuration = const Duration(minutes: 90);
        final seg1Arrival = depTime.add(midDuration);
        final seg2Departure = seg1Arrival.add(layoverDuration);

        segments.add(FlightSegment(
          flightNumber: '${airline['code']}${200 + i * 11}',
          airlineCode: airline['code']!,
          airlineName: airline['name']!,
          airlineLogoUrl: airline['logo']!,
          departureAirportCode: origin.code,
          departureAirportName: origin.nameEn,
          departureCity: origin.cityEn,
          departureTime: depTime,
          arrivalAirportCode: hubCode,
          arrivalAirportName: '$hubCode International',
          arrivalCity: hubCode,
          arrivalTime: seg1Arrival,
          duration: midDuration,
          aircraftType: 'Airbus A320neo',
          cabinClass: params.cabinClass.name,
        ));

        segments.add(FlightSegment(
          flightNumber: '${airline['code']}${300 + i * 11}',
          airlineCode: airline['code']!,
          airlineName: airline['name']!,
          airlineLogoUrl: airline['logo']!,
          departureAirportCode: hubCode,
          departureAirportName: '$hubCode International',
          departureCity: hubCode,
          departureTime: seg2Departure,
          arrivalAirportCode: destination.code,
          arrivalAirportName: destination.nameEn,
          arrivalCity: destination.cityEn,
          arrivalTime: arrTime,
          duration: midDuration,
          aircraftType: 'Boeing 777-300ER',
          cabinClass: params.cabinClass.name,
        ));
      }

      final isAffiliate = (i % 3 == 2);

      results.add(FlightEntity(
        id: 'fl_${origin.code}_${destination.code}_${airline['code']}_$i',
        providerName: isAffiliate ? 'Skyscanner / Travelpayouts' : providerName,
        bookingChannel: isAffiliate ? BookingChannel.affiliate : BookingChannel.direct,
        affiliateUrl: isAffiliate
            ? 'https://tp.media/r?marker=travelgo&p=4114&u=https%3A%2F%2Fflights.travelpayouts.com%2Fsearch%2F${origin.code}${destination.code}'
            : null,
        airlineName: airline['name']!,
        airlineCode: airline['code']!,
        airlineLogo: airline['logo']!,
        departureAirportCode: origin.code,
        departureCity: origin.cityEn,
        departureTime: depTime,
        arrivalAirportCode: destination.code,
        arrivalCity: destination.cityEn,
        arrivalTime: arrTime,
        totalDuration: duration,
        stops: stops,
        layoverInfo: stops > 0 ? '1 stop in ${segments.first.arrivalAirportCode} (1h 30m)' : null,
        basePriceUSD: flightBasePrice,
        taxesUSD: taxes,
        totalUSD: flightTotal,
        baggageIncluded: i % 4 != 0,
        remainingSeats: 3 + (i % 6),
        segments: segments,
      ));
    }

    if (params.directOnly) {
      return results.where((f) => f.stops == 0).toList();
    }
    return results;
  }

  @override
  Future<FlightEntity?> getFlightDetails(String flightId) async {
    final defaultParams = FlightSearchParams(
      originCode: 'ALG',
      originCity: 'Algiers',
      destinationCode: 'DXB',
      destinationCity: 'Dubai',
      departureDate: DateTime.now().add(const Duration(days: 7)),
    );
    final flights = await searchFlights(defaultParams);
    try {
      return flights.firstWhere((f) => f.id == flightId);
    } catch (_) {
      return flights.isNotEmpty ? flights.first : null;
    }
  }

  @override
  Future<RevalidationResult> revalidateFlight(String flightId, double expectedPriceUSD) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return RevalidationResult(
      status: RevalidationStatus.confirmed,
      itemId: flightId,
      currentPriceUSD: expectedPriceUSD,
      previousPriceUSD: expectedPriceUSD,
      remainingInventory: 4,
      statusMessage: 'Fare and seat verified successfully with inventory authority.',
      verifiedAt: DateTime.now(),
    );
  }

  @override
  Future<List<HotelEntity>> searchHotels(HotelSearchParams params) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final dest = params.destination.trim().isEmpty ? 'Dubai' : params.destination.trim();

    return [
      HotelEntity(
        id: 'ht_${dest.toLowerCase().replaceAll(' ', '_')}_palace',
        providerName: providerName,
        bookingChannel: BookingChannel.direct,
        nameEn: '$dest Grand Palace Hotel & Spa',
        nameAr: 'فندق وسبا $dest جراند بالاس',
        cityEn: dest,
        cityAr: dest,
        countryEn: 'United Arab Emirates',
        countryAr: 'الإمارات العربية المتحدة',
        address: 'Downtown Boulevard, $dest',
        starRating: 5,
        userRating: 9.4,
        reviewCount: 1420,
        distanceToCenter: '0.8 km from center',
        pricePerNightUSD: 245.0,
        taxesPerNightUSD: 24.5,
        freeCancellation: true,
        breakfastIncluded: true,
        mainImageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=600&auto=format&fit=crop',
        galleryImages: [
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=600&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?q=80&w=600&auto=format&fit=crop',
        ],
        amenities: ['Free High-Speed Wi-Fi', 'Infinity Pool', 'Spa & Wellness', 'Valet Parking', 'Airport Shuttle'],
        descriptionEn: 'Luxury 5-star oasis in the heart of $dest featuring panoramic skyline views, award-winning dining, and bespoke concierge service.',
        descriptionAr: 'واحة فاخرة من فئة 5 نجوم في قلب $dest تتميز بإطلالات بانورامية خلابة، ومطاعم حائزة على جوائز، وخدمة كونسيرج مخصصة.',
        latitude: params.latitude ?? 25.1972,
        longitude: params.longitude ?? 55.2744,
        rooms: const [
          HotelRoomOption(
            id: 'rm_dlx_king',
            nameEn: 'Deluxe King Room with City View',
            nameAr: 'غرفة ديلوكس كينغ مع إطلالة على المدينة',
            pricePerNightUSD: 245.0,
            maxGuests: 2,
            bedType: '1 Extra Large Double Bed',
            breakfastIncluded: true,
            freeCancellation: true,
          ),
          HotelRoomOption(
            id: 'rm_exec_suite',
            nameEn: 'Executive Sky Suite',
            nameAr: 'جناح تنفيذي سكاي',
            pricePerNightUSD: 395.0,
            maxGuests: 3,
            bedType: '1 King Bed + 1 Sofa Bed',
            breakfastIncluded: true,
            freeCancellation: true,
          ),
        ],
      ),
      HotelEntity(
        id: 'ht_${dest.toLowerCase().replaceAll(' ', '_')}_resort',
        providerName: 'Booking.com Affiliate Network',
        bookingChannel: BookingChannel.affiliate,
        affiliateUrl: 'https://www.booking.com/searchresults.html?ss=$dest&aid=travelgo_affiliate',
        nameEn: '$dest Waterfront Marina Resort',
        nameAr: 'منتجع مارينا $dest المائي',
        cityEn: dest,
        cityAr: dest,
        countryEn: 'United Arab Emirates',
        countryAr: 'الإمارات العربية المتحدة',
        address: 'Marina Promenade, $dest',
        starRating: 4,
        userRating: 8.9,
        reviewCount: 980,
        distanceToCenter: '2.4 km from center',
        pricePerNightUSD: 165.0,
        taxesPerNightUSD: 16.5,
        freeCancellation: true,
        breakfastIncluded: false,
        mainImageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?q=80&w=600&auto=format&fit=crop',
        galleryImages: [
          'https://images.unsplash.com/photo-1540541338287-41700207dee6?q=80&w=600&auto=format&fit=crop',
        ],
        amenities: ['Private Beach Access', 'Fitness Center', 'Outdoor Pool', '24/7 Room Service'],
        descriptionEn: 'Stylish waterfront resort offering private beach relaxation, modern suites, and easy access to top attractions.',
        descriptionAr: 'منتجع عصري على الواجهة البحرية يوفر شاطئاً خاصاً وأجنحة حديثة مع سهولة الوصول إلى أبرز المعالم السياحية.',
        latitude: params.latitude ?? 25.0805,
        longitude: params.longitude ?? 55.1403,
        rooms: const [
          HotelRoomOption(
            id: 'rm_marina_queen',
            nameEn: 'Superior Marina Queen Room',
            nameAr: 'غرفة سوبيريور مارينا كوين',
            pricePerNightUSD: 165.0,
            maxGuests: 2,
            bedType: '1 Large Double Bed',
            breakfastIncluded: false,
            freeCancellation: true,
          ),
        ],
      ),
      HotelEntity(
        id: 'ht_${dest.toLowerCase().replaceAll(' ', '_')}_boutique',
        providerName: providerName,
        bookingChannel: BookingChannel.direct,
        nameEn: '$dest Heritage Boutique Hotel',
        nameAr: 'فندق $dest التراثي البوتيكي',
        cityEn: dest,
        cityAr: dest,
        countryEn: 'United Arab Emirates',
        countryAr: 'الإمارات العربية المتحدة',
        address: 'Historic Quarter, $dest',
        starRating: 4,
        userRating: 9.1,
        reviewCount: 610,
        distanceToCenter: '1.2 km from center',
        pricePerNightUSD: 125.0,
        taxesPerNightUSD: 12.5,
        freeCancellation: true,
        breakfastIncluded: true,
        mainImageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?q=80&w=600&auto=format&fit=crop',
        galleryImages: [],
        amenities: ['Free Breakfast', 'Free Wi-Fi', 'Rooftop Terrace', 'Boutique Coffee House'],
        descriptionEn: 'Charming boutique property combining traditional heritage architecture with sophisticated modern comfort.',
        descriptionAr: 'فندق بوتيكي ساحر يجمع بين العمارة التراثية الأصيلة والراحة العصرية الراقية.',
        latitude: params.latitude ?? 25.2630,
        longitude: params.longitude ?? 55.3020,
      ),
    ];
  }

  @override
  Future<HotelEntity?> getHotelDetails(String hotelId) async {
    final hotels = await searchHotels(HotelSearchParams(
      destination: 'Dubai',
      checkInDate: DateTime.now().add(const Duration(days: 1)),
      checkOutDate: DateTime.now().add(const Duration(days: 4)),
    ));
    try {
      return hotels.firstWhere((h) => h.id == hotelId);
    } catch (_) {
      return hotels.isNotEmpty ? hotels.first : null;
    }
  }

  @override
  Future<RevalidationResult> revalidateHotel(String hotelId, double expectedPriceUSD) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return RevalidationResult(
      status: RevalidationStatus.confirmed,
      itemId: hotelId,
      currentPriceUSD: expectedPriceUSD,
      previousPriceUSD: expectedPriceUSD,
      remainingInventory: 3,
      statusMessage: 'Room availability and nightly rate verified directly with property authority.',
      verifiedAt: DateTime.now(),
    );
  }
}
