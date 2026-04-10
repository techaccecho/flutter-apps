class Thread {
  final String id;
  final String title;
  final String author;
  final String createdAt;

  Thread({
    required this.id,
    required this.title,
    required this.author,
    required this.createdAt,
  });
}

class CommentItem {
  final String id;
  final String username;
  final String message;
  final String time;
  final bool isOp; // original poster

  CommentItem({
    required this.id,
    required this.username,
    required this.message,
    required this.time,
    this.isOp = false,
  });
}