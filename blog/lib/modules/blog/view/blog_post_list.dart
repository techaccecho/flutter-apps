import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_repository.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/modules/blog/view/blog_create_new_button.dart';
import 'package:blog/modules/blog/view/blog_post_view.dart';
import 'package:blog/modules/blog/view/create_post/blog_post_create.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/modules/blog/view/blog_post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostList extends StatelessWidget {
  const PostList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BlogBloc(repository: BlogRepository())..add(LoadBlogPostsEvent()),
      child:  BlocBuilder<BlogBloc, BlogState>(
        builder: (context, state) {
          if (state is BlogLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BlogLoadedState) {
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
                  itemCount: state.posts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: BlogPostCard(
                        post: state.posts[index],
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

          if (state is BlogPostLoadedState) {
            return Expanded(
              child: BlogPostView(post: state.blogPost),
            );
          }

          if (state is BlogPostCreateState) {
            return BlogPostCreateView(post: null, author: state.author, isEditing: false);
          }

          if (state is BlogPostEditState) {
            return BlogPostCreateView(post: state.blogPost, author: state.blogPost?.author.alias?? "", isEditing: true);
          }

          return const Center(child: Text(Strings.blogPostNone));
        },
      )
    );
  }
}