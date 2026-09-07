import 'package:flutter/material.dart';
import '../../../../core/architecture/bloc_base.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../bloc/flight_search_bloc.dart';
import '../../bloc/flight_search_event.dart';
import '../../bloc/flight_search_state.dart';
import '../../models/flight_offer.dart';
import '../../models/flight_search_query.dart';
import '../widgets/airport_search_modal.dart';
import '../widgets/flight_offer_card.dart';
import 'flight_offer_details_screen.dart';

class FlightSearchResultsScreen extends StatelessWidget {
  final FlightSearchBloc bloc;

  const FlightSearchResultsScreen({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlightSearchBloc, FlightSearchState>(
      bloc: bloc,
      builder: (context, state) {
        final query = (state is FlightSearchSuccess)
            ? state.query
            : (state is FlightSearchLoading ? state.query : null);

        final title = query != null
            ? '${query.originCode} → ${query.destinationCode}'
            : 'Flight Search Results';

        final subtitle = query != null
            ? '${DateFormatter.formatDate(query.departureDate)} • ${query.totalPassengers} Pax • ${query.cabinClass}'
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
                tooltip: 'Change Destination',
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final selected = await AirportSearchModal.show(
                    context,
                    title: 'Search New Destination',
                  );
                  if (selected != null && query != null) {
                    bloc.add(SearchFlightsRequested(
                      FlightSearchQuery(
                        originCode: query.originCode,
                        originCity: query.originCity,
                        destinationCode: selected.code,
                        destinationCity: selected.city,
                        departureDate: query.departureDate,
                        adults: query.adults,
                        cabinClass: query.cabinClass,
                      ),
                    ));
                  }
                },
              ),
              if (state is FlightSearchSuccess)
                PopupMenuButton<String>(
                  tooltip: 'Sort Flights',
                  icon: const Icon(Icons.sort),
                  onSelected: (sortKey) {
                    bloc.add(FilterFlightsRequested(sortBy: sortKey));
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'price', child: Text('Lowest Price')),
                    const PopupMenuItem(value: 'duration', child: Text('Shortest Duration')),
                    const PopupMenuItem(value: 'departure', child: Text('Earliest Departure')),
                  ],
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FlightSearchState state) {
    if (state is FlightSearchLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.accentBlue),
            SizedBox(height: 16),
            Text('Searching live airline fares & seat availability...', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    if (state is FlightSearchFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flight_land, size: 56, color: AppTheme.errorRed),
              const SizedBox(height: 16),
              Text(
                state.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => bloc.add(SearchFlightsRequested(state.query)),
                child: const Text('Try Searching Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is FlightSearchSuccess) {
      final offers = state.filteredOffers;

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
                  _buildFilterChip('All Airlines', state.activeAirlineFilter == null, () {
                    bloc.add(const FilterFlightsRequested(airlineFilter: null));
                  }),
                  const SizedBox(width: 8),
                  ...state.allOffers
                      .map((o) => o.validatingAirline)
                      .toSet()
                      .map((airline) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterChip(airline, state.activeAirlineFilter == airline, () {
                              bloc.add(FilterFlightsRequested(airlineFilter: airline));
                            }),
                          )),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Results count
            Text(
              '${offers.length} available flight offers found',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 8),

            // Offer List
            Expanded(
              child: ListView.builder(
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return FlightOfferCard(
                    offer: offer,
                    onSelect: () => _navigateToOfferDetails(context, offer),
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

  void _navigateToOfferDetails(BuildContext context, FlightOffer offer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FlightOfferDetailsScreen(offer: offer),
      ),
    );
  }
}
