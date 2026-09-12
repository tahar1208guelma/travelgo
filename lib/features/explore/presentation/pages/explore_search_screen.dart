import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../flights/bloc/flight_search_bloc.dart';
import '../../../flights/bloc/flight_search_event.dart';
import '../../../flights/datasources/flight_remote_datasource.dart';
import '../../../flights/models/flight_search_query.dart';
import '../../../flights/presentation/pages/flight_search_results_screen.dart';
import '../../../flights/presentation/widgets/airport_search_modal.dart';
import '../../../flights/repositories/flight_repository_impl.dart';
import '../../../hotels/bloc/hotel_search_bloc.dart';
import '../../../hotels/bloc/hotel_search_event.dart';
import '../../../hotels/datasources/hotel_remote_datasource.dart';
import '../../../hotels/models/hotel_search_query.dart';
import '../../../hotels/presentation/pages/hotel_search_results_screen.dart';
import '../../../hotels/presentation/widgets/city_search_modal.dart';
import '../../../hotels/repositories/hotel_repository_impl.dart';

class ExploreSearchScreen extends StatefulWidget {
  const ExploreSearchScreen({super.key});

  @override
  State<ExploreSearchScreen> createState() => _ExploreSearchScreenState();
}

class _ExploreSearchScreenState extends State<ExploreSearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Flight search form state
  String _flightOriginCode = 'ALG';
  String _flightOriginCity = 'Algiers';
  String _flightDestCode = 'IST';
  String _flightDestCity = 'Istanbul';
  DateTime _flightDepartureDate = DateTime.now().add(const Duration(days: 14));
  String _flightCabin = 'Economy';
  final int _flightAdults = 1;

  // Hotel search form state
  String _hotelCity = 'Istanbul';
  DateTime _hotelCheckIn = DateTime.now().add(const Duration(days: 14));
  DateTime _hotelCheckOut = DateTime.now().add(const Duration(days: 19));
  final int _hotelGuests = 2;
  final int _hotelRooms = 1;

  late final ApiClient _apiClient;
  late final FlightRepositoryImpl _flightRepository;
  late final HotelRepositoryImpl _hotelRepository;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _apiClient = ApiClient();
    _flightRepository = FlightRepositoryImpl(
      remoteDataSource: FlightRemoteDataSourceImpl(apiClient: _apiClient),
    );
    _hotelRepository = HotelRepositoryImpl(
      remoteDataSource: HotelRemoteDataSourceImpl(apiClient: _apiClient),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _swapAirports() {
    setState(() {
      final tempCode = _flightOriginCode;
      final tempCity = _flightOriginCity;
      _flightOriginCode = _flightDestCode;
      _flightOriginCity = _flightDestCity;
      _flightDestCode = tempCode;
      _flightDestCity = tempCity;
    });
  }

  void _executeFlightSearch({
    String? originCode,
    String? originCity,
    String? destCode,
    String? destCity,
    DateTime? depDate,
  }) {
    final query = FlightSearchQuery(
      originCode: originCode ?? _flightOriginCode,
      originCity: originCity ?? _flightOriginCity,
      destinationCode: destCode ?? _flightDestCode,
      destinationCity: destCity ?? _flightDestCity,
      departureDate: depDate ?? _flightDepartureDate,
      adults: _flightAdults,
      cabinClass: _flightCabin,
    );

    final bloc = FlightSearchBloc(repository: _flightRepository);
    bloc.add(SearchFlightsRequested(query));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FlightSearchResultsScreen(bloc: bloc),
      ),
    );
  }

  void _executeHotelSearch({String? city, DateTime? checkIn, DateTime? checkOut}) {
    final query = HotelSearchQuery(
      destination: city ?? _hotelCity,
      city: city ?? _hotelCity,
      checkInDate: checkIn ?? _hotelCheckIn,
      checkOutDate: checkOut ?? _hotelCheckOut,
      adults: _hotelGuests,
      rooms: _hotelRooms,
    );

    final bloc = HotelSearchBloc(repository: _hotelRepository);
    bloc.add(SearchHotelsRequested(query));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelSearchResultsScreen(bloc: bloc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRAVELGO • Explore & Book', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.electricCyan,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.flight_takeoff, size: 20), text: 'Flights'),
            Tab(icon: Icon(Icons.hotel, size: 20), text: 'Hotels'),
            Tab(icon: Icon(Icons.luggage, size: 20), text: 'Packages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFlightSearchTab(),
          _buildHotelSearchTab(),
          _buildPackagesTab(),
        ],
      ),
    );
  }

  Widget _buildFlightSearchTab() {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // FLIGHT SEARCH HERO CARD
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryNavy, Color(0xFF1E293B), AppTheme.accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.flight_takeoff, color: AppTheme.electricCyan, size: 24),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Live Flight Search',
                                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Quick Airport Search',
                        icon: const Icon(Icons.search, color: AppTheme.electricCyan),
                        onPressed: _selectDestination,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Route Selectors with Swap Button
                  if (context.isDesktop) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildSelectorTile(
                            label: 'FROM / المغادرة',
                            value: '$_flightOriginCity ($_flightOriginCode)',
                            icon: Icons.flight_takeoff,
                            onTap: _selectOrigin,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: IconButton.filledTonal(
                            tooltip: 'Swap Airports',
                            icon: const Icon(Icons.swap_horiz, color: AppTheme.primaryNavy),
                            style: IconButton.styleFrom(backgroundColor: AppTheme.electricCyan),
                            onPressed: _swapAirports,
                          ),
                        ),
                        Expanded(
                          child: _buildSelectorTile(
                            label: 'TO / الوجهة',
                            value: '$_flightDestCity ($_flightDestCode)',
                            icon: Icons.flight_land,
                            onTap: _selectDestination,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSelectorTile(
                            label: 'Departure Date',
                            value: DateFormatter.formatDate(_flightDepartureDate),
                            icon: Icons.calendar_today,
                            onTap: _selectFlightDate,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Column(
                          children: [
                            _buildSelectorTile(
                              label: 'FROM (Departure)',
                              value: '$_flightOriginCity ($_flightOriginCode)',
                              icon: Icons.flight_takeoff,
                              onTap: _selectOrigin,
                            ),
                            const SizedBox(height: 10),
                            _buildSelectorTile(
                              label: 'TO (Arrival)',
                              value: '$_flightDestCity ($_flightDestCode)',
                              icon: Icons.flight_land,
                              onTap: _selectDestination,
                            ),
                          ],
                        ),
                        Positioned(
                          right: 16,
                          child: InkWell(
                            onTap: _swapAirports,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.electricCyan,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.swap_vert, color: AppTheme.primaryNavy, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildSelectorTile(
                      label: 'Departure Date',
                      value: DateFormatter.formatDate(_flightDepartureDate),
                      icon: Icons.calendar_today,
                      onTap: _selectFlightDate,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Cabin class selector chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Economy', 'Business', 'First'].map((cabin) {
                        final isSelected = _flightCabin == cabin;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(cabin, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.white70)),
                            selected: isSelected,
                            selectedColor: AppTheme.accentBlue,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            side: BorderSide.none,
                            onSelected: (_) => setState(() => _flightCabin = cabin),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Transparency Banner
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.electricCyan.withValues(alpha: 0.3), width: 1),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppTheme.electricCyan, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'TRAVELGO 0.75% Fixed Fee Transparency • No hidden airfare markups',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _executeFlightSearch(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.electricCyan,
                        foregroundColor: AppTheme.primaryNavy,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.search, fontWeight: FontWeight.bold),
                      label: const Text(
                        'Search Available Flights',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // QUICK POPULAR DESTINATIONS SHORTCUTS
            // ==========================================
            Text(
              'Popular Global Routes (1-Tap Search)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickDestinationChip('🇫🇷 Paris (CDG)', 'CDG', 'Paris'),
                  _buildQuickDestinationChip('🇹🇷 Istanbul (IST)', 'IST', 'Istanbul'),
                  _buildQuickDestinationChip('🇦🇪 Dubai (DXB)', 'DXB', 'Dubai'),
                  _buildQuickDestinationChip('🇶🇦 Doha (DOH)', 'DOH', 'Doha'),
                  _buildQuickDestinationChip('🇸🇦 Jeddah (JED)', 'JED', 'Jeddah'),
                  _buildQuickDestinationChip('🇬🇧 London (LHR)', 'LHR', 'London'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Explore Top Flight Destinations (Direct Search)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
            ),
            const SizedBox(height: 12),

            _buildPromoRouteCard(
              originCity: 'Algiers',
              originCode: 'ALG',
              destCity: 'Istanbul',
              destCode: 'IST',
              airline: 'Air Algerie & Turkish Airlines Direct',
              startingPrice: '\$251.88',
              flag: '🇹🇷',
              onTap: () => _executeFlightSearch(
                originCode: 'ALG',
                originCity: 'Algiers',
                destCode: 'IST',
                destCity: 'Istanbul',
              ),
            ),
            const SizedBox(height: 10),
            _buildPromoRouteCard(
              originCity: 'Algiers',
              originCode: 'ALG',
              destCity: 'Paris',
              destCode: 'CDG',
              airline: 'Air France & Air Algerie Daily',
              startingPrice: '\$342.55',
              flag: '🇫🇷',
              onTap: () => _executeFlightSearch(
                originCode: 'ALG',
                originCity: 'Algiers',
                destCode: 'CDG',
                destCity: 'Paris',
              ),
            ),
            const SizedBox(height: 10),
            _buildPromoRouteCard(
              originCity: 'Dubai',
              originCode: 'DXB',
              destCity: 'London',
              destCode: 'LHR',
              airline: 'Emirates Non-stop',
              startingPrice: '\$725.40',
              flag: '🇬🇧',
              onTap: () => _executeFlightSearch(
                originCode: 'DXB',
                originCity: 'Dubai',
                destCode: 'LHR',
                destCity: 'London',
              ),
            ),
            const SizedBox(height: 10),
            _buildPromoRouteCard(
              originCity: 'Algiers',
              originCode: 'ALG',
              destCity: 'Doha',
              destCode: 'DOH',
              airline: 'Qatar Airways Direct',
              startingPrice: '\$480.00',
              flag: '🇶🇦',
              onTap: () => _executeFlightSearch(
                originCode: 'ALG',
                originCity: 'Algiers',
                destCode: 'DOH',
                destCity: 'Doha',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDestinationChip(String label, String code, String city) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryNavy)),
        backgroundColor: AppTheme.slateBackground,
        side: const BorderSide(color: AppTheme.cardBorder),
        onPressed: () {
          setState(() {
            _flightDestCode = code;
            _flightDestCity = city;
          });
          _executeFlightSearch(destCode: code, destCity: city);
        },
      ),
    );
  }

  Widget _buildHotelSearchTab() {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryNavy, Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.hotel, color: AppTheme.electricCyan, size: 24),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Global Hotel Search',
                                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Search City',
                        icon: const Icon(Icons.search, color: AppTheme.electricCyan),
                        onPressed: _selectHotelCity,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSelectorTile(
                    label: 'Destination City',
                    value: _hotelCity,
                    icon: Icons.location_city,
                    onTap: _selectHotelCity,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectorTile(
                          label: 'Check-in',
                          value: DateFormatter.formatDate(_hotelCheckIn),
                          icon: Icons.calendar_today,
                          onTap: _selectCheckInDate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSelectorTile(
                          label: 'Check-out',
                          value: DateFormatter.formatDate(_hotelCheckOut),
                          icon: Icons.event,
                          onTap: _selectCheckOutDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.group, color: AppTheme.accentBlue, size: 20),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Guests & Rooms', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                                  Text('2 Adults • 1 Room', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _executeHotelSearch(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.electricCyan,
                        foregroundColor: AppTheme.primaryNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.search, fontWeight: FontWeight.bold),
                      label: const Text(
                        'Search Available Hotels',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Featured Luxury Hotel Properties',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
            ),
            const SizedBox(height: 12),

            _buildPromoHotelCard(
              name: 'Bosphorus View Grand Hotel',
              city: 'Istanbul, Turkey',
              rate: 'From \$130.98 / night',
              badge: '5-Star Luxury',
              rating: '9.6 Exceptional',
              onTap: () => _executeHotelSearch(city: 'Istanbul'),
            ),
            const SizedBox(height: 10),
            _buildPromoHotelCard(
              name: 'The Ritz-Carlton Waterfront',
              city: 'Istanbul, Turkey',
              rate: 'From \$221.65 / night',
              badge: 'VIP Concierge',
              rating: '9.8 Ultra Luxury',
              onTap: () => _executeHotelSearch(city: 'Istanbul'),
            ),
            const SizedBox(height: 10),
            _buildPromoHotelCard(
              name: 'Hotel El Aurassi Algiers',
              city: 'Algiers, Algeria',
              rate: 'From \$150.00 / night',
              badge: 'Panoramic Bay View',
              rating: '9.2 Highly Rated',
              onTap: () => _executeHotelSearch(city: 'Algiers'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackagesTab() {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryNavy, Color(0xFF0F766E), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.luggage, color: AppTheme.electricCyan, size: 26),
                      SizedBox(width: 10),
                      Text(
                        'Flight + Hotel Vacation Combos',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Bundle your roundtrip flight and luxury hotel stay together to save up to 25% with full 0.75% TRAVELGO service transparency.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _executeFlightSearch(
                        originCode: 'ALG',
                        originCity: 'Algiers',
                        destCode: 'IST',
                        destCity: 'Istanbul',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.electricCyan,
                        foregroundColor: AppTheme.primaryNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text('Explore Vacation Packages', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Curated All-Inclusive Getaways',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
            ),
            const SizedBox(height: 12),

            _buildPackageCard(
              title: '🌟 Istanbul 5-Day VIP Discovery',
              route: 'Algiers (ALG) ⇄ Istanbul (IST)',
              hotel: 'Grand Bosphorus 5-Star Hotel (4 Nights)',
              price: '\$580.00 / person',
              savings: 'Save 22%',
              onTap: () => _executeFlightSearch(originCode: 'ALG', destCode: 'IST'),
            ),
            const SizedBox(height: 12),
            _buildPackageCard(
              title: '🗼 Paris Romantic 4-Day Escape',
              route: 'Algiers (ALG) ⇄ Paris (CDG)',
              hotel: 'Boutique Champs-Élysées Luxury Stay',
              price: '\$695.00 / person',
              savings: 'Save 18%',
              onTap: () => _executeFlightSearch(originCode: 'ALG', destCode: 'CDG'),
            ),
            const SizedBox(height: 12),
            _buildPackageCard(
              title: '🌴 Dubai Marina & Skyline Holiday',
              route: 'Algiers (ALG) ⇄ Dubai (DXB)',
              hotel: 'Jumeirah Beachfront Resort (5 Nights)',
              price: '\$890.00 / person',
              savings: 'Save 25%',
              onTap: () => _executeFlightSearch(originCode: 'ALG', destCode: 'DXB'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard({
    required String title,
    required String route,
    required String hotel,
    required String price,
    required String savings,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(savings, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.successGreen)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.flight, size: 16, color: AppTheme.accentBlue),
                  const SizedBox(width: 6),
                  Text(route, style: const TextStyle(fontSize: 12, color: AppTheme.textDark)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.hotel, size: 16, color: AppTheme.accentBlue),
                  const SizedBox(width: 6),
                  Text(hotel, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              const Divider(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total with 0.75% fee:', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.accentBlue)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accentBlue, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoRouteCard({
    required String originCity,
    required String originCode,
    required String destCity,
    required String destCode,
    required String airline,
    required String startingPrice,
    required String flag,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(flag, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$originCity ($originCode) → $destCity ($destCode)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                    ),
                    const SizedBox(height: 2),
                    Text(airline, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    startingPrice,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.accentBlue),
                  ),
                  const Text('incl. 0.75%', style: TextStyle(fontSize: 10, color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoHotelCard({
    required String name,
    required String city,
    required String rate,
    required String badge,
    required String rating,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.hotel, color: AppTheme.accentBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy), overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.warningOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.warningOrange)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(city, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(rate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.accentBlue)),
                  Text(rating, style: const TextStyle(fontSize: 10.5, color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectOrigin() async {
    final selected = await AirportSearchModal.show(
      context,
      title: 'Select Origin Airport',
      initialCode: _flightOriginCode,
    );
    if (selected != null) {
      setState(() {
        _flightOriginCode = selected.code;
        _flightOriginCity = selected.city;
      });
    }
  }

  void _selectDestination() async {
    final selected = await AirportSearchModal.show(
      context,
      title: 'Select Destination Airport',
      initialCode: _flightDestCode,
    );
    if (selected != null) {
      setState(() {
        _flightDestCode = selected.code;
        _flightDestCity = selected.city;
      });
      // Directly execute search for selected destination
      _executeFlightSearch(
        destCode: selected.code,
        destCity: selected.city,
      );
    }
  }

  void _selectHotelCity() async {
    final selected = await CitySearchModal.show(
      context,
      title: 'Select Hotel Destination City',
      initialCity: _hotelCity,
    );
    if (selected != null) {
      setState(() => _hotelCity = selected.city);
      // Directly execute search for hotels in that city
      _executeHotelSearch(city: selected.city);
    }
  }

  void _selectFlightDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _flightDepartureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _flightDepartureDate = picked);
    }
  }

  void _selectCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hotelCheckIn,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _hotelCheckIn = picked;
        if (_hotelCheckOut.isBefore(picked.add(const Duration(days: 1)))) {
          _hotelCheckOut = picked.add(const Duration(days: 2));
        }
      });
    }
  }

  void _selectCheckOutDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hotelCheckOut,
      firstDate: _hotelCheckIn.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _hotelCheckOut = picked);
    }
  }
}
