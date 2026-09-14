import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ar', ''),
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

  Future<bool> load() async {
    try {
      final jsonString = await rootBundle.loadString('assets/translations/${locale.languageCode}.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    } catch (e) {
      // Fallback to embedded default map if asset loading fails in headless tests
      _localizedStrings = {};
      return false;
    }
  }

  String translate(String key) {
    if (_localizedStrings.containsKey(key)) {
      return _localizedStrings[key]!;
    }
    return _fallbackEn[key] ?? key;
  }

  bool get isRTL => locale.languageCode == 'ar';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
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
