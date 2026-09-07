import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/network/api_client.dart';
import 'package:travelgo/features/flights/bloc/flight_search_bloc.dart';
import 'package:travelgo/features/flights/bloc/flight_search_event.dart';
import 'package:travelgo/features/flights/bloc/flight_search_state.dart';
import 'package:travelgo/features/flights/datasources/flight_remote_datasource.dart';
import 'package:travelgo/features/flights/models/flight_search_query.dart';
import 'package:travelgo/features/flights/repositories/flight_repository_impl.dart';

void main() {
  group('FlightSearchBloc & Flight Feature Tests', () {
    late FlightSearchBloc bloc;
    late FlightRepositoryImpl repository;

    setUp(() {
      repository = FlightRepositoryImpl(
        remoteDataSource: FlightRemoteDataSourceImpl(
          apiClient: ApiClient(timeout: const Duration(milliseconds: 50)),
        ),
      );
      bloc = FlightSearchBloc(repository: repository);
    });

    tearDown(() {
      bloc.dispose();
    });

    test('Initial state is FlightSearchInitial', () {
      expect(bloc.state, isA<FlightSearchInitial>());
    });

    test('SearchFlightsRequested transitions to Loading then Success with 0.75% fee', () async {
      final query = FlightSearchQuery(
        originCode: 'ALG',
        originCity: 'Algiers',
        destinationCode: 'IST',
        destinationCity: 'Istanbul',
        departureDate: DateTime(2026, 9, 20),
      );

      final states = <FlightSearchState>[];
      final sub = bloc.stream.listen(states.add);
      final successFuture = bloc.stream.firstWhere((s) => s is FlightSearchSuccess);
      bloc.add(SearchFlightsRequested(query));

      final successState = await successFuture as FlightSearchSuccess;
      expect(states.any((s) => s is FlightSearchLoading), isTrue);
      expect(successState.filteredOffers, isNotEmpty);

      // Verify that every generated offer has a non-null 0.75% TRAVELGO service fee
      final firstOffer = successState.filteredOffers.first;
      expect(firstOffer.price.hasServiceFee, isTrue);
      expect(firstOffer.price.serviceFee, greaterThan(0));

      await sub.cancel();
    });

    test('FilterFlightsRequested filters offers by validating airline', () async {
      final query = FlightSearchQuery(
        originCode: 'ALG',
        originCity: 'Algiers',
        destinationCode: 'IST',
        destinationCity: 'Istanbul',
        departureDate: DateTime(2026, 9, 20),
      );

      final successFuture = bloc.stream.firstWhere((s) => s is FlightSearchSuccess);
      bloc.add(SearchFlightsRequested(query));
      await successFuture;

      final filterFuture = bloc.stream.firstWhere((s) => s is FlightSearchSuccess && s.activeAirlineFilter == 'Air Algerie');
      bloc.add(const FilterFlightsRequested(airlineFilter: 'Air Algerie'));
      final filteredState = await filterFuture as FlightSearchSuccess;

      expect(filteredState.activeAirlineFilter, equals('Air Algerie'));
      for (final offer in filteredState.filteredOffers) {
        expect(offer.validatingAirline, equals('Air Algerie'));
      }
    });
  });
}
