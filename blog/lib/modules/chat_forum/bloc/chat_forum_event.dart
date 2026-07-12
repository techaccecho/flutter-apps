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

class ChatCreateThreadEvent extends ChatForumEvent {
  final String authorId;
  final String title;
  final String content;

  const ChatCreateThreadEvent({
    required this.authorId,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [authorId, title, content];

  @override
  Map<String, dynamic> get properties => {'authorId': authorId};
}

class ChatUpdateThreadEvent extends ChatForumEvent {
  final String threadId;
  final String title;
  final String content;

  const ChatUpdateThreadEvent({
    required this.threadId,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [threadId, title, content];

  @override
  Map<String, dynamic> get properties => {'threadId': threadId};
}

class ChatDeleteThreadEvent extends ChatForumEvent {
  final String threadId;
  final String? reason;

  const ChatDeleteThreadEvent({required this.threadId, this.reason});

  @override
  List<Object?> get props => [threadId, reason];

  @override
  Map<String, dynamic> get properties => {
    'threadId': threadId,
    if (reason != null) 'reason': reason,
  };
}

class ChatSoftDeleteThreadEvent extends ChatForumEvent {
  final String threadId;
  final String reason;

  const ChatSoftDeleteThreadEvent({
    required this.threadId,
    required this.reason,
  });

  @override
  List<Object?> get props => [threadId, reason];

  @override
  Map<String, dynamic> get properties => {
    'threadId': threadId,
    'reason': reason,
  };
}

class ChatAddCommentEvent extends ChatForumEvent {
  final String threadId;
  final String authorId;
  final String message;

  const ChatAddCommentEvent({
    required this.threadId,
    required this.authorId,
    required this.message,
  });

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}
