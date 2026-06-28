import 'package:blog/modules/core/application.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/shared/models/user.dart';
import 'package:blog/shared/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ArchivedUsersListView extends StatefulWidget {
  const ArchivedUsersListView({super.key});

  @override
  State<ArchivedUsersListView> createState() => _ArchivedUsersListViewState();
}

class _ArchivedUsersListViewState extends State<ArchivedUsersListView> {
  late Future<List<User>> _usersFuture;

  // Fallback archived users
  final List<User> _mockArchivedUsers = [
    User(
      id: 'fd5aaa3c-4c64-4d42-accd-2eab61fbdc67',
      authId: 'auth|cedric',
      email: 'cedric@echo.dev',
      alias: 'cedric_dev',
      firstName: 'Cedric',
      lastName: 'Developer',
      bio: 'Lead researcher and developer. Documenting Echo and testing forgotten system components.',
      role: 'user',
      isLocked: true,
      createdAt: DateTime.parse('2026-04-01T00:00:00.000Z'),
      lastActivityAt: DateTime.parse('2026-06-23T04:31:02.000Z'),
    ),
    User(
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
    ),
    User(
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
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    _usersFuture = context
        .read<AuthRepository>()
        .getArchivedUsers()
        .then((users) {
          if (users.isEmpty) {
            return _mockArchivedUsers;
          }
          return users;
        })
        .catchError((_) {
          // Fallback to offline mock list on unauthorized or failure
          return _mockArchivedUsers;
        });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Archived System Logs & Profiles',
              style: AppTextStyles.h1,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Select an archived account below to view their historical timeline, activity logs, and system publications.',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final users = snapshot.data ?? _mockArchivedUsers;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : 'U',
                            style: AppTextStyles.h2.copyWith(color: Colors.white),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(user.displayName, style: AppTextStyles.h2),
                            const SizedBox(width: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Archived',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              user.bio ?? 'No biography details preserved.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Text(
                                  'Role: ${user.role.toUpperCase()}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Text(
                                  'Last Active: ${dateFormat.format(user.lastActivityAt.toLocal())}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigate to the user's profile view (linking to Profile navigation)
                          context.read<ApplicationBloc>().add(
                                ApplicationNavigateEvent(
                                  route: HomeViewState.profile,
                                  userId: user.id,
                                ),
                              );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
