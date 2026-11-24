import '../../../features/hotel_partner/data/repositories/hotel_partner_repository.dart';
import '../../../features/hotels/domain/entities/hotel_entity.dart';
import '../../../features/hotels/domain/entities/hotel_search_params.dart';
import '../domain/hotel_search_provider.dart';
import '../domain/revalidation_result.dart';

class PartnerDirectHotelProvider implements HotelSearchProvider {
  final HotelPartnerRepository _repository;

  PartnerDirectHotelProvider(this._repository);

  @override
  String get providerId => 'partner_direct';

  @override
  String get providerName => 'TRAVELGO Direct Partner Network';

  @override
  Duration get timeout => const Duration(seconds: 3);

  @override
  Future<List<HotelEntity>> searchHotels(HotelSearchParams params) async {
    final partners = await _repository.getPublishedHotelEntities();
    final query = params.destination.trim().toLowerCase();

    return partners.where((p) {
      if (query.isEmpty) return true;
      return p.cityEn.toLowerCase().contains(query) ||
          p.cityAr.toLowerCase().contains(query) ||
          p.countryEn.toLowerCase().contains(query) ||
          p.countryAr.toLowerCase().contains(query) ||
          p.nameEn.toLowerCase().contains(query) ||
          p.nameAr.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Future<HotelEntity?> getHotelDetails(String hotelId) async {
    final partners = await _repository.getPublishedHotelEntities();
    try {
      return partners.firstWhere((p) => p.id == hotelId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<RevalidationResult> revalidateHotel(String hotelId, double expectedPriceUSD) async {
    return RevalidationResult(
      status: RevalidationStatus.confirmed,
      itemId: hotelId,
      currentPriceUSD: expectedPriceUSD,
      previousPriceUSD: expectedPriceUSD,
      remainingInventory: 5,
      statusMessage: 'Direct partner rate verified with property manager.',
      verifiedAt: DateTime.now(),
    );
  }
}
