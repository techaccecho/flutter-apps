import 'package:blog/shared/models/create_blog.dart';

class CreateThread {
  final String authorId;
  final String title;
  final String content;

  CreateThread({
    required this.authorId,
    required this.title,
    required this.content,
  });

  CreateBlog toCreateBlog() => CreateBlog(
    authorId: authorId,
    title: title,
    content: content,
    type: 'thread',
    isDraft: false,
  );
}
