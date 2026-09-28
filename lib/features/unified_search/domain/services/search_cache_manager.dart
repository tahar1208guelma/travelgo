import 'dart:collection';
import '../entities/unified_search_result_entity.dart';

class CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  CacheEntry({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// In-memory LRU Cache with TTL (Redis-compatible abstraction for production)
class SearchCacheManager {
  static final SearchCacheManager _instance = SearchCacheManager._internal();
  factory SearchCacheManager() => _instance;
  SearchCacheManager._internal();

  final int maxEntries = 100;
  final Duration defaultTTL = const Duration(hours: 1);

  final LinkedHashMap<String, CacheEntry<List<UnifiedSearchResultEntity>>> _cache =
      LinkedHashMap<String, CacheEntry<List<UnifiedSearchResultEntity>>>();

  int _hits = 0;
  int _misses = 0;

  int get hits => _hits;
  int get misses => _misses;
  int get size => _cache.length;

  List<UnifiedSearchResultEntity>? get(String key) {
    final entry = _cache[key];
    if (entry == null) {
      _misses++;
      return null;
    }

    if (entry.isExpired) {
      _cache.remove(key);
      _misses++;
      return null;
    }

    // Refresh LRU order
    _cache.remove(key);
    _cache[key] = entry;
    _hits++;
    return entry.data;
  }

  void put(String key, List<UnifiedSearchResultEntity> results, {Duration? ttl}) {
    if (_cache.length >= maxEntries) {
      // Evict oldest entry (LRU)
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = CacheEntry(
      data: results,
      expiresAt: DateTime.now().add(ttl ?? defaultTTL),
    );
  }

  void invalidate(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
    _hits = 0;
    _misses = 0;
  }
}
