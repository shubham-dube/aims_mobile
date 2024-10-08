import 'package:flutter/material.dart';

class FIconTheme {
  FIconTheme._();

  static final lightIconTheme = const IconThemeData(
    color: Colors.black, // Color of the icon
    size: 24.0,         // Size of the icon
    opacity: 1.0,       // Opacity of the icon (1.0 = fully opaque)
  );

  static final darkIconTheme = const IconThemeData(
    color: Colors.white, // Color of the icon for dark theme
    size: 24.0,          // Size of the icon
    opacity: 1.0,        // Opacity of the icon
  );
}
