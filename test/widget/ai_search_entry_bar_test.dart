import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/localization/app_localizations.dart';
import 'package:travelgo/features/ai_agent/presentation/widgets/ai_search_entry_bar.dart';

void main() {
  testWidgets('AISearchEntryBar renders input field and send action', (WidgetTester tester) async {
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
          home: Scaffold(
            body: AISearchEntryBar(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });
}
