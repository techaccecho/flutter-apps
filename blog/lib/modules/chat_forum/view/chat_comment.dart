import 'package:blog/shared/models/comment.dart';
import 'package:blog/shared/models/user_preview.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/core/application.dart';
import 'package:blog/modules/home/model/home_view_state.dart';

class ChatComment extends StatelessWidget {
  final Comment comment;
  final UserPreview? currentUser;

  const ChatComment({super.key, required this.comment, this.currentUser });

  @override
  Widget build(BuildContext context) {
    final isWeird = comment.content.contains("haven");

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isWeird ? AppColors.highlight : AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    context.read<ApplicationBloc>().add(
                      ApplicationNavigateEvent(
                        route: HomeViewState.profile,
                        userId: comment.author.id,
                      ),
                    );
                  },
                  child: Text(
                    comment.author.alias ?? '',
                    style: AppTextStyles.link.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (comment.author.id == currentUser?.id)
                  Text(
                    "OP",
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.content, style: AppTextStyles.body),
                  const SizedBox(height: 8),
                  Text(
                    comment.displayCreatedAt,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}