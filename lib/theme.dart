import 'package:flutter/material.dart';

class BoilerVibeTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.black,
      hintColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: Colors.black,
          fontFamily: 'Montserrat',
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          color: Colors.black,
          fontFamily: 'Montserrat',
          fontSize: 16,
        ),
        bodySmall: TextStyle(
          color: Colors.black,
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.black,
        textTheme: ButtonTextTheme.primary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.black,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.white,
      hintColor: Colors.black,
      scaffoldBackgroundColor: Color(0xFF0D1114), // Use HEX color 0D1114
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF0D1114),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontSize: 16,
        ),
        bodySmall: TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.white,
        textTheme: ButtonTextTheme.primary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.black,
      ),
    );
  }
}

//hello