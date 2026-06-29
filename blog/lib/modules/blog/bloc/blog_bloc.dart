import 'dart:async';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/shared/util/abstract_bloc/base_bloc.dart';
import 'package:blog/shared/util/abstract_bloc/base_emitter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_post_repository.dart';
import 'package:blog/modules/blog/model/create_blog_post.dart';

class BlogBloc extends AbstractBloc<BlogEvent, BlogState> {
  final BlogPostRepository _repository;

  BlogBloc({
    required BlogPostRepository repository
  })  : _repository = repository,
        super(BlogLoadingState()) {
    on<LoadBlogPostsEvent>(_loadBlogPosts);
    on<OpenBlogPostEvent>(_openBlogPost);
    on<CreateNewBlogPostEvent>(_createNewBlogPost);
    on<SaveNewBlogPostEvent>(_saveNewBlogPost);
  }

  Future<void> _loadBlogPosts(
      LoadBlogPostsEvent event, Emitter<BlogState> emit) async {
    emit.logCall(BlogLoadedState((await _repository.getPosts(cursor: null)).posts));
  }

  Future<void> _openBlogPost(
      OpenBlogPostEvent event, Emitter<BlogState> emit) async {
    emit.logCall(BlogPostLoadedState(blogPost: await _repository.getPost(event.blogId)));
  }

  Future<void> _createNewBlogPost(
      CreateNewBlogPostEvent event, Emitter<BlogState> emit) async {
    
    emit.logCall(BlogPostCreateState(author: event.author));
  }

  Future<void> _saveNewBlogPost(
    SaveNewBlogPostEvent event,
    Emitter<BlogState> emit,
  ) async {
    final request = CreateBlogPost(
      authorId:  event.authorId,
      title: event.title,
      content: event.content,
      createdAt: event.publishDate,
    );

    await _repository.createPost(request);
    emit.logCall(BlogLoadedState((await _repository.getPosts(cursor: null)).posts));
  }
}
