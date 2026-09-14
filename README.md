# TRAVELGO — Complete Flight & Hotel Booking Mobile Application

**TRAVELGO** is a production-grade, multi-platform travel booking application engineered with **Flutter**, **Dart**, **Riverpod**, and **Material Design 3**.

---

## 🌟 Key Highlights & Features

1. **Dual-Language & Bidirectional Layouts**: Full Arabic (RTL) and English (LTR) localization with dynamic runtime language switching and persistent storage.
2. **Flight Search & Results Engine**:
   - One-Way & Round-Trip flight search.
   - Comprehensive input validation (origin != destination, departure before return, >=1 adult).
   - Real-time filtering (Cheapest, Fastest, Best Value, Airline filter, Max stops, Price range).
   - Full itinerary breakdown with flight segments, layovers, and baggage allowances.
3. **Hotel Discovery & Booking Engine**:
   - Destination autocomplete and check-in/out date range picker.
   - Rich hotel cards with photo galleries, verified review scores, distance to city center, star ratings, and breakfast/cancellation badges.
   - Amenities grid and room tier selection with custom pricing.
4. **Dual Booking & Monetization Model**:
   - **Direct Booking**: Seamless in-app checkout, passenger details, payment method selection, transparent \$1.00 USD standard platform service fee breakdown, PNR generation, and digital boarding passes.
   - **Affiliate Booking**: Outbound link generation with custom click-tracking IDs, redirection warning, and partner portal launch.
5. **Configurable Commission Engine**:
   - \$1.00 USD default service fee configurable from backend config document.
   - Separate pricing calculation pipelines for direct vs affiliate reservations.
6. **Multi-Currency System**:
   - Instant currency conversion between USD (\$), EUR (€), DZD (DA), SAR (SAR), TRY (₺), and GBP (£).
7. **Clean Architecture & Abstract Provider Layer**:
   - `TravelProvider` interface hot-swapping between `MockTravelProvider`, `AmadeusTravelProvider`, and affiliate networks.
   - Ready for Firebase and dedicated NestJS/PostgreSQL backend integration.
8. **Dark Mode & Material Design 3**:
   - Dynamic system / user theme switching with high contrast sapphire and emerald accents.

---

## 📁 Architecture Overview

```text
lib/
├── core/
│   ├── constants/       # AppColors, AppTypography, AppSpacing, AppAssets
│   ├── errors/          # Failures & Exceptions
│   ├── localization/    # AppLocalizations & LanguageNotifier (EN / AR RTL)
│   ├── services/        # CommissionService ($1 USD fee), CurrencyService, StorageService, NotificationService
│   ├── theme/           # AppTheme (MD3 Light/Dark) & ThemeNotifier
│   └── utils/           # CurrencyFormatter, DateFormatter, Validators
│
├── features/
│   ├── splash/          # Animated SplashScreen with initialization check
│   ├── onboarding/      # 3-step modern Onboarding with language switcher
│   ├── authentication/  # Login, Register, Forgot Password, Google & Guest Mode
│   ├── home/            # Home Discovery Hub, Recent Searches, Destinations & Deals
│   ├── flights/         # Flight Search, Filter Sheet, Results & Segment Details
│   ├── hotels/          # Hotel Search, Filters, Results & Gallery Details
│   ├── booking/         # Checkout Summary, Commission Breakdown, PNR Confirmation & My Trips
│   ├── favorites/       # Offline-saved Flights and Hotels
│   ├── profile/         # Profile overview, Edit Profile, Role badge (user/admin)
│   └── settings/        # Currency picker, Language switch, Dark mode & Notifications
│
├── providers_layer/     # Abstract TravelProvider, Mock engine & Amadeus adapter
├── shared/              # Reusable MD3 Widgets & Domain Models
└── main.dart            # Application Entry Point & ProviderScope
```

---

## 🚀 Running the Project

```bash
# 1. Get packages
flutter pub get

# 2. Run unit and widget tests
flutter test

# 3. Run application on connected Android device or emulator
flutter run
```
