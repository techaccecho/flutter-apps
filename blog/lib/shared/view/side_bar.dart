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
                onTap: () => context.read<ApplicationBloc>().add(
                  ApplicationNavigateEvent(route: HomeViewState.blog),
                ),
              ),
              const SizedBox(height: 4),
              NavItem(
                title: Strings.linkForums,
                isSelected:
                    state is ApplicationContentLoadedState &&
                    state.route == HomeViewState.chatForum,
                onTap: () => context.read<ApplicationBloc>().add(
                  ApplicationNavigateEvent(route: HomeViewState.chatForum),
                ),
              ),
              const SizedBox(height: 4),

              BlocBuilder<ApplicationBloc, ApplicationState>(
                builder: (context, state) {
                  if (state is ApplicationContentLoadedState &&
                      state.isLoggedIn) {
                    return NavItem(
                      title: Strings.linkProfile,
                      isSelected: state.route == HomeViewState.profile,
                      onTap: () => context.read<ApplicationBloc>().add(
                        ApplicationNavigateEvent(route: HomeViewState.profile),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: 24),

              // About Section
              Text(Strings.titleAbout, style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(Strings.captionAbout, style: AppTextStyles.body),

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
