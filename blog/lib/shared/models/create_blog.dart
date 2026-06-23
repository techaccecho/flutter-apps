class CreateBlog {
  final String authorId;
  final String title;
  final String content;
  final String type;

  CreateBlog({
    required this.authorId,
    required this.title,
    required this.content,
    required this.type
  });

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'title': title,
      'content': content,
      'type': type
    };
  }
}