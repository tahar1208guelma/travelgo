import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/search/adapters/amadeus_flight_provider.dart';
import 'package:travelgo/core/search/adapters/duffel_flight_provider.dart';
import 'package:travelgo/core/search/adapters/sandbox_travel_provider.dart';
import 'package:travelgo/core/search/adapters/travelpayouts_affiliate_provider.dart';
import 'package:travelgo/core/search/adapters/travelpayouts_hotel_provider.dart';
import 'package:travelgo/core/search/domain/flight_search_provider.dart';
import 'package:travelgo/core/search/domain/hotel_search_provider.dart';
import 'package:travelgo/core/search/domain/revalidation_result.dart';
import 'package:travelgo/core/search/services/city_airports_resolver.dart';
import 'package:travelgo/core/search/services/flight_deduplicator.dart';
import 'package:travelgo/core/search/services/flight_search_aggregator.dart';
import 'package:travelgo/core/search/services/hotel_deduplicator.dart';
import 'package:travelgo/core/search/services/hotel_search_aggregator.dart';
import 'package:travelgo/features/flights/domain/entities/flight_entity.dart';
import 'package:travelgo/features/flights/domain/entities/flight_search_params.dart';
import 'package:travelgo/features/flights/presentation/controllers/flight_search_controller.dart';
import 'package:travelgo/features/hotels/domain/entities/hotel_entity.dart';
import 'package:travelgo/features/hotels/domain/entities/hotel_search_params.dart';
import 'package:travelgo/shared/models/airport.dart';

class FailingFlightTestProvider implements FlightSearchProvider {
  @override
  String get providerId => 'failing_flight_test';
  @override
  String get providerName => 'Failing Flaky Provider';
  @override
  Duration get timeout => const Duration(milliseconds: 80);

  @override
  Future<List<FlightEntity>> searchFlights(FlightSearchParams params) async {
    throw Exception('Connection timeout: Gateway unavailable');
  }

  @override
  Future<FlightEntity?> getFlightDetails(String flightId) async => null;

  @override
  Future<RevalidationResult> revalidateFlight(String flightId, double expectedPriceUSD) async {
    throw Exception('Revalidation failure');
  }
}

class FailingHotelTestProvider implements HotelSearchProvider {
  @override
  String get providerId => 'failing_hotel_test';
  @override
  String get providerName => 'Failing Hotel Test Provider';
  @override
  Duration get timeout => const Duration(milliseconds: 80);

  @override
  Future<List<HotelEntity>> searchHotels(HotelSearchParams params) async {
    throw Exception('Server 503 Service Unavailable');
  }

  @override
  Future<HotelEntity?> getHotelDetails(String hotelId) async => null;

  @override
  Future<RevalidationResult> revalidateHotel(String hotelId, double expectedPriceUSD) async {
    throw Exception('Revalidation failure');
  }
}

void main() {
  group('1. Multi-Airport City Mapping & Nearby Airports (+150km)', () {
    const resolver = CityAirportsResolver();

    test('Identifies major metropolitan multi-airport city codes accurately', () {
      expect(resolver.isMultiAirportCity('LON'), isTrue);
      expect(resolver.isMultiAirportCity('NYC'), isTrue);
      expect(resolver.isMultiAirportCity('PAR'), isTrue);
      expect(resolver.isMultiAirportCity('DXB'), isTrue);
      expect(resolver.isMultiAirportCity('TYO'), isTrue);
      expect(resolver.isMultiAirportCity('ROM'), isTrue);
      expect(resolver.isMultiAirportCity('MIL'), isTrue);
      expect(resolver.isMultiAirportCity('CHI'), isTrue);
      expect(resolver.isMultiAirportCity('WAS'), isTrue);
      expect(resolver.isMultiAirportCity('ALG'), isFalse); // Single primary international hub
    });

    test('Resolves LON to Heathrow (LHR), Gatwick (LGW), Stansted (STN), Luton (LTN), City (LCY)', () {
      final lonAirports = resolver.resolveAirportCodes('LON');
      expect(lonAirports, contains('LHR'));
      expect(lonAirports, contains('LGW'));
      expect(lonAirports, contains('STN'));
      expect(lonAirports, contains('LTN'));
      expect(lonAirports, contains('LCY'));
    });

    test('Resolves NYC to JFK, EWR, LGA', () {
      final nycAirports = resolver.resolveAirportCodes('NYC');
      expect(nycAirports, contains('JFK'));
      expect(nycAirports, contains('EWR'));
      expect(nycAirports, contains('LGA'));
    });

    test('Resolves PAR to CDG, ORY, BVA', () {
      final parAirports = resolver.resolveAirportCodes('PAR');
      expect(parAirports, contains('CDG'));
      expect(parAirports, contains('ORY'));
      expect(parAirports, contains('BVA'));
    });

    test('Resolves DXB to DXB and DWC', () {
      final dxbAirports = resolver.resolveAirportCodes('DXB');
      expect(dxbAirports, contains('DXB'));
      expect(dxbAirports, contains('DWC'));
    });

    test('Resolves TYO to HND and NRT', () {
      final tyoAirports = resolver.resolveAirportCodes('TYO');
      expect(tyoAirports, contains('HND'));
      expect(tyoAirports, contains('NRT'));
    });

    test('Discovers nearby airports within +150 km using Haversine formula', () {
      final cdg = Airport.findByCode('CDG')!;
      final nearbyToCdg = cdg.getNearbyAirports(radiusKm: 150.0);

      expect(nearbyToCdg.any((a) => a.code == 'ORY'), isTrue, reason: 'Orly is ~35km from CDG');
      expect(nearbyToCdg.any((a) => a.code == 'BVA'), isTrue, reason: 'Beauvais is ~70km from CDG');
      expect(nearbyToCdg.any((a) => a.code == 'DXB'), isFalse, reason: 'Dubai is >5000km away');
    });

    test('Retrieves sister airports for a single airport code', () {
      final sisters = resolver.getSisterAirports('LHR');
      final codes = sisters.map((a) => a.code).toList();
      expect(codes, contains('LGW'));
      expect(codes, contains('STN'));
    });
  });

  group('2. Duffel NDC Flight Provider & External Adapters', () {
    test('DuffelFlightProvider adheres to zero client secrets and valid provider metadata', () {
      final duffel = DuffelFlightProvider();
      expect(duffel.providerId, 'duffel_ndc');
      expect(duffel.providerName, 'Duffel NDC Direct');
      expect(duffel.timeout.inSeconds, lessThanOrEqualTo(8));
      expect(duffel.backendBaseUrl, contains('api.travelgo.app'));
    });

    test('DuffelFlightProvider generates realistic NDC flight content in offline/demo mode', () async {
      final duffel = DuffelFlightProvider();
      final params = FlightSearchParams(
        originCode: 'LHR',
        originCity: 'London',
        destinationCode: 'DXB',
        destinationCity: 'Dubai',
        departureDate: DateTime.now().add(const Duration(days: 10)),
      );

      final offers = await duffel.searchFlights(params);
      expect(offers.isNotEmpty, isTrue);
      final offer = offers.first;
      expect(offer.airlineCode, 'BA');
      expect(offer.airlineName, 'British Airways');
      expect(offer.bookingChannel, BookingChannel.direct);
      expect(offer.segments.isNotEmpty, isTrue);
      expect(offer.totalUSD, greaterThan(100.0));
    });

    test('DuffelFlightProvider confirms inventory via revalidation', () async {
      final duffel = DuffelFlightProvider();
      final result = await duffel.revalidateFlight('duffel_offer_123', 450.0);
      expect(result.status, RevalidationStatus.confirmed);
      expect(result.currentPriceUSD, 450.0);
      expect(result.remainingInventory, greaterThan(0));
    });

    test('TravelpayoutsHotelProvider returns verified affiliate hotel with \$0 markup', () async {
      final tp = TravelpayoutsHotelProvider();
      expect(tp.providerId, 'travelpayouts_hotel');

      final hotels = await tp.searchHotels(HotelSearchParams(
        destination: 'Dubai',
        checkInDate: DateTime.now().add(const Duration(days: 5)),
        checkOutDate: DateTime.now().add(const Duration(days: 9)),
      ));

      expect(hotels.isNotEmpty, isTrue);
      final hotel = hotels.first;
      expect(hotel.bookingChannel, BookingChannel.affiliate);
      expect(hotel.affiliateUrl, isNotNull);
      expect(hotel.affiliateUrl, contains('tp.media/r?marker=travelgo'));
      expect(hotel.isDirect, isFalse);
    });
  });

  group('3. FlightSearchAggregator & Multi-Provider Parallelism', () {
    test('Aggregates Amadeus, Duffel, Travelpayouts, and Sandbox concurrently', () async {
      final aggregator = FlightSearchAggregator(
        providers: [
          AmadeusFlightProvider(),
          DuffelFlightProvider(),
          TravelpayoutsAffiliateProvider(),
          SandboxTravelProvider(),
        ],
      );

      final params = FlightSearchParams(
        originCode: 'ALG',
        originCity: 'Algiers',
        destinationCode: 'DXB',
        destinationCity: 'Dubai',
        departureDate: DateTime.now().add(const Duration(days: 7)),
      );

      final result = await aggregator.searchAll(params);
      expect(result.results.isNotEmpty, isTrue);
      expect(result.providerMetrics.length, 4);
      expect(result.successfulProviders.length, greaterThanOrEqualTo(3));
    });

    test('Aggregator handles partial failure resilience without losing surviving results', () async {
      final aggregator = FlightSearchAggregator(
        providers: [
          SandboxTravelProvider(),
          DuffelFlightProvider(),
          FailingFlightTestProvider(),
        ],
      );

      final params = FlightSearchParams(
        originCode: 'LON',
        originCity: 'London',
        destinationCode: 'DXB',
        destinationCity: 'Dubai',
        departureDate: DateTime.now().add(const Duration(days: 5)),
      );

      final result = await aggregator.searchAll(params);
      expect(result.results.isNotEmpty, isTrue);
      expect(result.hasPartialErrors, isTrue);
      expect(result.failedProviders, contains('Failing Flaky Provider'));
      expect(result.successfulProviders, contains('Duffel NDC Direct'));
    });

    test('Aggregator expands multi-airport city search for LON and flexible dates', () async {
      final aggregator = FlightSearchAggregator(
        providers: [
          SandboxTravelProvider(),
        ],
      );

      final params = FlightSearchParams(
        originCode: 'LON', // Metropolitan multi-airport code
        originCity: 'London',
        destinationCode: 'DXB',
        destinationCity: 'Dubai',
        departureDate: DateTime.now().add(const Duration(days: 7)),
        flexibleDays: 1, // +/- 1 day search
      );

      final result = await aggregator.searchAll(params);
      expect(result.results.isNotEmpty, isTrue);
    });
  });

  group('4. HotelSearchAggregator & Multi-Provider Parallelism', () {
    test('Concurrently aggregates hotel providers with resilience', () async {
      final aggregator = HotelSearchAggregator(
        providers: [
          TravelpayoutsHotelProvider(),
          SandboxTravelProvider(),
          FailingHotelTestProvider(),
        ],
      );

      final params = HotelSearchParams(
        destination: 'Dubai',
        checkInDate: DateTime.now().add(const Duration(days: 5)),
        checkOutDate: DateTime.now().add(const Duration(days: 10)),
      );

      final result = await aggregator.searchAll(params);
      expect(result.results.isNotEmpty, isTrue);
      expect(result.hasPartialErrors, isTrue);
      expect(result.successfulProviders.length, greaterThanOrEqualTo(2));
    });
  });

  group('5. FlightDeduplicator Advanced Logic', () {
    final deduplicator = FlightDeduplicator();
    final depTime = DateTime(2026, 12, 10, 14, 0);

    test('Deduplicates by matching segment flight numbers and retains lower price', () {
      final flight1 = FlightEntity(
        id: 'f_ota_1',
        providerName: 'OTA Aggregator',
        bookingChannel: BookingChannel.affiliate,
        airlineName: 'Air Algérie',
        airlineCode: 'AH',
        airlineLogo: 'url',
        departureAirportCode: 'ALG',
        departureCity: 'Algiers',
        departureTime: depTime,
        arrivalAirportCode: 'DXB',
        arrivalCity: 'Dubai',
        arrivalTime: depTime.add(const Duration(hours: 6)),
        totalDuration: const Duration(hours: 6),
        stops: 0,
        basePriceUSD: 390.0,
        taxesUSD: 40.0,
        totalUSD: 430.0,
        segments: [
          FlightSegment(
            flightNumber: 'AH1020',
            airlineCode: 'AH',
            airlineName: 'Air Algérie',
            airlineLogoUrl: 'url',
            departureAirportCode: 'ALG',
            departureAirportName: 'Houari Boumediene',
            departureCity: 'Algiers',
            departureTime: depTime,
            arrivalAirportCode: 'DXB',
            arrivalAirportName: 'Dubai International',
            arrivalCity: 'Dubai',
            arrivalTime: depTime.add(const Duration(hours: 6)),
            duration: const Duration(hours: 6),
            aircraftType: 'A330',
            cabinClass: 'economy',
          ),
        ],
      );

      final flight2 = FlightEntity(
        id: 'f_gds_2',
        providerName: 'Amadeus GDS',
        bookingChannel: BookingChannel.direct,
        airlineName: 'Air Algérie',
        airlineCode: 'AH',
        airlineLogo: 'url',
        departureAirportCode: 'ALG',
        departureCity: 'Algiers',
        departureTime: depTime,
        arrivalAirportCode: 'DXB',
        arrivalCity: 'Dubai',
        arrivalTime: depTime.add(const Duration(hours: 6)),
        totalDuration: const Duration(hours: 6),
        stops: 0,
        basePriceUSD: 350.0,
        taxesUSD: 40.0,
        totalUSD: 390.0, // Cheaper!
        segments: [
          FlightSegment(
            flightNumber: 'AH1020', // Same physical flight!
            airlineCode: 'AH',
            airlineName: 'Air Algérie',
            airlineLogoUrl: 'url',
            departureAirportCode: 'ALG',
            departureAirportName: 'Houari Boumediene',
            departureCity: 'Algiers',
            departureTime: depTime,
            arrivalAirportCode: 'DXB',
            arrivalAirportName: 'Dubai International',
            arrivalCity: 'Dubai',
            arrivalTime: depTime.add(const Duration(hours: 6)),
            duration: const Duration(hours: 6),
            aircraftType: 'A330',
            cabinClass: 'economy',
          ),
        ],
      );

      final deduplicated = deduplicator.deduplicate([flight1, flight2]);
      expect(deduplicated.length, 1);
      expect(deduplicated.first.totalUSD, 390.0);
      expect(deduplicated.first.bookingChannel, BookingChannel.direct);
    });

    test('Prioritizes Direct booking channel when prices are identical', () {
      final affiliateFlight = FlightEntity(
        id: 'fl_aff',
        providerName: 'Skyscanner Affiliate',
        bookingChannel: BookingChannel.affiliate,
        airlineName: 'Emirates',
        airlineCode: 'EK',
        airlineLogo: 'url',
        departureAirportCode: 'DXB',
        departureCity: 'Dubai',
        departureTime: depTime,
        arrivalAirportCode: 'LHR',
        arrivalCity: 'London',
        arrivalTime: depTime.add(const Duration(hours: 7)),
        totalDuration: const Duration(hours: 7),
        stops: 0,
        basePriceUSD: 500.0,
        taxesUSD: 50.0,
        totalUSD: 550.0,
      );

      final directFlight = FlightEntity(
        id: 'fl_dir',
        providerName: 'Emirates Direct NDC',
        bookingChannel: BookingChannel.direct,
        airlineName: 'Emirates',
        airlineCode: 'EK',
        airlineLogo: 'url',
        departureAirportCode: 'DXB',
        departureCity: 'Dubai',
        departureTime: depTime,
        arrivalAirportCode: 'LHR',
        arrivalCity: 'London',
        arrivalTime: depTime.add(const Duration(hours: 7)),
        totalDuration: const Duration(hours: 7),
        stops: 0,
        basePriceUSD: 500.0,
        taxesUSD: 50.0,
        totalUSD: 550.0, // Same price!
      );

      final deduplicated = deduplicator.deduplicate([affiliateFlight, directFlight]);
      expect(deduplicated.length, 1);
      expect(deduplicated.first.bookingChannel, BookingChannel.direct);
      expect(deduplicated.first.providerName, 'Emirates Direct NDC');
    });
  });

  group('6. HotelDeduplicator Advanced Logic', () {
    final deduplicator = HotelDeduplicator();

    test('Deduplicates Arabic hotel names with normalization and retains direct partner rate', () {
      const hotelAffiliate = HotelEntity(
        id: 'ht_ar_aff',
        providerName: 'Agoda Affiliate',
        bookingChannel: BookingChannel.affiliate,
        nameEn: 'Atlantis The Palm Hotel and Resort',
        nameAr: 'فندق ومنتجع أتلانتس النخلة',
        cityEn: 'Dubai',
        cityAr: 'دبي',
        countryEn: 'UAE',
        countryAr: 'الإمارات',
        address: 'Crescent Rd, The Palm Jumeirah, Dubai',
        distanceToCenter: '18 km from center',
        descriptionEn: 'Iconic resort on the Palm Jumeirah.',
        descriptionAr: 'منتجع شهير في نخلة جميرا.',
        mainImageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945',
        latitude: 25.1304,
        longitude: 55.1171,
        starRating: 5,
        userRating: 4.8,
        reviewCount: 3000,
        pricePerNightUSD: 450.0,
      );

      const hotelDirectPartner = HotelEntity(
        id: 'ht_ar_dir',
        providerName: 'Direct Partner Portal',
        bookingChannel: BookingChannel.direct,
        nameEn: 'Atlantis The Palm',
        nameAr: 'أتلانتس النخلة دبي',
        cityEn: 'Dubai',
        cityAr: 'دبي',
        countryEn: 'UAE',
        countryAr: 'الإمارات',
        address: 'Crescent Rd, The Palm Jumeirah, Dubai',
        distanceToCenter: '18 km from center',
        descriptionEn: 'Iconic resort on the Palm Jumeirah.',
        descriptionAr: 'منتجع شهير في نخلة جميرا.',
        mainImageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945',
        latitude: 25.1305, // 12 meters apart
        longitude: 55.1172,
        starRating: 5,
        userRating: 4.8,
        reviewCount: 3000,
        pricePerNightUSD: 420.0, // Cheaper & Direct
      );

      final deduplicated = deduplicator.deduplicate([hotelAffiliate, hotelDirectPartner]);
      expect(deduplicated.length, 1);
      expect(deduplicated.first.isDirect, isTrue);
      expect(deduplicated.first.pricePerNightUSD, 420.0);
    });
  });

  group('7. Filter & Sorting State Tests', () {
    test('FlightFilterState filters by price, stops, airline, and baggage', () {
      final now = DateTime.now();
      final flights = [
        FlightEntity(
          id: 'f1',
          providerName: 'P1',
          bookingChannel: BookingChannel.direct,
          airlineName: 'Air Algérie',
          airlineCode: 'AH',
          airlineLogo: 'url',
          departureAirportCode: 'ALG',
          departureCity: 'Algiers',
          departureTime: now,
          arrivalAirportCode: 'DXB',
          arrivalCity: 'Dubai',
          arrivalTime: now.add(const Duration(hours: 6)),
          totalDuration: const Duration(hours: 6),
          stops: 0,
          basePriceUSD: 300.0,
          taxesUSD: 40.0,
          totalUSD: 340.0,
          baggageIncluded: true,
        ),
        FlightEntity(
          id: 'f2',
          providerName: 'P2',
          bookingChannel: BookingChannel.direct,
          airlineName: 'Turkish Airlines',
          airlineCode: 'TK',
          airlineLogo: 'url',
          departureAirportCode: 'ALG',
          departureCity: 'Algiers',
          departureTime: now,
          arrivalAirportCode: 'DXB',
          arrivalCity: 'Dubai',
          arrivalTime: now.add(const Duration(hours: 9)),
          totalDuration: const Duration(hours: 9),
          stops: 1,
          basePriceUSD: 450.0,
          taxesUSD: 50.0,
          totalUSD: 500.0,
          baggageIncluded: false,
        ),
      ];

      final state = FlightSearchResultState(
        params: FlightSearchParams(
          originCode: 'ALG',
          originCity: 'Algiers',
          destinationCode: 'DXB',
          destinationCity: 'Dubai',
          departureDate: now,
        ),
        rawFlights: flights,
        filterState: const FlightFilterState(
          maxStops: 0,
          baggageOnly: true,
          maxPriceUSD: 400.0,
        ),
      );

      final filtered = state.filteredFlights;
      expect(filtered.length, 1);
      expect(filtered.first.airlineCode, 'AH');
      expect(filtered.first.stops, 0);
      expect(filtered.first.baggageIncluded, isTrue);
    });
  });
}
