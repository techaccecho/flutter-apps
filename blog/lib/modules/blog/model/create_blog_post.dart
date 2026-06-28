import 'package:blog/shared/models/create_blog.dart';

class CreateBlogPost {
  final String authorId;
  final String title;
  final String content;
  final DateTime? createdAt;

  CreateBlogPost({
    required this.authorId,
    required this.title,
    required this.content,
    this.createdAt,
  });

  CreateBlog toCreateBlog() => CreateBlog(
    authorId: authorId,
    title: title,
    content: content,
    type: 'post',
    createdAt: createdAt,
  );
}