import 'package:blog/shared/util/abstract_bloc/base_event.dart';

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

  const CreateNewBlogPostEvent();

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