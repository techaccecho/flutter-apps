import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/core/application_bloc.dart';
import 'package:blog/modules/core/application_state.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogCreateNewButton extends StatelessWidget {
  const BlogCreateNewButton({super.key});

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<ApplicationBloc, ApplicationState>(
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
    });
  }
}