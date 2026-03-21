import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_state.dart';
import 'package:blog/modules/chat_forum/view/forum_item.dart';

class ChatForumView extends StatelessWidget {
  
  const ChatForumView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatForumBloc, ChatForumState>(
      builder: (context, state) {
        if (state is ChatForumLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatForumContentLoadedState) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.chats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.chats[index];
              return ForumItem(chat: item);
            },
          );
        }

        if (state is ChatForumErrorState) {
          return const Center(child: Text("Something went wrong"));
        }

        return const Center(child: Text("Loading forums..."));
      },
    );
  }
}