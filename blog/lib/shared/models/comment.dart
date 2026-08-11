import 'package:blog/shared/models/attachment.dart';
import 'package:blog/shared/models/user_preview.dart';
import 'package:blog/shared/models/reaction.dart';
import 'package:blog/shared/models/engagement.dart';
import 'package:blog/shared/models/reply.dart';
import 'package:intl/intl.dart';

class Comment {
  final String id;
  final UserPreview author;
  final String content;
  final List<Reply> replies;
  final List<Attachment> attachments;
  final List<UserPreview> viewers;
  final List<Reaction> reactions;
  final Engagement engagement;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.replies,
    required this.attachments,
    required this.viewers,
    required this.reactions,
    required this.engagement,
    required this.createdAt,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    author: UserPreview.fromJson(json['author']),
    content: json['content'],
    replies: (json['replies'] as List? ?? [])
        .map((r) => Reply.fromJson(r))
        .toList(),
    attachments: (json['attachments'] as List? ?? [])
        .map((a) => Attachment.fromJson(a))
        .toList(),
    viewers: (json['viewers'] as List? ?? [])
        .map((u) => UserPreview.fromJson(u))
        .toList(),
    reactions: (json['reactions'] as List? ?? [])
        .map((r) => Reaction.fromJson(r))
        .toList(),
    engagement: Engagement.fromJson(json['engagement']),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'content': content,
      'replies': replies.map((r) => r.toJson()).toList(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'viewers': viewers.map((v) => v.toJson()).toList(),
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'engagement': engagement.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get displayCreatedAt =>
      DateFormat('yyyy-MM-dd HH:mm').format(createdAt.toLocal());
}
