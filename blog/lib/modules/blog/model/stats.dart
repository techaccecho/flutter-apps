class Stats {
  final double commentsCount;
  final List<ReactionSummary> reactions;
  final double viewsCount;
  final double? updatedAt;

  Stats({
    required this.commentsCount,
    required this.reactions,
    required this.viewsCount,
    this.updatedAt,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        commentsCount: (json['commentsCount'] as num).toDouble(),
        reactions: (json['reactions'] as List)
            .map((e) => ReactionSummary.fromJson(e))
            .toList(),
        viewsCount: (json['viewsCount'] as num).toDouble(),
        updatedAt: json['updatedAt'] != null
            ? (json['updatedAt'] as num).toDouble()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'commentsCount': commentsCount,
        'reactions': reactions.map((e) => e.toJson()).toList(),
        'viewsCount': viewsCount,
        'updatedAt': updatedAt,
      };
}

class ReactionSummary {
  final String type;
  final double count;

  ReactionSummary({
    required this.type,
    required this.count,
  });

  factory ReactionSummary.fromJson(Map<String, dynamic> json) =>
      ReactionSummary(
        type: json['type'],
        count: (json['count'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'count': count,
      };
}