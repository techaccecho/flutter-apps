import 'dart:async';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/model/blog_post.dart';

class BlogRepository {
  final _controller = StreamController<BlogEvent>();

  List<BlogPost> blogs = [
      BlogPost(
          id: "1",
          title: "Strange Logs in My System",
          author: "cedric_dev",
          date: "Mar 2, 2006",
          excerpt: "I’ve been seeing patterns in my logs that I can’t explain...",
          comments: 12,
        ),
        BlogPost(
          id: "2",
          title: "Exploring a Forgotten Game",
          author: "cedric_dev",
          date: "Feb 24, 2006",
          excerpt: "I found something interesting while browsing old archives...",
          comments: 8,
        ),
  ];

  BlogRepository();

  Stream<BlogEvent> get data async* {
    yield* _controller.stream;
  }

  Future<List<BlogPost>> getBlogPosts(bool fromCache) async {
    if (!fromCache) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return List.of(blogs);
  }

  Future<BlogPost> getBlogPost(String blogId) async {
    return blogs[int.tryParse(blogId)!];
  }

  void dispose() => _controller.close();
}
