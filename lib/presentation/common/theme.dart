import "package:flutter/material.dart";

ThemeData darkTheme = ThemeData(
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 18, color: Colors.white70),
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF10ABD1),
    brightness: Brightness.dark,
  ),
);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
  ),
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10ABD1)),
);
