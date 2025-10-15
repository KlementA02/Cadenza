import 'package:flutter/material.dart';

class Texttheme {
  Texttheme._();

  static TextTheme get lightTextTheme {
    return const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 16.0),
      bodyMedium: TextStyle(color: Colors.black54, fontSize: 14.0),
      headlineLarge: TextStyle(
          color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(
          color: Colors.black87, fontSize: 20.0, fontWeight: FontWeight.w600),
    );
  }

  static TextTheme get darkTextTheme {
    return const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16.0),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14.0),
      headlineLarge: TextStyle(
          color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(
          color: Colors.white70, fontSize: 20.0, fontWeight: FontWeight.w600),
    );
  }
}
