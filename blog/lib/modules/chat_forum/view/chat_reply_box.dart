import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/shared/view/raised_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatReplyBox extends StatefulWidget {
  final String threadId;
  final String authorId;

  const ChatReplyBox({super.key, required this.threadId, required this.authorId });

  @override
  State<ChatReplyBox> createState() => _ChatReplyBoxState();
}

class _ChatReplyBoxState extends State<ChatReplyBox> {
  final controller = TextEditingController();

  void onReply() {
    final message = controller.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A message cannot be empty')),
      );
      return;
    }

    context
        .read<ChatForumBloc>()
        .add(ChatAddCommentEvent(threadId: widget.threadId, authorId: widget.authorId, message: controller.text));
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Write a reply...",
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 120, child: RaisedButton(action: onReply, title: "Post"))
        ],
      ),
    );
  }
}