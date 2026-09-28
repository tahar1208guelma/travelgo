import '../../domain/entities/unified_search_result_entity.dart';

class LocalSearchDataSource {
  static final List<UnifiedSearchResultEntity> mockLocalCatalog = [
    const UnifiedSearchResultEntity(
      id: 'loc_ht_001',
      title: 'El Aurassi Luxury Hotel & Suites',
      titleAr: 'فندق الأوراسي الفاخر والأجنحة',
      subtitle: 'Algiers City Center, Algeria',
      subtitleAr: 'وسط مدينة الجزائر، الجزائر',
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80',
      ],
      price: 135.0,
      currency: 'USD',
      rating: 4.8,
      reviewCount: 420,
      source: 'local_database',
      type: AccommodationType.hotel,
      coordinates: GeoCoordinates(latitude: 36.7725, longitude: 3.0588),
      amenities: ['WiFi', 'Pool', 'Breakfast', 'Spa', 'Sea View', 'Parking'],
      freeCancellation: true,
      breakfastIncluded: true,
      commissionRate: 0.12,
      loyaltyPointsEarned: 150,
      isPartnerVerified: true,
    ),
    const UnifiedSearchResultEntity(
      id: 'loc_dc_002',
      title: 'Taghit Oasis Desert Camp & Safari',
      titleAr: 'مخيم تاغيت الصحراوي وسفاري الواحات',
      subtitle: 'Taghit Dunes, Bechar, Algeria',
      subtitleAr: 'كثبان تاغيت، بشار، الجزائر',
      imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=800&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=800&q=80',
        'https://images.unsplash.com/photo-1489493887464-892be6d1daae?w=800&q=80',
      ],
      price: 85.0,
      currency: 'USD',
      rating: 4.9,
      reviewCount: 310,
      source: 'local_database',
      type: AccommodationType.desertCamp,
      coordinates: GeoCoordinates(latitude: 30.9167, longitude: -2.0333),
      amenities: ['Campfire', 'Camel Trekking', 'Dinner Included', 'Stargazing Guide', 'Free Parking'],
      freeCancellation: true,
      breakfastIncluded: true,
      commissionRate: 0.12,
      loyaltyPointsEarned: 120,
      isPartnerVerified: true,
    ),
    const UnifiedSearchResultEntity(
      id: 'loc_ap_003',
      title: 'Hydra Panoramic Luxury Apartment',
      titleAr: 'شقة هيدرا الفاخرة بإطلالة بانورامية',
      subtitle: 'Hydra, Algiers, Algeria',
      subtitleAr: 'حيدرة، الجزائر العاصمة',
      imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=80',
      ],
      price: 95.0,
      currency: 'USD',
      rating: 4.7,
      reviewCount: 145,
      source: 'local_database',
      type: AccommodationType.apartment,
      coordinates: GeoCoordinates(latitude: 36.7441, longitude: 3.0425),
      amenities: ['Full Kitchen', 'WiFi', 'Washer', 'Balcony', 'Self Check-in'],
      freeCancellation: true,
      breakfastIncluded: false,
      commissionRate: 0.12,
      loyaltyPointsEarned: 100,
      isPartnerVerified: true,
    ),
    const UnifiedSearchResultEntity(
      id: 'loc_dc_004',
      title: 'Timimoun Red Sand Dunes Resort',
      titleAr: 'منتجع الكثبان الحمراء تيميمون',
      subtitle: 'Timimoun Oasis, Adrar, Algeria',
      subtitleAr: 'واحة تيميمون، أدرار، الجزائر',
      imageUrl: 'https://images.unsplash.com/photo-1547234935-80c7145ec969?w=800&q=80',
      price: 110.0,
      currency: 'USD',
      rating: 4.9,
      reviewCount: 280,
      source: 'local_database',
      type: AccommodationType.desertCamp,
      coordinates: GeoCoordinates(latitude: 29.2639, longitude: 0.2311),
      amenities: ['Oasis Pool', 'Traditional Berber Music', '4x4 Tour', 'Air Conditioning'],
      freeCancellation: true,
      breakfastIncluded: true,
      commissionRate: 0.12,
      loyaltyPointsEarned: 130,
      isPartnerVerified: true,
    ),
    const UnifiedSearchResultEntity(
      id: 'loc_ht_005',
      title: 'Sheraton Club des Pins Resort',
      titleAr: 'منتجع شيراتون نادي الصنوبر',
      subtitle: 'Staoueli Beachfront, Algiers',
      subtitleAr: 'شاطئ سطاوالي، الجزائر',
      imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80',
      price: 195.0,
      currency: 'USD',
      rating: 4.6,
      reviewCount: 520,
      source: 'local_database',
      type: AccommodationType.hotel,
      coordinates: GeoCoordinates(latitude: 36.7583, longitude: 2.8750),
      amenities: ['Private Beach', 'Infinity Pool', 'Tennis Court', 'Spa & Wellness', 'Free Breakfast'],
      freeCancellation: true,
      breakfastIncluded: true,
      commissionRate: 0.12,
      loyaltyPointsEarned: 220,
      isPartnerVerified: true,
    ),
  ];

  Future<List<UnifiedSearchResultEntity>> search(UnifiedSearchFilters filters) async {
    await Future.delayed(const Duration(milliseconds: 150)); // simulate fast DB query
    final query = filters.query.toLowerCase();
    final dest = filters.destination.toLowerCase();

    return mockLocalCatalog.where((item) {
      if (query.isNotEmpty) {
        final matchesTitle = item.title.toLowerCase().contains(query) || item.titleAr.contains(query);
        final matchesSub = item.subtitle.toLowerCase().contains(query) || item.subtitleAr.contains(query);
        if (!matchesTitle && !matchesSub) return false;
      }
      if (dest.isNotEmpty) {
        final matchesDest = item.subtitle.toLowerCase().contains(dest) || item.subtitleAr.contains(dest);
        if (!matchesDest) return false;
      }
      return true;
    }).toList();
  }
}
