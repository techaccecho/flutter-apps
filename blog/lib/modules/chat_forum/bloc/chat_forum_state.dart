import 'package:blog/modules/chat_forum/model/thread.dart';
import 'package:blog/shared/util/abstract_bloc/base_state.dart';
import 'package:blog/shared/models/author.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_repository.dart';

class ChatForumState extends BaseState {
  const ChatForumState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ChatForumInitialState extends ChatForumState {
  const ChatForumInitialState();
}

class ChatForumCoreLoadedState extends ChatForumState {
  const ChatForumCoreLoadedState();
}

class ChatForumLoadingState extends ChatForumState {
  const ChatForumLoadingState();
}

class ChatForumContentLoadedState extends ChatForumState {

  final ThreadPaginatedResult chat;

  const ChatForumContentLoadedState({
    required this.chat,
  });

  @override
  List<Object?> get props => [chat];

  @override
  Map<String, dynamic> get properties => {
    'chat': chat,
  };
}

class ChatForumErrorState extends ChatForumState {

  final String error;

  const ChatForumErrorState({
    required this.error,
  });

  @override
  List<Object?> get props => [error];

  @override
  Map<String, dynamic> get properties => {
    'error': error,
  };
}

class ChatForumThreadLoadingState extends ChatForumState {}

class ChatForumThreadLoadedState extends ChatForumState {
  final Thread thread;
  final Author? currentAuthor;

  const ChatForumThreadLoadedState({
    required this.thread,
    this.currentAuthor
  });


  @override
  List<Object?> get props => [thread];

  @override
  Map<String, dynamic> get properties => {};

}

class ChatForumThreadErrorState extends ChatForumState {}