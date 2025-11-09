import 'package:flutter/material.dart';

/// Responsive helper class for Flutter apps
/// Provides utilities for responsive design across mobile, tablet, and desktop
class ResponsiveHelper {
  // Breakpoint constants
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  // Material Design spacing scale
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  /// Get current screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get current screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < mobileBreakpoint;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= tabletBreakpoint;
  }

  /// Get screen type as enum
  static ScreenType getScreenType(BuildContext context) {
    final width = screenWidth(context);
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  /// Check if device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get responsive value based on screen size
  static T getValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets getPadding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return getValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive horizontal padding
  static EdgeInsets getHorizontalPadding(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final value = getValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return EdgeInsets.symmetric(horizontal: value);
  }

  /// Get responsive vertical padding
  static EdgeInsets getVerticalPadding(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final value = getValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return EdgeInsets.symmetric(vertical: value);
  }

  /// Get responsive font size
  static double getFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return getValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get grid column count based on screen size
  static int getGridColumnCount(
    BuildContext context, {
    required int mobile,
    int? tablet,
    int? desktop,
  }) {
    return getValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get maximum content width for centered content on large screens
  static double getMaxContentWidth(BuildContext context) {
    return getValue(
      context,
      mobile: double.infinity,
      tablet: 900,
      desktop: 1200,
    );
  }

  /// Get responsive spacing
  static double getSpacing(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return getValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive gap (SizedBox)
  static SizedBox getGap(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final spacing = getValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return SizedBox(width: spacing, height: spacing);
  }

  /// Get responsive horizontal gap
  static SizedBox getHorizontalGap(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final spacing = getValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return SizedBox(width: spacing);
  }

  /// Get responsive vertical gap
  static SizedBox getVerticalGap(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final spacing = getValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return SizedBox(height: spacing);
  }

  /// Scale value based on screen width
  static double scaleWidth(BuildContext context, double value) {
    final width = screenWidth(context);
    return (value / 375) * width; // 375 is base mobile width
  }

  /// Scale value based on screen height
  static double scaleHeight(BuildContext context, double value) {
    final height = screenHeight(context);
    return (value / 812) * height; // 812 is base mobile height
  }
}

/// Enum for screen types
enum ScreenType {
  mobile,
  tablet,
  desktop,
}

/// Extension on BuildContext for easier access to responsive helpers
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isPortrait => ResponsiveHelper.isPortrait(this);
  bool get isLandscape => ResponsiveHelper.isLandscape(this);
  ScreenType get screenType => ResponsiveHelper.getScreenType(this);
  double get screenWidth => ResponsiveHelper.screenWidth(this);
  double get screenHeight => ResponsiveHelper.screenHeight(this);
}

/// Responsive widget wrapper that rebuilds when screen size category changes
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveHelper.getScreenType(context);
        return builder(context, screenType);
      },
    );
  }
}

/// Widget for different layouts per screen type
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveHelper.isDesktop(context)) {
          return desktop ?? tablet ?? mobile;
        } else if (ResponsiveHelper.isTablet(context)) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Centered content container with max width constraint
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveHelper.getMaxContentWidth(context),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}