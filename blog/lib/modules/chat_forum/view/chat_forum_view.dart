import 'dart:async';
import 'package:blog/modules/chat_forum/view/chat_comment.dart';
import 'package:blog/modules/chat_forum/view/chat_reply_box.dart';
import 'package:blog/modules/chat_forum/view/chat_thread_header.dart';
import 'package:blog/modules/core/application.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_state.dart';
import 'package:blog/modules/chat_forum/model/thread.dart';
import 'package:blog/modules/chat_forum/view/forum_item.dart';
import 'package:blog/shared/models/author.dart';

class ChatForumView extends StatefulWidget {
  const ChatForumView({super.key});

  @override
  State<ChatForumView> createState() => _ChatForumViewState();
}

class _ChatForumViewState extends State<ChatForumView> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final forumState = context.read<ChatForumBloc>().state;
    final initialQuery = forumState is ChatForumContentLoadedState ? (forumState.search ?? '') : '';
    _searchController = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 900), () {
      context.read<ChatForumBloc>().add(
        ChatForumLoadEvent(search: query.trim().isEmpty ? null : query.trim()),
      );
    });
  }

  Future<void> _showCreateThreadDialog(BuildContext context, Author author) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('New Thread'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 6,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final content = contentController.text.trim();

              if (title.isEmpty || content.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Title and message cannot be empty'),
                  ),
                );
                return;
              }

              context.read<ChatForumBloc>().add(
                ChatCreateThreadEvent(
                  authorId: author.id,
                  title: title,
                  content: content,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 500), () {
        titleController.dispose();
        contentController.dispose();
      });
    });
  }

  Future<void> _showEditThreadDialog(BuildContext context, Thread thread) {
    final titleController = TextEditingController(text: thread.title);
    final contentController = TextEditingController(text: thread.content);

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('Edit Thread'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 6,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final content = contentController.text.trim();

              if (title.isEmpty || content.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Title and message cannot be empty'),
                  ),
                );
                return;
              }

              context.read<ChatForumBloc>().add(
                ChatUpdateThreadEvent(
                  threadId: thread.id,
                  title: title,
                  content: content,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 500), () {
        titleController.dispose();
        contentController.dispose();
      });
    });
  }

  Future<void> _confirmDeleteThread(BuildContext context, Thread thread) async {
    final shouldDelete = await _confirmAction(
      context,
      title: 'Delete thread?',
      message: 'This action cannot be undone.',
    );

    if (!shouldDelete || !context.mounted) {
      return;
    }

    context.read<ChatForumBloc>().add(
      ChatDeleteThreadEvent(threadId: thread.id),
    );
  }

  Future<void> _confirmHardDeleteThread(
    BuildContext context,
    Thread thread,
  ) async {
    final reason = await _confirmReasonedAction(
      context,
      title: 'Delete thread?',
      message:
          'This permanently deletes the thread and related data. This action cannot be undone.',
    );

    if (reason == null || !context.mounted) {
      return;
    }

    context.read<ChatForumBloc>().add(
      ChatDeleteThreadEvent(threadId: thread.id, reason: reason),
    );
  }

  Future<void> _confirmSoftDeleteThread(
    BuildContext context,
    Thread thread,
  ) async {
    final reason = await _confirmReasonedAction(
      context,
      title: 'Remove thread?',
      message:
          'This hides the thread from other users and makes it read-only for the owner.',
    );

    if (reason == null || !context.mounted) {
      return;
    }

    context.read<ChatForumBloc>().add(
      ChatSoftDeleteThreadEvent(threadId: thread.id, reason: reason),
    );
  }

  Future<bool> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    return confirmed == true;
  }

  Future<String?> _confirmReasonedAction(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    const reasons = ['Broke site rules', 'Unsafe content', 'Spam or abuse'];
    var selectedReason = reasons.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: selectedReason,
                decoration: const InputDecoration(labelText: 'Reason'),
                items: reasons
                    .map(
                      (reason) =>
                          DropdownMenuItem(value: reason, child: Text(reason)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedReason = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );

    return confirmed == true ? selectedReason : null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatForumBloc, ChatForumState>(
      builder: (context, state) {
        final currentUser = context.read<ApplicationBloc>().currentUser;
        final author = currentUser != null
            ? Author.fromUser(currentUser)
            : null;

        if (state is ChatForumThreadLoadedState) {
          final isOwner = author?.id == state.thread.author.id;
          final isAdmin = currentUser?.role == Strings.roleAdmin;
          final isReadOnly = state.thread.isAdminRemoved;
          final canEdit = isOwner && !isReadOnly;
          final canDelete = isOwner || isAdmin;
          final canSoftDelete = isAdmin && !state.thread.isAdminRemoved;
          final canShowComments = !state.thread.isAdminRemoved || isAdmin;

          return Column(
            children: [
              ChatThreadHeader(
                thread: state.thread,
                canEdit: canEdit,
                canDelete: canDelete,
                canSoftDelete: canSoftDelete,
                onEdit: () => _showEditThreadDialog(context, state.thread),
                onSoftDelete: () =>
                    _confirmSoftDeleteThread(context, state.thread),
                onDelete: () => isAdmin
                    ? _confirmHardDeleteThread(context, state.thread)
                    : _confirmDeleteThread(context, state.thread),
              ),
              if (state.thread.isAdminRemoved)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    0,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'This thread has been removed by an admin because it broke site rules.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              if (canShowComments)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.thread.comments.length,
                    itemBuilder: (context, index) {
                      return ChatComment(comment: state.thread.comments[index]);
                    },
                  ),
                )
              else
                const Expanded(child: SizedBox.shrink()),
              if (author != null && !state.thread.isAdminRemoved) ...[
                ChatReplyBox(threadId: state.thread.id, authorId: author.id),
              ],
            ],
          );
        }

        if (state is ChatForumThreadLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatForumThreadErrorState) {
          return const Center(child: Text(Strings.somethingWentWrong));
        }

        // List View (Initial state, List loading state, Content loaded state, List error state)
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Create new thread button
            BlocBuilder<ApplicationBloc, ApplicationState>(
              builder: (context, appState) {
                if (appState is ApplicationContentLoadedState &&
                    appState.isLoggedIn &&
                    appState.currentUser != null) {
                  final threadAuthor = Author.fromUser(appState.currentUser!);
                  return InkWell(
                    onTap: () => _showCreateThreadDialog(context, threadAuthor),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: AppSpacing.sm),
                          Text(Strings.threadNew, style: AppTextStyles.h2),
                        ],
                      ),
                    ),
                  );
                } else {
                  return SizedBox(height: AppSpacing.md);
                }
              },
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search forum threads by title, content, or author...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Latest posts header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              alignment: Alignment.centerLeft,
              child: Text(Strings.threadLatest, style: AppTextStyles.h2),
            ),
            Expanded(
              child: _buildListContent(context, state, currentUser),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListContent(
    BuildContext context,
    ChatForumState state,
    dynamic currentUser,
  ) {
    if (state is ChatForumLoadingState || state is ChatForumInitialState) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ChatForumErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(Strings.somethingWentWrong, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () {
                context.read<ChatForumBloc>().add(
                  ChatForumLoadEvent(
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

    if (state is ChatForumContentLoadedState) {
      final isAdmin = currentUser?.role == Strings.roleAdmin;
      final visibleThreads = state.chat.threads.where((thread) {
        bool isVisible = true;
        if (!isAdmin && (thread.isDraft || thread.isAdminRemoved)) {
          isVisible = thread.author.id == currentUser?.id;
        }
        return isVisible;
      }).toList();

      if (visibleThreads.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'No threads found matching your search.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: visibleThreads.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = visibleThreads[index];
          return ForumItem(thread: item);
        },
      );
    }

    return const SizedBox.shrink();
  }
}
