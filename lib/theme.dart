import 'package:flutter/material.dart';

class BoilerVibeTheme {
  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Color(0xFF111111),  // Dark brown color
        secondary: Color(0xFFFFA726),  // Orange color
      ),
      scaffoldBackgroundColor: Colors.white,  // White background color
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF111111),
        titleTextStyle: TextStyle(
          color: Color(0xFFFFA726),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF111111),
        selectedItemColor: Color(0xFFFFA726),
        unselectedItemColor: Colors.grey,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
