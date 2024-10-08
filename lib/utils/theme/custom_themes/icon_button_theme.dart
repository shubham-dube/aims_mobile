import 'package:flutter/material.dart';

class FIconButtonTheme {
  FIconButtonTheme._();

  static final lightIconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      iconSize: 18,
      backgroundColor: Colors.transparent,
      disabledForegroundColor: Colors.white,
      disabledBackgroundColor: Colors.lightBlueAccent.shade200,
      side: const BorderSide(color: Colors.transparent),
      padding: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static final darkIconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      iconSize: 18,
      backgroundColor: Colors.transparent,
      disabledForegroundColor: Colors.white,
      disabledBackgroundColor: Colors.lightBlueAccent.shade200,
      side: const BorderSide(color: Colors.transparent),
      padding: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

}