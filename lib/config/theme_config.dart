import 'package:flutter/material.dart';
import 'responsive_config.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'DM_sans',
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        fontFamily: 'DM_sans',
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
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
      bodyLarge: TextStyle(fontFamily: 'DM_sans', color: Colors.black),
      bodyMedium: TextStyle(fontFamily: 'DM_sans', color: Colors.black87),
      bodySmall: TextStyle(fontFamily: 'DM_sans'),
      labelLarge: TextStyle(fontFamily: 'DM_sans'),
      labelMedium: TextStyle(fontFamily: 'DM_sans'),
      labelSmall: TextStyle(fontFamily: 'DM_sans'),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromRGBO(255, 32, 78, 1)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: 'DM_sans',
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0C0C23),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0C0C23),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontFamily: 'DM_sans',
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
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
      bodyLarge: TextStyle(fontFamily: 'DM_sans', color: Colors.white),
      bodyMedium: TextStyle(fontFamily: 'DM_sans', color: Colors.white70),
      bodySmall: TextStyle(fontFamily: 'DM_sans'),
      labelLarge: TextStyle(fontFamily: 'DM_sans'),
      labelMedium: TextStyle(fontFamily: 'DM_sans'),
      labelSmall: TextStyle(fontFamily: 'DM_sans'),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF1A1A2E),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: const Color.fromRGBO(255, 32, 78, 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A1A2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromRGBO(255, 32, 78, 1)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  static TextStyle getResponsiveTextStyle(BuildContext context, {
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: 'DM_sans',
      fontSize: ResponsiveConfig.isMobile(context) ? fontSize * 0.9 : fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
} 