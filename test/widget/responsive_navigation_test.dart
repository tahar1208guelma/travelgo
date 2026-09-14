import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/localization/app_localizations.dart';
import 'package:travelgo/features/home/presentation/screens/main_navigation_screen.dart';

Widget createTestableNavApp() {
  return const ProviderScope(
    child: MaterialApp(
      locale: Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MainNavigationScreen(),
    ),
  );
}

void main() {
  testWidgets('Renders Mobile Bottom NavigationBar on phone screens (< 768px)', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestableNavApp());
    await tester.pumpAndSettle();

    // Verify bottom NavigationBar exists on mobile
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('Home')), findsOneWidget);
    expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('Flights')), findsOneWidget);
    expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('Hotels')), findsOneWidget);
    expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('My Trips')), findsOneWidget);
    expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('Profile')), findsOneWidget);
  });

  testWidgets('Renders Desktop Sidebar on wide screens (>= 1024px)', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestableNavApp());
    await tester.pumpAndSettle();

    // On desktop, bottom NavigationBar should NOT be rendered
    expect(find.byType(NavigationBar), findsNothing);

    // Desktop sidebar brand header and navigation items should be visible
    expect(find.text('TRAVELGO'), findsWidgets);
    expect(find.text('Cross-Platform App'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Flights'), findsWidgets);
    expect(find.text('Hotels'), findsWidgets);
    expect(find.text('My Trips'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });
}
