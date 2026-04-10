import 'package:blog/shared/util/abstract_bloc/base_event.dart';

abstract class ChatForumEvent extends BaseEvent {
  const ChatForumEvent();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties;
}

class ChatForumLoadEvent extends ChatForumEvent {
  final bool fromCache;
  const ChatForumLoadEvent({this.fromCache = false});

  @override
  List<Object?> get props => [fromCache];

  @override
  Map<String, dynamic> get properties => {"fromCache": fromCache};
}

class ChatForumRefreshEvent extends ChatForumEvent {

  const ChatForumRefreshEvent();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ChatLoadThreadEvent extends ChatForumEvent {
  final String threadId;

  const ChatLoadThreadEvent(this.threadId);


  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ChatAddCommentEvent extends ChatForumEvent {
  final String message;
  
  const ChatAddCommentEvent(this.message);

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}