import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/constants/app_colors.dart';
import 'package:travelgo/shared/widgets/custom_button.dart';

void main() {
  testWidgets('CustomButton renders text and triggers callback', (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Search Flights',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Search Flights'), findsOneWidget);
    await tester.tap(find.byType(CustomButton));
    await tester.pump();

    expect(pressed, isTrue);
  });
}
