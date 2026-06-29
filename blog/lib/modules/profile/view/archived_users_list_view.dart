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
  static const int _pageSize = 10;

  final ScrollController _scrollController = ScrollController();
  final List<User> _users = [];

  String? _nextCursor;
  bool _hasMore = false;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialUsers();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !_hasMore || _isLoadingMore) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _loadMoreUsers();
    }
  }

  Future<void> _loadInitialUsers() async {
    setState(() {
      _isInitialLoading = true;
      _hasError = false;
      _users.clear();
      _nextCursor = null;
      _hasMore = false;
    });

    try {
      final response = await context
          .read<AuthRepository>()
          .getArchivedUsersPage(limit: _pageSize);

      if (!mounted) {
        return;
      }

      setState(() {
        _users.addAll(response.users);
        _nextCursor = response.nextCursor;
        _hasMore = response.hasMore;
        _isInitialLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasError = true;
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMoreUsers() async {
    if (!_hasMore || _isLoadingMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _hasError = false;
    });

    try {
      final response = await context
          .read<AuthRepository>()
          .getArchivedUsersPage(limit: _pageSize, cursor: _nextCursor);

      if (!mounted) {
        return;
      }

      setState(() {
        _users.addAll(response.users);
        _nextCursor = response.nextCursor;
        _hasMore = response.hasMore;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasError = true;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadInitialUsers,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: _itemCount,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildHeader();
            }

            if (_isInitialLoading && index == 1) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (_hasError && _users.isEmpty && index == 1) {
              return _buildErrorState();
            }

            if (!_isInitialLoading && _users.isEmpty && index == 1) {
              return _buildEmptyState();
            }

            final userIndex = index - 1;
            if (userIndex < _users.length) {
              return _buildUserTile(_users[userIndex], dateFormat);
            }

            return _buildFooter();
          },
        ),
      ),
    );
  }

  int get _itemCount {
    if (_isInitialLoading || _users.isEmpty) {
      return 2;
    }

    if (_isLoadingMore || _hasError) {
      return _users.length + 2;
    }

    return _users.length + 1;
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Archived Profiles', style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Select an archived account below to view their historical timeline, activity logs, and system publications.',
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'No archived users found.',
        style: AppTextStyles.body,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          const Text(
            'Unable to load archived users.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: _loadInitialUsers,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    if (_isLoadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: OutlinedButton(
          onPressed: _loadMoreUsers,
          child: const Text('Retry'),
        ),
      ),
    );
  }

  Widget _buildUserTile(User user, DateFormat dateFormat) {
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
            Expanded(
              child: Text(
                user.displayName,
                style: AppTextStyles.h2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
            Text(
              'Last Active: ${dateFormat.format(user.lastActivityAt.toLocal())}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        onTap: () {
          context.read<ApplicationBloc>().add(
            ApplicationNavigateEvent(
              route: HomeViewState.profile,
              userId: user.id,
            ),
          );
        },
      ),
    );
  }
}
