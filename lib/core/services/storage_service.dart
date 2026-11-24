import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be overridden in main.dart');
});

class StorageService {
  static const String _searchesKey = 'recent_searches_cache';
  static const String _favoritesKey = 'favorites_cache';
  static const String _userKey = 'cached_user_profile';
  static const String _authTokenKey = 'auth_session_token';
  static const String _refreshTokenKey = 'auth_session_refresh_token';
  static const String _onboardingSeenKey = 'onboarding_seen';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Onboarding
  bool hasSeenOnboarding() => _prefs.getBool(_onboardingSeenKey) ?? false;
  Future<bool> setOnboardingSeen() => _prefs.setBool(_onboardingSeenKey, true);

  // Recent Searches
  List<Map<String, dynamic>> getRecentSearches() {
    final raw = _prefs.getStringList(_searchesKey) ?? [];
    return raw.map((item) => json.decode(item) as Map<String, dynamic>).toList();
  }

  Future<void> saveRecentSearch(Map<String, dynamic> search) async {
    final current = getRecentSearches();
    current.removeWhere((item) => item['query'] == search['query'] && item['type'] == search['type']);
    current.insert(0, search);
    if (current.length > 10) current.removeLast();
    await _prefs.setStringList(_searchesKey, current.map((item) => json.encode(item)).toList());
  }

  // Favorites
  List<String> getFavoriteIds() => _prefs.getStringList(_favoritesKey) ?? [];

  Future<void> toggleFavorite(String id) async {
    final current = getFavoriteIds();
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    await _prefs.setStringList(_favoritesKey, current);
  }

  bool isFavorite(String id) => getFavoriteIds().contains(id);

  // Cached User & Session Tokens
  Map<String, dynamic>? getCachedUser() {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    return json.decode(raw) as Map<String, dynamic>;
  }

  Future<void> setCachedUser(Map<String, dynamic>? user) async {
    if (user == null) {
      await _prefs.remove(_userKey);
    } else {
      await _prefs.setString(_userKey, json.encode(user));
    }
  }

  String? getAuthToken() => _prefs.getString(_authTokenKey);

  Future<bool> setAuthToken(String? token) async {
    if (token == null) {
      return _prefs.remove(_authTokenKey);
    }
    return _prefs.setString(_authTokenKey, token);
  }

  String? getRefreshToken() => _prefs.getString(_refreshTokenKey);

  Future<bool> setRefreshToken(String? token) async {
    if (token == null) {
      return _prefs.remove(_refreshTokenKey);
    }
    return _prefs.setString(_refreshTokenKey, token);
  }

  Future<void> clearAuthSession() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_authTokenKey);
    await _prefs.remove(_refreshTokenKey);
  }

  // Hotel Partner Portal Storage
  static const String _partnerHotelsKey = 'partner_hotels_cache_v1';
  static const String _partnerProfileKey = 'partner_profile_cache_v1';
  static const String _partnerReservationsKey = 'partner_reservations_cache_v1';
  static const String _partnerPayoutsKey = 'partner_payouts_cache_v1';

  List<String>? getPartnerHotelsJson() => _prefs.getStringList(_partnerHotelsKey);
  Future<void> savePartnerHotelsJson(List<String> list) => _prefs.setStringList(_partnerHotelsKey, list);

  String? getPartnerProfileJson() => _prefs.getString(_partnerProfileKey);
  Future<void> savePartnerProfileJson(String jsonStr) => _prefs.setString(_partnerProfileKey, jsonStr);

  List<String>? getPartnerReservationsJson() => _prefs.getStringList(_partnerReservationsKey);
  Future<void> savePartnerReservationsJson(List<String> list) => _prefs.setStringList(_partnerReservationsKey, list);

  List<String>? getPartnerPayoutsJson() => _prefs.getStringList(_partnerPayoutsKey);
  Future<void> savePartnerPayoutsJson(List<String> list) => _prefs.setStringList(_partnerPayoutsKey, list);
}
