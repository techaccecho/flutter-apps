class CreateBlog {
  final String authorId;
  final String title;
  final String content;
  final String type;
  final bool isDraft;
  final DateTime? createdAt;

  CreateBlog({
    required this.authorId,
    required this.title,
    required this.content,
    required this.type,
    required this.isDraft,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'title': title,
      'content': content,
      'type': type,
      'isDraft': isDraft,
      if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
    };
  }
}
