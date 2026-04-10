import 'package:blog/modules/chat_forum/model/thread.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';

class ChatComment extends StatelessWidget {
  final CommentItem comment;

  const ChatComment({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final isWeird = comment.message.contains("haven");

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
                Text(
                  comment.username,
                  style: AppTextStyles.h3,
                ),
                if (comment.isOp)
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
                  Text(comment.message, style: AppTextStyles.body),
                  const SizedBox(height: 8),
                  Text(
                    comment.time,
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