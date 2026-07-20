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
  static const visitedLink = Color.fromARGB(255, 199, 198, 201);

  // ARG / glitch accents (use sparingly)
  static const danger = Color(0xffcc0000);
  static const highlight = Color(0xfffff2a8);
}