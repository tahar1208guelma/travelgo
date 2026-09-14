import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/services/print_service.dart';
import 'package:travelgo/core/services/share_service.dart';
import 'package:travelgo/features/bookings/data/mock_booking_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Print & Share Services Tests', () {
    late PrintService printService;
    late ShareService shareService;

    setUp(() {
      printService = PrintService();
      shareService = ShareService();
    });

    test('PrintResult model represents success and failure correctly', () {
      final successResult = PrintResult.success();
      expect(successResult.isSuccess, isTrue);
      expect(successResult.errorMessage, isNull);

      final failResult = PrintResult.failure('Printer unavailable');
      expect(failResult.isSuccess, isFalse);
      expect(failResult.errorMessage, 'Printer unavailable');
    });

    test('FileSaveResult model represents file operations correctly', () {
      final success = FileSaveResult.success('C:\\Users\\User\\Downloads\\doc.pdf');
      expect(success.isSuccess, isTrue);
      expect(success.filePath, 'C:\\Users\\User\\Downloads\\doc.pdf');
      expect(success.errorMessage, isNull);

      final failure = FileSaveResult.failure('Permission denied');
      expect(failure.isSuccess, isFalse);
      expect(failure.errorMessage, 'Permission denied');
    });

    test('Suggested PDF file names format accurately according to specs', () {
      expect(
        MockBookingData.flightBooking.suggestedPdfFileName,
        'TRAVELGO_Booking_TRV-2026-000001.pdf',
      );
      expect(
        MockBookingData.hotelBooking.suggestedPdfFileName,
        'TRAVELGO_HotelVoucher_TRV-2026-000002.pdf',
      );
      expect(
        MockBookingData.combinedBooking.suggestedPdfFileName,
        'TRAVELGO_CombinedBooking_TRV-2026-000003.pdf',
      );
    });
  });
}
