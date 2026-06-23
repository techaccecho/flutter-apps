import 'dart:async';
import 'package:blog/shared/util/abstract_bloc/base_bloc.dart';
import 'package:blog/shared/util/abstract_bloc/base_emitter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/chat_forum/model/add_thread_comment.dart';

import 'chat_forum.dart';

class ChatForumBloc extends AbstractBloc<ChatForumEvent, ChatForumState> {
  final ChatForumRepository _repository;

  ChatForumBloc({
    required ChatForumRepository repository
  })  : _repository = repository,
        super(const ChatForumInitialState()) {
    on<ChatForumLoadEvent>(_onChatForumLoad);
    on<ChatForumRefreshEvent>(_onChatForumRefresh);
    on<ChatLoadThreadEvent>(_fetchChatThread);
    on<ChatAddCommentEvent>(_onAddComment);
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
    ThreadPaginatedResult threads = await _repository.getThreads();
    //List<ChatItem> chats = await _repository.get(fromCache);
    emit.logCall(ChatForumContentLoadedState(chat: threads));
  }

  Future<void> _fetchChatThread(
      ChatLoadThreadEvent event, Emitter<ChatForumState> emit) async {
    
    emit.logCall(ChatForumThreadLoadingState());

    try {
      final thread = await _repository.getThread(event.threadId);
      //final comments = await _repository.getComments(event.threadId);

      emit.logCall(ChatForumThreadLoadedState(thread: thread));
    } catch (_) {
      emit.logCall(ChatForumThreadErrorState());
    }

  }

  Future<void> _onAddComment(ChatAddCommentEvent event, Emitter<ChatForumState> emit) async {
    emit.logCall(ChatForumLoadingState());

    final request = AddThreadComment(authorId: event.authorId, content: event.message);
    final response = await _repository.addThreadComment(id: event.threadId, request: request);

    emit.logCall(ChatForumThreadLoadedState(
      thread: response
    ));
  }

  //   final newComment = CommentItem(
//     id: DateTime.now().toString(),
//     username: "You",
//     message: event.message,
//     time: "just now",
//   );

  @override
  Future<void> close() async {
    //_subscription.cancel();
    //_repository.dispose();
    super.close();
  }
}
