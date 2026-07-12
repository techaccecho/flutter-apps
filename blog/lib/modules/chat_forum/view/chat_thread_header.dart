import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/modules/chat_forum/model/thread.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatThreadHeader extends StatelessWidget {
  final Thread thread;
  final bool canEdit;
  final bool canDelete;
  final bool canSoftDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSoftDelete;

  const ChatThreadHeader({
    super.key,
    required this.thread,
    this.canEdit = false,
    this.canDelete = false,
    this.canSoftDelete = false,
    this.onEdit,
    this.onDelete,
    this.onSoftDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => {
              context.read<ChatForumBloc>().add(
                ChatForumLoadEvent(fromCache: true),
              ),
            },
            icon: Icon(Icons.arrow_back),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(thread.title, style: AppTextStyles.h1),
                const SizedBox(height: 4),
                Text(
                  "Started by ${thread.author.displayName} · ${thread.displayCreatedAt}",
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  thread.isAdminRemoved
                      ? 'Content removed by administrator'
                      : thread.content,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
          if (canEdit) ...[
            IconButton(
              tooltip: 'Edit thread',
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
            ),
          ],
          if (canSoftDelete) ...[
            IconButton(
              tooltip: 'Remove thread',
              onPressed: onSoftDelete,
              icon: const Icon(Icons.block),
            ),
          ],
          if (canDelete) ...[
            IconButton(
              tooltip: 'Delete thread',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ],
      ),
    );
  }
}
