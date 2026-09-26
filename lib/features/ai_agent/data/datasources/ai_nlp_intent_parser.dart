import '../../../flights/domain/entities/flight_search_params.dart';
import '../../domain/entities/ai_search_intent.dart';

class AINlpIntentParser {
  static const Map<String, Map<String, String>> _cityMap = {
    // Algeria
    'algiers': {'code': 'ALG', 'cityEn': 'Algiers', 'cityAr': 'الجزائر'},
    'الجزائر': {'code': 'ALG', 'cityEn': 'Algiers', 'cityAr': 'الجزائر'},
    'oran': {'code': 'ORN', 'cityEn': 'Oran', 'cityAr': 'وهران'},
    'وهران': {'code': 'ORN', 'cityEn': 'Oran', 'cityAr': 'وهران'},
    'constantine': {'code': 'CZL', 'cityEn': 'Constantine', 'cityAr': 'قسنطينة'},
    'قسنطينة': {'code': 'CZL', 'cityEn': 'Constantine', 'cityAr': 'قسنطينة'},
    'annaba': {'code': 'AAE', 'cityEn': 'Annaba', 'cityAr': 'عنابة'},
    'عنابة': {'code': 'AAE', 'cityEn': 'Annaba', 'cityAr': 'عنابة'},

    // France & Europe
    'paris': {'code': 'CDG', 'cityEn': 'Paris', 'cityAr': 'باريس'},
    'باريس': {'code': 'CDG', 'cityEn': 'Paris', 'cityAr': 'باريس'},
    'marseille': {'code': 'MRS', 'cityEn': 'Marseille', 'cityAr': 'مارسيليا'},
    'مارسيليا': {'code': 'MRS', 'cityEn': 'Marseille', 'cityAr': 'مارسيليا'},
    'london': {'code': 'LHR', 'cityEn': 'London', 'cityAr': 'لندن'},
    'لندن': {'code': 'LHR', 'cityEn': 'London', 'cityAr': 'لندن'},
    'rome': {'code': 'FCO', 'cityEn': 'Rome', 'cityAr': 'روما'},
    'روما': {'code': 'FCO', 'cityEn': 'Rome', 'cityAr': 'روما'},
    'milan': {'code': 'MXP', 'cityEn': 'Milan', 'cityAr': 'ميلانو'},
    'ميلانو': {'code': 'MXP', 'cityEn': 'Milan', 'cityAr': 'ميلانو'},
    'madrid': {'code': 'MAD', 'cityEn': 'Madrid', 'cityAr': 'مدريد'},
    'مدريد': {'code': 'MAD', 'cityEn': 'Madrid', 'cityAr': 'مدريد'},
    'barcelona': {'code': 'BCN', 'cityEn': 'Barcelona', 'cityAr': 'برشلونة'},
    'برشلونة': {'code': 'BCN', 'cityEn': 'Barcelona', 'cityAr': 'برشلونة'},
    'amsterdam': {'code': 'AMS', 'cityEn': 'Amsterdam', 'cityAr': 'أمستردام'},
    'أمستردام': {'code': 'AMS', 'cityEn': 'Amsterdam', 'cityAr': 'أمستردام'},
    'امستردام': {'code': 'AMS', 'cityEn': 'Amsterdam', 'cityAr': 'أمستردام'},

    // Middle East & Gulf
    'dubai': {'code': 'DXB', 'cityEn': 'Dubai', 'cityAr': 'دبي'},
    'دبي': {'code': 'DXB', 'cityEn': 'Dubai', 'cityAr': 'دبي'},
    'abu dhabi': {'code': 'AUH', 'cityEn': 'Abu Dhabi', 'cityAr': 'أبوظبي'},
    'أبوظبي': {'code': 'AUH', 'cityEn': 'Abu Dhabi', 'cityAr': 'أبوظبي'},
    'ابوظبي': {'code': 'AUH', 'cityEn': 'Abu Dhabi', 'cityAr': 'أبوظبي'},
    'riyadh': {'code': 'RUH', 'cityEn': 'Riyadh', 'cityAr': 'الرياض'},
    'الرياض': {'code': 'RUH', 'cityEn': 'Riyadh', 'cityAr': 'الرياض'},
    'jeddah': {'code': 'JED', 'cityEn': 'Jeddah', 'cityAr': 'جدة'},
    'جدة': {'code': 'JED', 'cityEn': 'Jeddah', 'cityAr': 'جدة'},
    'madinah': {'code': 'MED', 'cityEn': 'Madinah', 'cityAr': 'المدينة المنورة'},
    'المدينة': {'code': 'MED', 'cityEn': 'Madinah', 'cityAr': 'المدينة المنورة'},
    'المدينة المنورة': {'code': 'MED', 'cityEn': 'Madinah', 'cityAr': 'المدينة المنورة'},
    'doha': {'code': 'DOH', 'cityEn': 'Doha', 'cityAr': 'الدوحة'},
    'الدوحة': {'code': 'DOH', 'cityEn': 'Doha', 'cityAr': 'الدوحة'},

    // Turkey
    'istanbul': {'code': 'IST', 'cityEn': 'Istanbul', 'cityAr': 'إسطنبول'},
    'إسطنبول': {'code': 'IST', 'cityEn': 'Istanbul', 'cityAr': 'إسطنبول'},
    'اسطنبول': {'code': 'IST', 'cityEn': 'Istanbul', 'cityAr': 'إسطنبول'},
    'antalya': {'code': 'AYT', 'cityEn': 'Antalya', 'cityAr': 'أنطاليا'},
    'أنطاليا': {'code': 'AYT', 'cityEn': 'Antalya', 'cityAr': 'أنطاليا'},
    'انطاليا': {'code': 'AYT', 'cityEn': 'Antalya', 'cityAr': 'أنطاليا'},

    // North Africa
    'cairo': {'code': 'CAI', 'cityEn': 'Cairo', 'cityAr': 'القاهرة'},
    'القاهرة': {'code': 'CAI', 'cityEn': 'Cairo', 'cityAr': 'القاهرة'},
    'sharm': {'code': 'SSH', 'cityEn': 'Sharm El Sheikh', 'cityAr': 'شرم الشيخ'},
    'شرم الشيخ': {'code': 'SSH', 'cityEn': 'Sharm El Sheikh', 'cityAr': 'شرم الشيخ'},
    'tunis': {'code': 'TUN', 'cityEn': 'Tunis', 'cityAr': 'تونس'},
    'تونس': {'code': 'TUN', 'cityEn': 'Tunis', 'cityAr': 'تونس'},
    'casablanca': {'code': 'CMN', 'cityEn': 'Casablanca', 'cityAr': 'الدار البيضاء'},
    'الدار البيضاء': {'code': 'CMN', 'cityEn': 'Casablanca', 'cityAr': 'الدار البيضاء'},
    'كازابلانكا': {'code': 'CMN', 'cityEn': 'Casablanca', 'cityAr': 'الدار البيضاء'},
    'marrakesh': {'code': 'RAK', 'cityEn': 'Marrakesh', 'cityAr': 'مراكش'},
    'مراكش': {'code': 'RAK', 'cityEn': 'Marrakesh', 'cityAr': 'مراكش'},

    // Asia & Islands
    'kuala lumpur': {'code': 'KUL', 'cityEn': 'Kuala Lumpur', 'cityAr': 'كوالالمبور'},
    'كوالالمبور': {'code': 'KUL', 'cityEn': 'Kuala Lumpur', 'cityAr': 'كوالالمبور'},
    'bangkok': {'code': 'BKK', 'cityEn': 'Bangkok', 'cityAr': 'بانكوك'},
    'بانكوك': {'code': 'BKK', 'cityEn': 'Bangkok', 'cityAr': 'بانكوك'},
    'phuket': {'code': 'HKT', 'cityEn': 'Phuket', 'cityAr': 'فوكيت'},
    'فوكيت': {'code': 'HKT', 'cityEn': 'Phuket', 'cityAr': 'فوكيت'},
    'bali': {'code': 'DPS', 'cityEn': 'Bali', 'cityAr': 'بالي'},
    'بالي': {'code': 'DPS', 'cityEn': 'Bali', 'cityAr': 'بالي'},
    'maldives': {'code': 'MLE', 'cityEn': 'Maldives', 'cityAr': 'المالديف'},
    'المالديف': {'code': 'MLE', 'cityEn': 'Maldives', 'cityAr': 'المالديف'},
    'tokyo': {'code': 'HND', 'cityEn': 'Tokyo', 'cityAr': 'طوكيو'},
    'طوكيو': {'code': 'HND', 'cityEn': 'Tokyo', 'cityAr': 'طوكيو'},
  };

  /// Parses a natural language query into a validated AISearchIntent
  static AISearchIntent parseQuery(String query, {DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    final lower = query.toLowerCase().trim();
    final List<String> missingFields = [];
    final List<String> validationErrors = [];
    final List<String> userPreferences = [];

    // 1. Detect Search Type (Flight, Hotel, Package)
    AISearchType searchType = AISearchType.flight;
    final isHotelOnly = lower.contains('hotel') ||
        lower.contains('فندق') ||
        lower.contains('إقامة') ||
        lower.contains('منتجع') ||
        lower.contains('resort') ||
        lower.contains('stay');

    final isFlight = lower.contains('flight') ||
        lower.contains('طيران') ||
        lower.contains('رحلة') ||
        lower.contains('تذكرة') ||
        lower.contains('fly') ||
        lower.contains('سفر');

    if (isHotelOnly && !isFlight) {
      searchType = AISearchType.hotel;
    } else if (isHotelOnly && isFlight) {
      searchType = AISearchType.package;
    }

    // 2. Extract Origin and Destination
    String? originCode;
    String? originCity;
    String? destCode;
    String? destCity;

    // Check for "from X" or "من X"
    for (final entry in _cityMap.entries) {
      final key = entry.key;
      final fromPatternEn = RegExp(r'\bfrom\s+' + key + r'\b', caseSensitive: false);
      final fromPatternAr = RegExp(r'من\s+' + key);

      if (fromPatternEn.hasMatch(lower) || fromPatternAr.hasMatch(lower)) {
        originCode = entry.value['code'];
        originCity = entry.value['cityEn'];
        break;
      }
    }

    // Check for "to Y" or "إلى Y" or general destination mention
    for (final entry in _cityMap.entries) {
      final key = entry.key;
      final toPatternEn = RegExp(r'\bto\s+' + key + r'\b', caseSensitive: false);
      final inPatternEn = RegExp(r'\bin\s+' + key + r'\b', caseSensitive: false);
      final toPatternAr = RegExp(r'إلى\s+' + key);
      final inPatternAr = RegExp(r'في\s+' + key);

      if (toPatternEn.hasMatch(lower) ||
          inPatternEn.hasMatch(lower) ||
          toPatternAr.hasMatch(lower) ||
          inPatternAr.hasMatch(lower)) {
        destCode = entry.value['code'];
        destCity = entry.value['cityEn'];
        break;
      }
    }

    // If destination is still not found, check direct word match
    if (destCode == null) {
      for (final entry in _cityMap.entries) {
        if (lower.contains(entry.key) && entry.value['code'] != originCode) {
          destCode = entry.value['code'];
          destCity = entry.value['cityEn'];
          break;
        }
      }
    }

    // 3. Extract Passenger Counts
    int adults = 1;
    int children = 0;
    int infants = 0;

    if (lower.contains('لشخصين') ||
        lower.contains('شخصين') ||
        lower.contains('2 adults') ||
        lower.contains('for 2') ||
        lower.contains('two adults') ||
        lower.contains('شخصان')) {
      adults = 2;
    } else {
      final adultMatch = RegExp(r'(\d+)\s*(adult|adults|بالغ|بالغين|مسافر|مسافرين|people|persons)', caseSensitive: false).firstMatch(lower);
      if (adultMatch != null) {
        adults = int.tryParse(adultMatch.group(1)!) ?? 1;
      }
    }

    final childMatch = RegExp(r'(\d+)\s*(child|children|طفل|أطفال)', caseSensitive: false).firstMatch(lower);
    if (childMatch != null) {
      children = int.tryParse(childMatch.group(1)!) ?? 0;
    }

    // 4. Extract Duration & Dates
    int? durationDays;
    int? numberOfNights;
    DateTime? departureDate;
    DateTime? returnDate;
    TripType tripType = TripType.roundTrip;

    // Trip duration keywords
    if (lower.contains('أسبوع') || lower.contains('week') || lower.contains('7 days')) {
      durationDays = 7;
    }

    final nightsMatch = RegExp(r'(\d+)\s*(night|nights|ليال|ليالي|ليلة)', caseSensitive: false).firstMatch(lower);
    if (nightsMatch != null) {
      numberOfNights = int.tryParse(nightsMatch.group(1)!);
      durationDays = numberOfNights;
    }

    final daysMatch = RegExp(r'(\d+)\s*(day|days|أيام|يوم)', caseSensitive: false).firstMatch(lower);
    if (daysMatch != null) {
      durationDays = int.tryParse(daysMatch.group(1)!);
    }

    // Date extraction: Month or relative
    if (lower.contains('نوفمبر') || lower.contains('november')) {
      final targetYear = now.month > 11 ? now.year + 1 : now.year;
      departureDate = DateTime(targetYear, 11, 10);
    } else if (lower.contains('ديسمبر') || lower.contains('december')) {
      final targetYear = now.month > 12 ? now.year + 1 : now.year;
      departureDate = DateTime(targetYear, 12, 10);
    } else if (lower.contains('أكتوبر') || lower.contains('october')) {
      final targetYear = now.month > 10 ? now.year + 1 : now.year;
      departureDate = DateTime(targetYear, 10, 10);
    } else if (lower.contains('الشهر القادم') || lower.contains('next month')) {
      departureDate = DateTime(now.year, now.month + 1, 15);
    } else if (lower.contains('الأسبوع القادم') || lower.contains('next week')) {
      departureDate = now.add(const Duration(days: 7));
    } else if (lower.contains('غدا') || lower.contains('tomorrow')) {
      departureDate = now.add(const Duration(days: 1));
    }

    if (departureDate != null && durationDays != null) {
      returnDate = departureDate.add(Duration(days: durationDays));
    }

    if (lower.contains('one way') || lower.contains('ذهاب فقط') || lower.contains('one-way')) {
      tripType = TripType.oneWay;
      returnDate = null;
    }

    // 5. Extract Hotel Specifics
    int? hotelMinStars;
    String? hotelLocation;

    if (lower.contains('5 نجوم') || lower.contains('5 star') || lower.contains('5 stars') || lower.contains('5-star')) {
      hotelMinStars = 5;
    } else if (lower.contains('4 نجوم') || lower.contains('4 star') || lower.contains('4 stars') || lower.contains('4-star')) {
      hotelMinStars = 4;
    } else if (lower.contains('3 نجوم') || lower.contains('3 star') || lower.contains('3 stars') || lower.contains('3-star')) {
      hotelMinStars = 3;
    }

    if (lower.contains('وسط المدينة') || lower.contains('city center') || lower.contains('downtown')) {
      hotelLocation = 'City Center';
    } else if (lower.contains('beach') || lower.contains('شاطئ') || lower.contains('بحر')) {
      hotelLocation = 'Beachfront';
    }

    // 6. Nonstop & Cabin Class
    bool nonstop = false;
    if (lower.contains('direct') || lower.contains('مباشر') || lower.contains('nonstop') || lower.contains('non-stop')) {
      nonstop = true;
    }

    CabinClass cabinClass = CabinClass.economy;
    if (lower.contains('business') || lower.contains('درجة الأعمال') || lower.contains('الأعمال')) {
      cabinClass = CabinClass.business;
    } else if (lower.contains('first class') || lower.contains('الدرجة الأولى')) {
      cabinClass = CabinClass.firstClass;
    } else if (lower.contains('premium') || lower.contains('الممتازة')) {
      cabinClass = CabinClass.premiumEconomy;
    }

    // 7. Preferences & Budget
    double? budgetUSD;
    final budgetMatch = RegExp(
      r'(?:\$|usd|dollar|دولار|ميزانية|under|بميزانية)\s*(\d+)|(\d+)\s*(?:\$|usd|dollar|dollars|دولار)',
      caseSensitive: false,
    ).firstMatch(lower);
    if (budgetMatch != null) {
      final valStr = budgetMatch.group(1) ?? budgetMatch.group(2);
      if (valStr != null) {
        budgetUSD = double.tryParse(valStr);
      }
    }

    if (lower.contains('breakfast') || lower.contains('إفطار') || lower.contains('فطور')) {
      userPreferences.add('breakfast_included');
    }
    if (lower.contains('free cancellation') || lower.contains('إلغاء مجاني')) {
      userPreferences.add('free_cancellation');
    }
    if (lower.contains('cheapest') || lower.contains('أرخص')) {
      userPreferences.add('cheapest');
    }

    // 8. Missing Fields Calculation (Mandatory fields for execution)
    if (searchType == AISearchType.flight || searchType == AISearchType.package) {
      if (originCode == null) missingFields.add('origin');
      if (destCode == null) missingFields.add('destination');
      if (departureDate == null) missingFields.add('departure_date');
    } else if (searchType == AISearchType.hotel) {
      if (destCity == null && destCode == null) missingFields.add('destination');
      if (departureDate == null) missingFields.add('check_in_date');
    }

    // 9. Schema Validations
    if (originCode != null && destCode != null && originCode.toUpperCase() == destCode.toUpperCase()) {
      validationErrors.add('Origin and destination cannot be the same airport.');
    }

    return AISearchIntent(
      rawQuery: query,
      searchType: searchType,
      originCode: originCode,
      originCity: originCity,
      destinationCode: destCode,
      destinationCity: destCity,
      departureDate: departureDate,
      returnDate: returnDate,
      tripType: tripType,
      adults: adults,
      children: children,
      infants: infants,
      cabinClass: cabinClass,
      nonstopPreference: nonstop,
      hotelMinStars: hotelMinStars,
      hotelLocationPreference: hotelLocation,
      numberOfNights: numberOfNights ?? durationDays,
      budgetUSD: budgetUSD,
      userPreferences: userPreferences,
      missingFields: missingFields,
      validationErrors: validationErrors,
    );
  }
}
