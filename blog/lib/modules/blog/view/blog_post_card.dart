import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';

class BlogPostCard extends StatelessWidget {
  final BlogPost post;
  final VoidCallback onTap;

  const BlogPostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWeird = post.title.contains("Strange");

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isWeird ? AppColors.highlight : AppColors.surface,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text(
              "by ${post.author} · ${post.date}",
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(post.excerpt, style: AppTextStyles.body),
            const SizedBox(height: 12),
            Text(
              "${post.comments} comments",
              style: AppTextStyles.link,
            ),
          ],
        ),
      ),
    );
  }
}