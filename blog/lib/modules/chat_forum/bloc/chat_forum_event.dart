import 'package:blog/shared/util/abstract_bloc/base_event.dart';

abstract class ChatForumEvent extends BaseEvent {
  const ChatForumEvent();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties;
}

class ChatForumStartupEvent extends ChatForumEvent {
  const ChatForumStartupEvent();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ChatForumRefreshEvent extends ChatForumEvent {

  const ChatForumRefreshEvent();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}