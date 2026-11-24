---
name: automated-testing
description: Unit, widget, and integration testing for software applications. Use this skill when writing unit tests for business logic, repositories, and state controllers, creating widget tests for UI components and user interactions, implementing end-to-end integration tests, mocking external dependencies, and diagnosing flaky tests.
---

# Automated Testing: Unit, Widget & Integration

This skill establishes standard patterns and procedures for designing, implementing, and running automated tests across the test pyramid: unit, widget/component, and integration tests.

---

## 1. Objectives & Scope

- **Test Pyramid Balance**: High volume of fast, deterministic Unit Tests; moderate Widget Tests for UI interaction; targeted Integration Tests for end-to-end flows.
- **Isolation & Determinism**: Use mocks, fakes, and test fixtures rather than live external networks or persistent databases.
- **Failure Path Coverage**: Systematically test edge cases, invalid inputs, network timeouts, 4xx/5xx errors, and corrupted state.
- **Maintainable Assertions**: Write readable, resilient tests that verify behavior rather than brittle internal implementation details.

---

## 2. Execution Instructions

### Step 1: Unit Testing (Domain & Business Logic)
1. **Target**: Pure entities, domain services, utility calculations, and state controllers (e.g., Riverpod `StateNotifier`).
2. **Setup**:
   - Create a clean test harness for each test case (`setUp` / `tearDown`).
   - For Riverpod controllers, instantiate an isolated `ProviderContainer`:
     ```dart
     final container = ProviderContainer(
       overrides: [
         flightRepositoryProvider.overrideWithValue(mockFlightRepository),
       ],
     );
     addTearDown(container.dispose);
     ```
3. **Execution**:
   - Follow the **Arrange - Act - Assert (AAA)** pattern.
   - Test both success cases and edge cases (empty lists, invalid boundaries, null parameters).
   - Test exception propagation (e.g., ensuring `RepositoryException` maps to domain `Failure`).

### Step 2: Widget & Component Testing (UI & Interaction)
1. **Target**: Screen widgets, custom controls, form validation, and responsive layouts.
2. **Pumping & Rendering**:
   - Wrap target widgets in required ancestors (`MaterialApp`, `Directionality`, `ProviderScope`, `Scaffold`).
   - Use `tester.pumpWidget()` to mount the widget tree.
   - Use `tester.pump()` for frame advances and `tester.pumpAndSettle()` for animations to settle.
3. **User Interaction**:
   - Simulate user gestures: `tester.tap()`, `tester.enterText()`, `tester.drag()`.
   - Verify widget state updates after user input (e.g., error messages appear on invalid submission).
4. **Responsive Testing**:
   - Set virtual surface sizes to test Mobile (<600dp), Tablet (600–1024dp), and Desktop (>1024dp):
     ```dart
     tester.view.physicalSize = const Size(1280, 800);
     tester.view.devicePixelRatio = 1.0;
     addTearDown(tester.view.resetPhysicalSize);
     ```

### Step 3: Integration & End-to-End Testing
1. **Target**: Critical user journeys (e.g., Search Flights -> Select Offer -> Fill Passenger Info -> Confirm Booking).
2. **Mocking Backend/Gateway**:
   - Use mock servers or in-memory repositories to ensure zero reliance on live production APIs.
3. **Assertions**:
   - Verify seamless transitions across multiple screens and persistence into local storage.

### Step 4: Running Test Suites & Coverage Analysis
1. Run all tests locally:
   ```bash
   flutter test --no-pub
   ```
2. Run targeted tests:
   ```bash
   flutter test test/unit/features/flights/flight_repository_test.dart
   flutter test test/widget/features/booking/booking_summary_test.dart
   ```
3. Generate coverage reports:
   ```bash
   flutter test --coverage
   # Output located at coverage/lcov.info
   ```

---

## 3. Practical Checklists

### Pre-Testing Checklist
- [ ] Requirements and acceptance criteria defined.
- [ ] Dependencies to mock (repositories, HTTP clients, secure storage) identified.
- [ ] Test directory mirrors source structure (`test/unit/`, `test/widget/`, `test/integration/`).

### Test Implementation Checklist
- [ ] **Arrange-Act-Assert**: Tests clearly divided into AAA phases.
- [ ] **No Hardcoded Delays**: Never use `Future.delayed()` for synchronization; use `tester.pumpAndSettle()` or async matchers (`completion()`).
- [ ] **Teardown Cleanliness**: Containers, controllers, streams, and virtual screen sizes reset in `tearDown` or `addTearDown`.
- [ ] **Negative Scenarios Covered**:
  - [ ] Network timeout / unreachable backend.
  - [ ] 401 Unauthorized / expired token.
  - [ ] 400 Bad Request / invalid schema.
  - [ ] Empty state / zero results.
- [ ] **Localization & RTL**: Widgets tested in both LTR and RTL orientations where applicable.

### Quality & CI Checklist
- [ ] 100% of test suite passes without flaky failures.
- [ ] Tests run cleanly in sandbox / headless CI without requiring GUI display or live internet.

---

## 4. Error-Handling & Flakiness Troubleshooting

| Test Symptom | Root Cause | Fix Procedure |
| :--- | :--- | :--- |
| **`pumpAndSettle timed out`** | An infinite animation (looping progress spinner, continuous timer) is running | Use `tester.pump(Duration(milliseconds: 100))` for specific steps instead of `pumpAndSettle()`. |
| **`Bad state: No ProviderScope found`** | Widget uses Riverpod hooks/refs without parent `ProviderScope` | Wrap the test widget with `ProviderScope(overrides: [...], child: ...)`. |
| **`A RenderFlex overflowed by X pixels`** | Fixed widget size tested on smaller simulated viewport | Verify viewport size or update widget layout to use `Expanded` / `SingleChildScrollView`. |
| **State Leaks Between Tests** | Shared static state or persistent singleton cache | Reset singleton states and use isolated `ProviderContainer` per test. |

---

## 5. Security Guardrails

- **Zero Real Secrets in Fixtures**: Never use real API keys, production passwords, or real customer PII in test mocks or fixtures.
- **Isolated Sandbox Execution**: Test runners must not communicate with live production billing or database systems.
- **Deterministic Clocks**: Mock time-dependent operations (`clock` package) to prevent tests from failing due to timezone or leap year shifts.

---

## 6. Examples & Test Templates

### Riverpod StateNotifier Unit Test Example
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockFlightRepository extends Mock implements FlightRepository {}

void main() {
  late MockFlightRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockFlightRepository();
    container = ProviderContainer(
      overrides: [
        flightRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('searchFlights emits success state with flights when repo succeeds', () async {
    // Arrange
    final testFlights = [Flight(id: 'FL-101', price: 150.0)];
    when(() => mockRepo.searchFlights(any()))
        .thenAnswer((_) async => Right(testFlights));

    final notifier = container.read(flightSearchProvider.notifier);

    // Act
    await notifier.search(const SearchCriteria(origin: 'JFK', destination: 'LHR'));

    // Assert
    final state = container.read(flightSearchProvider);
    expect(state.isLoading, isFalse);
    expect(state.flights, equals(testFlights));
    expect(state.error, isNull);
  });
}
```

### Interactive Widget Test Example
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('displays validation error when airport codes are identical', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: FlightSearchForm()),
        ),
      ),
    );

    // Enter origin and destination with identical codes
    await tester.enterText(find.byKey(const Key('origin_field')), 'DXB');
    await tester.enterText(find.byKey(const Key('destination_field')), 'DXB');
    await tester.tap(find.byKey(const Key('search_button')));
    await tester.pumpAndSettle();

    // Assert validation message appears
    expect(find.text('Origin and destination cannot be identical'), findsOneWidget);
  });
}
```
