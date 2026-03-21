import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum.dart';
import 'package:blog/modules/chat_forum/view/chat_forum_view.dart';

class ChatForumScreen extends StatefulWidget {
  const ChatForumScreen({super.key, required this.title});

  final String title;

  @override
  State<ChatForumScreen> createState() => _ChatForumScreenState();
}

class _ChatForumScreenState extends State<ChatForumScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: BlocProvider(
          create: (context) => ChatForumBloc(repository: ChatForumRepository()),
          child: const ChatForumView())
      )
    );
  }
}
