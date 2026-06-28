import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_state.dart';
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

class _UserProfileViewState extends State<UserProfileView> {
  late Future<User?> _userFuture;

  // Fallback user for Cedric
  final User _fallbackCedric = User(
    id: 'fd5aaa3c-4c64-4d42-accd-2eab61fbdc67',
    authId: 'auth|cedric',
    email: 'cedric@echo.dev',
    alias: 'cedric_dev',
    firstName: 'Cedric',
    lastName: 'Developer',
    bio: 'Lead researcher and developer. Documenting Echo and testing forgotten system components.',
    role: 'user',
    isLocked: true, // Archived
    createdAt: DateTime.parse('2026-04-01T00:00:00.000Z'),
    lastActivityAt: DateTime.parse('2026-06-23T04:31:02.000Z'),
  );

  final User _fallbackCedric2 = User(
    id: '7a00be8d-8c06-4355-9219-2dde3a6b6cf2',
    authId: 'auth|cedric2',
    email: 'billohuegen@gmail.com',
    alias: 'cedric_dev',
    firstName: 'Cedric',
    lastName: 'Developer',
    bio: 'Lead researcher and developer. Documenting Echo and testing forgotten system components.',
    role: 'user',
    isLocked: true, // Archived
    createdAt: DateTime.parse('2026-04-01T00:00:00.000Z'),
    lastActivityAt: DateTime.parse('2026-06-23T04:31:02.000Z'),
  );

  final User _fallbackMarcus = User(
    id: 'marcus-archived-id',
    authId: 'auth|marcus',
    email: 'marcus@echo.dev',
    alias: 'marcus_dev',
    firstName: 'Marcus',
    lastName: 'Engineer',
    bio: 'Former systems engineer. Researching Echo protocols and early server architectures.',
    role: 'user',
    isLocked: true,
    createdAt: DateTime.parse('2026-03-15T00:00:00.000Z'),
    lastActivityAt: DateTime.parse('2026-05-20T10:15:30.000Z'),
  );

  final User _fallbackElena = User(
    id: 'elena-archived-id',
    authId: 'auth|elena',
    email: 'elena@echo.dev',
    alias: 'elena_ops',
    firstName: 'Elena',
    lastName: 'Ops',
    bio: 'DevOps lead. Documenting early site infrastructure and database migrations.',
    role: 'admin',
    isLocked: true,
    createdAt: DateTime.parse('2026-02-10T00:00:00.000Z'),
    lastActivityAt: DateTime.parse('2026-06-01T15:45:00.000Z'),
  );

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void didUpdateWidget(UserProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadUser();
    }
  }

  void _loadUser() {
    final userId = widget.userId;
    if (userId == null) {
      _userFuture = Future.value(null);
      return;
    }

    final authRepository = context.read<AuthRepository>();

    // Try fetching from public archived endpoint first, then fallback to standard authenticated endpoint
    _userFuture = authRepository
        .getArchivedUser(userId)
        .catchError((_) {
          return authRepository.getUser(userId);
        })
        .then<User?>((user) => user)
        .catchError((e) {
          // Fallback to local mock profiles if both endpoints fail
          if (userId == _fallbackCedric.id) {
            return _fallbackCedric;
          }
          if (userId == _fallbackCedric2.id) {
            return _fallbackCedric2;
          }
          if (userId == _fallbackMarcus.id) {
            return _fallbackMarcus;
          }
          if (userId == _fallbackElena.id) {
            return _fallbackElena;
          }
          return null;
        });
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
          final userId = widget.userId;
          if (userId == _fallbackCedric.id) {
            return _buildProfileContent(_fallbackCedric);
          }
          if (userId == _fallbackCedric2.id) {
            return _buildProfileContent(_fallbackCedric2);
          }
          if (userId == _fallbackMarcus.id) {
            return _buildProfileContent(_fallbackMarcus);
          }
          if (userId == _fallbackElena.id) {
            return _buildProfileContent(_fallbackElena);
          }

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
    // Collect user timeline items
    final List<dynamic> timelineItems = [];

    final blogState = context.read<BlogBloc>().state;
    if (blogState is BlogLoadedState) {
      timelineItems.addAll(blogState.posts.where((p) => p.author.id == user.id));
    }

    final forumState = context.read<ChatForumBloc>().state;
    if (forumState is ChatForumContentLoadedState) {
      timelineItems.addAll(forumState.chat.threads.where((t) => t.author.id == user.id));
    }

    // Sort chronologically (latest first)
    timelineItems.sort((a, b) {
      final dateA = a is BlogPost ? a.createdAt : (a as Thread).createdAt;
      final dateB = b is BlogPost ? b.createdAt : (b as Thread).createdAt;
      return dateB.compareTo(dateA);
    });

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
                      (user.displayName.isNotEmpty) ? user.displayName[0].toUpperCase() : 'U',
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
                            Text(
                              user.displayName,
                              style: AppTextStyles.h1,
                            ),
                            if (user.isLocked) ...[
                              const SizedBox(width: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  border: Border.all(color: Colors.red.shade400),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Archived (Read-Only)',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Role: ${user.role.toUpperCase()}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          user.bio ?? 'No biography provided.',
                          style: AppTextStyles.body,
                        ),
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
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        dateFormat.format(user.lastActivityAt.toLocal()),
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    height: 32,
                    width: 1,
                    color: AppColors.border,
                  ),
                  Column(
                    children: [
                      Text(
                        'Member Since',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        user.displayCreatedAt,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Activity timeline
            Text(
              'Activity History',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.md),

            if (timelineItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'No recent activity recorded for this user.',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: timelineItems.length,
                itemBuilder: (context, index) {
                  final item = timelineItems[index];
                  final isPost = item is BlogPost;

                  final String title = isPost ? item.title : item.title;
                  final String content = isPost ? item.content : item.content;
                  final DateTime date = isPost ? item.createdAt : item.createdAt;

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
                        isPost ? Icons.book : Icons.forum,
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
                                isPost ? 'Published Blog Post' : 'Created Forum Thread',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                dateFormat.format(date.toLocal()),
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            title,
                            style: AppTextStyles.h3,
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          content.length > 120
                              ? '${content.substring(0, 120).replaceAll(RegExp(r'[#*_\-\`\n]'), ' ')}...'
                              : content.replaceAll(RegExp(r'[#*_\-\`\n]'), ' '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body,
                        ),
                      ),
                      onTap: () {
                        if (isPost) {
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
                },
              ),
          ],
        ),
      ),
    );
  }
}
