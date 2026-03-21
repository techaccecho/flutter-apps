import 'package:flutter/material.dart';
import 'package:blog/resources/app_text_styles.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 24, 113, 197)),
      fontFamily: AppTextStyles.fontFamily,
      textTheme: const TextTheme(
        titleLarge: AppTextStyles.title,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.bodySmall,
      ),
    );
  }
}