class Media {
  final String id;
  final String type;
  final String url;
  final double createdAt;
  final double? updatedAt;

  Media({
    required this.id,
    required this.type,
    required this.url,
    required this.createdAt,
    this.updatedAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        id: json['id'],
        type: json['type'],
        url: json['url'],
        createdAt: (json['createdAt'] as num).toDouble(),
        updatedAt: json['updatedAt'] != null
            ? (json['updatedAt'] as num).toDouble()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'url': url,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}