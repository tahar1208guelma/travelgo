import '../../domain/entities/unified_search_result_entity.dart';

class AmadeusSearchDataSource {
  static final List<UnifiedSearchResultEntity> mockAmadeusGdsCatalog = [
    const UnifiedSearchResultEntity(
      id: 'amd_ht_101',
      title: 'Burj Al Arab Jumeirah Ultra Luxury',
      titleAr: 'برج العرب جميرا الفاخر',
      subtitle: 'Jumeirah Beach Road, Dubai, UAE',
      subtitleAr: 'شارع شاطئ جميرا، دبي، الإمارات',
      imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80',
      price: 890.0,
      currency: 'USD',
      rating: 4.9,
      reviewCount: 1840,
      source: 'amadeus_api',
      type: AccommodationType.hotel,
      coordinates: GeoCoordinates(latitude: 25.1413, longitude: 55.1853),
      amenities: ['Private Butler', 'Helipad', 'Infinity Pool', 'Michelin Dining', 'Luxury Spa'],
      freeCancellation: true,
      breakfastIncluded: true,
      commissionRate: 0.08,
      loyaltyPointsEarned: 500,
      isPartnerVerified: false,
    ),
    const UnifiedSearchResultEntity(
      id: 'amd_ht_102',
      title: 'Four Seasons Hotel George V',
      titleAr: 'فندق فور سيزونز جورج الخامس',
      subtitle: 'Champs-Elysées, Paris, France',
      subtitleAr: 'الشانزليزيه، باريس، فرنسا',
      imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80',
      price: 750.0,
      currency: 'USD',
      rating: 4.9,
      reviewCount: 960,
      source: 'amadeus_api',
      type: AccommodationType.hotel,
      coordinates: GeoCoordinates(latitude: 48.8688, longitude: 2.3011),
      amenities: ['Courtyard Garden', 'Spa', 'Valet Parking', 'Concierge 24/7', 'Fine Dining'],
      freeCancellation: true,
      breakfastIncluded: false,
      commissionRate: 0.08,
      loyaltyPointsEarned: 450,
      isPartnerVerified: false,
    ),
    const UnifiedSearchResultEntity(
      id: 'amd_ht_103',
      title: 'Raffles The Palm Dubai Palace',
      titleAr: 'رافلز النخلة قصر دبي',
      subtitle: 'Palm Jumeirah West Crescent, Dubai',
      subtitleAr: 'الهلال الغربي لنخلة جميرا، دبي',
      imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80',
      price: 420.0,
      currency: 'USD',
      rating: 4.8,
      reviewCount: 680,
      source: 'amadeus_api',
      type: AccommodationType.hotel,
      coordinates: GeoCoordinates(latitude: 25.1124, longitude: 55.1389),
      amenities: ['Private Beach', 'Cinema Room', 'Kids Club', 'Outdoor Pool', 'Free WiFi'],
      freeCancellation: true,
      breakfastIncluded: true,
      commissionRate: 0.08,
      loyaltyPointsEarned: 300,
      isPartnerVerified: false,
    ),
  ];

  Future<List<UnifiedSearchResultEntity>> search(UnifiedSearchFilters filters) async {
    await Future.delayed(const Duration(milliseconds: 220)); // simulate GDS API latency
    final query = filters.query.toLowerCase();
    final dest = filters.destination.toLowerCase();

    return mockAmadeusGdsCatalog.where((item) {
      if (query.isNotEmpty) {
        final matches = item.title.toLowerCase().contains(query) || item.subtitle.toLowerCase().contains(query);
        if (!matches) return false;
      }
      if (dest.isNotEmpty) {
        final matchesDest = item.subtitle.toLowerCase().contains(dest);
        if (!matchesDest) return false;
      }
      return true;
    }).toList();
  }
}
