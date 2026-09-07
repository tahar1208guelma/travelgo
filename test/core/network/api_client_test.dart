import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/network/api_result.dart';
import 'package:travelgo/core/network/network_exceptions.dart';

void main() {
  group('ApiResult & Network Layer Tests', () {
    test('ApiResult.success unwraps correctly', () {
      final result = ApiResult.success({'status': 'confirmed'});
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals({'status': 'confirmed'}));
      expect(result.errorMessageOrNull, isNull);

      final val = result.when(
        success: (data) => 'Got data',
        failure: (msg, code, sc) => 'Failed',
      );
      expect(val, equals('Got data'));
    });

    test('ApiResult.failure unwraps message and code correctly', () {
      final result = ApiResult<String>.failure('Invalid token', code: 'UNAUTHORIZED', statusCode: 401);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.errorMessageOrNull, equals('Invalid token'));

      final val = result.when(
        success: (data) => 'Got data',
        failure: (msg, code, sc) => '$code: $msg',
      );
      expect(val, equals('UNAUTHORIZED: Invalid token'));
    });

    test('NetworkExceptions hierarchy and serialization', () {
      const ex1 = PriceChangedException(oldPrice: 250.0, newPrice: 280.0);
      expect(ex1.errorCode, equals('PRICE_CHANGED'));
      expect(ex1.statusCode, equals(409));

      const ex2 = UnauthorizedException();
      expect(ex2.statusCode, equals(401));

      const ex3 = InventorySoldOutException();
      expect(ex3.statusCode, equals(410));

      const ex4 = PaymentFailedException('Card declined by issuing bank', declineCode: 'INSUFFICIENT_FUNDS');
      expect(ex4.statusCode, equals(402));
      expect(ex4.errorCode, equals('INSUFFICIENT_FUNDS'));
    });
  });
}
