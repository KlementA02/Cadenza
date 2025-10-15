import 'package:flutter/material.dart';

class FloatingActionButtonTheme {
  FloatingActionButtonTheme._();

  static FloatingActionButtonThemeData get theme {
    return const FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      extendedPadding: EdgeInsets.all(8.0),
      extendedIconLabelSpacing: 8.0,
      iconSize: 24.0,
      elevation: 6.0,
    );
  }

  static FloatingActionButtonThemeData get lightTheme {
    return const FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      extendedPadding: EdgeInsets.all(8.0),
      extendedIconLabelSpacing: 8.0,
      iconSize: 24.0,
      elevation: 6.0,
    );
  }

  static FloatingActionButtonThemeData get darkTheme {
    return const FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      extendedPadding: EdgeInsets.all(8.0),
      extendedIconLabelSpacing: 8.0,
      iconSize: 24.0,
      elevation: 6.0,
    );
  }
}
