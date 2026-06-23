import 'package:blog/shared/models/create_blog.dart';

class CreateBlogPost {
  final String authorId;
  final String title;
  final String content;

  CreateBlogPost({
    required this.authorId,
    required this.title,
    required this.content
  });

  CreateBlog toCreateBlog() => CreateBlog(
    authorId: authorId,
    title: title,
    content: content,
    type: 'post'
    );
}