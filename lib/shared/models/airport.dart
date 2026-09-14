class Airport {
  final String code;
  final String nameEn;
  final String nameAr;
  final String cityEn;
  final String cityAr;
  final String countryEn;
  final String countryAr;

  const Airport({
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.cityEn,
    required this.cityAr,
    required this.countryEn,
    required this.countryAr,
  });

  String getCity({bool isArabic = false}) => isArabic ? cityAr : cityEn;
  String getName({bool isArabic = false}) => isArabic ? nameAr : nameEn;
  String getCountry({bool isArabic = false}) => isArabic ? countryAr : countryEn;

  static const List<Airport> majorAirports = [
    Airport(
      code: 'ALG',
      nameEn: 'Houari Boumediene Airport',
      nameAr: 'مطار هواري بومدين الدولي',
      cityEn: 'Algiers',
      cityAr: 'الجزائر العاصمة',
      countryEn: 'Algeria',
      countryAr: 'الجزائر',
    ),
    Airport(
      code: 'DXB',
      nameEn: 'Dubai International Airport',
      nameAr: 'مطار دبي الدولي',
      cityEn: 'Dubai',
      cityAr: 'دبي',
      countryEn: 'United Arab Emirates',
      countryAr: 'الإمارات العربية المتحدة',
    ),
    Airport(
      code: 'IST',
      nameEn: 'Istanbul International Airport',
      nameAr: 'مطار إسطنبول الدولي',
      cityEn: 'Istanbul',
      cityAr: 'إسطنبول',
      countryEn: 'Turkey',
      countryAr: 'تركيا',
    ),
    Airport(
      code: 'CDG',
      nameEn: 'Charles de Gaulle Airport',
      nameAr: 'مطار شارل ديغول الدولي',
      cityEn: 'Paris',
      cityAr: 'باريس',
      countryEn: 'France',
      countryAr: 'فرنسا',
    ),
    Airport(
      code: 'LHR',
      nameEn: 'Heathrow Airport',
      nameAr: 'مطار هيثرو الدولي',
      cityEn: 'London',
      cityAr: 'لندن',
      countryEn: 'United Kingdom',
      countryAr: 'المملكة المتحدة',
    ),
    Airport(
      code: 'RUH',
      nameEn: 'King Khalid International Airport',
      nameAr: 'مطار الملك خالد الدولي',
      cityEn: 'Riyadh',
      cityAr: 'الرياض',
      countryEn: 'Saudi Arabia',
      countryAr: 'المملكة العربية السعودية',
    ),
    Airport(
      code: 'JED',
      nameEn: 'King Abdulaziz International Airport',
      nameAr: 'مطار الملك عبد العزيز الدولي',
      cityEn: 'Jeddah',
      cityAr: 'جدة',
      countryEn: 'Saudi Arabia',
      countryAr: 'المملكة العربية السعودية',
    ),
    Airport(
      code: 'CAI',
      nameEn: 'Cairo International Airport',
      nameAr: 'مطار القاهرة الدولي',
      cityEn: 'Cairo',
      cityAr: 'القاهرة',
      countryEn: 'Egypt',
      countryAr: 'مصر',
    ),
    Airport(
      code: 'DOH',
      nameEn: 'Hamad International Airport',
      nameAr: 'مطار حمد الدولي',
      cityEn: 'Doha',
      cityAr: 'الدوحة',
      countryEn: 'Qatar',
      countryAr: 'قطر',
    ),
    Airport(
      code: 'JFK',
      nameEn: 'John F. Kennedy International Airport',
      nameAr: 'مطار جون إف كينيدي الدولي',
      cityEn: 'New York',
      cityAr: 'نيويورك',
      countryEn: 'United States',
      countryAr: 'الولايات المتحدة',
    ),
  ];
}
