import 'package:cadenza/Theme/floatingactionbutton_theme.dart';
import 'package:cadenza/Theme/listtile_theme.dart';
import 'package:flutter/material.dart';

class KAppThemes {
  KAppThemes._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light, // Ensure brightness matches
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light, // Match brightness
    ),
    listTileTheme: ListtileTheme.lightTheme,
    floatingActionButtonTheme: FloatingActionButtonTheme.lightTheme,
    scaffoldBackgroundColor: Colors.white,
  );

  static final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark, // Ensure brightness matches
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark, // Match brightness
      ),
      listTileTheme: ListtileTheme.darkTheme,
      floatingActionButtonTheme: FloatingActionButtonTheme.darkTheme,
      scaffoldBackgroundColor: Colors.black);
}
