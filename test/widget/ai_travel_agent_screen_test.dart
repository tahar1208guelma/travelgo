import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/localization/app_localizations.dart';
import 'package:travelgo/features/ai_agent/presentation/screens/ai_travel_agent_screen.dart';

void main() {
  testWidgets('AITravelAgentScreen renders app bar and welcome message', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en', 'US'),
            Locale('ar', 'DZ'),
          ],
          locale: Locale('en', 'US'),
          home: AITravelAgentScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check App Bar and elements
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
  });
}
