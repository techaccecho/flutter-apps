import 'dart:async';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/shared/util/abstract_bloc/base_bloc.dart';
import 'package:blog/shared/util/abstract_bloc/base_emitter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/blog/bloc/blog_post_repository.dart';
import 'package:blog/modules/blog/model/create_blog_post.dart';
import 'package:blog/modules/blog/model/update_blog_post.dart';
import 'package:blog/modules/blog/util/blog_content.dart';

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
    on<EditBlogPostEvent>(_editBlogPost);
    on<SaveNewBlogPostEvent>(_saveNewBlogPost);
    on<UpdateBlogPostEvent>(_updateBlogPost);
    on<DeleteBlogPostEvent>(_deleteBlogPost);
    on<SoftDeleteBlogPostEvent>(_softDeleteBlogPost);
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
        search: event.search,
      );

      emit.logCall(
        BlogLoadedState(
          response.posts,
          nextCursor: response.nextCursor,
          hasMore: response.hasMore,
          search: event.search,
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
        search: currentState.search,
      );

      emit.logCall(
        BlogLoadedState(
          [...currentState.posts, ...response.posts],
          nextCursor: response.nextCursor,
          hasMore: response.hasMore,
          search: currentState.search,
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
    try {
      emit.logCall(
        BlogPostLoadedState(blogPost: await _repository.getPost(event.blogId)),
      );
    } catch (_) {
      emit.logCall(BlogErrorState());
    }
  }

  Future<void> _createNewBlogPost(
    CreateNewBlogPostEvent event,
    Emitter<BlogState> emit,
  ) async {
    emit.logCall(BlogPostCreateState(author: event.author));
  }

  Future<void> _editBlogPost(
    EditBlogPostEvent event,
    Emitter<BlogState> emit,
  ) async {
    try {
      final blogPost = await _repository.getPost(event.blogId);
      final response = await _repository.getPosts(
        cursor: null,
        limit: _pageSize,
        sort: _sortDirection,
      );
      final latestPost = _latestPublishedPost(
        response.posts.where((post) => post.id != event.blogId),
      );

      emit.logCall(
        BlogPostEditState(blogPost: blogPost, latestPost: latestPost),
      );
    } catch (_) {
      emit.logCall(BlogErrorState());
    }
  }

  Future<void> _saveNewBlogPost(
    SaveNewBlogPostEvent event,
    Emitter<BlogState> emit,
  ) async {
    final request = CreateBlogPost(
      authorId: event.authorId,
      title: event.title,
      content: sanitizeBlogContent(event.content),
      isDraft: event.isDraft,
      createdAt: event.publishDate,
    );

    try {
      await _repository.createPost(request);
      await _reloadFirstPage(emit);
    } catch (_) {
      emit.logCall(BlogErrorState());
    }
  }

  Future<void> _updateBlogPost(
    UpdateBlogPostEvent event,
    Emitter<BlogState> emit,
  ) async {
    try {
      await _repository.updatePost(
        id: event.blogId,
        update: UpdateBlogPost(
          title: event.title,
          content: sanitizeBlogContent(event.content),
          isDraft: event.isDraft,
        ),
      );
      await _reloadFirstPage(emit);
    } catch (_) {
      emit.logCall(BlogErrorState());
    }
  }

  Future<void> _deleteBlogPost(
    DeleteBlogPostEvent event,
    Emitter<BlogState> emit,
  ) async {
    try {
      await _repository.deletePost(event.blogId, reason: event.reason);
      await _reloadFirstPage(emit);
    } catch (_) {
      emit.logCall(BlogErrorState());
    }
  }

  Future<void> _reloadFirstPage(Emitter<BlogState> emit) async {
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

  Future<void> _softDeleteBlogPost(
    SoftDeleteBlogPostEvent event,
    Emitter<BlogState> emit,
  ) async {
    try {
      await _repository.softDeletePost(
        id: event.blogId,
        reason: event.reason,
      );
      await _reloadFirstPage(emit);
    } catch (_) {
      emit.logCall(BlogErrorState());
    }
  }

  BlogPost? _latestPublishedPost(Iterable<BlogPost> posts) {
    BlogPost? latestPost;

    for (final post in posts) {
      if (post.isDraft) {
        continue;
      }

      if (latestPost == null || post.createdAt.isAfter(latestPost.createdAt)) {
        latestPost = post;
      }
    }

    return latestPost;
  }
}
