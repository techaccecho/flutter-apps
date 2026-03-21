import 'package:flutter/material.dart';

class AppColors {
  // Base
  static const background = Color(0xfff5f5f5);
  static const surface = Colors.white;

  // Primary (classic blue blog vibe)
  static const primary = Color(0xff3366cc);
  static const primaryDark = Color(0xff254a99);

  // Text
  static const textPrimary = Color(0xff000000);
  static const textSecondary = Color(0xff555555);
  static const textMuted = Color(0xff888888);

  // Borders / dividers
  static const border = Color(0xffdddddd);

  // States
  static const link = Color(0xff0000ee); // classic web blue
  static const visitedLink = Color(0xff551a8b);

  // ARG / glitch accents (use sparingly)
  static const danger = Color(0xffcc0000);
  static const highlight = Color(0xfffff2a8);
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}
