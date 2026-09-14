import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/utils/responsive.dart';

void main() {
  group('Responsive Utility Tests', () {
    testWidgets('Detects Mobile breakpoint accurately (< 768px)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isMobile(context), isTrue);
              expect(Responsive.isTablet(context), isFalse);
              expect(Responsive.isDesktop(context), isFalse);
              expect(Responsive.isTabletOrDesktop(context), isFalse);
              expect(
                Responsive.value(context, mobile: 'Mobile', tablet: 'Tablet', desktop: 'Desktop'),
                'Mobile',
              );
              expect(Responsive.gridColumns(context, mobile: 1, tablet: 2, desktop: 4), 1);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Detects Tablet breakpoint accurately (768px - 1023px)', (tester) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isMobile(context), isFalse);
              expect(Responsive.isTablet(context), isTrue);
              expect(Responsive.isDesktop(context), isFalse);
              expect(Responsive.isTabletOrDesktop(context), isTrue);
              expect(
                Responsive.value(context, mobile: 'Mobile', tablet: 'Tablet', desktop: 'Desktop'),
                'Tablet',
              );
              expect(Responsive.gridColumns(context, mobile: 1, tablet: 2, desktop: 4), 2);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Detects Desktop breakpoint accurately (>= 1024px)', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isMobile(context), isFalse);
              expect(Responsive.isTablet(context), isFalse);
              expect(Responsive.isDesktop(context), isTrue);
              expect(Responsive.isTabletOrDesktop(context), isTrue);
              expect(
                Responsive.value(context, mobile: 'Mobile', tablet: 'Tablet', desktop: 'Desktop'),
                'Desktop',
              );
              expect(Responsive.gridColumns(context, mobile: 1, tablet: 2, desktop: 4), 4);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
