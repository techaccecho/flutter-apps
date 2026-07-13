import 'package:blog/shared/util/abstract_bloc/base_event.dart';
import 'package:blog/shared/models/author.dart';

abstract class BlogEvent extends BaseEvent {
  const BlogEvent();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties;
}

class LoadBlogPostsEvent extends BlogEvent {
  final bool fromCache;
  final String? search;
  const LoadBlogPostsEvent({this.fromCache = false, this.search});

  @override
  List<Object?> get props => [fromCache, search];

  @override
  Map<String, dynamic> get properties => {
    if (search != null) 'search': search,
  };
}

class LoadMoreBlogPostsEvent extends BlogEvent {
  const LoadMoreBlogPostsEvent();

  @override
  Map<String, dynamic> get properties => {};
}

class OpenBlogPostEvent extends BlogEvent {
  final String blogId;
  const OpenBlogPostEvent({required this.blogId});

  @override
  List<Object?> get props => [blogId];

  @override
  Map<String, dynamic> get properties => {"blogId": blogId};
}

class CreateNewBlogPostEvent extends BlogEvent {
  final Author author;

  const CreateNewBlogPostEvent({required this.author});

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class EditBlogPostEvent extends BlogEvent {
  final String blogId;
  const EditBlogPostEvent({required this.blogId});

  @override
  List<Object?> get props => [blogId];

  @override
  Map<String, dynamic> get properties => {"blogId": blogId};
}

class SaveNewBlogPostEvent extends BlogEvent {
  final String authorId;
  final String title;
  final String content;
  final bool isDraft;
  final DateTime? publishDate;

  const SaveNewBlogPostEvent({
    required this.authorId,
    required this.title,
    required this.content,
    required this.isDraft,
    this.publishDate,
  });

  @override
  List<Object?> get props => [authorId, title, content, isDraft, publishDate];

  @override
  Map<String, dynamic> get properties => {
    'isDraft': isDraft,
    if (publishDate != null) 'publishDate': publishDate!.toIso8601String(),
  };
}

class UpdateBlogPostEvent extends BlogEvent {
  final String blogId;
  final String title;
  final String content;
  final bool isDraft;

  const UpdateBlogPostEvent({
    required this.blogId,
    required this.title,
    required this.content,
    required this.isDraft,
  });

  @override
  List<Object?> get props => [blogId, title, content, isDraft];

  @override
  Map<String, dynamic> get properties => {'blogId': blogId, 'isDraft': isDraft};
}

class DeleteBlogPostEvent extends BlogEvent {
  final String blogId;
  final String? reason;

  const DeleteBlogPostEvent({required this.blogId, this.reason});

  @override
  List<Object?> get props => [blogId, reason];

  @override
  Map<String, dynamic> get properties => {
    'blogId': blogId,
    if (reason != null) 'reason': reason,
  };
}

class SoftDeleteBlogPostEvent extends BlogEvent {
  final String blogId;
  final String reason;

  const SoftDeleteBlogPostEvent({
    required this.blogId,
    required this.reason,
  });

  @override
  List<Object?> get props => [blogId, reason];

  @override
  Map<String, dynamic> get properties => {
    'blogId': blogId,
    'reason': reason,
  };
}
