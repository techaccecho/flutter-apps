import 'package:flutter/material.dart';

class AppColors {
  // Base (dark, matches the in-game night sky / hearth glow)
  static const background = Color(0xff0d0b12);
  static const surface = Color(0xff1a1522);

  // Primary (Hearth Hollow golden-hour amber)
  static const primary = Color(0xffe8a33d);
  static const primaryDark = Color(0xffa8701f);

  // Text
  static const textPrimary = Color(0xfff5efe6);
  static const textSecondary = Color(0xffb8ada0);
  static const textMuted = Color(0xff7a7068);

  // Borders / dividers
  static const border = Color(0xff332c22);

  // States
  static const link = Color(0xffe8a33d);
  static const visitedLink = Color(0xff8f8478);

  // Corrupted Grove / glitch accents (use sparingly)
  static const danger = Color(0xffcc3333);
  static const highlight = Color(0xff5ad1c8);

  // Per-level accent colors (World section plates)
  static const hearthHollow = Color(0xffe8a33d);
  static const cliffsidePath = Color(0xff6f92a8);
  static const corruptedGrove = Color(0xff5ad1c8);
  static const haven = Color(0xff7a5ad1);
}
