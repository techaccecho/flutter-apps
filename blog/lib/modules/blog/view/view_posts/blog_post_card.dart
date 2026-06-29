import 'package:blog/resources/resources.dart';
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/core/application.dart';
import 'package:blog/modules/home/model/home_view_state.dart';

class BlogPostCard extends StatelessWidget {
  final BlogPost post;
  final VoidCallback onTap;

  const BlogPostCard({super.key, required this.post, required this.onTap});

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
            RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall,
                children: [
                  const TextSpan(text: "by "),
                  TextSpan(
                    text: post.author.displayName,
                    style: AppTextStyles.link.copyWith(fontSize: 12),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        context.read<ApplicationBloc>().add(
                          ApplicationNavigateEvent(
                            route: HomeViewState.profile,
                            userId: post.author.id,
                          ),
                        );
                      },
                  ),
                  TextSpan(text: " · ${post.displayCreatedAt}"),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(post.content.length > 50 ? post.content.substring(0, 50) : post.content, style: AppTextStyles.body),
            const SizedBox(height: 12),
            Text("${post.engagement.comments} comments", style: AppTextStyles.link),
          ],
        ),
      ),
    );
  }
}
