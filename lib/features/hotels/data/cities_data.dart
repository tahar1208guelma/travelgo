class CityDestinationInfo {
  final String city;
  final String country;
  final String region;
  final int propertyCount;
  final String popularLandmark;
  final bool isPopular;

  const CityDestinationInfo({
    required this.city,
    required this.country,
    required this.region,
    required this.propertyCount,
    required this.popularLandmark,
    this.isPopular = false,
  });

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return city.toLowerCase().contains(q) ||
        country.toLowerCase().contains(q) ||
        popularLandmark.toLowerCase().contains(q);
  }
}

class CitiesData {
  static const List<CityDestinationInfo> globalCities = [
    CityDestinationInfo(
      city: 'Istanbul',
      country: 'Turkey',
      region: 'Europe / Asia',
      propertyCount: 2450,
      popularLandmark: 'Bosphorus, Taksim, Sultanahmet',
      isPopular: true,
    ),
    CityDestinationInfo(
      city: 'Algiers',
      country: 'Algeria',
      region: 'MENA',
      propertyCount: 380,
      popularLandmark: 'El Aurassi, Casbah, Hydra',
      isPopular: true,
    ),
    CityDestinationInfo(
      city: 'Paris',
      country: 'France',
      region: 'Europe',
      propertyCount: 3120,
      popularLandmark: 'Champs-Elysees, Eiffel Tower, Louvre',
      isPopular: true,
    ),
    CityDestinationInfo(
      city: 'Dubai',
      country: 'United Arab Emirates',
      region: 'MENA',
      propertyCount: 1890,
      popularLandmark: 'Downtown, Palm Jumeirah, Marina',
      isPopular: true,
    ),
    CityDestinationInfo(
      city: 'London',
      country: 'United Kingdom',
      region: 'Europe',
      propertyCount: 2900,
      popularLandmark: 'Westminster, Hyde Park, Covent Garden',
      isPopular: true,
    ),
    CityDestinationInfo(
      city: 'Doha',
      country: 'Qatar',
      region: 'MENA',
      propertyCount: 650,
      popularLandmark: 'The Pearl, West Bay, Souq Waqif',
      isPopular: true,
    ),
    CityDestinationInfo(
      city: 'Cairo',
      country: 'Egypt',
      region: 'MENA',
      propertyCount: 1100,
      popularLandmark: 'Zamalek, Giza Pyramids, Nile Corniche',
      isPopular: true,
    ),
    CityDestinationInfo(
      city: 'Rome',
      country: 'Italy',
      region: 'Europe',
      propertyCount: 2200,
      popularLandmark: 'Colosseum, Trevi Fountain, Vatican',
      isPopular: true,
    ),
    CityDestinationInfo(
      city: 'Madrid',
      country: 'Spain',
      region: 'Europe',
      propertyCount: 1750,
      popularLandmark: 'Gran Via, Puerta del Sol, Retiro Park',
      isPopular: true,
    ),
    CityDestinationInfo(
      city: 'New York',
      country: 'United States',
      region: 'Americas',
      propertyCount: 2100,
      popularLandmark: 'Manhattan, Central Park, Times Square',
      isPopular: true,
    ),
    CityDestinationInfo(
      city: 'Tokyo',
      country: 'Japan',
      region: 'Asia',
      propertyCount: 2800,
      popularLandmark: 'Shinjuku, Shibuya, Ginza',
      isPopular: true,
    ),
    CityDestinationInfo(
      city: 'Riyadh',
      country: 'Saudi Arabia',
      region: 'MENA',
      propertyCount: 920,
      popularLandmark: 'Kingdom Centre, Olaya, Al Nakheel',
      isPopular: true,
    ),
  ];
}
