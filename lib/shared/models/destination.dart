class Destination {
  final String id;
  final String cityEn;
  final String cityAr;
  final String countryEn;
  final String countryAr;
  final String imageUrl;
  final double startingPriceUSD;
  final String popularTag;

  const Destination({
    required this.id,
    required this.cityEn,
    required this.cityAr,
    required this.countryEn,
    required this.countryAr,
    required this.imageUrl,
    required this.startingPriceUSD,
    required this.popularTag,
  });

  String getCity({bool isArabic = false}) => isArabic ? cityAr : cityEn;
  String getCountry({bool isArabic = false}) => isArabic ? countryAr : countryEn;

  static const List<Destination> popularDestinations = [
    Destination(
      id: 'dest_dubai',
      cityEn: 'Dubai',
      cityAr: 'دبي',
      countryEn: 'United Arab Emirates',
      countryAr: 'الإمارات العربية المتحدة',
      imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?q=80&w=800&auto=format&fit=crop',
      startingPriceUSD: 240.0,
      popularTag: 'Trending',
    ),
    Destination(
      id: 'dest_istanbul',
      cityEn: 'Istanbul',
      cityAr: 'إسطنبول',
      countryEn: 'Turkey',
      countryAr: 'تركيا',
      imageUrl: 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?q=80&w=800&auto=format&fit=crop',
      startingPriceUSD: 185.0,
      popularTag: 'Popular',
    ),
    Destination(
      id: 'dest_paris',
      cityEn: 'Paris',
      cityAr: 'باريس',
      countryEn: 'France',
      countryAr: 'فرنسا',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=800&auto=format&fit=crop',
      startingPriceUSD: 310.0,
      popularTag: 'Top Rated',
    ),
    Destination(
      id: 'dest_algiers',
      cityEn: 'Algiers',
      cityAr: 'الجزائر العاصمة',
      countryEn: 'Algeria',
      countryAr: 'الجزائر',
      imageUrl: 'https://images.unsplash.com/photo-1569154941061-e231b4725ef1?q=80&w=800&auto=format&fit=crop',
      startingPriceUSD: 140.0,
      popularTag: 'Heritage',
    ),
    Destination(
      id: 'dest_london',
      cityEn: 'London',
      cityAr: 'لندن',
      countryEn: 'United Kingdom',
      countryAr: 'المملكة المتحدة',
      imageUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?q=80&w=800&auto=format&fit=crop',
      startingPriceUSD: 350.0,
      popularTag: 'Classic',
    ),
    Destination(
      id: 'dest_riyadh',
      cityEn: 'Riyadh',
      cityAr: 'الرياض',
      countryEn: 'Saudi Arabia',
      countryAr: 'المملكة العربية السعودية',
      imageUrl: 'https://images.unsplash.com/photo-1586724237569-f3d0c1dee8c6?q=80&w=800&auto=format&fit=crop',
      startingPriceUSD: 210.0,
      popularTag: 'Business & Culture',
    ),
  ];
}
