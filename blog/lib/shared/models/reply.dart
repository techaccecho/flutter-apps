import 'package:blog/shared/models/user_preview.dart';
import 'package:blog/shared/models/attachment.dart';
import 'package:blog/shared/models/reaction.dart';
import 'package:blog/shared/models/engagement.dart';

class Reply {
  final String id;
  final UserPreview author;
  final String content;
  final List<Attachment> attachments;
  final List<UserPreview> viewers;
  final List<Reaction> reactions;
  final Engagement engagement;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Reply({
    required this.id,
    required this.author,
    required this.content,
    required this.attachments,
    required this.viewers,
    required this.reactions,
    required this.engagement,
    required this.createdAt,
    required this.updatedAt
  });

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
    id: json['id'],
    author: UserPreview.fromJson(json['author']),
    content: json['content'],
    attachments: (json['attachments'] as List? ?? []).map((a) => Attachment.fromJson(a)).toList(),
    viewers: (json['viewers'] as List? ?? []).map((v) => UserPreview.fromJson(v)).toList(),
    reactions: (json['reactions'] as List? ?? []).map((r) => Reaction.fromJson(r)).toList(),
    engagement: Engagement.fromJson(json['engagement']),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'content': content,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'viewers': viewers.map((v) => v.toJson()).toList(),
      'reactions': attachments.map((r) => r.toJson()).toList(),
      'engagement': engagement.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}