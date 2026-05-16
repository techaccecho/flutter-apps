import 'package:blog/modules/blog/model/author.dart';
import 'package:blog/modules/blog/model/comment.dart';
import 'package:blog/modules/blog/model/media.dart';
import 'package:blog/modules/blog/model/reaction.dart';
import 'package:blog/modules/blog/model/stats.dart';

class Post {
  final Author author;
  final String? category;
  final List<Comment> comments;
  final String content;
  final double createdAt;
  final String id;
  final bool isDraft;
  final bool isLocked;
  final bool isPinned;
  final double? lastActivityAt;
  final List<Media> media;
  final double priority;
  final List<Reaction> reactions;
  final Stats stats;
  final String title;
  final String type; // "blog" | "thread"
  final double? updatedAt;

  Post({
    required this.author,
    this.category,
    required this.comments,
    required this.content,
    required this.createdAt,
    required this.id,
    required this.isDraft,
    required this.isLocked,
    required this.isPinned,
    this.lastActivityAt,
    required this.media,
    required this.priority,
    required this.reactions,
    required this.stats,
    required this.title,
    required this.type,
    this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        author: Author.fromJson(json['author']),
        category: json['category'],
        comments: (json['comments'] as List)
            .map((e) => Comment.fromJson(e))
            .toList(),
        content: json['content'],
        createdAt: (json['createdAt'] as num).toDouble(),
        id: json['id'],
        isDraft: json['isDraft'],
        isLocked: json['isLocked'],
        isPinned: json['isPinned'],
        lastActivityAt: json['lastActivityAt'] != null
            ? (json['lastActivityAt'] as num).toDouble()
            : null,
        media: (json['media'] as List)
            .map((e) => Media.fromJson(e))
            .toList(),
        priority: (json['priority'] as num).toDouble(),
        reactions: (json['reactions'] as List)
            .map((e) => Reaction.fromJson(e))
            .toList(),
        stats: Stats.fromJson(json['stats']),
        title: json['title'],
        type: json['type'],
        updatedAt: json['updatedAt'] != null
            ? (json['updatedAt'] as num).toDouble()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'author': author.toJson(),
        'category': category,
        'comments': comments.map((e) => e.toJson()).toList(),
        'content': content,
        'createdAt': createdAt,
        'id': id,
        'isDraft': isDraft,
        'isLocked': isLocked,
        'isPinned': isPinned,
        'lastActivityAt': lastActivityAt,
        'media': media.map((e) => e.toJson()).toList(),
        'priority': priority,
        'reactions': reactions.map((e) => e.toJson()).toList(),
        'stats': stats.toJson(),
        'title': title,
        'type': type,
        'updatedAt': updatedAt,
      };
}