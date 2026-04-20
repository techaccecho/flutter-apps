import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const fontFamily = 'DataType';

  static const title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: AppColors.link,
    decoration: TextDecoration.underline,
  );

  static const button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: AppColors.link,
  );

  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: AppColors.link,
    decoration: TextDecoration.underline,
  );

}