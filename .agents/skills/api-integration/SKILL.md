---
name: api-integration
description: REST API integration, client development, and network debugging. Use this skill when integrating external or backend REST APIs, writing data transfer models (DTOs), configuring HTTP clients and interceptors, implementing token refresh flows, handling network errors, and diagnosing API issues.
---

# REST API Integration & Debugging

This skill provides a systematic workflow for integrating RESTful APIs into client and backend applications, implementing robust serialization, handling authentication lifecycle, and diagnosing network communication failures.

---

## 1. Objectives & Scope

- **Contract Adherence**: Accurately translate API specifications (OpenAPI/Swagger, JSON schemas) into type-safe domain models and DTOs.
- **Resilient Client Architecture**: Implement HTTP clients with timeouts, retry policies, authentication interceptors, and response logging.
- **Error Mapping & Normalization**: Map HTTP status codes and error payloads into strongly-typed domain failures.
- **Network Diagnostics & Debugging**: Rapidly isolate connectivity, header, authentication, and payload serialization bugs.
- **Security & Efficiency**: Prevent secret leakage, enforce TLS, and support caching and pagination.

---

## 2. Execution Instructions

### Step 1: API Contract & Schema Inspection
1. Review the endpoint documentation: HTTP method (`GET`, `POST`, `PUT`, `DELETE`, `PATCH`), URI structure, query parameters, request body schema, and headers.
2. Identify authentication requirements: Bearer JWT, API Key (server-proxied only), OAuth2 refresh flows.
3. Identify response variations: Success (`200 OK`, `201 Created`, `204 No Content`), Client Errors (`400`, `401`, `403`, `404`, `422`, `429`), and Server Errors (`500`, `502`, `503`).

### Step 2: DTO Design & Serialization
1. Construct immutable Data Transfer Objects (DTOs) with explicit null-safety.
2. Provide defensive JSON deserialization (`fromJson` / `toJson`):
   - Safely parse timestamps (`DateTime.tryParse()`).
   - Coerce numeric strings or numbers safely (`(json['price'] as num?)?.toDouble()`).
   - Fall back to sensible defaults or nullable properties instead of crashing on missing optional keys.
3. Validate data integrity before mapping DTOs to pure Domain Entities.

### Step 3: HTTP Client & Interceptor Configuration
1. **Base Configuration**:
   - Set explicit connect, send, and receive timeouts (e.g., connect: 10s, receive: 15s).
   - Configure common headers (`Accept: application/json`, `Content-Type: application/json`).
2. **Authentication Interceptor**:
   - Inject the user's active access token dynamically from secure storage.
   - Detect `401 Unauthorized` responses and initiate token refresh with mutex lock to prevent concurrent refresh storms.
3. **Retry Strategy**:
   - Implement exponential backoff for idempotent requests (`GET`, `PUT`, `DELETE`) on transient network drops or `503 Service Unavailable`.
   - Never automatically retry non-idempotent mutation requests (`POST` payment/booking creation) without an Idempotency-Key.

### Step 4: Robust Error Mapping
1. Catch low-level network errors (socket timeout, DNS lookup failure, connection refused) and map to typed `NetworkFailure`.
2. Inspect HTTP status codes:
   - `400 / 422`: Extract structured validation errors and map to `ValidationFailure`.
   - `401`: Trigger re-authentication or token refresh flow; map to `AuthenticationFailure`.
   - `403`: Map to `AuthorizationFailure` (forbidden resource/tier).
   - `404`: Map to `NotFoundFailure`.
   - `429`: Parse `Retry-After` header and map to `RateLimitFailure`.
   - `5xx`: Map to `ServerFailure`.

### Step 5: Network Debugging & Diagnosis
1. Reconstruct failing requests using standard `curl` commands to isolate client logic from API backend issues:
   ```bash
   curl -v -X POST "https://api.example.com/v1/search" \
     -H "Authorization: Bearer <TOKEN>" \
     -H "Content-Type: application/json" \
     -d '{"query":"flights"}'
   ```
2. Enable structured request/response logging in development mode:
   - Log request method, URL, headers (scrubbing Authorization), request body, response code, and latency.
3. Inspect raw payloads to catch casing mismatches (e.g., `camelCase` vs `snake_case`) or unexpected string/number type conversions.

---

## 3. Practical Checklists

### Pre-Integration Checklist
- [ ] API contract / schema documented with example request and response payloads.
- [ ] API endpoints verified using curl or Postman before writing client code.
- [ ] Base URL environment configuration configured (`DEV`, `STAGING`, `PROD`).

### Integration Execution Checklist
- [ ] Explicit timeouts configured for all network requests.
- [ ] All DTO models are immutable with null-safe deserializers.
- [ ] Network exceptions are caught and converted to domain `Failure` / `Result` types.
- [ ] Sensitive headers (passwords, tokens, CVVs) are redacted from logs.
- [ ] Safe pagination handling (supports cursor or limit/offset parameters).
- [ ] Unauthenticated guest state is supported gracefully where appropriate.

### Post-Integration & Testing Checklist
- [ ] Mocked unit tests verify JSON deserialization with valid, empty, and partial payloads.
- [ ] Repository tests verify both successful responses and error mapping for 4xx/5xx responses.
- [ ] Token expiration and automatic refresh flow tested under concurrent requests.

---

## 4. Error-Handling & Troubleshooting Matrix

| Issue | Root Cause | Remediation Procedure |
| :--- | :--- | :--- |
| **`SocketException` / Timeout** | Poor connectivity, wrong host, or firewall block | Check device connectivity; verify base URL and DNS; retry with exponential backoff. |
| **`401 Unauthorized` Loop** | Refresh token expired or refresh endpoint failing | Abort retry loop; clear cached tokens; redirect user to login screen. |
| **`TypeError: Null is not a subtype of String`** | API returned `null` for a field expected to be non-nullable | Make DTO property nullable or supply default fallback in `fromJson`. |
| **`429 Too Many Requests`** | API quota exceeded or missing throttling | Check `Retry-After` header; introduce client-side request debouncing or queueing. |
| **CORS Error (Web Platform)** | Missing CORS headers on API server | Verify `Access-Control-Allow-Origin` on backend, or route web requests through API gateway. |

---

## 5. Security Guardrails

- **Zero Client Secrets**: Third-party private API keys must never be stored in client code; proxy third-party queries through the backend gateway.
- **TLS & Certificate Validation**: Never disable certificate verification (`badCertificateCallback` returning true) in production builds.
- **Log Scrubbing**: Ensure logging interceptors mask sensitive fields (`password`, `token`, `authorization`, `creditCard`).
- **Idempotency**: Use unique client-generated UUID `Idempotency-Key` headers on financial or creation endpoints to avoid duplicate charges.

---

## 6. Examples & Implementation Snippets

### Safe DTO Deserialization Example (Dart)
```dart
class FlightOfferDto {
  final String id;
  final String airlineCode;
  final double price;
  final DateTime departureTime;
  final String? cabinClass;

  const FlightOfferDto({
    required this.id,
    required this.airlineCode,
    required this.price,
    required this.departureTime,
    this.cabinClass,
  });

  factory FlightOfferDto.fromJson(Map<String, dynamic> json) {
    return FlightOfferDto(
      id: json['id'] as String? ?? '',
      airlineCode: json['airlineCode'] as String? ?? 'UNKNOWN',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      departureTime: DateTime.tryParse(json['departureTime'] as String? ?? '') ??
          DateTime.now(),
      cabinClass: json['cabinClass'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'airlineCode': airlineCode,
    'price': price,
    'departureTime': departureTime.toIso8601String(),
    if (cabinClass != null) 'cabinClass': cabinClass,
  };
}
```

### Typed Error Mapping Pattern
```dart
Future<Either<Failure, T>> safeApiCall<T>(Future<T> Function() call) async {
  try {
    final result = await call();
    return Right(result);
  } on SocketException catch (e) {
    return Left(NetworkFailure(message: 'No internet connection: ${e.message}'));
  } on HttpException catch (e) {
    return Left(ServerFailure(message: 'HTTP Protocol error: ${e.message}'));
  } on FormatException catch (e) {
    return Left(ValidationFailure(message: 'Malformed response format: ${e.message}'));
  } catch (e) {
    return Left(UnexpectedFailure(message: e.toString()));
  }
}
```
