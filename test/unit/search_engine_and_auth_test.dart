import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/search/adapters/sandbox_travel_provider.dart';
import 'package:travelgo/core/search/adapters/travelpayouts_affiliate_provider.dart';
import 'package:travelgo/core/search/domain/flight_search_provider.dart';
import 'package:travelgo/core/search/domain/hotel_search_provider.dart';
import 'package:travelgo/core/search/domain/revalidation_result.dart';
import 'package:travelgo/core/search/services/flight_deduplicator.dart';
import 'package:travelgo/core/search/services/flight_search_aggregator.dart';
import 'package:travelgo/core/search/services/hotel_deduplicator.dart';
import 'package:travelgo/core/search/services/hotel_search_aggregator.dart';
import 'package:travelgo/core/services/commission_service.dart';
import 'package:travelgo/features/flights/domain/entities/flight_entity.dart';
import 'package:travelgo/features/flights/domain/entities/flight_search_params.dart';
import 'package:travelgo/features/hotels/domain/entities/hotel_entity.dart';
import 'package:travelgo/features/hotels/domain/entities/hotel_search_params.dart';
import 'package:travelgo/shared/models/airport.dart';

class FailingFlightProvider implements FlightSearchProvider {
  @override
  String get providerId => 'failing_provider';
  @override
  String get providerName => 'Failing Test Provider';
  @override
  Duration get timeout => const Duration(milliseconds: 100);

  @override
  Future<List<FlightEntity>> searchFlights(FlightSearchParams params) async {
    throw Exception('Connection timed out or network dropped');
  }

  @override
  Future<FlightEntity?> getFlightDetails(String flightId) async => null;

  @override
  Future<RevalidationResult> revalidateFlight(String flightId, double expectedPriceUSD) async {
    throw Exception('Failed to revalidate');
  }
}

class FailingHotelProvider implements HotelSearchProvider {
  @override
  String get providerId => 'failing_hotel_provider';
  @override
  String get providerName => 'Failing Hotel Provider';
  @override
  Duration get timeout => const Duration(milliseconds: 100);

  @override
  Future<List<HotelEntity>> searchHotels(HotelSearchParams params) async {
    throw Exception('Service unavailable');
  }

  @override
  Future<HotelEntity?> getHotelDetails(String hotelId) async => null;

  @override
  Future<RevalidationResult> revalidateHotel(String hotelId, double expectedPriceUSD) async {
    throw Exception('Failed');
  }
}

void main() {
  group('Airport Database & Location Tests', () {
    test('Calculates Haversine distance between ALG and DXB accurately', () {
      final alg = Airport.findByCode('ALG')!;
      final dxb = Airport.findByCode('DXB')!;

      final distance = alg.distanceTo(dxb);
      // Great circle distance Algiers to Dubai is ~5060 km
      expect(distance, greaterThan(4900.0));
      expect(distance, lessThan(5200.0));
    });

    test('Finds nearby airports within 150 km', () {
      final cdg = Airport.findByCode('CDG')!;
      final nearby = cdg.getNearbyAirports(radiusKm: 150.0);

      // Orly (ORY) is near Paris CDG (~35 km)
      expect(nearby.any((a) => a.code == 'ORY'), isTrue);
    });

    test('Finds airports by city code or query', () {
      final londonAirports = Airport.findAirports('LON');
      expect(londonAirports.length, greaterThanOrEqualTo(2));
      expect(londonAirports.any((a) => a.code == 'LHR'), isTrue);
      expect(londonAirports.any((a) => a.code == 'LGW'), isTrue);
    });
  });

  group('Multi-Provider Search Aggregator & Partial Failure Resilience', () {
    test('FlightSearchAggregator returns partial results when one provider fails', () async {
      final aggregator = FlightSearchAggregator(
        providers: [
          SandboxTravelProvider(),
          TravelpayoutsAffiliateProvider(),
          FailingFlightProvider(),
        ],
      );

      final params = FlightSearchParams(
        originCode: 'ALG',
        originCity: 'Algiers',
        destinationCode: 'DXB',
        destinationCity: 'Dubai',
        departureDate: DateTime.now().add(const Duration(days: 7)),
      );

      final aggregated = await aggregator.searchAll(params);

      // Should still return results from Sandbox and Travelpayouts!
      expect(aggregated.results.isNotEmpty, isTrue);
      expect(aggregated.hasPartialErrors, isTrue);
      expect(aggregated.successfulProviders.length, greaterThanOrEqualTo(2));
      expect(aggregated.failedProviders.contains('Failing Test Provider'), isTrue);
    });

    test('HotelSearchAggregator handles failing providers gracefully', () async {
      final aggregator = HotelSearchAggregator(
        providers: [
          SandboxTravelProvider(),
          FailingHotelProvider(),
        ],
      );

      final params = HotelSearchParams(
        destination: 'Dubai',
        checkInDate: DateTime.now().add(const Duration(days: 5)),
        checkOutDate: DateTime.now().add(const Duration(days: 9)),
      );

      final aggregated = await aggregator.searchAll(params);
      expect(aggregated.results.isNotEmpty, isTrue);
      expect(aggregated.hasPartialErrors, isTrue);
      expect(aggregated.successfulProviders.isNotEmpty, isTrue);
    });
  });

  group('Deduplication Service Tests', () {
    test('FlightDeduplicator retains lowest price when duplicates are found', () {
      final deduplicator = FlightDeduplicator();
      final now = DateTime(2026, 12, 1, 10, 0);

      final flight1 = FlightEntity(
        id: 'fl_1',
        providerName: 'Provider A',
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
        basePriceUSD: 350.0,
        taxesUSD: 40.0,
        totalUSD: 390.0,
      );

      final flight2 = FlightEntity(
        id: 'fl_2',
        providerName: 'Provider B',
        bookingChannel: BookingChannel.affiliate,
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
        basePriceUSD: 320.0,
        taxesUSD: 40.0,
        totalUSD: 360.0, // Cheaper!
      );

      final deduplicated = deduplicator.deduplicate([flight1, flight2]);
      expect(deduplicated.length, 1);
      expect(deduplicated.first.totalUSD, 360.0);
    });

    test('HotelDeduplicator matches hotels by geographic proximity and normalized name', () {
      final deduplicator = HotelDeduplicator();

      const hotel1 = HotelEntity(
        id: 'ht_1',
        providerName: 'OTA Aggregator',
        bookingChannel: BookingChannel.affiliate,
        nameEn: 'Grand Palace Hotel and Spa',
        nameAr: 'فندق جراند بالاس',
        cityEn: 'Dubai',
        cityAr: 'دبي',
        countryEn: 'UAE',
        countryAr: 'الإمارات',
        address: 'Downtown',
        starRating: 5,
        userRating: 9.0,
        reviewCount: 100,
        distanceToCenter: '1 km',
        pricePerNightUSD: 250.0,
        mainImageUrl: 'url',
        descriptionEn: 'desc',
        descriptionAr: 'وصف',
        latitude: 25.1972,
        longitude: 55.2744,
      );

      const hotel2 = HotelEntity(
        id: 'ht_2',
        providerName: 'Direct Partner',
        bookingChannel: BookingChannel.direct,
        nameEn: 'Grand Palace Hotel', // Same hotel
        nameAr: 'فندق جراند بالاس',
        cityEn: 'Dubai',
        cityAr: 'دبي',
        countryEn: 'UAE',
        countryAr: 'الإمارات',
        address: 'Downtown',
        starRating: 5,
        userRating: 9.0,
        reviewCount: 100,
        distanceToCenter: '1 km',
        pricePerNightUSD: 240.0, // Direct & Cheaper!
        mainImageUrl: 'url',
        descriptionEn: 'desc',
        descriptionAr: 'وصف',
        latitude: 25.1973, // ~15 meters away
        longitude: 55.2745,
      );

      final deduplicated = deduplicator.deduplicate([hotel1, hotel2]);
      expect(deduplicated.length, 1);
      expect(deduplicated.first.bookingChannel, BookingChannel.direct);
      expect(deduplicated.first.pricePerNightUSD, 240.0);
    });
  });

  group('Commission & Platform Deduction System Tests', () {
    test('Standard Direct Booking Service Fee is deterministic (\$1.00 USD default)', () {
      final commissionService = CommissionService();
      final pricing = commissionService.calculatePricing(
        basePriceUSD: 250.0,
        isAffiliate: false,
      );

      expect(pricing.basePriceUSD, 250.0);
      expect(pricing.serviceFeeUSD, 1.00);
      expect(pricing.platformCommissionUSD, 1.00);
      expect(pricing.totalAmountUSD, 251.0);
    });

    test('Affiliate Booking has \$0.00 platform markup by default', () {
      final commissionService = CommissionService();
      final pricing = commissionService.calculatePricing(
        basePriceUSD: 300.0,
        isAffiliate: true,
      );

      expect(pricing.serviceFeeUSD, 0.0);
      expect(pricing.totalAmountUSD, 300.0);
    });

    test('Percentage Commission Model (0.75%) calculates deterministic app cut', () {
      final commissionService = CommissionService();
      commissionService.updateConfig(
        const CommissionConfig(
          model: CommissionModel.percentage,
          percentageCommissionRate: 0.0075,
        ),
      );

      final pricing = commissionService.calculatePricing(
        basePriceUSD: 400.0,
        isAffiliate: false,
      );

      // 400 * 0.0075 = $3.00 USD
      expect(pricing.serviceFeeUSD, 3.00);
      expect(pricing.platformCommissionUSD, 3.00);
      expect(pricing.totalAmountUSD, 403.0);
    });

    test('Computes net partner payout correctly', () {
      final commissionService = CommissionService();
      // Gross $500 with 10% commission = $50 app deduction, $450 partner payout
      final payout = commissionService.calculatePartnerPayout(
        grossAmountUSD: 500.0,
        commissionRate: 0.10,
      );
      expect(payout, 450.0);
    });
  });
}
