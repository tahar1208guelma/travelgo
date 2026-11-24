import 'dart:math';

class Airport {
  final String code;
  final String nameEn;
  final String nameAr;
  final String cityEn;
  final String cityAr;
  final String countryEn;
  final String countryAr;
  final String cityCode;
  final double latitude;
  final double longitude;

  const Airport({
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.cityEn,
    required this.cityAr,
    required this.countryEn,
    required this.countryAr,
    String? cityCode,
    this.latitude = 0.0,
    this.longitude = 0.0,
  }) : cityCode = cityCode ?? code;

  String getCity({bool isArabic = false}) => isArabic ? cityAr : cityEn;
  String getName({bool isArabic = false}) => isArabic ? nameAr : nameEn;
  String getCountry({bool isArabic = false}) => isArabic ? countryAr : countryEn;

  /// Haversine formula to compute great-circle distance in kilometers
  double distanceTo(Airport other) {
    return distanceToCoords(other.latitude, other.longitude);
  }

  double distanceToCoords(double otherLat, double otherLng) {
    if ((latitude == 0.0 && longitude == 0.0) || (otherLat == 0.0 && otherLng == 0.0)) {
      return 0.0;
    }
    const earthRadiusKm = 6371.0;
    final dLat = (otherLat - latitude) * pi / 180.0;
    final dLon = (otherLng - longitude) * pi / 180.0;
    final lat1 = latitude * pi / 180.0;
    final lat2 = otherLat * pi / 180.0;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Returns nearby airports within [radiusKm] (default 150 km)
  List<Airport> getNearbyAirports({double radiusKm = 150.0}) {
    if (latitude == 0.0 && longitude == 0.0) return [];
    return majorAirports.where((other) {
      if (other.code == code) return false;
      final dist = distanceTo(other);
      return dist > 0 && dist <= radiusKm;
    }).toList();
  }

  /// Finds airports matching a city code or search query
  static List<Airport> findAirports(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return majorAirports;
    return majorAirports.where((a) {
      return a.code.toLowerCase() == q ||
          a.cityCode.toLowerCase() == q ||
          a.cityEn.toLowerCase().contains(q) ||
          a.cityAr.contains(q) ||
          a.nameEn.toLowerCase().contains(q) ||
          a.nameAr.contains(q) ||
          a.countryEn.toLowerCase().contains(q) ||
          a.countryAr.contains(q);
    }).toList();
  }

  static Airport? findByCode(String code) {
    final c = code.trim().toUpperCase();
    try {
      return majorAirports.firstWhere((a) => a.code == c);
    } catch (_) {
      return null;
    }
  }

  /// Metropolitan city codes mapping to constituent commercial airports.
  static const Map<String, List<String>> metropolitanCityCodes = {
    'LON': ['LHR', 'LGW', 'STN', 'LTN', 'LCY'], // London
    'NYC': ['JFK', 'EWR', 'LGA'], // New York
    'PAR': ['CDG', 'ORY', 'BVA'], // Paris
    'DXB': ['DXB', 'DWC'], // Dubai
    'TYO': ['HND', 'NRT'], // Tokyo
    'ROM': ['FCO', 'CIA'], // Rome
    'MIL': ['MXP', 'LIN'], // Milan
    'CHI': ['ORD', 'MDW'], // Chicago
    'WAS': ['IAD', 'DCA', 'BWI'], // Washington D.C.
    'IST': ['IST', 'SAW'], // Istanbul
    'BUE': ['EZE', 'AEP'], // Buenos Aires
    'YTO': ['YYZ'], // Toronto
  };

  /// Returns true if [code] is a multi-airport metropolitan area code (e.g. LON, NYC, PAR, TYO, DXB).
  static bool isMetropolitanCityCode(String code) {
    return metropolitanCityCodes.containsKey(code.trim().toUpperCase());
  }

  /// Returns all airports associated with a metropolitan or city code.
  static List<Airport> getAirportsForCity(String code) {
    final upper = code.trim().toUpperCase();
    if (metropolitanCityCodes.containsKey(upper)) {
      final codes = metropolitanCityCodes[upper]!;
      return majorAirports.where((a) => codes.contains(a.code)).toList();
    }
    final byCityCode = majorAirports.where((a) => a.cityCode.toUpperCase() == upper).toList();
    if (byCityCode.isNotEmpty) return byCityCode;

    final single = findByCode(upper);
    return single != null ? [single] : [];
  }

  /// Resolves an IATA airport code, city code, or query into a list of specific airport codes.
  /// If [includeNearby] is true, includes nearby airports within [radiusKm] (default 150 km).
  static List<String> resolveAirportCodes(
    String codeOrCity, {
    bool includeNearby = false,
    double radiusKm = 150.0,
  }) {
    final Set<String> resolved = {};
    final upper = codeOrCity.trim().toUpperCase();

    if (metropolitanCityCodes.containsKey(upper)) {
      resolved.addAll(metropolitanCityCodes[upper]!);
    }

    for (final airport in majorAirports) {
      if (airport.cityCode.toUpperCase() == upper || airport.code.toUpperCase() == upper) {
        resolved.add(airport.code);
      }
    }

    if (resolved.isEmpty) {
      final matches = findAirports(codeOrCity);
      for (final m in matches) {
        resolved.add(m.code);
      }
    }

    if (includeNearby && resolved.isNotEmpty) {
      final currentList = resolved.map((c) => findByCode(c)).whereType<Airport>().toList();
      for (final a in currentList) {
        final nearby = a.getNearbyAirports(radiusKm: radiusKm);
        for (final n in nearby) {
          resolved.add(n.code);
        }
      }
    }

    return resolved.isNotEmpty ? resolved.toList() : [upper];
  }

  static const List<Airport> majorAirports = [
    // ALGERIA & NORTH AFRICA
    Airport(
      code: 'ALG',
      cityCode: 'ALG',
      nameEn: 'Houari Boumediene Airport',
      nameAr: 'مطار هواري بومدين الدولي',
      cityEn: 'Algiers',
      cityAr: 'الجزائر العاصمة',
      countryEn: 'Algeria',
      countryAr: 'الجزائر',
      latitude: 36.6910,
      longitude: 3.2154,
    ),
    Airport(
      code: 'ORN',
      cityCode: 'ORN',
      nameEn: 'Ahmed Ben Bella Airport',
      nameAr: 'مطار أحمد بن بلة الدولي',
      cityEn: 'Oran',
      cityAr: 'وهران',
      countryEn: 'Algeria',
      countryAr: 'الجزائر',
      latitude: 35.6238,
      longitude: -0.6212,
    ),
    Airport(
      code: 'CZL',
      cityCode: 'CZL',
      nameEn: 'Mohamed Boudiaf Airport',
      nameAr: 'مطار محمد بوضياف الدولي',
      cityEn: 'Constantine',
      cityAr: 'قسنطينة',
      countryEn: 'Algeria',
      countryAr: 'الجزائر',
      latitude: 36.2760,
      longitude: 6.6204,
    ),
    Airport(
      code: 'AAE',
      cityCode: 'AAE',
      nameEn: 'Rabah Bitat Airport',
      nameAr: 'مطار رابح بيطاط الدولي',
      cityEn: 'Annaba',
      cityAr: 'عنابة',
      countryEn: 'Algeria',
      countryAr: 'الجزائر',
      latitude: 36.8222,
      longitude: 7.8094,
    ),
    Airport(
      code: 'CAI',
      cityCode: 'CAI',
      nameEn: 'Cairo International Airport',
      nameAr: 'مطار القاهرة الدولي',
      cityEn: 'Cairo',
      cityAr: 'القاهرة',
      countryEn: 'Egypt',
      countryAr: 'مصر',
      latitude: 30.1219,
      longitude: 31.4056,
    ),
    Airport(
      code: 'CMN',
      cityCode: 'CAS',
      nameEn: 'Mohammed V International Airport',
      nameAr: 'مطار محمد الخامس الدولي',
      cityEn: 'Casablanca',
      cityAr: 'الدار البيضاء',
      countryEn: 'Morocco',
      countryAr: 'المغرب',
      latitude: 33.3675,
      longitude: -7.5898,
    ),
    Airport(
      code: 'TUN',
      cityCode: 'TUN',
      nameEn: 'Tunis-Carthage International Airport',
      nameAr: 'مطار تونس قرطاج الدولي',
      cityEn: 'Tunis',
      cityAr: 'تونس',
      countryEn: 'Tunisia',
      countryAr: 'تونس',
      latitude: 36.8510,
      longitude: 10.2272,
    ),

    // MIDDLE EAST & GULF
    Airport(
      code: 'DXB',
      cityCode: 'DXB',
      nameEn: 'Dubai International Airport',
      nameAr: 'مطار دبي الدولي',
      cityEn: 'Dubai',
      cityAr: 'دبي',
      countryEn: 'United Arab Emirates',
      countryAr: 'الإمارات العربية المتحدة',
      latitude: 25.2532,
      longitude: 55.3657,
    ),
    Airport(
      code: 'DWC',
      cityCode: 'DXB',
      nameEn: 'Al Maktoum International Airport',
      nameAr: 'مطار آل مكتوم الدولي',
      cityEn: 'Dubai',
      cityAr: 'دبي',
      countryEn: 'United Arab Emirates',
      countryAr: 'الإمارات العربية المتحدة',
      latitude: 24.8960,
      longitude: 55.1614,
    ),
    Airport(
      code: 'AUH',
      cityCode: 'AUH',
      nameEn: 'Zayed International Airport',
      nameAr: 'مطار زايد الدولي',
      cityEn: 'Abu Dhabi',
      cityAr: 'أبوظبي',
      countryEn: 'United Arab Emirates',
      countryAr: 'الإمارات العربية المتحدة',
      latitude: 24.4330,
      longitude: 54.6511,
    ),
    Airport(
      code: 'DOH',
      cityCode: 'DOH',
      nameEn: 'Hamad International Airport',
      nameAr: 'مطار حمد الدولي',
      cityEn: 'Doha',
      cityAr: 'الدوحة',
      countryEn: 'Qatar',
      countryAr: 'قطر',
      latitude: 25.2731,
      longitude: 51.6081,
    ),
    Airport(
      code: 'RUH',
      cityCode: 'RUH',
      nameEn: 'King Khalid International Airport',
      nameAr: 'مطار الملك خالد الدولي',
      cityEn: 'Riyadh',
      cityAr: 'الرياض',
      countryEn: 'Saudi Arabia',
      countryAr: 'المملكة العربية السعودية',
      latitude: 24.9576,
      longitude: 46.6988,
    ),
    Airport(
      code: 'JED',
      cityCode: 'JED',
      nameEn: 'King Abdulaziz International Airport',
      nameAr: 'مطار الملك عبد العزيز الدولي',
      cityEn: 'Jeddah',
      cityAr: 'جدة',
      countryEn: 'Saudi Arabia',
      countryAr: 'المملكة العربية السعودية',
      latitude: 21.6796,
      longitude: 39.1565,
    ),
    Airport(
      code: 'MED',
      cityCode: 'MED',
      nameEn: 'Prince Mohammad Bin Abdulaziz Airport',
      nameAr: 'مطار الأمير محمد بن عبد العزيز الدولي',
      cityEn: 'Medina',
      cityAr: 'المدينة المنورة',
      countryEn: 'Saudi Arabia',
      countryAr: 'المملكة العربية السعودية',
      latitude: 24.5534,
      longitude: 39.7051,
    ),
    Airport(
      code: 'KWI',
      cityCode: 'KWI',
      nameEn: 'Kuwait International Airport',
      nameAr: 'مطار الكويت الدولي',
      cityEn: 'Kuwait City',
      cityAr: 'الكويت',
      countryEn: 'Kuwait',
      countryAr: 'الكويت',
      latitude: 29.2268,
      longitude: 47.9788,
    ),
    Airport(
      code: 'BAH',
      cityCode: 'BAH',
      nameEn: 'Bahrain International Airport',
      nameAr: 'مطار البحرين الدولي',
      cityEn: 'Manama',
      cityAr: 'المنامة',
      countryEn: 'Bahrain',
      countryAr: 'البحرين',
      latitude: 26.2708,
      longitude: 50.6336,
    ),
    Airport(
      code: 'MCT',
      cityCode: 'MCT',
      nameEn: 'Muscat International Airport',
      nameAr: 'مطار مسقط الدولي',
      cityEn: 'Muscat',
      cityAr: 'مسقط',
      countryEn: 'Oman',
      countryAr: 'سلطنة عمان',
      latitude: 23.5933,
      longitude: 58.2844,
    ),
    Airport(
      code: 'AMM',
      cityCode: 'AMM',
      nameEn: 'Queen Alia International Airport',
      nameAr: 'مطار الملكة علياء الدولي',
      cityEn: 'Amman',
      cityAr: 'عمان',
      countryEn: 'Jordan',
      countryAr: 'الأردن',
      latitude: 31.7226,
      longitude: 35.9932,
    ),
    Airport(
      code: 'BEY',
      cityCode: 'BEY',
      nameEn: 'Beirut-Rafic Hariri International Airport',
      nameAr: 'مطار رفيق الحريري الدولي',
      cityEn: 'Beirut',
      cityAr: 'بيروت',
      countryEn: 'Lebanon',
      countryAr: 'لبنان',
      latitude: 33.8209,
      longitude: 35.4884,
    ),

    // TURKEY & EUROPE
    Airport(
      code: 'IST',
      cityCode: 'IST',
      nameEn: 'Istanbul International Airport',
      nameAr: 'مطار إسطنبول الدولي',
      cityEn: 'Istanbul',
      cityAr: 'إسطنبول',
      countryEn: 'Turkey',
      countryAr: 'تركيا',
      latitude: 41.2753,
      longitude: 28.7519,
    ),
    Airport(
      code: 'SAW',
      cityCode: 'IST',
      nameEn: 'Sabiha Gokcen International Airport',
      nameAr: 'مطار صبيحة كوكجن الدولي',
      cityEn: 'Istanbul',
      cityAr: 'إسطنبول',
      countryEn: 'Turkey',
      countryAr: 'تركيا',
      latitude: 40.8986,
      longitude: 29.3092,
    ),
    Airport(
      code: 'CDG',
      cityCode: 'PAR',
      nameEn: 'Charles de Gaulle Airport',
      nameAr: 'مطار شارل ديغول الدولي',
      cityEn: 'Paris',
      cityAr: 'باريس',
      countryEn: 'France',
      countryAr: 'فرنسا',
      latitude: 49.0097,
      longitude: 2.5479,
    ),
    Airport(
      code: 'ORY',
      cityCode: 'PAR',
      nameEn: 'Paris Orly Airport',
      nameAr: 'مطار باريس أورلي',
      cityEn: 'Paris',
      cityAr: 'باريس',
      countryEn: 'France',
      countryAr: 'فرنسا',
      latitude: 48.7262,
      longitude: 2.3652,
    ),
    Airport(
      code: 'BVA',
      cityCode: 'PAR',
      nameEn: 'Paris Beauvais Airport',
      nameAr: 'مطار بوفيه تيه باريس',
      cityEn: 'Paris',
      cityAr: 'باريس',
      countryEn: 'France',
      countryAr: 'فرنسا',
      latitude: 49.4544,
      longitude: 2.1128,
    ),
    Airport(
      code: 'LHR',
      cityCode: 'LON',
      nameEn: 'Heathrow Airport',
      nameAr: 'مطار هيثرو الدولي',
      cityEn: 'London',
      cityAr: 'لندن',
      countryEn: 'United Kingdom',
      countryAr: 'المملكة المتحدة',
      latitude: 51.4700,
      longitude: -0.4543,
    ),
    Airport(
      code: 'LGW',
      cityCode: 'LON',
      nameEn: 'Gatwick Airport',
      nameAr: 'مطار غاتويك الدولي',
      cityEn: 'London',
      cityAr: 'لندن',
      countryEn: 'United Kingdom',
      countryAr: 'المملكة المتحدة',
      latitude: 51.1537,
      longitude: -0.1821,
    ),
    Airport(
      code: 'STN',
      cityCode: 'LON',
      nameEn: 'Stansted Airport',
      nameAr: 'مطار لندن ستانستد',
      cityEn: 'London',
      cityAr: 'لندن',
      countryEn: 'United Kingdom',
      countryAr: 'المملكة المتحدة',
      latitude: 51.8860,
      longitude: 0.2389,
    ),
    Airport(
      code: 'LTN',
      cityCode: 'LON',
      nameEn: 'London Luton Airport',
      nameAr: 'مطار لندن لوتون',
      cityEn: 'London',
      cityAr: 'لندن',
      countryEn: 'United Kingdom',
      countryAr: 'المملكة المتحدة',
      latitude: 51.8747,
      longitude: -0.3683,
    ),
    Airport(
      code: 'LCY',
      cityCode: 'LON',
      nameEn: 'London City Airport',
      nameAr: 'مطار لندن سيتي',
      cityEn: 'London',
      cityAr: 'لندن',
      countryEn: 'United Kingdom',
      countryAr: 'المملكة المتحدة',
      latitude: 51.5053,
      longitude: 0.0553,
    ),
    Airport(
      code: 'FRA',
      cityCode: 'FRA',
      nameEn: 'Frankfurt Airport',
      nameAr: 'مطار فرانكفورت الدولي',
      cityEn: 'Frankfurt',
      cityAr: 'فرانكفورت',
      countryEn: 'Germany',
      countryAr: 'ألمانيا',
      latitude: 50.0379,
      longitude: 8.5622,
    ),
    Airport(
      code: 'MUC',
      cityCode: 'MUC',
      nameEn: 'Munich Airport',
      nameAr: 'مطار ميونخ الدولي',
      cityEn: 'Munich',
      cityAr: 'ميونخ',
      countryEn: 'Germany',
      countryAr: 'ألمانيا',
      latitude: 48.3537,
      longitude: 11.7861,
    ),
    Airport(
      code: 'AMS',
      cityCode: 'AMS',
      nameEn: 'Amsterdam Airport Schiphol',
      nameAr: 'مطار سخيبول أمستردام',
      cityEn: 'Amsterdam',
      cityAr: 'أمستردام',
      countryEn: 'Netherlands',
      countryAr: 'هولندا',
      latitude: 52.3105,
      longitude: 4.7683,
    ),
    Airport(
      code: 'MAD',
      cityCode: 'MAD',
      nameEn: 'Adolfo Suarez Madrid-Barajas Airport',
      nameAr: 'مطار مدريد باراخاس الدولي',
      cityEn: 'Madrid',
      cityAr: 'مدريد',
      countryEn: 'Spain',
      countryAr: 'إسبانيا',
      latitude: 40.4839,
      longitude: -3.5680,
    ),
    Airport(
      code: 'BCN',
      cityCode: 'BCN',
      nameEn: 'Josep Tarradellas Barcelona-El Prat Airport',
      nameAr: 'مطار برشلونة الدولي',
      cityEn: 'Barcelona',
      cityAr: 'برشلونة',
      countryEn: 'Spain',
      countryAr: 'إسبانيا',
      latitude: 41.2974,
      longitude: 2.0833,
    ),
    Airport(
      code: 'FCO',
      cityCode: 'ROM',
      nameEn: 'Leonardo da Vinci-Fiumicino Airport',
      nameAr: 'مطار ليوناردو دا فينشي فيوميتشينو',
      cityEn: 'Rome',
      cityAr: 'روما',
      countryEn: 'Italy',
      countryAr: 'إيطاليا',
      latitude: 41.8003,
      longitude: 12.2389,
    ),
    Airport(
      code: 'CIA',
      cityCode: 'ROM',
      nameEn: 'Rome Ciampino Airport',
      nameAr: 'مطار روما شيامبينو',
      cityEn: 'Rome',
      cityAr: 'روما',
      countryEn: 'Italy',
      countryAr: 'إيطاليا',
      latitude: 41.7994,
      longitude: 12.5949,
    ),
    Airport(
      code: 'MXP',
      cityCode: 'MIL',
      nameEn: 'Milan Malpensa Airport',
      nameAr: 'مطار ميلانو مالبينسا',
      cityEn: 'Milan',
      cityAr: 'ميلانو',
      countryEn: 'Italy',
      countryAr: 'إيطاليا',
      latitude: 45.6301,
      longitude: 8.7231,
    ),
    Airport(
      code: 'LIN',
      cityCode: 'MIL',
      nameEn: 'Milan Linate Airport',
      nameAr: 'مطار ميلانو ليناتي',
      cityEn: 'Milan',
      cityAr: 'ميلانو',
      countryEn: 'Italy',
      countryAr: 'إيطاليا',
      latitude: 45.4451,
      longitude: 9.2767,
    ),

    // NORTH AMERICA
    Airport(
      code: 'JFK',
      cityCode: 'NYC',
      nameEn: 'John F. Kennedy International Airport',
      nameAr: 'مطار جون إف كينيدي الدولي',
      cityEn: 'New York',
      cityAr: 'نيويورك',
      countryEn: 'United States',
      countryAr: 'الولايات المتحدة',
      latitude: 40.6413,
      longitude: -73.7781,
    ),
    Airport(
      code: 'EWR',
      cityCode: 'NYC',
      nameEn: 'Newark Liberty International Airport',
      nameAr: 'مطار نيوآرك ليبرتي الدولي',
      cityEn: 'New York',
      cityAr: 'نيويورك',
      countryEn: 'United States',
      countryAr: 'الولايات المتحدة',
      latitude: 40.6895,
      longitude: -74.1745,
    ),
    Airport(
      code: 'LGA',
      cityCode: 'NYC',
      nameEn: 'LaGuardia Airport',
      nameAr: 'مطار لاغوارديا',
      cityEn: 'New York',
      cityAr: 'نيويورك',
      countryEn: 'United States',
      countryAr: 'الولايات المتحدة',
      latitude: 40.7769,
      longitude: -73.8740,
    ),
    Airport(
      code: 'LAX',
      cityCode: 'LAX',
      nameEn: 'Los Angeles International Airport',
      nameAr: 'مطار لوس أنجلوس الدولي',
      cityEn: 'Los Angeles',
      cityAr: 'لوس أنجلوس',
      countryEn: 'United States',
      countryAr: 'الولايات المتحدة',
      latitude: 33.9416,
      longitude: -118.4085,
    ),
    Airport(
      code: 'ORD',
      cityCode: 'CHI',
      nameEn: "O'Hare International Airport",
      nameAr: 'مطار أوهير الدولي شيكاغو',
      cityEn: 'Chicago',
      cityAr: 'شيكاغو',
      countryEn: 'United States',
      countryAr: 'الولايات المتحدة',
      latitude: 41.9742,
      longitude: -87.9073,
    ),
    Airport(
      code: 'MDW',
      cityCode: 'CHI',
      nameEn: 'Chicago Midway International Airport',
      nameAr: 'مطار ميدواي شيكاغو الدولي',
      cityEn: 'Chicago',
      cityAr: 'شيكاغو',
      countryEn: 'United States',
      countryAr: 'الولايات المتحدة',
      latitude: 41.7868,
      longitude: -87.7522,
    ),
    Airport(
      code: 'IAD',
      cityCode: 'WAS',
      nameEn: 'Washington Dulles International Airport',
      nameAr: 'مطار واشنطن دولس الدولي',
      cityEn: 'Washington',
      cityAr: 'واشنطن',
      countryEn: 'United States',
      countryAr: 'الولايات المتحدة',
      latitude: 38.9531,
      longitude: -77.4565,
    ),
    Airport(
      code: 'DCA',
      cityCode: 'WAS',
      nameEn: 'Ronald Reagan Washington National Airport',
      nameAr: 'مطار رونالد ريغان واشنطن الوطني',
      cityEn: 'Washington',
      cityAr: 'واشنطن',
      countryEn: 'United States',
      countryAr: 'الولايات المتحدة',
      latitude: 38.8512,
      longitude: -77.0402,
    ),
    Airport(
      code: 'BWI',
      cityCode: 'WAS',
      nameEn: 'Baltimore/Washington International Airport',
      nameAr: 'مطار بالتيمور واشنطن الدولي',
      cityEn: 'Washington',
      cityAr: 'واشنطن',
      countryEn: 'United States',
      countryAr: 'الولايات المتحدة',
      latitude: 39.1754,
      longitude: -76.6683,
    ),
    Airport(
      code: 'MIA',
      cityCode: 'MIA',
      nameEn: 'Miami International Airport',
      nameAr: 'مطار ميامي الدولي',
      cityEn: 'Miami',
      cityAr: 'ميامي',
      countryEn: 'United States',
      countryAr: 'الولايات المتحدة',
      latitude: 25.7959,
      longitude: -80.2870,
    ),
    Airport(
      code: 'EZE',
      cityCode: 'BUE',
      nameEn: 'Ministro Pistarini International Airport (Ezeiza)',
      nameAr: 'مطار إيزيزا الدولي بوينس آيرس',
      cityEn: 'Buenos Aires',
      cityAr: 'بوينس آيرس',
      countryEn: 'Argentina',
      countryAr: 'الأرجنتين',
      latitude: -34.8222,
      longitude: -58.5358,
    ),
    Airport(
      code: 'AEP',
      cityCode: 'BUE',
      nameEn: 'Aeroparque Jorge Newbery',
      nameAr: 'مطار خورخي نيوبري بوينس آيرس',
      cityEn: 'Buenos Aires',
      cityAr: 'بوينس آيرس',
      countryEn: 'Argentina',
      countryAr: 'الأرجنتين',
      latitude: -34.5592,
      longitude: -58.4156,
    ),
    Airport(
      code: 'YYZ',
      cityCode: 'YTO',
      nameEn: 'Toronto Pearson International Airport',
      nameAr: 'مطار تورونتو بيرسون الدولي',
      cityEn: 'Toronto',
      cityAr: 'تورونتو',
      countryEn: 'Canada',
      countryAr: 'كندا',
      latitude: 43.6777,
      longitude: -79.6248,
    ),

    // ASIA & PACIFIC
    Airport(
      code: 'HND',
      cityCode: 'TYO',
      nameEn: 'Tokyo Haneda Airport',
      nameAr: 'مطار طوكيو هانيدا الدولي',
      cityEn: 'Tokyo',
      cityAr: 'طوكيو',
      countryEn: 'Japan',
      countryAr: 'اليابان',
      latitude: 35.5494,
      longitude: 139.7798,
    ),
    Airport(
      code: 'NRT',
      cityCode: 'TYO',
      nameEn: 'Narita International Airport',
      nameAr: 'مطار ناريتا الدولي',
      cityEn: 'Tokyo',
      cityAr: 'طوكيو',
      countryEn: 'Japan',
      countryAr: 'اليابان',
      latitude: 35.7720,
      longitude: 140.3929,
    ),
    Airport(
      code: 'SIN',
      cityCode: 'SIN',
      nameEn: 'Singapore Changi Airport',
      nameAr: 'مطار شانغي سنغافورة',
      cityEn: 'Singapore',
      cityAr: 'سنغافورة',
      countryEn: 'Singapore',
      countryAr: 'سنغافورة',
      latitude: 1.3644,
      longitude: 103.9915,
    ),
    Airport(
      code: 'BKK',
      cityCode: 'BKK',
      nameEn: 'Suvarnabhumi Airport',
      nameAr: 'مطار سوفارنابومي بانكوك',
      cityEn: 'Bangkok',
      cityAr: 'بانكوك',
      countryEn: 'Thailand',
      countryAr: 'تايلاند',
      latitude: 13.6900,
      longitude: 100.7501,
    ),
    Airport(
      code: 'KUL',
      cityCode: 'KUL',
      nameEn: 'Kuala Lumpur International Airport',
      nameAr: 'مطار كوالالمبور الدولي',
      cityEn: 'Kuala Lumpur',
      cityAr: 'كوالالمبور',
      countryEn: 'Malaysia',
      countryAr: 'ماليزيا',
      latitude: 2.7456,
      longitude: 101.7099,
    ),
  ];
}
