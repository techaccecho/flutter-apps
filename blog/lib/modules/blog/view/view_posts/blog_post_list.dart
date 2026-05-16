import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/model/post.dart';
import 'package:blog/modules/blog/view/view_posts/blog_create_new_button.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostList extends StatelessWidget {

  final Post post;
  final int postsAmount;

  const PostList({super.key, required this.post, required this.postsAmount});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
      // Create new post button
      BlogCreateNewButton(),
      // Latest posts
      Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        alignment: Alignment.centerLeft,
        child: Text(
          Strings.blogPostLatest,
          style: AppTextStyles.h2,
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: postsAmount,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: BlogPostCard(
                post: post,
                onTap: () {
                  context.read<BlogBloc>().add(
                    OpenBlogPostEvent(blogId: index.toString()),
                  );
                },
              ),
            );
          },
        ),
      )
    ]);
  }
}