import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/services/print_service.dart';
import 'package:travelgo/core/services/share_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Print & Share Services Tests', () {
    test('PrintResult model instantiates success and failure correctly', () {
      final success = PrintResult.success();
      expect(success.isSuccess, isTrue);
      expect(success.errorMessage, isNull);

      final failure = PrintResult.failure('Print cancelled');
      expect(failure.isSuccess, isFalse);
      expect(failure.errorMessage, equals('Print cancelled'));
    });

    test('ShareResultInfo model instantiates success and failure correctly', () {
      final success = ShareResultInfo.success('/tmp/doc.pdf');
      expect(success.isSuccess, isTrue);
      expect(success.savedPath, equals('/tmp/doc.pdf'));

      final failure = ShareResultInfo.failure('Share failed');
      expect(failure.isSuccess, isFalse);
      expect(failure.message, equals('Share failed'));
    });

    test('PrintService getAvailablePrinters returns empty list or printer list safely', () async {
      final printService = PrintService();
      final printers = await printService.getAvailablePrinters();
      expect(printers, isA<List>());
    });
  });
}
