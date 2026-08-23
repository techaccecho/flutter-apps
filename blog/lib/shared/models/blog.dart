import 'package:blog/shared/models/comment.dart';
import 'package:blog/shared/models/attachment.dart';
import 'package:blog/shared/models/user_preview.dart';
import 'package:blog/shared/models/reaction.dart';
import 'package:blog/shared/models/engagement.dart';

class Blog {
  final String id;
  final UserPreview author;
  final String type;
  final String title;
  final String content;
  final int priority;
  final bool isDraft;
  final bool isPinned;
  final bool isLocked;
  final List<UserPreview> participants;
  final List<Comment> comments;
  final List<Attachment> attachments;
  final List<UserPreview> viewers;
  final List<Reaction> reactions;
  final Engagement engagement;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Blog({
    required this.id,
    required this.author,
    required this.type,
    required this.title,
    required this.content,
    required this.priority,
    required this.isDraft,
    required this.isPinned,
    required this.isLocked,
    required this.participants,
    required this.comments,
    required this.attachments,
    required this.viewers,
    required this.reactions,
    required this.engagement,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Blog.fromJson(Map<String, dynamic> json) => Blog(
    id: json['id'],
    author: UserPreview.fromJson(json['author']),
    type: json['type'],
    title: json['title'],
    content: json['content'],
    priority: json['priority'],
    isDraft: json['isDraft'],
    isPinned: json['isPinned'],
    isLocked: json['isLocked'],
    participants: (json['participants'] as List? ?? [])
        .map((p) => UserPreview.fromJson(p))
        .toList(),
    comments: (json['comments'] as List? ?? [])
        .map((c) => Comment.fromJson(c))
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
    deletedAt: json['deletedAt'] != null
        ? DateTime.parse(json['deletedAt'])
        : null,
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'type': type,
      'title': title,
      'content': content,
      'priority': priority,
      'isDraft': isDraft,
      'isPinned': isPinned,
      'isLocked': isLocked,
      'participants': participants.map((p) => p.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'viewers': viewers.map((v) => v.toJson()).toList(),
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'engagement': engagement.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
