---
name: code-review
description: Senior-level code review for software projects. Use this skill when reviewing pull requests, inspecting code diffs, assessing architectural boundaries (such as Clean Architecture, separation of concerns, and state management), verifying maintainability, and providing structured, actionable code feedback.
---

# Senior-Level Code Review

This skill guides agents and senior engineers in conducting thorough, constructive, and architecturally rigorous code reviews across multi-tier software projects.

---

## 1. Objectives & Scope

- **Architectural Integrity**: Ensure strict boundary separation (e.g., Clean Architecture: domain, data, presentation layers).
- **Correctness & Robustness**: Spot logic errors, concurrency issues, edge-case mishandling, and uncaught exceptions.
- **Maintainability & Readability**: Enforce idiomatic standards, clear naming, high cohesion, and low coupling.
- **Performance & Resource Management**: Identify leaks, redundant allocations, excessive re-renders, and unclosed resources.
- **Actionable Feedback**: Provide polite, specific, categorized, and prioritized feedback.

---

## 2. Execution Instructions

### Step 1: Context & Scope Discovery
1. Identify the purpose of the change (ticket/issue, user story, bug fix, or refactor).
2. Inspect the diff summary:
   ```bash
   git status --short
   git diff --stat origin/main...HEAD
   ```
3. Determine if the change introduces breaking public API changes, database schema alterations, or config updates.

### Step 2: Layer & Boundary Verification
1. **Domain Layer**:
   - Verify domain entities and use-cases contain zero UI or database framework dependencies.
   - Ensure business logic resides in domain entities or use-cases, not widgets or raw controllers.
2. **Data Layer**:
   - Verify models correctly handle nullability, deserialization errors, and API schema shifts.
   - Confirm network/database exceptions are mapped to domain-specific failures (`Failure` / `Result` types).
3. **Presentation / UI Layer**:
   - Ensure UI widgets do not perform direct network, database, or heavy computational tasks.
   - Check state management bindings (e.g., Riverpod, Bloc) for proper lifecycle scoping and disposal.

### Step 3: Logic, Concurrency & Edge Cases
1. **Null & Type Safety**: Ensure all nullable fields are validated or guarded with null-coalescing operators.
2. **Async Operations**:
   - Verify all asynchronous calls have explicit error handling (`try/catch` or `.catchError()`).
   - Check for race conditions, unhandled cancellations, and un-awaited futures that should be awaited.
3. **Resource Disposal**: Confirm streams, controllers, timers, and client sockets are closed in `dispose()` lifecycle hooks.

### Step 4: Test Coverage & Quality
1. Verify that new functionality includes corresponding unit or widget tests.
2. Check for negative and edge-case tests (e.g., empty lists, timeouts, 4xx/5xx HTTP errors, invalid user input).
3. Ensure existing tests pass without regressions:
   ```bash
   # Dart/Flutter example
   flutter test --no-pub
   ```

### Step 5: Constructive Comment Formulation
Structure every review comment using Conventional Comments syntax:
- `[P0 - Blocker]`: Critical bug, data loss risk, severe security vulnerability, or architectural violation.
- `[P1 - Important]`: Significant logic error, missing test coverage, or unhandled failure state.
- `[P2 - Suggestion]`: Performance enhancement, code readability improvement, or refactoring recommendation.
- `[P3 - Nitpick]`: Formatting, naming nuance, or minor non-blocking polish.
- `[Kudos]`: Commend clever solutions, clean abstractions, or well-crafted tests.

---

## 3. Practical Checklists

### Pre-Review Checklist
- [ ] PR description clearly explains *what* was changed and *why*.
- [ ] Diff size is manageable (ideally under 400 lines of logic changes; flag mega-PRs for splitting).
- [ ] Automated CI/linter checks pass cleanly.

### Review Execution Checklist
- [ ] **Architecture**: No forbidden cross-layer imports (e.g., Presentation importing Data sources directly).
- [ ] **Error Handling**: No empty `catch` blocks or swallowed errors.
- [ ] **State & Re-renders**: State mutations trigger minimal necessary UI rebuilds.
- [ ] **Immutability**: Data transfer objects and entity models are immutable (`final` fields, `copyWith` methods).
- [ ] **Logging**: Diagnostic logs use structured tags and contain zero sensitive PII or credentials.
- [ ] **Localization**: User-facing strings are externalized into translation catalogs, not hardcoded.

### Sign-Off Checklist
- [ ] All P0 and P1 comments are resolved or accepted as tracked follow-up issues.
- [ ] Verification tests verified locally or via CI.
- [ ] Clear approval or requested-changes verdict posted with summary.

---

## 4. Error-Handling & Ambiguity Procedures

| Scenario | Symptom / Risk | Required Resolution |
| :--- | :--- | :--- |
| **Missing Test Suite** | PR adds 200+ lines of business logic without tests | Request tests before approving: mark as `[P1 - Important]`. |
| **Architectural Leak** | UI widget directly calls HTTP client or DB query | Block PR: mark as `[P0 - Blocker]`, suggest moving call to Repository/Controller. |
| **Hidden Breaking Change** | Renamed API parameter breaks client consumption | Request API versioning or backward-compatible fallback. |
| **Unbounded Resource Usage** | Infinite scroll or unbounded list fetching without pagination | Request cursor/offset pagination and local cache limits. |

---

## 5. Security Considerations

- **Secrets & Credentials**: Flag any committed `.env` files, API keys, private certificates, or test tokens.
- **Input Sanitization**: Ensure all external inputs (URL parameters, text inputs, QR codes) are validated before parsing.
- **Authentication & Authorization**: Verify that protected endpoints and actions verify role permissions (`admin` vs `user` vs `guest`).
- **Financial & Data Integrity**: Never trust client-calculated prices or discounts; ensure backend verification is enforced.

---

## 6. Examples & Review Templates

### Sample Review Comment: Architectural Leak
```markdown
[P0 - Blocker] Layer Boundary Violation
In `lib/features/flights/presentation/screens/flight_list_screen.dart#L84`:
The widget directly invokes `http.get(Uri.parse(...))` to fetch flight offers.

**Issue**: Presentation widgets must not perform direct network I/O. This bypasses caching, error mapping, and makes UI testing difficult.
**Recommendation**: Route this request through `FlightRepository` and read state via `flightSearchControllerProvider`:
```dart
// Suggested refactor:
ref.read(flightSearchControllerProvider.notifier).searchFlights(criteria);
```
```

### Sample Review Comment: Resource Leak
```markdown
[P1 - Important] Unclosed StreamSubscription
In `lib/features/booking/presentation/controllers/booking_timer.dart#L32`:
`_timerSubscription` is initialized in `startTimer()`, but is never cancelled when the controller is destroyed.

**Issue**: This will cause memory leaks and trigger state updates on disposed widgets.
**Recommendation**: Cancel the subscription inside `dispose()` / `onDispose`:
```dart
ref.onDispose(() {
  _timerSubscription?.cancel();
});
```
```
