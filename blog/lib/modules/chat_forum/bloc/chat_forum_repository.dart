import 'dart:async';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/modules/chat_forum/model/chat_item.dart';

class ChatForumRepository {
  final _controller = StreamController<ChatForumEvent>();

  ChatForumRepository();

  Stream<ChatForumEvent> get data async* {
    yield const ChatForumStartupEvent();
    yield* _controller.stream;
  }

  Future<List<ChatItem>> fetchContent() {
    return Future.delayed(const Duration(seconds: 3), () {
      return [
        ChatItem(
          title: 'Chat one',
          participants: 3,
          replies: 20,
          lastPost: "Here is a last post from someone"
        ),
        ChatItem(
          title: 'Chat two',
          participants: 2,
          replies: 50,
          lastPost: "Here is a last post from someone"
        ),
        ChatItem(
          title: 'Chat three',
          participants: 5,
          replies: 5,
          lastPost: "Here is a last post from someone"
        )
      ];
    });
  }

  void dispose() => _controller.close();
}
