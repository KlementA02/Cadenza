import 'package:cadenza/Theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final _themeMode = ThemeMode.system.obs;
  final _accent = AccentColor.indigo.obs;

  ThemeMode get themeMode => _themeMode.value;
  AccentColor get accent => _accent.value;

  void toggleTheme() {
    if (_themeMode.value == ThemeMode.light) {
      _themeMode.value = ThemeMode.dark;
    } else if (_themeMode.value == ThemeMode.dark) {
      _themeMode.value = ThemeMode.light;
    } else {
      final brightness = Get.mediaQuery.platformBrightness;
      _themeMode.value =
          brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    }
    Get.changeThemeMode(_themeMode.value);
  }

  void setAccent(AccentColor accentColor) {
    _accent.value = accentColor;
    Get.changeTheme(Get.theme);
  }
}
