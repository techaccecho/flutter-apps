class AddComment {
  final String authorId;
  final String content;

  AddComment({required this.authorId, required this.content});

  Map<String, dynamic> toJson() {
    return {'authorId': authorId, 'content': content};
  }
}
