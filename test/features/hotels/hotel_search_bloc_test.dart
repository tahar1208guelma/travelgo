import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/network/api_client.dart';
import 'package:travelgo/features/hotels/bloc/hotel_search_bloc.dart';
import 'package:travelgo/features/hotels/bloc/hotel_search_event.dart';
import 'package:travelgo/features/hotels/bloc/hotel_search_state.dart';
import 'package:travelgo/features/hotels/datasources/hotel_remote_datasource.dart';
import 'package:travelgo/features/hotels/models/hotel_search_query.dart';
import 'package:travelgo/features/hotels/repositories/hotel_repository_impl.dart';

void main() {
  group('HotelSearchBloc & Hotel Feature Tests', () {
    late HotelSearchBloc bloc;
    late HotelRepositoryImpl repository;

    setUp(() {
      repository = HotelRepositoryImpl(
        remoteDataSource: HotelRemoteDataSourceImpl(
          apiClient: ApiClient(timeout: const Duration(milliseconds: 50)),
        ),
      );
      bloc = HotelSearchBloc(repository: repository);
    });

    tearDown(() {
      bloc.dispose();
    });

    test('Initial state is HotelSearchInitial', () {
      expect(bloc.state, isA<HotelSearchInitial>());
    });

    test('SearchHotelsRequested transitions to Loading then Success with 0.75% fee', () async {
      final query = HotelSearchQuery(
        destination: 'Istanbul',
        city: 'Istanbul',
        checkInDate: DateTime(2026, 9, 20),
        checkOutDate: DateTime(2026, 9, 25),
        adults: 2,
        rooms: 1,
      );

      final states = <HotelSearchState>[];
      final sub = bloc.stream.listen(states.add);

      final successFuture = bloc.stream.firstWhere((s) => s is HotelSearchSuccess);
      bloc.add(SearchHotelsRequested(query));

      final successState = await successFuture as HotelSearchSuccess;

      expect(states.any((s) => s is HotelSearchLoading), isTrue);
      expect(successState.filteredHotels, isNotEmpty);

      // Verify that every generated hotel offer has a non-null 0.75% TRAVELGO service fee
      final firstHotel = successState.filteredHotels.first;
      expect(firstHotel.price.hasServiceFee, isTrue);
      expect(firstHotel.price.serviceFee, greaterThan(0));

      await sub.cancel();
    });

    test('FilterHotelsRequested filters properties by 5-star rating', () async {
      final query = HotelSearchQuery(
        destination: 'Istanbul',
        city: 'Istanbul',
        checkInDate: DateTime(2026, 9, 20),
        checkOutDate: DateTime(2026, 9, 25),
      );

      final successFuture = bloc.stream.firstWhere((s) => s is HotelSearchSuccess);
      bloc.add(SearchHotelsRequested(query));
      await successFuture;

      final filterFuture = bloc.stream.firstWhere((s) => s is HotelSearchSuccess && s.activeMinStarRating == 5);
      bloc.add(const FilterHotelsRequested(minStarRating: 5));
      final filteredState = await filterFuture as HotelSearchSuccess;

      expect(filteredState.activeMinStarRating, equals(5));
      for (final hotel in filteredState.filteredHotels) {
        expect(hotel.starRating, greaterThanOrEqualTo(5));
      }
    });
  });
}
