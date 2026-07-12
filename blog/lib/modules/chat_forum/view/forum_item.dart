import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:flutter/material.dart';
import 'package:blog/modules/chat_forum/model/thread.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForumItem extends StatelessWidget {
  final Thread thread;

  const ForumItem({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<ChatForumBloc>().add(ChatLoadThreadEvent(thread.id));
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.forum, size: 28),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(thread.title, style: AppTextStyles.h2),
                      ),
                      if (thread.isAdminRemoved)
                        Chip(
                          label: const Text('Removed'),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: AppColors.background,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    "${thread.engagement.comments} replies • ${thread.participants.length} participants",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (thread.comments.isNotEmpty) ...[
                    Text(
                      "Last post: ${thread.comments[thread.comments.length - 1].content}",
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
