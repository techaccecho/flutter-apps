import 'package:blog/modules/core/application.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("BlogNet", style: AppTextStyles.h1),

          const SizedBox(height: 16),

          Text("Navigation", style: AppTextStyles.h2),
          const SizedBox(height: 8),

          GestureDetector(
            onTap: () => context.read<ApplicationBloc>().add(ApplicationNavigateEvent(route: HomeViewState.blog)), 
            child: Text("• Home", style: AppTextStyles.link)),
          GestureDetector(
            onTap: () => context.read<ApplicationBloc>().add(ApplicationNavigateEvent(route: HomeViewState.chatForum)), 
            child: Text("• Forums", style: AppTextStyles.link)),
          GestureDetector(
            onTap: () => context.read<ApplicationBloc>().add(ApplicationNavigateEvent(route: HomeViewState.profile)), 
            child: Text("• Profile", style: AppTextStyles.link)),

          const SizedBox(height: 24),

          Text("About", style: AppTextStyles.h2),
          const SizedBox(height: 8),

          Text(
            "A community of developers sharing ideas, code, and discoveries.",
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}