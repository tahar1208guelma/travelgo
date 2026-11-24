import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale) {
    if (locale.languageCode == 'en') {
      _localizedStrings = Map.from(_fallbackEn);
    } else if (locale.languageCode == 'fr') {
      _localizedStrings = Map.from(_fallbackFr);
    }
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ar', ''),
    Locale('fr', ''),
  ];

  static const Map<String, String> _fallbackEn = {
    'app_name': 'TRAVELGO',
    'app_tagline': 'Your Gateway to the World',
    'skip': 'Skip',
    'next': 'Next',
    'get_started': 'Get Started',
    'continue_btn': 'Continue',
    'save': 'Save',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'search': 'Search',
    'apply': 'Apply',
    'reset': 'Reset',
    'close': 'Close',
    'back': 'Back',
    'view_all': 'View All',
    'see_details': 'See Details',
    'book_now': 'Book Now',
    'direct_booking': 'Direct Booking',
    'affiliate_booking': 'Book with Partner',
    'nav_home': 'Home',
    'nav_flights': 'Flights',
    'nav_hotels': 'Hotels',
    'nav_bookings': 'My Trips',
    'nav_profile': 'Profile',
    'home_greeting_morning': 'Good Morning',
    'home_greeting_afternoon': 'Good Afternoon',
    'home_greeting_evening': 'Good Evening',
    'home_where_to': 'Where would you like to go?',
    'home_tab_flights': 'Flights',
    'home_tab_hotels': 'Hotels',
    'home_popular_destinations': 'Popular Destinations',
    'home_recommended_hotels': 'Featured Hotels',
    'home_recent_searches': 'Recent Searches',
    'home_special_offers': 'Special Offers',
    'flight_search_title': 'Search Flights',
    'flight_trip_type_round': 'Round Trip',
    'flight_trip_type_one': 'One Way',
    'flight_from': 'From',
    'flight_to': 'To',
    'flight_departure_date': 'Departure',
    'flight_return_date': 'Return',
    'flight_passengers': 'Passengers',
    'flight_cabin_class': 'Cabin Class',
    'flight_search_action': 'Search Flights',
    'flight_results_title': 'Flight Results',
    'flight_found_count': 'flights found',
    'hotel_search_title': 'Search Hotels',
    'hotel_destination': 'Destination / City',
    'hotel_check_in': 'Check-in',
    'hotel_check_out': 'Check-out',
    'hotel_guests': 'Guests',
    'hotel_rooms': 'Rooms',
    'hotel_night_count': 'night(s)',
    'hotel_search_action': 'Search Hotels',
    'hotel_results_title': 'Hotel Results',
    'hotel_found_count': 'hotels found',
    'hotel_per_night': '/ night',
    'hotel_total_price': 'Total for',
    'hotel_free_cancellation': 'Free Cancellation',
    'hotel_breakfast_included': 'Breakfast Included',
    'booking_summary_title': 'Booking Summary',
    'booking_trip_details': 'Trip Details',
    'booking_guest_details': 'Guest / Passenger Details',
    'booking_payment_details': 'Price Breakdown',
    'booking_base_fare': 'Base Fare / Rate',
    'booking_taxes': 'Taxes & Airport Fees',
    'booking_service_fee': 'Platform Service Fee',
    'booking_total': 'Total Amount',
    'booking_service_fee_note': 'Includes \$1.00 USD standard booking guarantee & support.',
    'booking_pay_and_confirm': 'Pay & Confirm Booking',
    'booking_confirmation_title': 'Booking Confirmed!',
    'booking_reference_number': 'Reference Number (PNR)',
    'booking_view_my_bookings': 'View in My Bookings',
    'booking_back_home': 'Back to Home',
    'booking_view_document': 'View Document',
    'booking_view_pdf': 'View PDF',
    'booking_save_pdf': 'Save PDF',
    'booking_print': 'Print',
    'booking_share': 'Share',
    'booking_document_title': 'Booking Document',
    'booking_trip_details_title': 'Trip Details',
    'booking_demo_badge': 'DEMO / TEST BOOKING',
    'my_bookings_title': 'My Bookings',
    'my_bookings_upcoming': 'Upcoming',
    'my_bookings_completed': 'Completed',
    'my_bookings_cancelled': 'Cancelled',
    'my_bookings_empty_title': 'No Bookings Yet',
    'ai_assistant_title': 'AI Travel Assistant',
    'ai_assistant_subtitle': 'Smart trip planning, natural search & budget optimization',
    'ai_search_title': 'AI Smart Search',
    'ai_search_banner_flight': 'Search Flights with AI',
    'ai_search_banner_hotel': 'Search Hotels with AI',
    'ai_search_banner_desc': 'Describe your trip naturally in your own words',
    'ai_search_missing_fields_title': 'Clarify Trip Details',
    'ai_search_missing_fields_desc': 'We understood most of your request! Please clarify the following missing details:',
    'ai_search_recognized_details': 'Recognized Details:',
    'ai_search_continue_action': 'Continue to Results',
    'ai_search_input_hint': 'e.g. Flight from Algiers to Paris for 2 adults next month',
    'ai_search_hotel_input_hint': 'e.g. 4-star hotel in Istanbul near city center for 5 nights',
    'ai_budget_title': 'Trip Budget Allocation',
    'ai_badge_verified': 'Verified Live Fare',
    'ai_thinking': 'AI is searching & crafting your plan...',
  };

  static const Map<String, String> _fallbackFr = {
    'app_name': 'TRAVELGO',
    'app_tagline': 'Votre porte d\'entrée vers le monde',
    'skip': 'Passer',
    'next': 'Suivant',
    'get_started': 'Commencer',
    'continue_btn': 'Continuer',
    'save': 'Enregistrer',
    'cancel': 'Annuler',
    'confirm': 'Confirmer',
    'search': 'Rechercher',
    'apply': 'Appliquer',
    'reset': 'Réinitialiser',
    'close': 'Fermer',
    'back': 'Retour',
    'view_all': 'Voir tout',
    'see_details': 'Voir les détails',
    'book_now': 'Réserver',
    'direct_booking': 'Réservation directe',
    'affiliate_booking': 'Réserver avec partenaire',
    'nav_home': 'Accueil',
    'nav_flights': 'Vols',
    'nav_hotels': 'Hôtels',
    'nav_bookings': 'Mes voyages',
    'nav_profile': 'Profil',
    'nav_explore': 'Explorer',
    'home_greeting_morning': 'Bonjour',
    'home_greeting_afternoon': 'Bon après-midi',
    'home_greeting_evening': 'Bonsoir',
    'home_where_to': 'Où souhaitez-vous aller ?',
    'home_tab_flights': 'Vols',
    'home_tab_hotels': 'Hôtels',
    'home_popular_destinations': 'Destinations populaires',
    'home_recommended_hotels': 'Hôtels en vedette',
    'home_recent_searches': 'Recherches récentes',
    'home_special_offers': 'Offres spéciales',
    'flight_search_title': 'Rechercher des vols',
    'flight_trip_type_round': 'Aller-retour',
    'flight_trip_type_one': 'Aller simple',
    'flight_from': 'De',
    'flight_to': 'Vers',
    'flight_departure_date': 'Départ',
    'flight_return_date': 'Retour',
    'flight_passengers': 'Passagers',
    'flight_cabin_class': 'Classe de cabine',
    'flight_search_action': 'Rechercher des vols',
    'flight_results_title': 'Résultats des vols',
    'flight_found_count': 'vols trouvés',
    'hotel_search_title': 'Rechercher des hôtels',
    'hotel_destination': 'Destination / Ville',
    'hotel_check_in': 'Arrivée',
    'hotel_check_out': 'Départ',
    'hotel_guests': 'Voyageurs',
    'hotel_rooms': 'Chambres',
    'hotel_night_count': 'nuit(s)',
    'hotel_search_action': 'Rechercher des hôtels',
    'hotel_results_title': 'Résultats des hôtels',
    'hotel_found_count': 'hôtels trouvés',
    'hotel_per_night': '/ nuit',
    'hotel_total_price': 'Total pour',
    'hotel_free_cancellation': 'Annulation gratuite',
    'hotel_breakfast_included': 'Petit-déjeuner inclus',
    'booking_summary_title': 'Récapitulatif de la réservation',
    'booking_trip_details': 'Détails du voyage',
    'booking_guest_details': 'Détails des passagers',
    'booking_payment_details': 'Détail du prix',
    'booking_base_fare': 'Tarif de base',
    'booking_taxes': 'Taxes et frais d\'aéroport',
    'booking_service_fee': 'Frais de service plateforme',
    'booking_total': 'Montant total',
    'booking_service_fee_note': 'Comprend 1,00 \$ USD de garantie de réservation standard et support.',
    'booking_pay_and_confirm': 'Payer et confirmer la réservation',
    'booking_confirmation_title': 'Réservation confirmée !',
    'booking_reference_number': 'Numéro de référence (PNR)',
    'booking_view_my_bookings': 'Voir dans mes voyages',
    'booking_back_home': 'Retour à l\'accueil',
    'booking_view_document': 'Voir le document',
    'booking_view_pdf': 'Voir le PDF',
    'booking_save_pdf': 'Enregistrer le PDF',
    'booking_print': 'Imprimer',
    'booking_share': 'Partager',
    'booking_document_title': 'Document de réservation',
    'booking_trip_details_title': 'Détails du voyage',
    'booking_demo_badge': 'RÉSERVATION TEST / DÉMO',
    'my_bookings_title': 'Mes voyages',
    'my_bookings_upcoming': 'À venir',
    'my_bookings_completed': 'Terminés',
    'my_bookings_cancelled': 'Annulés',
    'my_bookings_empty_title': 'Aucune réservation',
    'ai_assistant_title': 'Assistant de voyage IA',
    'ai_assistant_subtitle': 'Planification intelligente et optimisation budgétaire',
    'ai_search_title': 'Recherche intelligente IA',
    'ai_search_banner_flight': 'Rechercher des vols avec l\'IA',
    'ai_search_banner_hotel': 'Rechercher des hôtels avec l\'IA',
    'ai_search_banner_desc': 'Décrivez votre voyage naturellement avec vos propres mots',
    'ai_budget_title': 'Répartition du budget de voyage',
    'ai_badge_verified': 'Tarif en direct vérifié',
    'ai_thinking': 'L\'IA recherche et prépare votre itinéraire...',
  };

  static Map<String, String> _flattenJson(Map<String, dynamic> json, [String prefix = '']) {
    final result = <String, String>{};
    json.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        result.addAll(_flattenJson(value, fullKey));
      } else {
        result[fullKey] = value.toString();
      }
    });
    return result;
  }

  Future<bool> load() async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/translations/${locale.languageCode}.json')
          .timeout(const Duration(milliseconds: 100));
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = _flattenJson(jsonMap);
      return true;
    } catch (e) {
      // Fallback to embedded default map if asset loading fails in headless tests
      if (locale.languageCode == 'fr') {
        _localizedStrings = Map.from(_fallbackFr);
      } else if (locale.languageCode == 'en') {
        _localizedStrings = Map.from(_fallbackEn);
      } else {
        _localizedStrings = {};
      }
      return false;
    }
  }

  String translate(String key) {
    if (_localizedStrings.containsKey(key)) {
      return _localizedStrings[key]!;
    }
    if (locale.languageCode == 'fr') {
      return _fallbackFr[key] ?? _fallbackEn[key] ?? key;
    }
    return _fallbackEn[key] ?? key;
  }

  bool get isRTL => locale.languageCode == 'ar';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    try {
      await localizations.load();
    } catch (_) {}
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
