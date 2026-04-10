import 'dart:async';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/modules/chat_forum/model/chat_item.dart';
import 'package:blog/modules/chat_forum/model/thread.dart';

class ChatForumRepository {
  final _controller = StreamController<ChatForumEvent>();

  ChatForumRepository();

  List<CommentItem> comments = [
      CommentItem(id: '11', username: 'Bilo', message: 'kosdjnfd njisndjn ishdfybyhbf. sdbfyhsbdfy sb ybdfy b ybhysd y bys bhyhdgfy ghsy sdfs', time: '12:10'),
      CommentItem(id: '12', username: 'Caleb', message: 'njhbt dede fgf yg tfr ded tvyni kiubh tvrdex', time: '12:10'),
      CommentItem(id: '13', username: 'Crayton', message: 'kmuby redftgg klploj uygrdw sexcr vfvbgb', time: '12:10'),
      CommentItem(id: '14', username: 'Yusuf', message: '6yrtuyjkglh jlkjlmnijhg gvgj hbkhjlkjl ho; hbukhlb n.ljknhgfvtvyb hjkn', time: '12:10'),
      CommentItem(id: '14', username: 'William', message: 'oyuibln jkboiljk bnoiljbnoilj kbiuhjlkb knjnlkjbn', time: '12:10')];

  List<ChatItem> chatItems = [
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

  Stream<ChatForumEvent> get data async* {
    yield const ChatForumLoadEvent();
    yield* _controller.stream;
  }

  Future<List<ChatItem>> fetchContent(bool fromCache) {
    if (fromCache) {
      return Future.value(chatItems);
    } else {
      return Future.delayed(const Duration(seconds: 1), () {
        return chatItems;
      });
    }
  }

  Future<Thread> getThread(String threadId) async {
    return Thread(id: 'Thread 1', title: 'Wow look at this!', author: 'Arthor Zacharia', createdAt: '2026-03-21');
  }

  Future<List<CommentItem>> getComments(String threadId) async {
    return List.of(comments);
  }

  Future<bool> addComment(CommentItem comment) async {
    comments.add(comment);
    return true;
  }

  void dispose() => _controller.close();
}
