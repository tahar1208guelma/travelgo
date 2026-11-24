class Destination {
  final String id;
  final String cityEn;
  final String cityAr;
  final String cityFr;
  final String countryEn;
  final String countryAr;
  final String countryFr;
  final String imageUrl;
  final double startingPriceUSD;
  final String popularTag;

  const Destination({
    required this.id,
    required this.cityEn,
    required this.cityAr,
    String? cityFr,
    required this.countryEn,
    required this.countryAr,
    String? countryFr,
    required this.imageUrl,
    required this.startingPriceUSD,
    required this.popularTag,
  })  : cityFr = cityFr ?? cityEn,
        countryFr = countryFr ?? countryEn;

  String getCity({bool isArabic = false, String? langCode}) {
    if (langCode != null) {
      if (langCode == 'ar') return cityAr;
      if (langCode == 'fr') return cityFr;
      return cityEn;
    }
    return isArabic ? cityAr : cityEn;
  }

  String getCountry({bool isArabic = false, String? langCode}) {
    if (langCode != null) {
      if (langCode == 'ar') return countryAr;
      if (langCode == 'fr') return countryFr;
      return countryEn;
    }
    return isArabic ? countryAr : countryEn;
  }

  static const List<Destination> popularDestinations = [
    Destination(
      id: 'dest_dubai',
      cityEn: 'Dubai',
      cityAr: 'دبي',
      cityFr: 'Dubaï',
      countryEn: 'United Arab Emirates',
      countryAr: 'الإمارات العربية المتحدة',
      countryFr: 'Émirats arabes unis',
      imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?q=80&w=800&auto=format&fit=crop',
      startingPriceUSD: 240.0,
      popularTag: 'Trending',
    ),
    Destination(
      id: 'dest_istanbul',
      cityEn: 'Istanbul',
      cityAr: 'إسطنبول',
      cityFr: 'Istanbul',
      countryEn: 'Turkey',
      countryAr: 'تركيا',
      countryFr: 'Turquie',
      imageUrl: 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?q=80&w=800&auto=format&fit=crop',
      startingPriceUSD: 185.0,
      popularTag: 'Popular',
    ),
    Destination(
      id: 'dest_paris',
      cityEn: 'Paris',
      cityAr: 'باريس',
      cityFr: 'Paris',
      countryEn: 'France',
      countryAr: 'فرنسا',
      countryFr: 'France',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=800&auto=format&fit=crop',
      startingPriceUSD: 310.0,
      popularTag: 'Top Rated',
    ),
    Destination(
      id: 'dest_algiers',
      cityEn: 'Algiers',
      cityAr: 'الجزائر العاصمة',
      cityFr: 'Alger',
      countryEn: 'Algeria',
      countryAr: 'الجزائر',
      countryFr: 'Algérie',
      imageUrl: 'https://images.unsplash.com/photo-1569154941061-e231b4725ef1?q=80&w=800&auto=format&fit=crop',
      startingPriceUSD: 140.0,
      popularTag: 'Heritage',
    ),
    Destination(
      id: 'dest_london',
      cityEn: 'London',
      cityAr: 'لندن',
      cityFr: 'Londres',
      countryEn: 'United Kingdom',
      countryAr: 'المملكة المتحدة',
      countryFr: 'Royaume-Uni',
      imageUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?q=80&w=800&auto=format&fit=crop',
      startingPriceUSD: 350.0,
      popularTag: 'Classic',
    ),
    Destination(
      id: 'dest_riyadh',
      cityEn: 'Riyadh',
      cityAr: 'الرياض',
      cityFr: 'Riyad',
      countryEn: 'Saudi Arabia',
      countryAr: 'المملكة العربية السعودية',
      countryFr: 'Arabie saoudite',
      imageUrl: 'https://images.unsplash.com/photo-1586724237569-f3d0c1dee8c6?q=80&w=800&auto=format&fit=crop',
      startingPriceUSD: 210.0,
      popularTag: 'Business & Culture',
    ),
  ];
}
