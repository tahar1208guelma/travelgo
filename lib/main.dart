// Welcome developers!
import 'package:flutter/material.dart';
import 'core/responsive/adaptive_scaffold.dart';
import 'core/services/pdf_service.dart';
import 'core/services/print_service.dart';
import 'core/services/share_service.dart';
import 'core/theme/app_theme.dart';
import 'features/bookings/services/booking_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TravelGoApp());
}

class TravelGoApp extends StatelessWidget {
  const TravelGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate core service singletons
    final pdfService = PdfService();
    final printService = PrintService();
    final shareService = ShareService();
    final bookingRepository = MockBookingRepository();

    return MaterialApp(
      title: 'TRAVELGO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AdaptiveScaffold(
        repository: bookingRepository,
        pdfService: pdfService,
        printService: printService,
        shareService: shareService,
      ),
    );
  }
}
