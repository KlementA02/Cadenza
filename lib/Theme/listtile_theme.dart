import 'package:cadenza/Theme/app_palette.dart';
import 'package:flutter/material.dart';

class ListtileTheme {
  ListtileTheme._();

  static ListTileThemeData build(AppPalette palette) {
    return ListTileThemeData(
      iconColor: palette.accentColor,
      textColor: palette.foreground,
      tileColor: palette.surface,
      selectedColor: palette.accentColor,
      selectedTileColor:
          palette.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }
}
