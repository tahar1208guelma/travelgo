import '../../../shared/models/airport.dart';

/// Service responsible for resolving multi-airport city codes (LON, NYC, PAR, DXB, TYO, etc.)
/// and discovering nearby airports within a configurable radius (+150 km standard).
class CityAirportsResolver {
  const CityAirportsResolver();

  /// Determines whether a given 3-letter IATA code corresponds to a metropolitan area
  /// containing multiple commercial passenger airports.
  bool isMultiAirportCity(String code) {
    return Airport.isMetropolitanCityCode(code);
  }

  /// Resolves an origin or destination input (metropolitan code, city name, or specific airport code)
  /// into a distinct list of operational IATA airport codes.
  ///
  /// If [includeNearby] is enabled, airports within [radiusKm] (default 150 km) are appended.
  List<String> resolveAirportCodes(
    String codeOrCity, {
    bool includeNearby = false,
    double radiusKm = 150.0,
  }) {
    return Airport.resolveAirportCodes(
      codeOrCity,
      includeNearby: includeNearby,
      radiusKm: radiusKm,
    );
  }

  /// Retrieves all sister airports sharing the same metropolitan market.
  /// For instance, passing 'LHR' returns [LHR, LGW, STN, LTN, LCY].
  List<Airport> getSisterAirports(String airportCode) {
    final code = airportCode.trim().toUpperCase();
    final airport = Airport.findByCode(code);
    if (airport == null) {
      return Airport.getAirportsForCity(code);
    }

    final cityAirports = Airport.getAirportsForCity(airport.cityCode);
    if (cityAirports.isNotEmpty) {
      return cityAirports;
    }
    return [airport];
  }

  /// Discovers commercial airports located within [radiusKm] (default 150 km) of [airportCode].
  List<Airport> getNearbyAirports(String airportCode, {double radiusKm = 150.0}) {
    final airport = Airport.findByCode(airportCode);
    if (airport == null) return [];
    return airport.getNearbyAirports(radiusKm: radiusKm);
  }
}
