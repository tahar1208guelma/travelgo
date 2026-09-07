import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/features/flights/data/airports_data.dart';
import 'package:travelgo/features/flights/presentation/widgets/airport_search_modal.dart';

void main() {
  group('AirportSearchModal & AirportsData Tests', () {
    test('AirportsData matches queries accurately', () {
      const alg = AirportInfo(
        code: 'ALG',
        city: 'Algiers',
        name: 'Houari Boumediene Airport',
        country: 'Algeria',
        region: 'MENA',
      );

      expect(alg.matches('alg'), isTrue);
      expect(alg.matches('Algiers'), isTrue);
      expect(alg.matches('Boumediene'), isTrue);
      expect(alg.matches('Algeria'), isTrue);
      expect(alg.matches('Paris'), isFalse);
    });

    testWidgets('AirportSearchModal filters list in real-time on typing', (tester) async {
      AirportInfo? selectedAirport;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AirportSearchModal(
              title: 'Select Destination',
              onSelected: (airport) {
                selectedAirport = airport;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find Search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Type "IST" into search bar
      await tester.enterText(searchField, 'IST');
      await tester.pumpAndSettle();

      expect(find.text('Istanbul'), findsWidgets);
      expect(find.text('Algiers'), findsNothing);

      // Tap on Istanbul
      await tester.tap(find.text('Istanbul').first);
      await tester.pumpAndSettle();

      expect(selectedAirport, isNotNull);
      expect(selectedAirport!.code, equals('IST'));
    });
  });
}
