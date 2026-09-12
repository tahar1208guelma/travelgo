import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.isDesktop
        ? 32.0
        : (context.isTablet ? 24.0 : 16.0);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
          child: child,
        ),
      ),
    );
  }
}
