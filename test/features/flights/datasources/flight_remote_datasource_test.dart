import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/network/api_client.dart';
import 'package:travelgo/core/network/api_result.dart';
import 'package:travelgo/features/bookings/models/flight_booking_details.dart';
import 'package:travelgo/features/bookings/models/passenger.dart';
import 'package:travelgo/features/bookings/models/price_breakdown.dart';
import 'package:travelgo/features/flights/datasources/flight_remote_datasource.dart';
import 'package:travelgo/features/flights/models/flight_offer.dart';
import 'package:travelgo/features/flights/models/flight_search_query.dart';

class TestApiClient extends ApiClient {
  ApiResult<dynamic>? mockGetResult;
  ApiResult<dynamic>? mockPostResult;
  Exception? mockException;

  TestApiClient() : super(timeout: const Duration(milliseconds: 100));

  @override
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) responseParser,
    Map<String, String>? headers,
  }) async {
    if (mockException != null) {
      throw mockException!;
    }

    if (mockGetResult != null) {
      if (mockGetResult!.isSuccess) {
        return ApiResult.success(mockGetResult!.dataOrNull as T);
      } else {
        return ApiResult<T>.failure(
          mockGetResult!.errorMessageOrNull ?? 'Error',
          code: (mockGetResult as ApiFailure).code,
          statusCode: (mockGetResult as ApiFailure).statusCode
        );
      }
    }
    return ApiResult<T>.failure('Not implemented in mock');
  }

  @override
  Future<ApiResult<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    String? idempotencyKey,
    required T Function(dynamic json) responseParser,
    Map<String, String>? headers,
  }) async {
    if (mockException != null) {
      throw mockException!;
    }

    if (mockPostResult != null) {
      if (mockPostResult!.isSuccess) {
        return ApiResult.success(mockPostResult!.dataOrNull as T);
      } else {
        return ApiResult<T>.failure(
          mockPostResult!.errorMessageOrNull ?? 'Error',
          code: (mockPostResult as ApiFailure).code,
          statusCode: (mockPostResult as ApiFailure).statusCode
        );
      }
    }
    return ApiResult<T>.failure('Not implemented in mock');
  }
}

void main() {
  group('FlightRemoteDataSourceImpl Tests', () {
    late TestApiClient mockApiClient;
    late FlightRemoteDataSourceImpl dataSource;

    setUp(() {
      mockApiClient = TestApiClient();
      dataSource = FlightRemoteDataSourceImpl(apiClient: mockApiClient);
    });

    final testQuery = FlightSearchQuery(
      originCode: 'ALG',
      originCity: 'Algiers',
      destinationCode: 'IST',
      destinationCity: 'Istanbul',
      departureDate: DateTime.now().add(const Duration(days: 10)),
    );

    final mockOffer = FlightOffer(
      offerId: 'TEST-OFFER-1',
      validatingAirline: 'Test Airline',
      validatingAirlineCode: 'TA',
      priceLockExpiry: DateTime.now().add(const Duration(hours: 1)),
      price: const PriceBreakdown(
        basePrice: 100,
        currency: 'USD',
        totalAmount: 110
      ),
      outboundSegments: [
        FlightSegment(
          airline: 'Test Airline',
          flightNumber: 'TA123',
          departureAirport: 'Algiers',
          departureAirportCode: 'ALG',
          departureDateTime: DateTime.now().add(const Duration(days: 10)),
          arrivalAirport: 'Istanbul',
          arrivalAirportCode: 'IST',
          arrivalDateTime: DateTime.now().add(const Duration(days: 10, hours: 3)),
          duration: const Duration(hours: 3),
        )
      ],
    );

    test('fetchFlightOffers returns data from ApiClient on success', () async {
      final mockOffers = [mockOffer];
      mockApiClient.mockGetResult = ApiResult.success(mockOffers);

      final result = await dataSource.fetchFlightOffers(testQuery);

      expect(result, isNotEmpty);
      expect(result.first.offerId, equals('TEST-OFFER-1'));
      expect(result.first.validatingAirlineCode, equals('TA'));
    });

    test('fetchFlightOffers falls back to LiveFlightNetworkService on failure', () async {
      mockApiClient.mockGetResult = ApiResult<List<FlightOffer>>.failure('Network Error');

      final result = await dataSource.fetchFlightOffers(testQuery);

      // It should generate live offers
      expect(result, isNotEmpty);
      // The offerId from LiveFlightNetworkService won't be 'TEST-OFFER-1'
      expect(result.first.offerId, isNot('TEST-OFFER-1'));
    });

    test('fetchFlightOffers falls back to LiveFlightNetworkService on empty success', () async {
      mockApiClient.mockGetResult = ApiResult<List<FlightOffer>>.success([]);

      final result = await dataSource.fetchFlightOffers(testQuery);

      // It should generate live offers when result is empty list
      expect(result, isNotEmpty);
      expect(result.first.offerId, isNot('TEST-OFFER-1'));
    });

    test('fetchFlightOffers falls back to LiveFlightNetworkService on exception', () async {
      mockApiClient.mockException = Exception('Test exception');

      final result = await dataSource.fetchFlightOffers(testQuery);

      expect(result, isNotEmpty);
    });

    test('fetchOfferDetails returns offer on success', () async {
      mockApiClient.mockGetResult = ApiResult.success(mockOffer);

      final result = await dataSource.fetchOfferDetails('TEST-OFFER-1');

      expect(result, isNotNull);
      expect(result!.offerId, equals('TEST-OFFER-1'));
    });

    test('fetchOfferDetails returns null on failure', () async {
      mockApiClient.mockGetResult = ApiResult<FlightOffer>.failure('Not Found');

      final result = await dataSource.fetchOfferDetails('TEST-OFFER-1');

      expect(result, isNull);
    });

    test('fetchOfferDetails returns null on exception', () async {
      mockApiClient.mockException = Exception('Test exception');

      final result = await dataSource.fetchOfferDetails('TEST-OFFER-1');

      expect(result, isNull);
    });

    test('executeSeatHold returns hold reference from network on success', () async {
      mockApiClient.mockPostResult = ApiResult.success('NET-HOLD-12345');

      final passengers = [
        const Passenger(id: '1', fullName: 'Test User')
      ];

      final result = await dataSource.executeSeatHold('TEST-OFFER-1', passengers);

      expect(result, equals('NET-HOLD-12345'));
    });

    test('executeSeatHold returns fallback reference on failure', () async {
      mockApiClient.mockPostResult = ApiResult<String>.failure('Network Error');

      final passengers = [
        const Passenger(id: '1', fullName: 'Test User')
      ];

      final result = await dataSource.executeSeatHold('TEST-OFFER-1', passengers);

      expect(result, startsWith('TG-HOLD-'));
    });

    test('executeSeatHold returns fallback reference on exception', () async {
      mockApiClient.mockException = Exception('Test exception');

      final passengers = [
        const Passenger(id: '1', fullName: 'Test User')
      ];

      final result = await dataSource.executeSeatHold('TEST-OFFER-1', passengers);

      expect(result, startsWith('TG-HOLD-'));
    });
  });
}
