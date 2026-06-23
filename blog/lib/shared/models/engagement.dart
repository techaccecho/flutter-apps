class Engagement {
  final int views;
  final int comments;
  final int attachments;
  final int reactions;
  final DateTime? updatedAt;

  Engagement({
    required this.views,
    required this.comments,
    required this.attachments,
    required this.reactions,
    this.updatedAt
  });

  factory Engagement.fromJson(Map<String, dynamic> json) => Engagement(
    views: json['views'],
    comments: json['comments'],
    attachments: json['attachments'],
    reactions: json['reactions'],
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null
  );

  Map<String, dynamic> toJson() {
    return {
      'views': views,
      'comments': comments,
      'attachments': attachments,
      'reactions': reactions
    };
  }
}