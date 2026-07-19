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
    final currentUser = context.read<ApplicationBloc>().currentUser;

    if (currentUser != null && currentUser.id == userId) {
      _userFuture = authRepository
          .getUser(userId)
          .then<User?>((user) => user)
          .catchError((_) => null);
      return;
    }

    _userFuture = authRepository
        .getUser(userId)
        .catchError((_) {
          return authRepository.getArchivedUser(userId);
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
            authorId: userId,
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
            authorId: userId,
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
    final appBloc = context.read<ApplicationBloc>();
    final isOwnProfile = appBloc.currentUser?.id == user.id;

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
                            if (isOwnProfile) ...[
                              const SizedBox(width: AppSpacing.md),
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
                                tooltip: 'Edit Profile',
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                onPressed: () => _showEditProfileDialog(context, user),
                              ),
                            ],
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
                        if ((user.firstName?.isNotEmpty ?? false) || 
                            (user.lastName?.isNotEmpty ?? false) || 
                            (user.dateOfBirth?.isNotEmpty ?? false)) ...[
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              if ((user.firstName?.isNotEmpty ?? false) || (user.lastName?.isNotEmpty ?? false))
                                Text(
                                  '${user.firstName ?? ""} ${user.lastName ?? ""}'.trim(),
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) ...[
                                if ((user.firstName?.isNotEmpty ?? false) || (user.lastName?.isNotEmpty ?? false))
                                  Text(
                                    ' • ',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                const Icon(
                                  Icons.cake,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  user.dateOfBirth!,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
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
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
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
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, User user) async {
    final updatedUser = await showDialog<User>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _EditProfileDialog(
          user: user,
          applicationBloc: context.read<ApplicationBloc>(),
        );
      },
    );

    if (updatedUser != null && mounted) {
      setState(() {
        _userFuture = Future.value(updatedUser);
      });
    }
  }
}

class _EditProfileDialog extends StatefulWidget {
  final User user;
  final ApplicationBloc applicationBloc;

  const _EditProfileDialog({
    required this.user,
    required this.applicationBloc,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _aliasController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _dobController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController(text: widget.user.alias);
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _bioController = TextEditingController(text: widget.user.bio);
    _dobController = TextEditingController(text: widget.user.dateOfBirth);
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = context.read<AuthRepository>();
      final updatedUser = await authRepo.updateUser(
        widget.user.id,
        alias: _aliasController.text.trim().isEmpty ? null : _aliasController.text.trim(),
        firstName: _firstNameController.text.trim().isEmpty ? null : _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        dateOfBirth: _dobController.text.trim().isEmpty ? null : _dobController.text.trim(),
      );

      widget.applicationBloc.add(ApplicationUpdateUserEvent(updatedUser));

      if (mounted) {
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: const Text('Edit Profile'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: AppColors.danger),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                TextFormField(
                  controller: _aliasController,
                  decoration: const InputDecoration(
                    labelText: 'Alias / Display Name',
                    border: OutlineInputBorder(),
                    hintText: 'Enter screen name',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alias / Display Name is required';
                    }
                    final trimmed = value.trim();
                    if (trimmed.length < 3 || trimmed.length > 20) {
                      return 'Must be between 3 and 20 characters';
                    }
                    final aliasRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
                    if (!aliasRegex.hasMatch(trimmed)) {
                      return 'Can only contain letters, numbers, underscores, and hyphens';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(_dobController.text) ??
                          DateTime.now().subtract(const Duration(days: 6574)),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      final String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                      _dobController.text = formattedDate;
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                    hintText: 'Tell us about yourself...',
                  ),
                  maxLines: 3,
                  maxLength: 160,
                  validator: (value) {
                    if (value != null && value.length > 160) {
                      return 'Bio must be 160 characters or less';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
