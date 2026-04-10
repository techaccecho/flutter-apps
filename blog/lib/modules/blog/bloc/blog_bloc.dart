import 'dart:async';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_repository.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/shared/util/abstract_bloc/base_bloc.dart';
import 'package:blog/shared/util/abstract_bloc/base_emitter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogBloc extends AbstractBloc<BlogEvent, BlogState> {
  final BlogRepository _repository;
  late StreamSubscription<BlogEvent> _subscription;

  BlogBloc({
    required BlogRepository repository
  })  : _repository = repository,
        super(BlogLoadingState()) {
    on<LoadBlogPostsEvent>(_loadBlogPosts);
    on<OpenBlogPostEvent>(_openBlogPost);
    
    _subscription = _repository.data.listen(
      (event) => add(event),
    );
  }

  Future<void> _loadBlogPosts(
      LoadBlogPostsEvent event, Emitter<BlogState> emit) async {
    emit.logCall(BlogLoadedState(await _repository.getBlogPosts(event.fromCache)));
  }

  Future<void> _openBlogPost(
      OpenBlogPostEvent event, Emitter<BlogState> emit) async {
    emit.logCall(BlogPostLoadedState(blogPost: await _repository.getBlogPost(event.blogId)));
  }

  @override
  Future<void> close() async {
    _subscription.cancel();
    _repository.dispose();
    super.close();
  }
}
