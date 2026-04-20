import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogPostHeader extends StatelessWidget {
  final String title;
  final String author;
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
        }, icon: Icon(Icons.arrow_back)),
        SizedBox(width: AppSpacing.md,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text(
                "by $author · $date",
                style: AppTextStyles.bodySmall,
              ),
          ],
      ),])
    );
  }
}