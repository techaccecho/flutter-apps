import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/blog/view/blog_post_header.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';

class BlogPostView extends StatelessWidget {
  final BlogPost post;

  const BlogPostView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlogPostHeader(title: post.title),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.title, style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text(
                "by ${post.author} · ${post.date}",
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(
                post.excerpt, // replace with full content later
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ]
    );
  }
}