import 'package:flutter/material.dart';

class ListtileTheme {
  ListtileTheme._();

  static ListTileThemeData get theme {
    return const ListTileThemeData(
      iconColor: Colors.white,
      textColor: Colors.white,
      tileColor: Colors.black,
      selectedColor: Colors.white,
      selectedTileColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }

  static ListTileThemeData get lightTheme {
    return const ListTileThemeData(
      iconColor: Colors.black,
      textColor: Colors.black,
      tileColor: Colors.white,
      selectedColor: Colors.black,
      selectedTileColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }

  static ListTileThemeData get darkTheme {
    return const ListTileThemeData(
      iconColor: Colors.white,
      textColor: Colors.white,
      tileColor: Colors.black,
      selectedColor: Colors.white,
      selectedTileColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }
}
