import 'package:blog/modules/chat_forum/bloc/chat_forum_repository.dart';
import 'package:blog/modules/chat_forum/view/chat_comment.dart';
import 'package:blog/modules/chat_forum/view/chat_reply_box.dart';
import 'package:blog/modules/chat_forum/view/chat_thread_header.dart';
import 'package:blog/modules/core/application.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_state.dart';
import 'package:blog/modules/chat_forum/view/forum_item.dart';
import 'package:blog/shared/util/app_config.dart';
import 'package:blog/shared/providers/blog_api_provider.dart';
import 'package:dio/dio.dart';
import 'package:blog/shared/services/authentication_service.dart';
import 'package:blog/shared/providers/auth_api_provider.dart';
import 'package:blog/shared/repositories/auth_repository.dart';
import 'package:blog/shared/interceptors/auth_interceptor.dart';
import 'package:blog/shared/models/author.dart';

class ChatForumView extends StatelessWidget {
  const ChatForumView({super.key});

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
    final userRepository = AuthRepository(apiProvider: authApiProvider);
    final authenticationService = AuthenticationService(
      authRepository: userRepository,
    );

    dio.interceptors.addAll([
      AuthInterceptor(authService: authenticationService),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);

    return BlocProvider(
      create: (context) => ChatForumBloc(
        repository: ChatForumRepository(apiProvider: BlogApiProvider(dio)),
      )..add(ChatForumLoadEvent()),
      child: BlocBuilder<ChatForumBloc, ChatForumState>(
        builder: (context, state) {
          final currentUser = context.read<ApplicationBloc>().currentUser;
          final author = currentUser != null
              ? Author.fromUser(currentUser)
              : null;

          if (state is ChatForumLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatForumContentLoadedState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Create new thread button
                BlocBuilder<ApplicationBloc, ApplicationState>(
                  builder: (context, state) {
                    if (state is ApplicationContentLoadedState &&
                        state.isLoggedIn) {
                      return InkWell(
                        onTap: () => {
                          // context.read<BlogBloc>().add(CreateNewBlogPostEvent()),
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add),
                              SizedBox(width: AppSpacing.sm),
                              Text(Strings.threadNew, style: AppTextStyles.h2),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return SizedBox(height: AppSpacing.md);
                    }
                  },
                ),

                // Latest posts
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(Strings.threadLatest, style: AppTextStyles.h2),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.chat.threads.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.chat.threads[index];
                      return ForumItem(thread: item);
                    },
                  ),
                ),
              ],
            );
          }

          if (state is ChatForumErrorState) {
            return const Center(child: Text(Strings.somethingWentWrong));
          }

          if (state is ChatForumThreadLoadedState) {
            return Column(
              children: [
                ChatThreadHeader(thread: state.thread),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.thread.comments.length,
                    itemBuilder: (context, index) {
                      return ChatComment(comment: state.thread.comments[index]);
                    },
                  ),
                ),
                if (author != null) ...[
                  ChatReplyBox(
                    threadId: state.thread.id,
                    authorId: author.id,
                  ),
                ]
              ],
            );
          }

          return const Center(child: Text(Strings.forumLoading));
        },
      ),
    );
  }
}
