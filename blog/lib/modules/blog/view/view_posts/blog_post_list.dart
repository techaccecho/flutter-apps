import 'dart:async';
import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/modules/blog/view/view_posts/blog_create_new_button.dart';
import 'package:blog/modules/core/application.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_card.dart';
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostList extends StatefulWidget {
  const PostList({super.key});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;
  Timer? _debounce;
  bool _loadMoreRequested = false;

  @override
  void initState() {
    super.initState();
    final blogState = context.read<BlogBloc>().state;
    final initialQuery = blogState is BlogLoadedState ? (blogState.search ?? '') : '';
    _searchController = TextEditingController(text: initialQuery);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final blogState = context.read<BlogBloc>().state;
    if (blogState is BlogLoadedState) {
      _loadMoreIfNeeded(blogState);
    }
  }

  void _loadMoreIfNeeded(BlogLoadedState state) {
    if (!mounted ||
        !_scrollController.hasClients ||
        !state.hasMore ||
        state.isLoadingMore ||
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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 900), () {
      context.read<BlogBloc>().add(
        LoadBlogPostsEvent(search: query.trim().isEmpty ? null : query.trim()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final blogState = context.watch<BlogBloc>().state;
    final appState = context.watch<ApplicationBloc>().state;
    final currentUser = appState is ApplicationContentLoadedState
        ? appState.currentUser
        : context.read<ApplicationBloc>().currentUser;
    final isAdmin = currentUser?.role == Strings.roleAdmin;

    if (blogState is BlogLoadedState) {
      if (!blogState.isLoadingMore) {
        _loadMoreRequested = false;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadMoreIfNeeded(blogState));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        // Create new post button
        BlogCreateNewButton(),
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search blog posts by title, content, or author...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
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
          child: _buildContent(context, blogState, isAdmin, currentUser),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    BlogState blogState,
    bool isAdmin,
    dynamic currentUser,
  ) {
    if (blogState is BlogLoadingState) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (blogState is BlogErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(Strings.somethingWentWrong, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () {
                context.read<BlogBloc>().add(
                  LoadBlogPostsEvent(
                    search: _searchController.text.trim().isEmpty
                        ? null
                        : _searchController.text.trim(),
                  ),
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (blogState is BlogLoadedState) {
      final visiblePosts = blogState.posts.where((post) {
        bool isVisible = true;
        if (!isAdmin && (post.isDraft || post.isAdminRemoved)) {
          isVisible = post.author.id == currentUser?.id;
        }
        return isVisible;
      }).toList();

      if (visiblePosts.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'No posts found matching your search.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      final showFooter = blogState.hasMore || blogState.isLoadingMore || blogState.hasLoadMoreError;

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: visiblePosts.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= visiblePosts.length) {
            return _buildFooter(context, blogState);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: BlogPostCard(
              post: visiblePosts[index],
              onTap: () {
                context.read<BlogBloc>().add(
                  OpenBlogPostEvent(blogId: visiblePosts[index].id),
                );
              },
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFooter(BuildContext context, BlogLoadedState state) {
    if (state.isLoadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.hasLoadMoreError) {
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
