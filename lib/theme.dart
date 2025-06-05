import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'DM_sans',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'DM_sans'),
        displayMedium: TextStyle(fontFamily: 'DM_sans'),
        displaySmall: TextStyle(fontFamily: 'DM_sans'),
        headlineLarge: TextStyle(fontFamily: 'DM_sans'),
        headlineMedium: TextStyle(fontFamily: 'DM_sans'),
        headlineSmall: TextStyle(fontFamily: 'DM_sans'),
        titleLarge: TextStyle(fontFamily: 'DM_sans'),
        titleMedium: TextStyle(fontFamily: 'DM_sans'),
        titleSmall: TextStyle(fontFamily: 'DM_sans'),
        bodyLarge: TextStyle(fontFamily: 'DM_sans'),
        bodyMedium: TextStyle(fontFamily: 'DM_sans'),
        bodySmall: TextStyle(fontFamily: 'DM_sans'),
        labelLarge: TextStyle(fontFamily: 'DM_sans'),
        labelMedium: TextStyle(fontFamily: 'DM_sans'),
        labelSmall: TextStyle(fontFamily: 'DM_sans'),
      ),
    );
  }
} 