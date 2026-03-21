import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/chat_thread/bloc/chat_thread_bloc.dart';
import 'package:blog/modules/chat_thread/bloc/chat_thread_event.dart';
import 'package:blog/modules/chat_thread/bloc/chat_thread_repository.dart';
import 'package:blog/modules/chat_thread/view/chat_thread_view.dart';

class ChatThreadScreen extends StatelessWidget {
  final String threadId;

  const ChatThreadScreen({super.key, required this.threadId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatThreadBloc(repository: ChatThreadRepository())
        ..add(ChatLoadThreadEvent(threadId)),
      child: const ChatThreadView(),
    );
  }
}