import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travelgo/features/bookings/models/flight_booking_details.dart';
import 'package:travelgo/features/bookings/models/price_breakdown.dart';
import 'package:travelgo/features/flights/datasources/flight_remote_datasource.dart';
import 'package:travelgo/features/flights/models/flight_offer.dart';
import 'package:travelgo/features/flights/models/flight_search_query.dart';
import 'package:travelgo/features/flights/repositories/flight_repository_impl.dart';
import 'package:travelgo/features/bookings/models/passenger.dart';

@GenerateNiceMocks([MockSpec<FlightRemoteDataSource>()])
import 'flight_repository_impl_test.mocks.dart';

void main() {
  late FlightRepositoryImpl repository;
  late MockFlightRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockFlightRemoteDataSource();
    repository = FlightRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('FlightRepositoryImpl', () {
    final tQuery = FlightSearchQuery(
      originCode: 'ALG',
      originCity: 'Algiers',
      destinationCode: 'PAR',
      destinationCity: 'Paris',
      departureDate: DateTime(2023, 10, 10),
    );

    final tFlightSegment = FlightSegment(
      airline: 'Air Algerie',
      flightNumber: 'AH1000',
      departureAirport: 'Houari Boumediene',
      departureAirportCode: 'ALG',
      departureDateTime: DateTime(2023, 10, 10, 10, 0),
      arrivalAirport: 'Charles de Gaulle',
      arrivalAirportCode: 'CDG',
      arrivalDateTime: DateTime(2023, 10, 10, 13, 0),
      duration: const Duration(hours: 2, minutes: 20),
    );

    final tPriceBreakdown = PriceBreakdown.calculateWithTravelGoFee(
      basePrice: 100.0,
      taxesAndFees: 20.0,
      currency: 'USD',
    );

    final tFlightOffer = FlightOffer(
      offerId: 'offer123',
      validatingAirline: 'Air Algerie',
      validatingAirlineCode: 'AH',
      outboundSegments: [tFlightSegment],
      price: tPriceBreakdown,
      priceLockExpiry: DateTime.now().add(const Duration(hours: 1)),
    );

    final tPassenger = Passenger(
      id: 'p1',
      fullName: 'John Doe',
      passengerType: PassengerType.adult,
    );

    test('searchFlights should return a list of FlightOffers from remoteDataSource', () async {
      // arrange
      final tOffers = [tFlightOffer];
      when(mockRemoteDataSource.fetchFlightOffers(tQuery))
          .thenAnswer((_) async => tOffers);

      // act
      final result = await repository.searchFlights(tQuery);

      // assert
      expect(result, equals(tOffers));
      verify(mockRemoteDataSource.fetchFlightOffers(tQuery)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('getFlightOfferDetails should return FlightOffer from remoteDataSource when found', () async {
      // arrange
      when(mockRemoteDataSource.fetchOfferDetails('offer123'))
          .thenAnswer((_) async => tFlightOffer);

      // act
      final result = await repository.getFlightOfferDetails('offer123');

      // assert
      expect(result, equals(tFlightOffer));
      verify(mockRemoteDataSource.fetchOfferDetails('offer123')).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('getFlightOfferDetails should return null from remoteDataSource when not found', () async {
      // arrange
      when(mockRemoteDataSource.fetchOfferDetails('offer999'))
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getFlightOfferDetails('offer999');

      // assert
      expect(result, isNull);
      verify(mockRemoteDataSource.fetchOfferDetails('offer999')).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('holdFlightOffer should return hold reference string from remoteDataSource', () async {
      // arrange
      final tPassengers = [tPassenger];
      const tHoldReference = 'TG-HOLD-123456';
      when(mockRemoteDataSource.executeSeatHold('offer123', tPassengers))
          .thenAnswer((_) async => tHoldReference);

      // act
      final result = await repository.holdFlightOffer(
        offerId: 'offer123',
        passengers: tPassengers,
      );

      // assert
      expect(result, equals(tHoldReference));
      verify(mockRemoteDataSource.executeSeatHold('offer123', tPassengers)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('should propagate exceptions thrown by remoteDataSource', () async {
      // arrange
      when(mockRemoteDataSource.fetchFlightOffers(tQuery))
          .thenThrow(Exception('Network Error'));

      // act & assert
      expect(() => repository.searchFlights(tQuery), throwsException);
      verify(mockRemoteDataSource.fetchFlightOffers(tQuery)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });
}
