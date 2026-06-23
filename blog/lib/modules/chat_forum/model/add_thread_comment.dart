import 'package:blog/shared/models/add_comment.dart';

class AddThreadComment {
  final String authorId;
  final String content;

  AddThreadComment({
    required this.authorId,
    required this.content,
  });

  AddComment toAddComment() => AddComment(
    authorId: authorId,
    content: content
  );
}
