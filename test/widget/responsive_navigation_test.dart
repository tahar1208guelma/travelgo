import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelgo/core/localization/app_localizations.dart';
import 'package:travelgo/core/services/storage_service.dart';
import 'package:travelgo/features/home/presentation/screens/main_navigation_screen.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _transparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value(_transparentImage).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

final _transparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

Widget createTestableNavApp(StorageService storage, {int initialTabIndex = 1}) {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MainNavigationScreen(initialTabIndex: initialTabIndex),
    ),
  );
}

void main() {
  late StorageService storage;

  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await StorageService.init();
  });

  testWidgets('Renders Mobile Bottom NavigationBar on phone screens (< 768px)', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestableNavApp(storage));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

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

    await tester.pumpWidget(createTestableNavApp(storage));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

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
