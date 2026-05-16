import 'package:blog/modules/blog/model/post.dart';
import 'package:blog/shared/util/abstract_bloc/base_state.dart';

abstract class BlogState extends BaseState {
  const BlogState();

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> get properties => {};
}

class BlogInitialState extends BlogState {}

class BlogLoadingState extends BlogState {}

class BlogLoadedState extends BlogState {
  final List<Post> posts;

  const BlogLoadedState(this.posts);
}

class BlogPostLoadedState extends BlogState {
  final Post blogPost;

  const BlogPostLoadedState({required this.blogPost});

  @override
  List<Object?> get props => [blogPost];
}

class BlogPostCreateState extends BlogState {
  final String author;

  const BlogPostCreateState({required this.author});

  @override
  List<Object?> get props => [author];
}

class BlogPostEditState extends BlogState {
  final Post? blogPost;

  const BlogPostEditState({required this.blogPost});

  @override
  List<Object?> get props => [blogPost];
}

class BlogErrorState extends BlogState {}