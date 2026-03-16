import 'package:cadenza/Theme/app_palette.dart';
import 'package:cadenza/Theme/floatingactionbutton_theme.dart';
import 'package:cadenza/Theme/icon_theme.dart' as icon_theme_module;
import 'package:cadenza/Theme/listtile_theme.dart';
import 'package:cadenza/Theme/texttheme.dart';
import 'package:flutter/material.dart' hide FloatingActionButtonTheme;

class KAppThemes {
  KAppThemes._();

  static ThemeData buildLightTheme(AccentColor accent) {
    final palette = AppPalette(isDark: false, accent: accent);

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        brightness: Brightness.light,
        primary: palette.accentColor,
        surface: palette.surface,
      ),
      scaffoldBackgroundColor: palette.background,
      primaryColor: palette.accentColor,
      iconTheme: icon_theme_module.IconTheme.build(palette),
      listTileTheme: ListtileTheme.build(palette),
      floatingActionButtonTheme: FloatingActionButtonTheme.build(palette),
      textTheme: Texttheme.lightTextTheme,
    );
  }

  static ThemeData buildDarkTheme(AccentColor accent) {
    final palette = AppPalette(isDark: true, accent: accent);

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        brightness: Brightness.dark,
        primary: palette.accentColor,
        surface: palette.surface,
      ),
      scaffoldBackgroundColor: palette.background,
      primaryColor: palette.accentColor,
      iconTheme: icon_theme_module.IconTheme.build(palette),
      listTileTheme: ListtileTheme.build(palette),
      floatingActionButtonTheme: FloatingActionButtonTheme.build(palette),
      textTheme: Texttheme.darkTextTheme,
    );
  }
}
