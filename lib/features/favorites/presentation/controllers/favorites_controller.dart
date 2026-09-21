import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import 'package:travelgo/features/favorites/domain/entities/favorite_item_entity.dart';

final favoritesControllerProvider = StateNotifierProvider<FavoritesController, List<FavoriteItemEntity>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return FavoritesController(storage);
});

class FavoritesController extends StateNotifier<List<FavoriteItemEntity>> {
  final StorageService _storageService;

  FavoritesController(this._storageService) : super([]) {
    _initDefaultFavorites();
  }

  void _initDefaultFavorites() {
    // Seed initial favorites
    state = [
      FavoriteItemEntity(
        id: 'ht_dubai_001',
        title: 'Burj Al Arab Jumeirah',
        subtitle: 'Dubai, UAE',
        imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=800&auto=format&fit=crop',
        priceUSD: 850.0,
        type: 'hotel',
        rating: 9.6,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      FavoriteItemEntity(
        id: 'fl_ek_001',
        title: 'Emirates (Algiers → Dubai)',
        subtitle: 'Direct • 6h 15m',
        imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?q=80&w=300&auto=format&fit=crop',
        priceUSD: 365.0,
        type: 'flight',
        rating: 4.8,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  bool isFavorite(String id) {
    return state.any((item) => item.id == id);
  }

  void toggleFavorite(FavoriteItemEntity item) {
    if (isFavorite(item.id)) {
      state = state.where((i) => i.id != item.id).toList();
      _storageService.toggleFavorite(item.id);
    } else {
      state = [item, ...state];
      _storageService.toggleFavorite(item.id);
    }
  }
}
