import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';

class BlogPostMenuButton extends StatelessWidget {
  final String buttonText;

  const BlogPostMenuButton({super.key, required this.buttonText});

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
        // Handle tap event
      },
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Icon(Icons.link, size: 16, color: AppColors.primary),
        SizedBox(width: AppSpacing.xs),
        Text(
          buttonText,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
        ),
      ])
    ));
  }
}