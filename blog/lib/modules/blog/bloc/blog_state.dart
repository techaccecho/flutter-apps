import 'package:blog/modules/blog/model/blog_post.dart';
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
  final List<BlogPost> posts;

  const BlogLoadedState(this.posts);
}

class BlogPostLoadedState extends BlogState {
  final BlogPost blogPost;

  const BlogPostLoadedState({required this.blogPost});

  @override
  List<Object?> get props => [blogPost];
}

class BlogErrorState extends BlogState {}