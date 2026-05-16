class Reaction {
  final String id;
  final String type;
  final double createdAt;
  final double? updatedAt;

  Reaction({
    required this.id,
    required this.type,
    required this.createdAt,
    this.updatedAt,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
        id: json['id'],
        type: json['type'],
        createdAt: (json['createdAt'] as num).toDouble(),
        updatedAt: json['updatedAt'] != null
            ? (json['updatedAt'] as num).toDouble()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}