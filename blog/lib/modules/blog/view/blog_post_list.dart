import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_repository.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/modules/blog/view/blog_post_view.dart';
import 'package:blog/modules/blog/view/create_post/blog_post_create.dart';
import 'package:blog/modules/core/application_bloc.dart';
import 'package:blog/modules/core/application_state.dart';
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
              BlocBuilder<ApplicationBloc, ApplicationState>(
                builder: (context, state) {
                  
                  if (state is ApplicationContentLoadedState && state.isLoggedIn) {
                    return InkWell(
                      onTap: () => {
                        context.read<BlogBloc>().add(CreateNewBlogPostEvent()),
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(children: [
                          Icon(Icons.add),
                          SizedBox(width: AppSpacing.sm),
                          Text(Strings.blogPostNew, style: AppTextStyles.h2),
                        ]),
                      ),
                    );
                  } else {
                    return SizedBox(height: AppSpacing.md,);
                  }
              }),

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
            return BlogPostCreateView(post: null, author: state.author);
          }

          return const Center(child: Text(Strings.blogPostNone));
        },
      )
    );
  }
}