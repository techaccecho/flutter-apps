import 'dart:async';
import 'package:blog/shared/util/abstract_bloc/base_bloc.dart';
import 'package:blog/shared/util/abstract_bloc/base_emitter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/blog/util/blog_content.dart';
import 'package:blog/modules/chat_forum/model/add_thread_comment.dart';
import 'package:blog/modules/chat_forum/model/create_thread.dart';
import 'package:blog/modules/chat_forum/model/update_thread.dart';

import 'chat_forum.dart';

class ChatForumBloc extends AbstractBloc<ChatForumEvent, ChatForumState> {
  final ChatForumRepository _repository;

  ChatForumBloc({required ChatForumRepository repository})
    : _repository = repository,
      super(const ChatForumInitialState()) {
    on<ChatForumLoadEvent>(_onChatForumLoad);
    on<ChatForumRefreshEvent>(_onChatForumRefresh);
    on<ChatLoadThreadEvent>(_fetchChatThread);
    on<ChatCreateThreadEvent>(_onCreateThread);
    on<ChatUpdateThreadEvent>(_onUpdateThread);
    on<ChatDeleteThreadEvent>(_onDeleteThread);
    on<ChatSoftDeleteThreadEvent>(_onSoftDeleteThread);
    on<ChatAddCommentEvent>(_onAddComment);
  }

  Future<void> _onChatForumLoad(
    ChatForumLoadEvent event,
    Emitter<ChatForumState> emit,
  ) async {
    emit.logCall(const ChatForumLoadingState());
    await _fetchContent(emit, event.fromCache, search: event.search);
  }

  Future<void> _onChatForumRefresh(
    ChatForumRefreshEvent event,
    Emitter<ChatForumState> emit,
  ) async {
    emit.logCall(const ChatForumLoadingState());
    await _fetchContent(emit, false);
  }

  Future<void> _fetchContent(
    Emitter<ChatForumState> emit,
    bool fromCache, {
    String? search,
  }) async {
    ThreadPaginatedResult threads = await _repository.getThreads(search: search);
    //List<ChatItem> chats = await _repository.get(fromCache);
    emit.logCall(ChatForumContentLoadedState(chat: threads, search: search));
  }

  Future<void> _fetchChatThread(
    ChatLoadThreadEvent event,
    Emitter<ChatForumState> emit,
  ) async {
    emit.logCall(ChatForumThreadLoadingState());

    try {
      final thread = await _repository.getThread(event.threadId);
      //final comments = await _repository.getComments(event.threadId);

      emit.logCall(ChatForumThreadLoadedState(thread: thread));
    } catch (_) {
      emit.logCall(ChatForumThreadErrorState());
    }
  }

  Future<void> _onCreateThread(
    ChatCreateThreadEvent event,
    Emitter<ChatForumState> emit,
  ) async {
    emit.logCall(ChatForumLoadingState());

    try {
      final title = sanitizeBlogContent(event.title).trim();
      final content = sanitizeBlogContent(event.content);
      final validationError = _validateThreadInput(title, content);

      if (validationError != null) {
        emit.logCall(ChatForumErrorState(error: validationError));
        return;
      }

      final request = CreateThread(
        authorId: event.authorId,
        title: title,
        content: content,
      );
      await _repository.createThread(request);
      await _fetchContent(emit, false);
    } catch (_) {
      emit.logCall(const ChatForumErrorState(error: 'Unable to create thread'));
    }
  }

  Future<void> _onUpdateThread(
    ChatUpdateThreadEvent event,
    Emitter<ChatForumState> emit,
  ) async {
    emit.logCall(ChatForumThreadLoadingState());

    try {
      final title = sanitizeBlogContent(event.title).trim();
      final content = sanitizeBlogContent(event.content);
      final validationError = _validateThreadInput(title, content);

      if (validationError != null) {
        emit.logCall(ChatForumErrorState(error: validationError));
        return;
      }

      final thread = await _repository.updateThread(
        id: event.threadId,
        update: UpdateThread(title: title, content: content),
      );
      emit.logCall(ChatForumThreadLoadedState(thread: thread));
    } catch (_) {
      emit.logCall(const ChatForumErrorState(error: 'Unable to update thread'));
    }
  }

  Future<void> _onDeleteThread(
    ChatDeleteThreadEvent event,
    Emitter<ChatForumState> emit,
  ) async {
    emit.logCall(ChatForumLoadingState());

    try {
      await _repository.deleteThread(event.threadId, reason: event.reason);
      await _fetchContent(emit, false);
    } catch (_) {
      emit.logCall(const ChatForumErrorState(error: 'Unable to delete thread'));
    }
  }

  Future<void> _onSoftDeleteThread(
    ChatSoftDeleteThreadEvent event,
    Emitter<ChatForumState> emit,
  ) async {
    emit.logCall(ChatForumLoadingState());

    try {
      await _repository.softDeleteThread(
        id: event.threadId,
        reason: event.reason,
      );
      await _fetchContent(emit, false);
    } catch (_) {
      emit.logCall(const ChatForumErrorState(error: 'Unable to remove thread'));
    }
  }

  Future<void> _onAddComment(
    ChatAddCommentEvent event,
    Emitter<ChatForumState> emit,
  ) async {
    emit.logCall(ChatForumLoadingState());

    final request = AddThreadComment(
      authorId: event.authorId,
      content: event.message,
    );
    final response = await _repository.addThreadComment(
      id: event.threadId,
      request: request,
    );

    emit.logCall(ChatForumThreadLoadedState(thread: response));
  }

  String? _validateThreadInput(String title, String content) {
    if (title.isEmpty) {
      return 'Title cannot be empty';
    }

    if (title.length > 200) {
      return 'Title must be 200 characters or less';
    }

    return validateBlogContent(content);
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
