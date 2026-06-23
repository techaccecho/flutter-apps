import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_post_repository.dart';
import 'package:blog/shared/providers/blog_api_provider.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_list.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_view.dart';
import 'package:blog/modules/blog/view/create_post/blog_post_create.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/shared/util/app_config.dart';
import 'package:dio/dio.dart';
import 'package:blog/shared/services/authentication_service.dart';
import 'package:blog/shared/providers/auth_api_provider.dart';
import 'package:blog/shared/repositories/auth_repository.dart';
import 'package:blog/shared/interceptors/auth_interceptor.dart';

class PostLanding extends StatelessWidget {
  const PostLanding({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.blogApiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final authApiProvider = AuthApiProvider(dio);
    final authRepository = AuthRepository(apiProvider: authApiProvider);
    final authenticationService = AuthenticationService(
      authRepository: authRepository,
    );

    dio.interceptors.addAll([AuthInterceptor(authService: authenticationService), LogInterceptor(requestBody: true, responseBody: true)]);

    return BlocProvider(
      create: (_) => BlogBloc(repository: BlogPostRepository(apiProvider: BlogApiProvider(dio)))..add(LoadBlogPostsEvent()),
      child:  BlocBuilder<BlogBloc, BlogState>(
        builder: (context, state) {
          if (state is BlogLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BlogLoadedState) {
            return PostList(posts: state.posts, postsAmount: state.posts.length);
          }

          if (state is BlogPostLoadedState) {
            return BlogPostView(post: state.blogPost);
          }

          if (state is BlogPostCreateState) {
            return BlogPostCreateView(post: null, author: state.author, isEditing: false);
          }

          if (state is BlogPostEditState) {
            return BlogPostCreateView(post: state.blogPost, author: state.blogPost?.author ?? null, isEditing: true);
          }

          return const Center(child: Text(Strings.blogPostNone));
        },
      )
    );
  }
}