import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_post_repository.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_repository.dart';
import 'package:blog/modules/blog/view/blog_post_landing.dart';
import 'package:blog/modules/chat_forum/view/chat_forum_view.dart';
import 'package:blog/modules/core/application.dart';
import 'package:blog/modules/faq/view/faq_view.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/modules/profile/view/user_profile_view.dart';
import 'package:blog/modules/profile/view/archived_users_list_view.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/shared/view/side_bar.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final blogPostRepository = context.read<BlogPostRepository>();
    final chatForumRepository = context.read<ChatForumRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<BlogBloc>(
          create: (context) =>
              BlogBloc(repository: blogPostRepository)
                ..add(LoadBlogPostsEvent()),
        ),
        BlocProvider<ChatForumBloc>(
          create: (context) =>
              ChatForumBloc(repository: chatForumRepository)
                ..add(ChatForumLoadEvent()),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            if (width < AppBreakpoints.mobile) {
              return const _MobileLayout();
            } else if (width < AppBreakpoints.tablet) {
              return const _TabletLayout();
            } else {
              return const _DesktopLayout();
            }
          },
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _MobileHeader(),
        Expanded(
          child: BlocBuilder<ApplicationBloc, ApplicationState>(
            builder: (context, state) {
              if (state is ApplicationContentLoadedState) {
                if (state.route == HomeViewState.blog) {
                  return PostLanding();
                } else if (state.route == HomeViewState.chatForum) {
                  return ChatForumView();
                } else if (state.route == HomeViewState.profile) {
                  return UserProfileView(userId: state.viewUserId);
                } else if (state.route == HomeViewState.archived) {
                  return _buildArchivedViewGuard(state);
                } else if (state.route == HomeViewState.faq) {
                  return const FaqView();
                } else {
                  return CircularProgressIndicator();
                }
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ],
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "BlogNet",
            style: AppTextStyles.h2.copyWith(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(width: 200, child: Sidebar()),
              Expanded(
                child: BlocBuilder<ApplicationBloc, ApplicationState>(
                  builder: (context, state) {
                    if (state is ApplicationContentLoadedState) {
                      if (state.route == HomeViewState.blog) {
                        return PostLanding();
                      } else if (state.route == HomeViewState.chatForum) {
                        return ChatForumView();
                      } else if (state.route == HomeViewState.profile) {
                        return UserProfileView(userId: state.viewUserId);
                      } else if (state.route == HomeViewState.archived) {
                        return _buildArchivedViewGuard(state);
                      } else if (state.route == HomeViewState.faq) {
                        return const FaqView();
                      } else {
                        return CircularProgressIndicator();
                      }
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: Sidebar()),
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    Container(
                      color: const Color.fromARGB(255, 214, 214, 214),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                        horizontal: AppSpacing.md,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: const Color.fromARGB(255, 56, 56, 56),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              Strings.notificationContent,
                              style: AppTextStyles.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: BlocBuilder<ApplicationBloc, ApplicationState>(
                        builder: (context, state) {
                          if (state is ApplicationContentLoadedState) {
                            if (state.route == HomeViewState.blog) {
                              return PostLanding();
                            } else if (state.route == HomeViewState.chatForum) {
                              return ChatForumView();
                            } else if (state.route == HomeViewState.profile) {
                              return UserProfileView(userId: state.viewUserId);
                            } else if (state.route == HomeViewState.archived) {
                              return _buildArchivedViewGuard(state);
                            } else if (state.route == HomeViewState.faq) {
                              return const FaqView();
                            } else {
                              return const Text(Strings.appLoading);
                            }
                          }
                          return const Text(Strings.appLoading);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildArchivedViewGuard(ApplicationContentLoadedState state) {
  if (state.isLoggedIn && state.currentUser?.role == Strings.roleAdmin) {
    return const ArchivedUsersListView();
  }
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Text(
        'Access Denied: Only administrators can view the archived user directory.',
        style: AppTextStyles.body,
        textAlign: TextAlign.center,
      ),
    ),
  );
}
