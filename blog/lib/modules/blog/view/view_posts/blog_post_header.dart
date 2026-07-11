import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/shared/models/author.dart';
import 'package:blog/modules/core/application.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogPostHeader extends StatelessWidget {
  final String title;
  final Author author;
  final String date;
  final bool isDraft;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BlogPostHeader({
    super.key,
    required this.title,
    required this.author,
    required this.date,
    this.isDraft = false,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              context.read<BlogBloc>().add(
                const LoadBlogPostsEvent(fromCache: true),
              );
            },
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(title, style: AppTextStyles.h1)),
                    if (isDraft) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Chip(
                        label: const Text('Draft'),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.background,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall,
                    children: [
                      const TextSpan(text: "by "),
                      TextSpan(
                        text: author.displayName,
                        style: AppTextStyles.link.copyWith(fontSize: 12),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.read<ApplicationBloc>().add(
                              ApplicationNavigateEvent(
                                route: HomeViewState.profile,
                                userId: author.id,
                              ),
                            );
                          },
                      ),
                      TextSpan(text: " · $date"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (canManage) ...[
            IconButton(
              tooltip: 'Edit post',
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              tooltip: 'Delete post',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ],
      ),
    );
  }
}
