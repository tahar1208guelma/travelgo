import 'package:flutter/material.dart';
import '../../../../core/architecture/bloc_base.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../bloc/hotel_search_bloc.dart';
import '../../bloc/hotel_search_event.dart';
import '../../bloc/hotel_search_state.dart';
import '../../models/hotel_offer.dart';
import '../../models/hotel_search_query.dart';
import '../widgets/city_search_modal.dart';
import '../widgets/hotel_offer_card.dart';
import 'hotel_offer_details_screen.dart';

class HotelSearchResultsScreen extends StatelessWidget {
  final HotelSearchBloc bloc;

  const HotelSearchResultsScreen({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelSearchBloc, HotelSearchState>(
      bloc: bloc,
      builder: (context, state) {
        final query = (state is HotelSearchSuccess)
            ? state.query
            : (state is HotelSearchLoading ? state.query : null);

        final title = query != null ? 'Hotels in ${query.city}' : 'Hotel Search Results';
        final subtitle = query != null
            ? '${DateFormatter.formatDate(query.checkInDate)} - ${DateFormatter.formatDate(query.checkOutDate)} • ${query.totalNights} Nights • ${query.adults} Guests'
            : '';

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Change City',
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final selected = await CitySearchModal.show(
                    context,
                    title: 'Search New Destination City',
                  );
                  if (selected != null && query != null) {
                    bloc.add(SearchHotelsRequested(
                      HotelSearchQuery(
                        destination: selected.city,
                        city: selected.city,
                        checkInDate: query.checkInDate,
                        checkOutDate: query.checkOutDate,
                        adults: query.adults,
                        rooms: query.rooms,
                      ),
                    ));
                  }
                },
              ),
              if (state is HotelSearchSuccess)
                PopupMenuButton<String>(
                  tooltip: 'Sort Hotels',
                  icon: const Icon(Icons.sort),
                  onSelected: (sortKey) {
                    bloc.add(FilterHotelsRequested(sortBy: sortKey));
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'rating', child: Text('Highest Guest Rating')),
                    const PopupMenuItem(value: 'price', child: Text('Lowest Price')),
                    const PopupMenuItem(value: 'name', child: Text('Hotel Name')),
                  ],
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HotelSearchState state) {
    if (state is HotelSearchLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.accentBlue),
            SizedBox(height: 16),
            Text('Searching luxury hotels and room availability...', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    if (state is HotelSearchFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hotel_class, size: 56, color: AppTheme.errorRed),
              const SizedBox(height: 16),
              Text(
                state.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => bloc.add(SearchHotelsRequested(state.query)),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is HotelSearchSuccess) {
      final hotels = state.filteredHotels;

      return ResponsiveContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Pills Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All Properties', state.activeMinStarRating == null, () {
                    bloc.add(const FilterHotelsRequested(minStarRating: null));
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('5 Stars Only', state.activeMinStarRating == 5, () {
                    bloc.add(const FilterHotelsRequested(minStarRating: 5));
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('4+ Stars', state.activeMinStarRating == 4, () {
                    bloc.add(const FilterHotelsRequested(minStarRating: 4));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Results count
            Text(
              '${hotels.length} luxury properties available',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 8),

            // Hotel List
            Expanded(
              child: ListView.builder(
                itemCount: hotels.length,
                itemBuilder: (context, index) {
                  final hotel = hotels[index];
                  return HotelOfferCard(
                    offer: hotel,
                    onSelect: () => _navigateToHotelDetails(context, hotel),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.accentBlue.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.accentBlue : AppTheme.textDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  void _navigateToHotelDetails(BuildContext context, HotelOffer hotel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelOfferDetailsScreen(hotel: hotel),
      ),
    );
  }
}
