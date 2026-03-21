import 'package:flutter/material.dart';
import 'package:blog/modules/chat_forum/model/chat_item.dart';
import 'package:blog/modules/chat_thread/view/chat_thread_screen.dart';
import 'package:blog/resources/resources.dart';

class ForumItem extends StatelessWidget {
  final ChatItem chat;

  const ForumItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder:(context) => ChatThreadScreen(threadId: '1',),));
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
                  Text(chat.title, style: AppTextStyles.h2),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    "${chat.replies} replies • ${chat.participants} participants",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    "Last post: ${chat.lastPost}",
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}