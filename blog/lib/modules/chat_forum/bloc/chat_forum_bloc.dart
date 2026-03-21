import 'dart:async';
import 'package:blog/modules/chat_forum/model/chat_item.dart';
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
    on<ChatForumStartupEvent>(_onApplicationStartup);
    on<ChatForumRefreshEvent>(_onApplicationRefresh);

    _subscription = _repository.data.listen(
      (event) => add(event),
    );
  }

  Future<void> _onApplicationStartup(
      ChatForumStartupEvent event, Emitter<ChatForumState> emit) async {
    emit.logCall(ChatForumLoadingState());
    await _fetchContent(emit);
  }

  Future<void> _onApplicationRefresh(
      ChatForumRefreshEvent event, Emitter<ChatForumState> emit) async {
    emit.logCall(ChatForumLoadingState());
    await _fetchContent(emit);
  }

  Future<void> _fetchContent(Emitter<ChatForumState> emit) async {
    List<ChatItem> chats = await _repository.fetchContent();
    emit.logCall(ChatForumContentLoadedState(chats: chats));
  }

  @override
  Future<void> close() async {
    _subscription.cancel();
    _repository.dispose();
    super.close();
  }
}
