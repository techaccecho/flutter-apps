import 'package:blog/modules/chat_thread/model/thread.dart';
import 'package:blog/shared/util/abstract_bloc/base_state.dart';

class ChatThreadState extends BaseState {
  const ChatThreadState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ChatThreadLoadingState extends ChatThreadState {}

class ChatThreadLoadedState extends ChatThreadState {
  final Thread thread;
  final List<CommentItem> comments;

  const ChatThreadLoadedState({
    required this.thread,
    required this.comments,
  });


  @override
  List<Object?> get props => [thread, comments];

  @override
  Map<String, dynamic> get properties => {};

}

class ChatThreadErrorState extends ChatThreadState {}