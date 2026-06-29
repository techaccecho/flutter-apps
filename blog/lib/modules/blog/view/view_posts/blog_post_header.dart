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

  const BlogPostHeader({super.key, required this.title, required this.author, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        IconButton(onPressed: () => {
          context.read<BlogBloc>().add(LoadBlogPostsEvent(fromCache: true))
        }, icon: const Icon(Icons.arrow_back)),
        const SizedBox(width: AppSpacing.md,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h1),
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
      ),])
    );
  }
}