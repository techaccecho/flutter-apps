import 'package:blog/modules/core/application.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/resources/resources.dart';
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
              Text(Strings.appName, style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w700),),
              const SizedBox(height: 16),

              // Account Section
              if (state is ApplicationContentLoadedState) ...[
                Text(Strings.titleAccount, style: AppTextStyles.h2),
                if (state.isLoggedIn)
                  Text(Strings.captionYouAreSignedIn, style: AppTextStyles.link),
                if (!state.isLoggedIn)
                  RaisedButton(action: _login, title: Strings.linkSignIn),
                const SizedBox(height: 16),
              ],
                
              // Navigation Section
              Text(Strings.titleNavigation, style: AppTextStyles.h2),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => context.read<ApplicationBloc>().add(ApplicationNavigateEvent(route: HomeViewState.blog)), 
                child: Text(Strings.linkHome, style: AppTextStyles.link)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => context.read<ApplicationBloc>().add(ApplicationNavigateEvent(route: HomeViewState.chatForum)), 
                child: Text(Strings.linkForums, style: AppTextStyles.link)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => context.read<ApplicationBloc>().add(ApplicationNavigateEvent(route: HomeViewState.profile)), 
                child: Text(Strings.linkProfile, style: AppTextStyles.link)),
              const SizedBox(height: 24),

              // About Section
              Text(Strings.titleAbout, style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                Strings.captionAbout,
                style: AppTextStyles.body,
              ),

              Spacer(),
              if (state is ApplicationContentLoadedState && state.isLoggedIn)
                RaisedButton(action: _logout, title: Strings.btnSigOut),
            ],
          );
      }),
    );
  }
}