import 'package:flutter/material.dart';

enum AccentColor {
  indigo,
  red,
  blue,
  green,
  yellow,
}

class AppPalette {
  final bool isDark;
  final AccentColor accent;

  AppPalette({
    required this.isDark,
    required this.accent,
  });

  Color get background =>
      isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);

  Color get surface => isDark ? const Color(0xFF1E1E1E) : Colors.white;

  Color get foreground => isDark ? Colors.white : Colors.black;

  Color get accentColor {
    switch (accent) {
      case AccentColor.indigo:
        return Colors.indigo;
      case AccentColor.red:
        return Colors.red;
      case AccentColor.blue:
        return Colors.blue;
      case AccentColor.green:
        return Colors.green;
      case AccentColor.yellow:
        return Colors.yellow;
    }
  }
}
