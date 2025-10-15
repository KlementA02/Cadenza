import 'package:flutter/material.dart';

class ScaffoldTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        primary: Colors.black,
        secondary: Colors.white,
        surface: Colors.black,
        onSurface: Colors.white,
        brightness: Brightness.dark,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        primary: Colors.white,
        secondary: Colors.black,
        surface: Colors.white,
        onSurface: Colors.black,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        primary: Colors.black,
        secondary: Colors.white,
        surface: Colors.black,
        onSurface: Colors.white,
        brightness: Brightness.dark,
      ),
    );
  }
}
