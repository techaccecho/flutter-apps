import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/shared/util/abstract_bloc/base_state.dart';
import 'package:blog/shared/models/author.dart';

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
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool hasLoadMoreError;
  final String? search;

  const BlogLoadedState(
    this.posts, {
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.hasLoadMoreError = false,
    this.search,
  });

  BlogLoadedState copyWith({
    List<BlogPost>? posts,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
    String? search,
  }) {
    return BlogLoadedState(
      posts ?? this.posts,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [
    posts,
    nextCursor,
    hasMore,
    isLoadingMore,
    hasLoadMoreError,
    search,
  ];
}

class BlogPostLoadedState extends BlogState {
  final BlogPost blogPost;

  const BlogPostLoadedState({required this.blogPost});

  @override
  List<Object?> get props => [blogPost];
}

class BlogPostCreateState extends BlogState {
  final Author? author;

  const BlogPostCreateState({required this.author});

  @override
  List<Object?> get props => [author];
}

class BlogPostEditState extends BlogState {
  final BlogPost? blogPost;
  final BlogPost? latestPost;

  const BlogPostEditState({required this.blogPost, this.latestPost});

  @override
  List<Object?> get props => [blogPost, latestPost];
}

class BlogErrorState extends BlogState {}
