import 'package:flutter/material.dart';

class ResponsiveConfig {
  static double getScreenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double getScreenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  
  // Responsive padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    double width = getScreenWidth(context);
    if (width < mobileBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
    } else if (width < tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);
    }
    return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);
  }
  
  // Responsive font sizes
  static double getTitleFontSize(BuildContext context) {
    double width = getScreenWidth(context);
    if (width < mobileBreakpoint) return 24.0;
    if (width < tabletBreakpoint) return 28.0;
    return 32.0;
  }
  
  static double getBodyFontSize(BuildContext context) {
    double width = getScreenWidth(context);
    if (width < mobileBreakpoint) return 14.0;
    if (width < tabletBreakpoint) return 16.0;
    return 18.0;
  }
  
  // Responsive spacing
  static double getSpacing(BuildContext context) {
    double width = getScreenWidth(context);
    if (width < mobileBreakpoint) return 8.0;
    if (width < tabletBreakpoint) return 12.0;
    return 16.0;
  }
  
  // Check if device is mobile
  static bool isMobile(BuildContext context) => getScreenWidth(context) < mobileBreakpoint;
  
  // Check if device is tablet
  static bool isTablet(BuildContext context) => 
      getScreenWidth(context) >= mobileBreakpoint && getScreenWidth(context) < tabletBreakpoint;
  
  // Check if device is desktop
  static bool isDesktop(BuildContext context) => getScreenWidth(context) >= tabletBreakpoint;
} 