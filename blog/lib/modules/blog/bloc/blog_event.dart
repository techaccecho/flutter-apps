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
  const LoadBlogPostsEvent({this.fromCache = false});

  @override
  List<Object?> get props => [fromCache];

  @override
  Map<String, dynamic> get properties => {};
}

class OpenBlogPostEvent extends BlogEvent {

  final String blogId;
  const OpenBlogPostEvent({required this.blogId});

  @override
  List<Object?> get props => [blogId];

  @override
  Map<String, dynamic> get properties => {
    "blogId": blogId
  };
}

class CreateNewBlogPostEvent extends BlogEvent {
  final Author author;

  const CreateNewBlogPostEvent({ required this.author });

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
  Map<String, dynamic> get properties => {
    "blogId": blogId
  };
}

class SaveNewBlogPostEvent extends BlogEvent {
  final String authorId;
  final String title;
  final String content;
  final DateTime? publishDate;

  const SaveNewBlogPostEvent({
    required this.authorId,
    required this.title,
    required this.content,
    this.publishDate,
  });

  @override
  List<Object?> get props => [publishDate];

  @override
  Map<String, dynamic> get properties => {
    if (publishDate != null) 'publishDate': publishDate!.toIso8601String(),
  };
}
