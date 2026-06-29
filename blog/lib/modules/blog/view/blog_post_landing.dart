import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_list.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_view.dart';
import 'package:blog/modules/blog/view/create_post/blog_post_create.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostLanding extends StatelessWidget {
  const PostLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlogBloc, BlogState>(
      builder: (context, state) {
        if (state is BlogLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BlogLoadedState) {
          return PostList(
            posts: state.posts,
            hasMore: state.hasMore,
            isLoadingMore: state.isLoadingMore,
            hasLoadMoreError: state.hasLoadMoreError,
          );
        }

        if (state is BlogPostLoadedState) {
          return BlogPostView(post: state.blogPost);
        }

        if (state is BlogPostCreateState) {
          return BlogPostCreateView(
            post: null,
            author: state.author,
            isEditing: false,
          );
        }

        if (state is BlogPostEditState) {
          return BlogPostCreateView(
            post: state.blogPost,
            author: state.blogPost?.author,
            isEditing: true,
          );
        }

        return const Center(child: Text(Strings.blogPostNone));
      },
    );
  }
}
