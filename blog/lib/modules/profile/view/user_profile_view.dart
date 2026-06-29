import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_post_repository.dart';
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_repository.dart';
import 'package:blog/modules/chat_forum/model/thread.dart';
import 'package:blog/modules/core/application.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/shared/models/user.dart';
import 'package:blog/shared/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UserProfileView extends StatefulWidget {
  final String? userId;

  const UserProfileView({super.key, this.userId});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _ActivityTimelineItem {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isPost;

  const _ActivityTimelineItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isPost,
  });

  factory _ActivityTimelineItem.fromPost(BlogPost post) {
    return _ActivityTimelineItem(
      id: post.id,
      title: post.title,
      content: post.content,
      createdAt: post.createdAt,
      isPost: true,
    );
  }

  factory _ActivityTimelineItem.fromThread(Thread thread) {
    return _ActivityTimelineItem(
      id: thread.id,
      title: thread.title,
      content: thread.content,
      createdAt: thread.createdAt,
      isPost: false,
    );
  }
}

class _UserProfileViewState extends State<UserProfileView> {
  static const int _activityPageSize = 10;
  static const int _maxActivityFetchBatches = 3;

  late Future<User?> _userFuture;
  final List<_ActivityTimelineItem> _activityItems = [];

  String? _postCursor;
  String? _threadCursor;
  bool _hasMorePosts = true;
  bool _hasMoreThreads = true;
  bool _isActivityInitialLoading = true;
  bool _isActivityLoadingMore = false;
  bool _hasActivityError = false;
  int _activityLoadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadInitialActivity();
  }

  @override
  void didUpdateWidget(UserProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadUser();
      _loadInitialActivity();
    }
  }

  void _loadUser() {
    final userId = widget.userId;
    if (userId == null) {
      _userFuture = Future.value(null);
      return;
    }

    final authRepository = context.read<AuthRepository>();

    _userFuture = authRepository
        .getArchivedUser(userId)
        .catchError((_) {
          return authRepository.getUser(userId);
        })
        .then<User?>((user) => user)
        .catchError((_) {
          return null;
        });
  }

  Future<void> _loadInitialActivity() async {
    final userId = widget.userId;
    final generation = ++_activityLoadGeneration;

    setState(() {
      _activityItems.clear();
      _postCursor = null;
      _threadCursor = null;
      _hasMorePosts = userId != null;
      _hasMoreThreads = userId != null;
      _isActivityInitialLoading = userId != null;
      _isActivityLoadingMore = false;
      _hasActivityError = false;
    });

    if (userId == null) {
      return;
    }

    await _loadMoreActivity(generation: generation);
  }

  Future<void> _loadMoreActivity({int? generation}) async {
    final userId = widget.userId;
    final requestGeneration = generation ?? _activityLoadGeneration;
    if (userId == null ||
        _isActivityLoadingMore ||
        (!_hasMorePosts && !_hasMoreThreads)) {
      return;
    }

    setState(() {
      _isActivityLoadingMore = true;
      _hasActivityError = false;
    });

    final blogRepository = context.read<BlogPostRepository>();
    final forumRepository = context.read<ChatForumRepository>();
    final newItems = <_ActivityTimelineItem>[];
    var postCursor = _postCursor;
    var threadCursor = _threadCursor;
    var hasMorePosts = _hasMorePosts;
    var hasMoreThreads = _hasMoreThreads;
    var postFailedThisRequest = false;
    var threadFailedThisRequest = false;
    var hadRequestError = false;
    var requestedAnyPage = false;

    for (
      var batch = 0;
      batch < _maxActivityFetchBatches &&
          newItems.isEmpty &&
          ((hasMorePosts && !postFailedThisRequest) ||
              (hasMoreThreads && !threadFailedThisRequest));
      batch++
    ) {
      if (hasMorePosts && !postFailedThisRequest) {
        requestedAnyPage = true;
        try {
          final response = await blogRepository.getPosts(
            cursor: postCursor,
            limit: _activityPageSize,
            sort: 'desc',
          );

          postCursor = response.nextCursor;
          hasMorePosts = response.hasMore;
          newItems.addAll(
            response.posts
                .where((post) => post.author.id == userId)
                .map(_ActivityTimelineItem.fromPost),
          );
        } catch (_) {
          hadRequestError = true;
          postFailedThisRequest = true;
        }
      }

      if (hasMoreThreads && !threadFailedThisRequest) {
        requestedAnyPage = true;
        try {
          final response = await forumRepository.getThreads(
            cursor: threadCursor,
            limit: _activityPageSize,
            sort: 'desc',
          );

          threadCursor = response.nextCursor;
          hasMoreThreads = response.hasMore;
          newItems.addAll(
            response.threads
                .where((thread) => thread.author.id == userId)
                .map(_ActivityTimelineItem.fromThread),
          );
        } catch (_) {
          hadRequestError = true;
          threadFailedThisRequest = true;
        }
      }
    }

    if (!mounted ||
        requestGeneration != _activityLoadGeneration ||
        widget.userId != userId) {
      return;
    }

    setState(() {
      _postCursor = postCursor;
      _threadCursor = threadCursor;
      _hasMorePosts = hasMorePosts;
      _hasMoreThreads = hasMoreThreads;
      _mergeActivityItems(newItems);
      _isActivityInitialLoading = false;
      _isActivityLoadingMore = false;
      _hasActivityError =
          hadRequestError && (!requestedAnyPage || newItems.isEmpty);
    });
  }

  void _mergeActivityItems(List<_ActivityTimelineItem> items) {
    final existingKeys = _activityItems
        .map((item) => '${item.isPost ? 'post' : 'thread'}:${item.id}')
        .toSet();

    for (final item in items) {
      final key = '${item.isPost ? 'post' : 'thread'}:${item.id}';
      if (existingKeys.add(key)) {
        _activityItems.add(item);
      }
    }

    _activityItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        if (user == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Could not load user profile. Please sign in to view profiles.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return _buildProfileContent(user);
      },
    );
  }

  Widget _buildProfileContent(User user) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (user.displayName.isNotEmpty)
                          ? user.displayName[0].toUpperCase()
                          : 'U',
                      style: AppTextStyles.h1.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(user.displayName, style: AppTextStyles.h1),
                            if (user.isLocked) ...[
                              const SizedBox(width: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  border: Border.all(
                                    color: Colors.red.shade400,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Archived Account',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Text(
                              '${user.firstName ?? ""} ${user.lastName ?? ""}',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(user.bio ?? '', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Metadata card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Last Active',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        dateFormat.format(user.lastActivityAt.toLocal()),
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(height: 32, width: 1, color: AppColors.border),
                  Column(
                    children: [
                      Text(
                        'Member Since',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        user.displayCreatedAt,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Activity timeline
            Text('Activity History', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),

            _buildActivityTimeline(dateFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTimeline(DateFormat dateFormat) {
    if (_isActivityInitialLoading && _activityItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasActivityError && _activityItems.isEmpty) {
      return _buildActivityMessage(
        message: 'Unable to load activity history.',
        actionLabel: 'Retry',
        onPressed: _loadInitialActivity,
      );
    }

    if (_activityItems.isEmpty && !_hasMoreActivity) {
      return _buildActivityMessage(
        message: 'No recent activity recorded for this user.',
      );
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _activityItems.length,
          itemBuilder: (context, index) {
            return _buildActivityTile(_activityItems[index], dateFormat);
          },
        ),
        if (_isActivityLoadingMore)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_hasActivityError || _hasMoreActivity)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: OutlinedButton(
                onPressed: _loadMoreActivity,
                child: Text(
                  _hasActivityError ? 'Retry' : 'Load older activity',
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool get _hasMoreActivity => _hasMorePosts || _hasMoreThreads;

  Widget _buildActivityMessage({
    required String message,
    String? actionLabel,
    VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
          if (actionLabel != null && onPressed != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityTile(_ActivityTimelineItem item, DateFormat dateFormat) {
    final sanitizedContent = item.content.replaceAll(
      RegExp(r'[#*_\-\`\n]'),
      ' ',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Icon(
          item.isPost ? Icons.book : Icons.forum,
          color: AppColors.primary,
          size: 32,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.isPost ? 'Published Blog Post' : 'Created Forum Thread',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateFormat.format(item.createdAt.toLocal()),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(item.title, style: AppTextStyles.h3),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            sanitizedContent.length > 120
                ? '${sanitizedContent.substring(0, 120)}...'
                : sanitizedContent,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body,
          ),
        ),
        onTap: () {
          if (item.isPost) {
            context.read<BlogBloc>().add(OpenBlogPostEvent(blogId: item.id));
            context.read<ApplicationBloc>().add(
              const ApplicationNavigateEvent(route: HomeViewState.blog),
            );
          } else {
            context.read<ChatForumBloc>().add(ChatLoadThreadEvent(item.id));
            context.read<ApplicationBloc>().add(
              const ApplicationNavigateEvent(route: HomeViewState.chatForum),
            );
          }
        },
      ),
    );
  }
}
