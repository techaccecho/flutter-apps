import 'package:blog/shared/models/blog.dart';
import 'package:blog/shared/models/comment.dart';
import 'package:blog/shared/models/attachment.dart';
import 'package:blog/shared/models/user_preview.dart';
import 'package:blog/shared/models/reaction.dart';
import 'package:blog/shared/models/engagement.dart';
import 'package:blog/shared/models/author.dart';
import 'package:blog/modules/chat_forum/model/participant.dart';
import 'package:intl/intl.dart';

class Thread {
  final String id;
  final Author author;
  final String title;
  final String content;
  final int priority;
  final bool isDraft;
  final bool isPinned;
  final bool isLocked;
  final List<Participant> participants;
  final List<Comment> comments;
  final List<Attachment> attachments;
  final List<UserPreview> viewers;
  final List<Reaction> reactions;
  final Engagement engagement;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Thread({
    required this.id,
    required this.author,
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

  factory Thread.fromBlog(Blog blog) => Thread(
    id: blog.id,
    author: Author.fromUserPreview(blog.author),
    title: blog.title,
    content: blog.content,
    priority: blog.priority,
    isDraft: blog.isDraft,
    isPinned: blog.isPinned,
    isLocked: blog.isLocked,
    participants: blog.participants
        .map((p) => Participant.fromUserPreview(p))
        .toList(),
    comments: blog.comments,
    attachments: blog.attachments,
    viewers: blog.viewers,
    reactions: blog.reactions,
    engagement: blog.engagement,
    createdAt: blog.createdAt,
    updatedAt: blog.updatedAt,
    deletedAt: blog.deletedAt,
  );

  String get displayCreatedAt =>
      DateFormat('yyyy-MM-dd HH:mm').format(createdAt.toLocal());

  bool get isAdminRemoved => deletedAt != null;
}
