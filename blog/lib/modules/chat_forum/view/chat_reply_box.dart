import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/shared/view/raised_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatReplyBox extends StatefulWidget {
  const ChatReplyBox({super.key});

  @override
  State<ChatReplyBox> createState() => _ChatReplyBoxState();
}

class _ChatReplyBoxState extends State<ChatReplyBox> {
  final controller = TextEditingController();

  void postReply() {
    context
        .read<ChatForumBloc>()
        .add(ChatAddCommentEvent(controller.text));
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
          SizedBox(width: 120, child: RaisedButton(action: postReply, title: "Post"))
        ],
      ),
    );
  }
}