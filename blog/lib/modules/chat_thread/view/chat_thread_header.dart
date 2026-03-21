import 'package:flutter/material.dart';
import 'package:blog/modules/chat_thread/model/thread.dart';
import 'package:blog/resources/app_colors.dart';
import 'package:blog/resources/app_spacing.dart';
import 'package:blog/resources/app_text_styles.dart';

class ChatThreadHeader extends StatelessWidget {
  final Thread thread;

  const ChatThreadHeader({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(thread.title, style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Text(
            "Started by ${thread.author} · ${thread.createdAt}",
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}