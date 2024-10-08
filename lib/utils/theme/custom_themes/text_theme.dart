import 'package:flutter/material.dart';

class FTextTheme {
  FTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 0, color: Colors.black),
    headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 0, color: Colors.black),
    headlineSmall: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0, color: Colors.black),

    titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0, color: Colors.black),
    titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0, color: Colors.black),
    titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.black),

    bodyLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0, color: Colors.black),
    bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0, color: Colors.black),
    bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0, color: Colors.black),

    labelLarge: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0, color: Colors.black),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0, color: Colors.black.withOpacity(0.5)),
    labelSmall: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, letterSpacing: 0, color: Colors.black),
  );

  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 0, color: Colors.white),
    headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 0, color: Colors.white),
    headlineSmall: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0, color: Colors.white),

    titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0, color: Colors.white),
    titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0, color: Colors.white),
    titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.white),

    bodyLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0, color: Colors.white),
    bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0, color: Colors.white),
    bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0, color: Colors.white),

    labelLarge: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0, color: Colors.white),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0, color: Colors.white.withOpacity(0.5)),
    labelSmall: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, letterSpacing: 0, color: Colors.white),
  );
}