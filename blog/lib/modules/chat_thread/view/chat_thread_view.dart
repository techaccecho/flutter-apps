import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/chat_thread/bloc/chat_thread_bloc.dart';
import 'package:blog/modules/chat_thread/bloc/chat_thread_state.dart';
import 'package:blog/modules/chat_thread/view/chat_comment.dart';
import 'package:blog/modules/chat_thread/view/chat_reply_box.dart';
import 'package:blog/modules/chat_thread/view/chat_thread_header.dart';

class ChatThreadView extends StatelessWidget {
  const ChatThreadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ChatThreadBloc, ChatThreadState>(
        builder: (context, state) {
          if (state is ChatThreadLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatThreadLoadedState) {
            return Column(
              children: [
                ChatThreadHeader(thread: state.thread),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.comments.length,
                    itemBuilder: (context, index) {
                      return ChatComment(
                        comment: state.comments[index],
                      );
                    },
                  ),
                ),
                ChatReplyBox(),
              ],
            );
          }

          return const Center(child: Text("Error loading thread"));
        },
      ),
    );
  }
}