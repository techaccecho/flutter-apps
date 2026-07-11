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

class ChatForumView extends StatelessWidget {
  const ChatForumView({super.key});

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
      titleController.dispose();
      contentController.dispose();
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
      titleController.dispose();
      contentController.dispose();
    });
  }

  Future<void> _confirmDeleteThread(BuildContext context, Thread thread) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete thread?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    context.read<ChatForumBloc>().add(
      ChatDeleteThreadEvent(threadId: thread.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatForumBloc, ChatForumState>(
      builder: (context, state) {
        final currentUser = context.read<ApplicationBloc>().currentUser;
        final author = currentUser != null
            ? Author.fromUser(currentUser)
            : null;

        if (state is ChatForumLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatForumContentLoadedState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Create new thread button
              BlocBuilder<ApplicationBloc, ApplicationState>(
                builder: (context, state) {
                  if (state is ApplicationContentLoadedState &&
                      state.isLoggedIn &&
                      state.currentUser != null) {
                    final threadAuthor = Author.fromUser(state.currentUser!);
                    return InkWell(
                      onTap: () =>
                          _showCreateThreadDialog(context, threadAuthor),
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

              // Latest posts
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                alignment: Alignment.centerLeft,
                child: Text(Strings.threadLatest, style: AppTextStyles.h2),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.chat.threads.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.chat.threads[index];
                    return ForumItem(thread: item);
                  },
                ),
              ),
            ],
          );
        }

        if (state is ChatForumErrorState) {
          return const Center(child: Text(Strings.somethingWentWrong));
        }

        if (state is ChatForumThreadLoadedState) {
          final canManage = author?.id == state.thread.author.id;

          return Column(
            children: [
              ChatThreadHeader(
                thread: state.thread,
                canManage: canManage,
                onEdit: () => _showEditThreadDialog(context, state.thread),
                onDelete: () => _confirmDeleteThread(context, state.thread),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.thread.comments.length,
                  itemBuilder: (context, index) {
                    return ChatComment(comment: state.thread.comments[index]);
                  },
                ),
              ),
              if (author != null) ...[
                ChatReplyBox(threadId: state.thread.id, authorId: author.id),
              ],
            ],
          );
        }

        return const Center(child: Text(Strings.forumLoading));
      },
    );
  }
}
