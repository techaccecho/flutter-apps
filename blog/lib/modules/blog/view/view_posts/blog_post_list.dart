import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/view/view_posts/blog_create_new_button.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_card.dart';
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostList extends StatefulWidget {
  final List<BlogPost> posts;
  final bool hasMore;
  final bool isLoadingMore;
  final bool hasLoadMoreError;

  const PostList({
    super.key,
    required this.posts,
    required this.hasMore,
    required this.isLoadingMore,
    required this.hasLoadMoreError,
  });

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final ScrollController _scrollController = ScrollController();
  bool _loadMoreRequested = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMoreIfNeeded());
  }

  @override
  void didUpdateWidget(covariant PostList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoadingMore && !widget.isLoadingMore) {
      _loadMoreRequested = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMoreIfNeeded());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    _loadMoreIfNeeded();
  }

  void _loadMoreIfNeeded() {
    if (!mounted ||
        !_scrollController.hasClients ||
        !widget.hasMore ||
        widget.isLoadingMore ||
        _loadMoreRequested) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _requestLoadMore();
    }
  }

  void _requestLoadMore() {
    _loadMoreRequested = true;
    context.read<BlogBloc>().add(const LoadMoreBlogPostsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        // Create new post button
        BlogCreateNewButton(),
        // Latest posts
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          alignment: Alignment.centerLeft,
          child: Text(Strings.blogPostLatest, style: AppTextStyles.h2),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: widget.posts.length + (_showFooter ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= widget.posts.length) {
                return _buildFooter(context);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: BlogPostCard(
                  post: widget.posts[index],
                  onTap: () {
                    context.read<BlogBloc>().add(
                      OpenBlogPostEvent(blogId: widget.posts[index].id),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool get _showFooter =>
      widget.hasMore || widget.isLoadingMore || widget.hasLoadMoreError;

  Widget _buildFooter(BuildContext context) {
    if (widget.isLoadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.hasLoadMoreError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: OutlinedButton(
            onPressed: _requestLoadMore,
            child: const Text('Retry'),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
