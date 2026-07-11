import 'package:blog/shared/models/create_blog.dart';

class CreateBlogPost {
  final String authorId;
  final String title;
  final String content;
  final bool isDraft;
  final DateTime? createdAt;

  CreateBlogPost({
    required this.authorId,
    required this.title,
    required this.content,
    required this.isDraft,
    this.createdAt,
  });

  CreateBlog toCreateBlog() => CreateBlog(
    authorId: authorId,
    title: title,
    content: content,
    type: 'post',
    isDraft: isDraft,
    createdAt: createdAt,
  );
}
