import 'package:flutter/material.dart';
import 'package:blog/resources/resources.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final String excerpt;

  const PostCard({
    super.key,
    required this.title,
    required this.author,
    required this.date,
    required this.excerpt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'by $author · $date',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(excerpt, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          Text('Read more...', style: AppTextStyles.link),
        ],
      ),
    );
  }
}