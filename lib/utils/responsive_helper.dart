// lib/utils/responsive_helper.dart
import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1200;

  // Device type checks
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMaxWidth &&
      MediaQuery.of(context).size.width < tabletMaxWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMaxWidth;

  // Responsive dimensions
  static double getResponsiveFontSize(
      BuildContext context, double baseFontSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseFontSize * 0.9; // Small phones
    if (width >= mobileMaxWidth && width < tabletMaxWidth) {
      return baseFontSize * 1.15; // Tablets
    }
    if (width >= tabletMaxWidth) return baseFontSize * 1.2; // Desktop
    return baseFontSize;
  }

  static double getResponsivePadding(BuildContext context, double basePadding) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return basePadding * 0.8;
    if (width >= mobileMaxWidth) return basePadding * 1.3;
    return basePadding;
  }

  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSize * 0.85;
    if (width >= mobileMaxWidth) return baseSize * 1.2;
    return baseSize;
  }

  // Max width for content on large screens
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1400;
    if (isTablet(context)) return 900;
    return double.infinity;
  }

  // Grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= tabletMaxWidth) return 3; // Desktop
    if (width >= mobileMaxWidth) return 2; // Tablet
    return 1; // Mobile
  }

  // Helper to wrap content with max width for large screens
  static Widget constrainedContent({
    required BuildContext context,
    required Widget child,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: getMaxContentWidth(context),
        ),
        child: child,
      ),
    );
  }
}
