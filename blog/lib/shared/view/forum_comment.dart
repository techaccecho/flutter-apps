import 'package:flutter/material.dart';
import 'package:blog/resources/resources.dart';

class ForumComment extends StatelessWidget {
  final String username;
  final String message;
  final String time;

  const ForumComment({
    super.key,
    required this.username,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username column
          SizedBox(
            width: 120,
            child: Text(
              username,
              style: AppTextStyles.h2,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  time,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}