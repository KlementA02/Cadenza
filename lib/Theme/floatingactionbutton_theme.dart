import 'package:cadenza/Theme/app_palette.dart';
import 'package:flutter/material.dart';

class FloatingActionButtonTheme {
  FloatingActionButtonTheme._();

  static FloatingActionButtonThemeData build(AppPalette palette) {
    return FloatingActionButtonThemeData(
      backgroundColor: palette.accentColor,
      foregroundColor: palette.background,
      extendedPadding: const EdgeInsets.all(8.0),
      extendedIconLabelSpacing: 8.0,
      iconSize: 24.0,
      elevation: 6.0,
    );
  }
}
