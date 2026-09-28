import '../../domain/entities/unified_search_result_entity.dart';

class BookingAffiliateDataSource {
  static final List<UnifiedSearchResultEntity> mockAffiliateCatalog = [
    const UnifiedSearchResultEntity(
      id: 'aff_bk_201',
      title: 'Atlantis The Royal Resort & Residences',
      titleAr: 'أتلانتس ذا رويال دبي',
      subtitle: 'Palm Jumeirah, Dubai, UAE',
      subtitleAr: 'نخلة جميرا، دبي، الإمارات',
      imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80',
      price: 680.0,
      currency: 'USD',
      rating: 4.9,
      reviewCount: 2150,
      source: 'booking_com_affiliate',
      type: AccommodationType.hotel,
      coordinates: GeoCoordinates(latitude: 25.1378, longitude: 55.1294),
      amenities: ['Sky Pool', 'Waterpark Access', '17 Restaurants', 'Private Cabanas'],
      freeCancellation: true,
      breakfastIncluded: true,
      commissionRate: 0.05,
      commissionLink: 'https://www.booking.com/hotel/ae/atlantis-the-royal.html?aid=travelgo_aff_99',
      loyaltyPointsEarned: 250,
      isPartnerVerified: false,
    ),
    const UnifiedSearchResultEntity(
      id: 'aff_bk_202',
      title: 'Marina Bay Sands Landmark Resort',
      titleAr: 'منتجع مارينا باي ساندز الشهير',
      subtitle: 'Bayfront Avenue, Singapore',
      subtitleAr: 'بايفرونت، سنغافورة',
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800&q=80',
      price: 520.0,
      currency: 'USD',
      rating: 4.8,
      reviewCount: 3400,
      source: 'booking_com_affiliate',
      type: AccommodationType.hotel,
      coordinates: GeoCoordinates(latitude: 1.2838, longitude: 103.8591),
      amenities: ['World Largest Rooftop Infinity Pool', 'Banyan Tree Spa', 'Casino', 'Luxury Shopping'],
      freeCancellation: false,
      breakfastIncluded: false,
      commissionRate: 0.05,
      commissionLink: 'https://www.booking.com/hotel/sg/marina-bay-sands.html?aid=travelgo_aff_99',
      loyaltyPointsEarned: 200,
      isPartnerVerified: false,
    ),
    // Duplicate test candidate: Same hotel as El Aurassi in local DB but with affiliate source and different ID
    const UnifiedSearchResultEntity(
      id: 'aff_bk_203',
      title: 'Hotel El Aurassi Algiers',
      titleAr: 'فندق الأوراسي الجزائر',
      subtitle: 'Boulevard Frantz Fanon, Algiers',
      subtitleAr: 'شارع فرانز فانون، الجزائر',
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80',
      price: 145.0, // higher than local direct $135
      currency: 'USD',
      rating: 4.7,
      reviewCount: 380,
      source: 'booking_com_affiliate',
      type: AccommodationType.hotel,
      coordinates: GeoCoordinates(latitude: 36.7726, longitude: 3.0589), // 15 meters away
      amenities: ['WiFi', 'Pool', 'Breakfast'],
      freeCancellation: true,
      breakfastIncluded: true,
      commissionRate: 0.05,
      commissionLink: 'https://www.booking.com/hotel/dz/el-aurassi.html?aid=travelgo_aff_99',
      loyaltyPointsEarned: 80,
      isPartnerVerified: false,
    ),
  ];

  Future<List<UnifiedSearchResultEntity>> search(UnifiedSearchFilters filters) async {
    await Future.delayed(const Duration(milliseconds: 180));
    final query = filters.query.toLowerCase();
    final dest = filters.destination.toLowerCase();

    return mockAffiliateCatalog.where((item) {
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
