import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/modules/core/application.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/shared/view/nav_item.dart';
import 'package:blog/shared/view/raised_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  Future<void> _login() async {
    context.read<ApplicationBloc>().add(ApplicationLoginEvent());
  }

  Future<void> _logout() async {
    context.read<ApplicationBloc>().add(ApplicationLogoutEvent());
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  void _onNavigate(BuildContext context, HomeViewState route) {
    if (route == HomeViewState.blog) {
      context.read<BlogBloc>().add(LoadBlogPostsEvent());
    } else if (route == HomeViewState.chatForum) {
      context.read<ChatForumBloc>().add(ChatForumLoadEvent());
    }
    context.read<ApplicationBloc>().add(ApplicationNavigateEvent(route: route));
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: BlocBuilder<ApplicationBloc, ApplicationState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Strings.appName,
                style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              // Account Section
              if (state is ApplicationContentLoadedState) ...[
                Text(Strings.titleAccount, style: AppTextStyles.h2),
                if (state.isLoggedIn)
                  Row(
                    children: [
                      Text(Strings.welcome, style: AppTextStyles.body),
                      const SizedBox(width: 12), // Native built-in spacing
                      Text(
                        state.currentUser?.displayName ?? '',
                        style: AppTextStyles.link,
                      ),
                    ],
                  ),
                if (!state.isLoggedIn)
                  RaisedButton(action: _login, title: Strings.linkSignIn),
                const SizedBox(height: 16),
              ],

              // Navigation Section
              Text(Strings.titleNavigation, style: AppTextStyles.h2),
              const SizedBox(height: 8),
              NavItem(
                title: Strings.linkHome,
                isSelected:
                    state is ApplicationContentLoadedState &&
                    state.route == HomeViewState.blog,
                onTap: () => _onNavigate(context, HomeViewState.blog),
              ),
              const SizedBox(height: 4),
              NavItem(
                title: Strings.linkForums,
                isSelected:
                    state is ApplicationContentLoadedState &&
                    state.route == HomeViewState.chatForum,
                onTap: () => _onNavigate(context, HomeViewState.chatForum),
              ),
              const SizedBox(height: 4),
              if (state is ApplicationContentLoadedState &&
                  state.isLoggedIn &&
                  state.currentUser?.role == Strings.roleAdmin) ...[
                NavItem(
                  title: Strings.linkArchived,
                  isSelected: state.route == HomeViewState.archived,
                  onTap: () => _onNavigate(context, HomeViewState.archived),
                ),
                const SizedBox(height: 4),
              ],

              if (state is ApplicationContentLoadedState &&
                  state.isLoggedIn) ...[
                NavItem(
                  title: Strings.linkProfile,
                  isSelected: state.route == HomeViewState.profile &&
                      state.viewUserId == state.currentUser?.id,
                  onTap: () => _onNavigate(context, HomeViewState.profile),
                ),
                const SizedBox(height: 4),
              ],

              const SizedBox(height: 24),

              // About Section
              Text(Strings.titleAbout, style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(Strings.captionAbout, style: AppTextStyles.body),
              const SizedBox(height: 8),
              NavItem(
                title: Strings.linkRulesOfEngagementFaq,
                isSelected:
                    state is ApplicationContentLoadedState &&
                    state.route == HomeViewState.faq,
                onTap: () => _onNavigate(context, HomeViewState.faq),
              ),

              Spacer(),
              if (state is ApplicationContentLoadedState && state.isLoggedIn)
                RaisedButton(action: _logout, title: Strings.btnSigOut),
            ],
          );
        },
      ),
    );
  }
}
