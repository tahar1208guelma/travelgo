import 'package:flutter/material.dart';

enum DeviceScreenType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveBreakpoints {
  static const double mobileMax = 599.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;
  static const double maxContentWidth = 1200.0;

  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return DeviceScreenType.mobile;
    } else if (width < 1024) {
      return DeviceScreenType.tablet;
    } else {
      return DeviceScreenType.desktop;
    }
  }

  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1024;
  static bool isTabletOrDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 600;
}

extension ResponsiveContextExtension on BuildContext {
  bool get isMobile => ResponsiveBreakpoints.isMobile(this);
  bool get isTablet => ResponsiveBreakpoints.isTablet(this);
  bool get isDesktop => ResponsiveBreakpoints.isDesktop(this);
  bool get isTabletOrDesktop => ResponsiveBreakpoints.isTabletOrDesktop(this);
  DeviceScreenType get screenType => ResponsiveBreakpoints.getDeviceType(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}
