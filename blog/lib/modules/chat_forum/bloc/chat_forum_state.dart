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
  final String? search;

  const ChatForumContentLoadedState({
    required this.chat,
    this.search,
  });

  @override
  List<Object?> get props => [chat, search];

  @override
  Map<String, dynamic> get properties => {
    'chat': chat,
    if (search != null) 'search': search,
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
  final bool isSubmittingComment;

  const ChatForumThreadLoadedState({
    required this.thread,
    this.currentAuthor,
    this.isSubmittingComment = false
  });

  ChatForumThreadLoadedState copyWith({
    Thread? thread,
    bool? isSubmittingComment,
    Author? currentAuthor,
  }) {
    return ChatForumThreadLoadedState(
      thread: thread ?? this.thread,
      currentAuthor: currentAuthor ?? this.currentAuthor,
      isSubmittingComment: isSubmittingComment ?? this.isSubmittingComment,
    );
  }


  @override
  List<Object?> get props => [thread, currentAuthor, isSubmittingComment];

  @override
  Map<String, dynamic> get properties => {};

}

class ChatForumThreadErrorState extends ChatForumState {}