import 'package:blog/modules/core/application.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/resources/resources.dart';
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
        if (state is ApplicationContentLoadedState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Strings.appName, style: AppTextStyles.h1),
              const SizedBox(height: 16),

              Text(Strings.titleAuthentication, style: AppTextStyles.h2),
              if (state.isLoggedIn)
                Text(Strings.captionYouAreSignedIn, style: AppTextStyles.link),
              if (!state.isLoggedIn)
                  GestureDetector(
                  onTap: () => _login(), 
                  child: Text(Strings.linkSignIn, style: AppTextStyles.link)),
              const SizedBox(height: 16),

              Text(Strings.titleNavigation, style: AppTextStyles.h2),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => context.read<ApplicationBloc>().add(ApplicationNavigateEvent(route: HomeViewState.blog)), 
                child: Text(Strings.linkHome, style: AppTextStyles.link)),
              GestureDetector(
                onTap: () => context.read<ApplicationBloc>().add(ApplicationNavigateEvent(route: HomeViewState.chatForum)), 
                child: Text(Strings.linkForums, style: AppTextStyles.link)),
              GestureDetector(
                onTap: () => context.read<ApplicationBloc>().add(ApplicationNavigateEvent(route: HomeViewState.profile)), 
                child: Text(Strings.linkProfile, style: AppTextStyles.link)),
              const SizedBox(height: 24),

              Text(Strings.titleAbout, style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                Strings.captionAbout,
                style: AppTextStyles.body,
              ),

              Spacer(),
              if (state.isLoggedIn)
                ElevatedButton(onPressed: () => _logout(), child: Text(Strings.btnSigOut))
            ],
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }
}