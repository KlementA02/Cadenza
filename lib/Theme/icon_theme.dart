import 'package:cadenza/Theme/app_palette.dart';
import 'package:flutter/material.dart';

class IconTheme {
  IconTheme._();

  static IconThemeData build(AppPalette palette) {
    return IconThemeData(
      color: palette.accentColor,
      size: 24.0,
    );
  }
}
