import 'dart:async';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/shared/util/abstract_bloc/base_bloc.dart';
import 'package:blog/shared/util/abstract_bloc/base_emitter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_post_repository.dart';
import 'package:blog/modules/blog/model/create_blog_post.dart';

class BlogBloc extends AbstractBloc<BlogEvent, BlogState> {
  static const int _pageSize = 10;
  static const String _sortDirection = 'desc';

  final BlogPostRepository _repository;

  BlogBloc({required BlogPostRepository repository})
    : _repository = repository,
      super(BlogLoadingState()) {
    on<LoadBlogPostsEvent>(_loadBlogPosts);
    on<LoadMoreBlogPostsEvent>(_loadMoreBlogPosts);
    on<OpenBlogPostEvent>(_openBlogPost);
    on<CreateNewBlogPostEvent>(_createNewBlogPost);
    on<SaveNewBlogPostEvent>(_saveNewBlogPost);
  }

  Future<void> _loadBlogPosts(
    LoadBlogPostsEvent event,
    Emitter<BlogState> emit,
  ) async {
    try {
      final response = await _repository.getPosts(
        cursor: null,
        limit: _pageSize,
        sort: _sortDirection,
      );

      emit.logCall(
        BlogLoadedState(
          response.posts,
          nextCursor: response.nextCursor,
          hasMore: response.hasMore,
        ),
      );
    } catch (_) {
      emit.logCall(BlogErrorState());
    }
  }

  Future<void> _loadMoreBlogPosts(
    LoadMoreBlogPostsEvent event,
    Emitter<BlogState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BlogLoadedState ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    emit.logCall(
      currentState.copyWith(isLoadingMore: true, hasLoadMoreError: false),
    );

    try {
      final response = await _repository.getPosts(
        cursor: currentState.nextCursor,
        limit: _pageSize,
        sort: _sortDirection,
      );

      emit.logCall(
        BlogLoadedState(
          [...currentState.posts, ...response.posts],
          nextCursor: response.nextCursor,
          hasMore: response.hasMore,
        ),
      );
    } catch (_) {
      emit.logCall(
        currentState.copyWith(isLoadingMore: false, hasLoadMoreError: true),
      );
    }
  }

  Future<void> _openBlogPost(
    OpenBlogPostEvent event,
    Emitter<BlogState> emit,
  ) async {
    emit.logCall(
      BlogPostLoadedState(blogPost: await _repository.getPost(event.blogId)),
    );
  }

  Future<void> _createNewBlogPost(
    CreateNewBlogPostEvent event,
    Emitter<BlogState> emit,
  ) async {
    emit.logCall(BlogPostCreateState(author: event.author));
  }

  Future<void> _saveNewBlogPost(
    SaveNewBlogPostEvent event,
    Emitter<BlogState> emit,
  ) async {
    final request = CreateBlogPost(
      authorId: event.authorId,
      title: event.title,
      content: event.content,
      createdAt: event.publishDate,
    );

    await _repository.createPost(request);
    final response = await _repository.getPosts(
      cursor: null,
      limit: _pageSize,
      sort: _sortDirection,
    );
    emit.logCall(
      BlogLoadedState(
        response.posts,
        nextCursor: response.nextCursor,
        hasMore: response.hasMore,
      ),
    );
  }
}
