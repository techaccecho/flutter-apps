import 'package:blog/modules/blog/model/author.dart';
import 'package:blog/modules/blog/model/media.dart';
import 'package:blog/modules/blog/model/parent_comment.dart';
import 'package:blog/modules/blog/model/stats.dart';

class Comment {
  final Author author;
  final String content;
  final double createdAt;
  final String id;
  final List<Media> media;
  final ParentComment? parent;
  final Stats stats;
  final double? updatedAt;

  Comment({
    required this.author,
    required this.content,
    required this.createdAt,
    required this.id,
    required this.media,
    this.parent,
    required this.stats,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        author: Author.fromJson(json['author']),
        content: json['content'],
        createdAt: (json['createdAt'] as num).toDouble(),
        id: json['id'],
        media: (json['media'] as List)
            .map((e) => Media.fromJson(e))
            .toList(),
        parent: json['parent'] != null
            ? ParentComment.fromJson(json['parent'])
            : null,
        stats: Stats.fromJson(json['stats']),
        updatedAt: json['updatedAt'] != null
            ? (json['updatedAt'] as num).toDouble()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'author': author.toJson(),
        'content': content,
        'createdAt': createdAt,
        'id': id,
        'media': media.map((e) => e.toJson()).toList(),
        'parent': parent?.toJson(),
        'stats': stats.toJson(),
        'updatedAt': updatedAt,
      };
}