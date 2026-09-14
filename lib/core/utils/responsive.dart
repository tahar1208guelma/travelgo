import 'package:flutter/material.dart';

class Responsive {
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopMaxWidth = 1280.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static bool isTabletOrDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }
    if (isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  static int gridColumns(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 4,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}

/// A container that constrains content width and centers it on large screens
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = Responsive.desktopMaxWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// A builder that renders different widgets depending on the screen size
class AdaptiveLayout extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return (desktop ?? tablet ?? mobile)(context);
    }
    if (Responsive.isTablet(context)) {
      return (tablet ?? mobile)(context);
    }
    return mobile(context);
  }
}
