class ParentComment {
  final String content;
  final double createdAt;
  final String id;

  ParentComment({
    required this.content,
    required this.createdAt,
    required this.id,
  });

  factory ParentComment.fromJson(Map<String, dynamic> json) =>
      ParentComment(
        content: json['content'],
        createdAt: (json['createdAt'] as num).toDouble(),
        id: json['id'],
      );

  Map<String, dynamic> toJson() => {
        'content': content,
        'createdAt': createdAt,
        'id': id,
      };
}