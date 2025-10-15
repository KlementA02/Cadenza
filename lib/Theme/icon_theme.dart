import 'package:flutter/material.dart';

class IconTheme {
  IconTheme._();

  static IconThemeData get lightIconTheme {
    return const IconThemeData(
      color: Colors.black,
      size: 24.0,
    );
  }

  static IconThemeData get darkIconTheme {
    return const IconThemeData(
      color: Colors.white,
      size: 24.0,
    );
  }
}
