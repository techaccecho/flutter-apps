import 'package:blog/shared/models/add_comment.dart';

class AddBlogPostComment {
  final String authorId;
  final String content;

  AddBlogPostComment({required this.authorId, required this.content});

  AddComment toAddComment() => AddComment(authorId: authorId, content: content);
}
