import 'dart:async';
import 'package:blog/modules/chat_thread/bloc/chat_thread_event.dart';
import 'package:blog/modules/chat_thread/bloc/chat_thread_repository.dart';
import 'package:blog/modules/chat_thread/bloc/chat_thread_state.dart';
import 'package:blog/modules/chat_thread/model/thread.dart';
import 'package:blog/shared/util/abstract_bloc/base_bloc.dart';
import 'package:blog/shared/util/abstract_bloc/base_emitter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatThreadBloc extends AbstractBloc<ChatThreadEvent, ChatThreadState> {
  final ChatThreadRepository _repository;
  late StreamSubscription<ChatThreadEvent> _subscription;

  ChatThreadBloc({
    required ChatThreadRepository repository
  })  : _repository = repository,
        super(ChatThreadLoadingState()) {
    on<ChatLoadThreadEvent>(_fetchChatThread);
    on<ChatAddCommentEvent>(_onAddComment);
    
    _subscription = _repository.data.listen(
      (event) => add(event),
    );
  }

  Future<void> _fetchChatThread(
      ChatLoadThreadEvent event, Emitter<ChatThreadState> emit) async {
    
    emit.logCall(ChatThreadLoadingState());

    try {
      final thread = await _repository.getThread(event.threadId);
      final comments = await _repository.getComments(event.threadId);

      emit.logCall(ChatThreadLoadedState(thread: thread, comments: comments));
    } catch (_) {
      emit.logCall(ChatThreadErrorState());
    }

  }

  Future<void> _onAddComment(ChatAddCommentEvent event, Emitter<ChatThreadState> emit) async {
    if (state is ChatThreadLoadedState) {
      final current = state as ChatThreadLoadedState;

      final newComment = CommentItem(
        id: DateTime.now().toString(),
        username: "You",
        message: event.message,
        time: "just now",
      );

      _repository.addComment(newComment);

      emit.logCall(ChatThreadLoadedState(
        thread: current.thread,
        comments: await _repository.getComments("1"),
      ));
    }
  }

  @override
  Future<void> close() async {
    _subscription.cancel();
    _repository.dispose();
    super.close();
  }
}
