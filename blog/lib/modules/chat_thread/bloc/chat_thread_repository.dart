import 'dart:async';
import 'package:blog/modules/chat_thread/bloc/chat_thread_event.dart';
import 'package:blog/modules/chat_thread/model/thread.dart';

class ChatThreadRepository {
  final _controller = StreamController<ChatThreadEvent>();

  List<CommentItem> comments = [
      CommentItem(id: '11', username: 'Bilo', message: 'kosdjnfd njisndjn ishdfybyhbf. sdbfyhsbdfy sb ybdfy b ybhysd y bys bhyhdgfy ghsy sdfs', time: '12:10'),
      CommentItem(id: '12', username: 'Caleb', message: 'njhbt dede fgf yg tfr ded tvyni kiubh tvrdex', time: '12:10'),
      CommentItem(id: '13', username: 'Crayton', message: 'kmuby redftgg klploj uygrdw sexcr vfvbgb', time: '12:10'),
      CommentItem(id: '14', username: 'Yusuf', message: '6yrtuyjkglh jlkjlmnijhg gvgj hbkhjlkjl ho; hbukhlb n.ljknhgfvtvyb hjkn', time: '12:10'),
      CommentItem(id: '14', username: 'William', message: 'oyuibln jkboiljk bnoiljbnoilj kbiuhjlkb knjnlkjbn', time: '12:10')];

  ChatThreadRepository();

  Stream<ChatThreadEvent> get data async* {
    yield* _controller.stream;
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
