import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/chat_thread/bloc/chat_thread_bloc.dart';
import 'package:blog/modules/chat_thread/bloc/chat_thread_event.dart';

import '../../../resources/resources.dart';

class ChatReplyBox extends StatefulWidget {
  const ChatReplyBox({super.key});

  @override
  State<ChatReplyBox> createState() => _ChatReplyBoxState();
}

class _ChatReplyBoxState extends State<ChatReplyBox> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
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
          ElevatedButton(
            onPressed: () {
              context
                  .read<ChatThreadBloc>()
                  .add(ChatAddCommentEvent(controller.text));

              controller.clear();
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }
}