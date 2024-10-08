import 'package:flutter/material.dart';

class FTextButtonTheme {
  FTextButtonTheme._();

  static final lightTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.pinkAccent.shade400,
      backgroundColor: Colors.transparent,
      disabledForegroundColor: Colors.grey,
      padding: const EdgeInsets.all(8),
      textStyle: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w400),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static final darkTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.pinkAccent.shade100,
      backgroundColor: Colors.transparent,
      disabledForegroundColor: Colors.grey,
      padding: const EdgeInsets.all(8),
      textStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w400),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

}