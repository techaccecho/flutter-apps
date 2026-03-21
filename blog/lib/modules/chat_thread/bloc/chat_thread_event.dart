import 'package:blog/shared/util/abstract_bloc/base_event.dart';

abstract class ChatThreadEvent extends BaseEvent {
  const ChatThreadEvent();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties;
}

class ChatLoadThreadEvent extends ChatThreadEvent {
  final String threadId;

  const ChatLoadThreadEvent(this.threadId);


  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class ChatAddCommentEvent extends ChatThreadEvent {
  final String message;
  
  const ChatAddCommentEvent(this.message);

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}