import 'dart:async';
import 'package:blog/modules/chat_forum/model/chat_item.dart';
import 'package:blog/modules/chat_forum/model/thread.dart';
import 'package:blog/shared/util/abstract_bloc/base_bloc.dart';
import 'package:blog/shared/util/abstract_bloc/base_emitter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_forum.dart';

class ChatForumBloc extends AbstractBloc<ChatForumEvent, ChatForumState> {
  final ChatForumRepository _repository;
  late StreamSubscription<ChatForumEvent> _subscription;

  ChatForumBloc({
    required ChatForumRepository repository
  })  : _repository = repository,
        super(const ChatForumInitialState()) {
    on<ChatForumLoadEvent>(_onChatForumLoad);
    on<ChatForumRefreshEvent>(_onChatForumRefresh);
    on<ChatLoadThreadEvent>(_fetchChatThread);
    on<ChatAddCommentEvent>(_onAddComment);

    _subscription = _repository.data.listen(
      (event) => add(event),
    );
  }

  Future<void> _onChatForumLoad(
      ChatForumLoadEvent event, Emitter<ChatForumState> emit) async {
    emit.logCall(ChatForumLoadingState());
     await _fetchContent(emit, event.fromCache);
  }

  Future<void> _onChatForumRefresh(
      ChatForumRefreshEvent event, Emitter<ChatForumState> emit) async {
    emit.logCall(ChatForumLoadingState());
    await _fetchContent(emit, false);
  }

  Future<void> _fetchContent(Emitter<ChatForumState> emit, bool fromCache) async {
    List<ChatItem> chats = await _repository.fetchContent(fromCache);
    emit.logCall(ChatForumContentLoadedState(chats: chats));
  }

  Future<void> _fetchChatThread(
      ChatLoadThreadEvent event, Emitter<ChatForumState> emit) async {
    
    emit.logCall(ChatForumThreadLoadingState());

    try {
      final thread = await _repository.getThread(event.threadId);
      final comments = await _repository.getComments(event.threadId);

      emit.logCall(ChatForumThreadLoadedState(thread: thread, comments: comments));
    } catch (_) {
      emit.logCall(ChatForumThreadErrorState());
    }

  }

  Future<void> _onAddComment(ChatAddCommentEvent event, Emitter<ChatForumState> emit) async {
    if (state is ChatForumThreadLoadedState) {
      final current = state as ChatForumThreadLoadedState;

      final newComment = CommentItem(
        id: DateTime.now().toString(),
        username: "You",
        message: event.message,
        time: "just now",
      );

      _repository.addComment(newComment);

      emit.logCall(ChatForumThreadLoadedState(
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
