class Attachment {
  final String id;
  final String type;
  final String? url;
  final String? content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Attachment({
    required this.id,
    required this.type,
    this.url,
    this.content,
    required this.createdAt,
    this.updatedAt
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
    id: json['id'],
    type: json['type'],
    url: json['url'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'url': url,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch
    };
  }
}