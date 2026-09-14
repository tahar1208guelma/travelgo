# AGENTS.md — AI Coding Agent Guidelines for TRAVELGO

> **Target Audience**: All AI Coding Assistants, LLM Autonomous Agents, and Developers contributing to the **TRAVELGO** codebase.
> **Scope**: Strict architectural, security, testing, git, and behavioral rules.

---

## 1. Project Purpose

**TRAVELGO** is a production-grade, multi-platform travel booking application engineered with **Flutter**, **Dart**, **Riverpod**, and **Material Design 3**, currently targeting Android, iOS, Desktop, and Web. The platform empowers travelers to search, compare, and book flights and hotels through two primary monetization channels:
- **Direct Bookings**: In-app reservations collecting a deterministic, configurable platform service fee ($1.00 USD standard default).
- **Affiliate Bookings**: Outbound partner links with transparent click-tracking and $0.00 platform markup.
- **AI Travel Assistant Layer**: An intelligent, conversational travel planning and budget optimization assistant that augments user experience without compromising financial integrity.

---

## 2. Architecture Rules

1. **Clean Architecture Separation**: Strictly maintain the separation of layers:
   - `core/`: Application-wide constants, design tokens, error models, utilities, and reusable services.
   - `features/<feature_name>/`:
     - `domain/`: Pure Dart entities, value objects, and repository interfaces. Must **never** depend on Flutter UI or external data sources.
     - `data/`: Data models (JSON serialization), data sources (HTTP, local cache), and repository implementations.
     - `presentation/`: Riverpod `StateNotifier` controllers, screens, and reusable widgets.
   - `providers_layer/`: Abstract `TravelProvider` interface and interchangeable provider adapters (`MockTravelProvider`, `AmadeusTravelProvider`).
   - `shared/`: App-wide domain models (`Airport`, `Currency`, `Destination`) and reusable UI widgets.
2. **State Management**: Standardize on **Riverpod (v2.x)** using `StateNotifier` / `StateNotifierProvider` and pure `Provider`. Avoid arbitrary global mutable state.
3. **Repository Pattern**: UI widgets must **never** make direct API or database calls. All queries must pass through domain repositories.

---

## 3. Frontend Rules

1. **Material Design 3**: Adhere strictly to MD3 styling (`useMaterial3: true`), utilizing `AppColors`, `AppTypography`, and `AppSpacing`.
2. **Responsive & Adaptive UI**: All screens must support Mobile (<600dp), Tablet (600–1024dp), and Desktop (>1024dp) using `Responsive` utilities and `ResponsiveWrapper`.
3. **Bilingual & RTL/LTR Directionality**:
   - Every user-facing string **must** be localized in both `assets/translations/en.json` and `assets/translations/ar.json`.
   - Arabic layout must support full bidirectional mirror-flipping (`AppLocalizations`, `intl`).
   - Never hardcode user-facing strings in widget trees.

---

## 4. Backend Rules

1. **API Gateway Pattern**: The mobile client must **never** communicate directly with third-party travel GDS/aggregators using private keys. All external requests must route through a secure backend API gateway (Firebase Cloud Functions or NestJS/PostgreSQL backend).
2. **Zero Client Secrets**: No third-party API private keys, secret tokens, or payment credentials may be packaged in the Flutter client binary.

---

## 5. Supabase Rules (If Introduced)

1. **Row Level Security (RLS)**: Every Supabase table **must** have Row Level Security enabled (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY;`).
2. **Client Key Restriction**: Only use the public `anon_key` on client applications. The `service_role` key must **never** be included in client code or frontend builds.
3. **Migration Files**: All schema updates must be committed as idempotent SQL migration files under `supabase/migrations/`.
4. **Policy Enforcement**: Users can only read and write their own data (`auth.uid() = user_id`) unless an explicit `admin` claim is verified.

---

## 6. Authentication Rules

1. **Domain Model**: Authentication revolves around `UserEntity` with explicit roles (`UserRole.user`, `UserRole.admin`) and guest flags (`isGuest`).
2. **Guest Mode**: Guest users must be allowed full exploration of flight and hotel catalogues, with authentication prompted only during booking checkout or profile synchronization.
3. **Token Management**: Auth tokens must be securely stored in local cache (`StorageService`) and attached to backend requests via standard Bearer headers.

---

## 7. API Security Rules

1. **Request Validation**: All backend endpoints must validate incoming payload structures and enforce strict data types.
2. **Rate Limiting**: AI and search endpoints must enforce token-bucket or IP/user-based rate limits to prevent denial-of-service or API quota exhaustion.
3. **HTTPS / TLS**: All network communication must use HTTPS with certificate pinning where applicable.

---

## 8. Environment Variable Rules

1. **No Hardcoded Secrets**: Never commit real production secrets, API keys, or private tokens into Git.
2. **Environment Configuration**: Use `.env.example` templates to document required variables.
3. **Secret Storage**: Production credentials must be managed via Firebase Secret Manager, Cloud KMS, or secure CI/CD vault mechanisms.

---

## 9. AI / LLM Integration Rules (Critical)

> [!CAUTION]
> **STRICT FINANCIAL & ARCHITECTURAL GUARDRAILS FOR AI AGENTS**:
> 1. **Never Expose Secret API Keys in Frontend Code**: All LLM API calls must be proxied via the backend AI gateway.
> 2. **Never Trust LLM Output as Authoritative Financial or Booking Data**: LLMs are nondeterministic reasoning engines. Never allow an LLM to generate, invent, or override prices, taxes, or availability.
> 3. **Validate All Structured LLM Output**: All LLM responses must be parsed through strict schema validators (e.g., `AIExtractedIntent`, `AITripPlanModel`). If parsing fails, fall back gracefully to deterministic search.
> 4. **LLM Must Never Directly Execute Financial Transactions**: The LLM may only recommend flights or hotels. Actual reservation and payment execution must route through `BookingSummaryScreen` and deterministic repositories.
> 5. **LLM Must Never Fabricate Availability, Prices, Bookings, or Confirmations**: Prices and flight/hotel options displayed to the user must originate strictly from verified `FlightRepository` and `HotelRepository` datasets.
> 6. **Use Server-Side Tools/Functions for External APIs**: The LLM interacts with travel inventory solely through validated function calls and server-side tool definitions.
> 7. **Validate All Tool Arguments**: Enforce strict validation on dates, airport codes, guest counts, and budget limits before executing repository queries.
> 8. **Keep AI Functionality Isolated from Core Booking Logic**: AI modules must reside exclusively in `lib/features/ai_agent/` and remain removable/toggable without breaking core app features.
> 9. **Existing TravelGo Functionality Must Remain Operational**: Core search, results, filters, booking, favorites, and profile flows must remain 100% operational regardless of AI service state.

---

## 10. Booking Rules

1. **Dual-Channel Distinction**:
   - **Direct Booking**: Handled in-app with customer details form, price breakdown, PNR generation, and digital boarding passes in **My Bookings**.
   - **Affiliate Booking**: Generates tracking IDs, logs `affiliateClicks`, displays a partner notice dialog, and launches the partner portal via `url_launcher`.
2. **Document Generation**: Every confirmed booking must support PDF generation (`PdfService`), native printing (`PrintService`), QR code rendering, and system sharing (`ShareService`).
3. **Immutability**: Once confirmed, booking financial details (base price, taxes, service fee) must be immutable in user records.

---

## 11. Payment Rules

1. **Deterministic Calculation**: All prices, taxes, and service fees must be calculated using pure arithmetic functions in `CommissionService`.
2. **No Client Payment Secrets**: Payment gateways (Stripe, PayPal, Apple Pay, Google Pay) must process tokens via server-side intent verification.

---

## 12. Commission Rules ($1.00 USD Standard Platform Fee)

1. **Direct Booking Fee**: A standard platform service fee (default **\$1.00 USD**) is applied to all direct bookings:
   $$\text{Total Amount} = \text{Base Fare} + \text{Taxes} + \text{Service Fee (\$1.00 USD)}$$
2. **Affiliate Redirection Fee**: Service fee on affiliate redirects is **\$0.00** by default, ensuring zero unbacked markup to end users.
3. **Configurable Fee**: The service fee is dynamically loaded from `CommissionConfig` (backed by Firestore `config/global_commission`) allowing admin adjustments without client binary updates.

---

## 13. 0.75% Commission Rules (If Percentage Model is Configured)

1. **Formula**: If a percentage-based commission model (0.75%) is activated for specific partner tiers:
   $$\text{Platform Commission} = \text{Base Fare} \times 0.0075$$
2. **Deterministic Computation**: Must be computed inside `CommissionService` using standard floating-point / decimal arithmetic.
3. **Never LLM Generated**: The LLM must never calculate, estimate, or modify the 0.75% fee.
4. **Rounding & Currency**: Results must be rounded to 2 decimal places in USD and converted accurately via `CurrencyService`.

---

## 14. Database Migration Rules

1. **Non-Destructive Migrations**: Database changes must be additive (e.g. adding nullable columns, new collections) to avoid breaking existing clients.
2. **No Data Loss**: Never drop existing tables or delete existing collections without a verified backup and phased deprecation strategy.
3. **Rollback Strategy**: Every migration must have a tested, documented rollback procedure.

---

## 15. Testing Rules

1. **Run Existing Tests Before Major Changes**: Always execute the full test suite before committing architectural changes to guarantee zero regressions.
2. **Add Tests for Every New Feature/Service**:
   - Every new domain service must have corresponding unit tests in `test/unit/`.
   - Every new screen and custom interactive widget must have widget tests in `test/widget/`.
3. **Test Failure Scenarios**:
   - Test API timeouts and network dropouts.
   - Test malformed or invalid LLM responses.
   - Test out-of-range user inputs (invalid dates, negative budgets, identical airports).
   - Test unauthorized and expired session states.

---

## 16. Git Rules

1. **Never Directly Modify `main` / `master`**: All development must occur on dedicated branches unless explicitly instructed by the project lead.
2. **Branch Naming Conventions**:
   - `feature/<feature-name>` for new features (e.g., `feature/ai-travel-agent`).
   - `fix/<bug-name>` for bug fixes.
   - `refactor/<scope>` for architectural refactoring.
3. **Atomic & Meaningful Commits**: Use Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`).
4. **Do Not Rewrite Git History**: Never force push (`git push --force`) to shared branches.
5. **Preserve Codebase Integrity**: Never delete or rename existing working features without explicit user instruction.

---

## 17. Branching Rules

- **`main` / `master`**: Production-ready, stable releases.
- **`develop`**: Integration branch for upcoming releases.
- **`feature/*`**: Isolated feature development branches branched off `develop` (or `main`) and merged back via Pull Requests after passing all automated tests.

---

## 18. Error Handling

1. **Domain Failures vs Exceptions**:
   - Data layer catches `Exception` (`ServerException`, `CacheException`, `NetworkException`) and returns `Either<Failure, T>` or throws typed `Failure` models (`ServerFailure`, `CacheFailure`, `ValidationFailure`).
2. **Graceful User Feedback**: The UI must display user-friendly error messages (`ErrorView`, inline validation banners) and provide immediate retry actions.
3. **No Unhandled Async Rejections**: All `Future` and `Stream` operations must have explicit `.catchError()` or `try-catch` blocks.

---

## 19. Logging Rules

1. **No Sensitive PII in Logs**: Never log passwords, payment card numbers, CVVs, or full user identity tokens.
2. **Structured Logging**: Use categorized debug logging tags (`[AUTH]`, `[FLIGHT_SEARCH]`, `[HOTEL_SEARCH]`, `[BOOKING]`, `[AI_AGENT]`).
3. **Production Log Stripping**: Ensure debug logs are disabled or stripped in release builds (`kReleaseMode`).

---

## 20. Backward Compatibility

1. **Preserve Existing Data**: Updates must preserve existing local storage schemas, user favorites, and offline booking vouchers.
2. **Interface Stability**: Public methods on core services (`CommissionService`, `CurrencyService`, `StorageService`, `TravelProvider`) must maintain backward-compatible signatures.
3. **Graceful Fallbacks**: If new services (such as AI backend endpoints) are unreachable, the application must seamlessly fall back to deterministic local/sandbox providers.
