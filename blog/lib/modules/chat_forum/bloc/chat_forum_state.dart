import 'package:blog/modules/chat_forum/model/chat_item.dart';
import 'package:blog/modules/chat_forum/model/thread.dart';
import 'package:blog/shared/util/abstract_bloc/base_state.dart';

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

  final List<ChatItem> chats;

  const ChatForumContentLoadedState({
    required this.chats,
  });

  @override
  List<Object?> get props => [chats];

  @override
  Map<String, dynamic> get properties => {
    'chats': chats,
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
  final List<CommentItem> comments;

  const ChatForumThreadLoadedState({
    required this.thread,
    required this.comments,
  });


  @override
  List<Object?> get props => [thread, comments];

  @override
  Map<String, dynamic> get properties => {};

}

class ChatForumThreadErrorState extends ChatForumState {}