import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/utils/validators.dart';

void main() {
  group('AppValidators Tests', () {
    test('validateEmail returns null on valid email and error on invalid', () {
      expect(AppValidators.validateEmail('test@example.com'), isNull);
      expect(AppValidators.validateEmail('invalid-email'), isNotNull);
      expect(AppValidators.validateEmail(''), isNotNull);
    });

    test('validateAirportsDifferent ensures origin and destination differ', () {
      expect(AppValidators.validateAirportsDifferent('ALG', 'DXB'), isTrue);
      expect(AppValidators.validateAirportsDifferent('ALG', 'alg'), isFalse);
      expect(AppValidators.validateAirportsDifferent('DXB', 'DXB'), isFalse);
    });

    test('validateDateRange rejects return dates earlier than departure', () {
      final now = DateTime(2026, 9, 1);
      final validReturn = DateTime(2026, 9, 8);
      final invalidReturn = DateTime(2026, 8, 25);

      expect(AppValidators.validateDateRange(now, validReturn), isTrue);
      expect(AppValidators.validateDateRange(now, invalidReturn), isFalse);
      expect(AppValidators.validateDateRange(now, null), isTrue);
    });

    test('validatePassengerCount ensures at least 1 adult', () {
      expect(AppValidators.validatePassengerCount(1, 0, 0), isTrue);
      expect(AppValidators.validatePassengerCount(2, 1, 1), isTrue);
      expect(AppValidators.validatePassengerCount(0, 1, 0), isFalse);
      expect(AppValidators.validatePassengerCount(0, 0, 0), isFalse);
    });
  });
}
