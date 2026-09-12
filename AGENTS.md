# AGENTS.md — Instructions for Autonomous AI Coding Agents (Google Jules & AAIF Standard)

Welcome to **TravelGo**, an enterprise-grade full-stack travel booking platform for Flights and Hotels, supporting multi-currency payments, 9-stage merchant commission workflows, and trilingual localization (Arabic RTL, English, French).

This document serves as the operational guide and system prompt for autonomous AI coding agents—including **Google Jules** (`jules.google.com`) and any standard Agentic AI Foundation (AAIF) compliant tools.

---

## 1. Project Overview & Architecture

TravelGo consists of two main tiers:
- **Client Tier (Frontend)**: Flutter 3.x cross-platform application targeting Android, Windows, macOS, iOS, and Web. Implements BLoC state management, responsive UI, strict RTL/LTR layouts, offline caching, and biometric/secure local storage.
- **Service Tier (Backend)**: Node.js (v18+) with TypeScript, Express, PostgreSQL database, and Docker containerization. Handles authentication, booking orchestration, live flight/hotel provider sync, and the merchant commission ledger.

```
travelgo/
├── AGENTS.md                  # Instructions for AI agents (this file)
├── README.md                  # Developer & user documentation
├── pubspec.yaml               # Flutter package configuration & dependencies
├── analysis_options.yaml      # Flutter & Dart static analysis rules
├── docker-compose.yml         # Container orchestration (Postgres, Backend)
├── lib/                       # Flutter Application Source
│   ├── core/                  # Design system, themes, network, localization, utils
│   │   ├── api/               # HTTP client & interceptors
│   │   ├── localization/      # AR, EN, FR translations & RTL engine
│   │   ├── services/          # Local storage, PDF generation, security
│   │   └── theme/             # Color palettes, typography, components
│   ├── features/              # Feature modules (Clean Architecture)
│   │   ├── auth/              # Registration, Login, Biometrics
│   │   ├── flights/           # Flight search, deep stopover filtering, booking
│   │   ├── hotels/            # Hotel search, room selection, amenities
│   │   ├── wallet/            # Merchant wallet, commission tracking, payouts
│   │   ├── bookings/          # Active & past bookings, PNR tracking, PDF exports
│   │   └── profile/           # User preferences, currency, language settings
│   └── main.dart              # App entry point
├── test/                      # Flutter unit and widget tests
│   ├── core/                  # Core services & utilities tests
│   └── features/              # Feature BLoC and logic tests
├── backend/                   # Node.js TypeScript Backend
│   ├── src/                   # Server source code (Express controllers, routes, models)
│   ├── package.json           # Backend dependencies & scripts
│   ├── tsconfig.json          # TypeScript configuration
│   └── jest.config.js         # Backend test runner configuration
├── database/                  # SQL migrations & schema definitions
│   └── migrations/            # Versioned PostgreSQL database schema
└── .github/                   # GitHub Workflows & automation
    └── workflows/
        ├── build_release.yml  # CI/CD for Android APK & Windows builds
        └── jules.yml          # Google Jules autonomous agent workflow
```

---

## 2. Tech Stack & Prerequisites

| Layer | Technologies |
| :--- | :--- |
| **Mobile & Desktop** | Flutter 3.x, Dart 3.4+, flutter_bloc 8.x, go_router, dio, intl, pdf |
| **Backend API** | Node.js 18-20, TypeScript 5.x, Express 4.x, Zod, Helmet, JWT, Bcrypt |
| **Database** | PostgreSQL 15+, pg (node-postgres) |
| **Testing** | `flutter_test`, `jest`, `ts-jest` |
| **Build & CI** | GitHub Actions, Gradle (Android), CMake/Ninja (Windows) |

---

## 3. Setup & Execution Commands

When Jules starts a new VM task, run the following commands to install dependencies:

### Flutter Frontend Setup
```bash
# Get Flutter dependencies
flutter pub get

# Check for static analysis issues
flutter analyze

# Run all unit and widget tests
flutter test
```

### Backend API Setup
```bash
# Navigate to backend directory
cd backend

# Install node dependencies
npm install

# Run TypeScript compilation check
npm run build

# Run backend Jest test suite
npm test

# Run ESLint
npm run lint
```

---

## 4. Architectural Invariants & Business Logic (CRITICAL)

When modifying code or creating pull requests, Jules **must strictly preserve** the following core business rules:

### A. Merchant Commission Calculation (0.75%)
- Platform commission is strictly calculated on the backend: `commission_amount = booking_amount * 0.0075`.
- Never calculate or finalize commission amounts on the frontend client.

### B. Nine-Stage Commission Lifecycle
Commission balances must transition through the 9 predefined statuses:
1. `Booking` (Order placed)
2. `Payment confirmed` (Gateway webhook verified)
3. `Provider confirmed` (Airline PNR or Hotel voucher issued)
4. `Commission calculated` (0.75% computed)
5. `Commission pending` (Locked in escrow, not withdrawable)
6. `Commission available` (Released to merchant wallet available balance)
7. `Withdrawal request` (Merchant initiates payout request)
8. `Admin verification` (Compliance & anti-fraud check)
9. `Bank payout` -> `Withdrawal completed` (Funds transferred to merchant bank account)

> **CRITICAL**: Commission is **never** available immediately upon booking creation. It remains `Pending` until provider confirmation.

### C. Multi-Currency Isolation
- Wallets exist strictly in separate currencies: **EUR**, **USD**, **DZD**, **GBP**.
- **Never sum balances of different currencies together**. Each currency has its own available, pending, and earned balances.
- Minimum payout thresholds:
  - EUR: `50.00`
  - USD: `50.00`
  - DZD: `6,500.00`
  - GBP: `40.00`

### D. Append-Only Financial Ledger
- The `wallet_transactions` table is immutable. Rows must never be updated or deleted.
- Every transaction must capture `balance_before` and `balance_after`.
- Refunds or adjustments are recorded as new transaction entries (`type: 'adjustment'` or `type: 'refund'`).

### E. Banking Data Security & Privacy
- Sensitive account numbers and IBANs must be masked in API responses and frontend views (e.g., `DZ****1234`).
- Passwords must be hashed using `bcrypt` (minimum 10 salt rounds).
- Secrets and API credentials must be read exclusively from environment variables (`.env`). Never hardcode tokens or keys.

### F. Trilingual & Bi-Directional UI
- All UI strings must support Arabic (`ar`), English (`en`), and French (`fr`).
- Arabic must be rendered with proper Right-to-Left (RTL) padding, text alignments, and icon flipping.

---

## 5. Coding Standards & Conventions

### Dart & Flutter
- Follow effective Dart conventions (`prefer_const_constructors`, `avoid_print`, explicit type annotations for public APIs).
- Maintain separation of concerns: UI components listen to BLoC states; data access is encapsulated in repositories.
- Keep tests updated for any new feature or refactored logic. Run `flutter test` before submitting changes.

### TypeScript & Node.js
- Use strict TypeScript mode (`strict: true` in `tsconfig.json`).
- Validate incoming request payloads with Zod schemas.
- Centralize error handling through Express middleware.

---

## 6. Guidelines for Jules PRs & Commits

1. **Keep Changes Minimal and Focused**: Address only the requested task or issue. Do not perform unrelated refactoring.
2. **Commit Messages**: Follow Conventional Commits:
   - `feat: add airline filter for transit flights`
   - `fix: correct balance_after calculation on payout`
   - `test: add unit tests for merchant wallet bloc`
   - `docs: update API integration instructions`
3. **Verification Before PR**:
   - Ensure `flutter analyze` passes with zero errors.
   - Ensure `flutter test` passes all tests.
   - Ensure `npm test` passes in `backend/`.
