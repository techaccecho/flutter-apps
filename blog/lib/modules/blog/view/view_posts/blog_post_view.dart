import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_header.dart';
import 'package:blog/modules/blog/util/blog_content.dart';
import 'package:blog/modules/chat_forum/view/chat_comment.dart';
import 'package:blog/modules/core/application.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:blog/shared/view/reply_box.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';

class BlogPostView extends StatelessWidget {
  final BlogPost post;

  const BlogPostView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<ApplicationBloc>().currentUser;
    final isOwner = currentUser?.id == post.author.id;
    final isAdmin = currentUser?.role == Strings.roleAdmin;
    final isReadOnly = post.isAdminRemoved;
    final canEdit = isOwner && !isReadOnly;
    final canDelete = isOwner || isAdmin;
    final canSoftDelete = isAdmin && !post.isAdminRemoved;
    final canShowComments = !post.isAdminRemoved || isAdmin;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlogPostHeader(
            title: post.title,
            author: post.author,
            date: post.createdAt.toLocal().toString().split(" ").first,
            isDraft: post.isDraft,
            canEdit: canEdit,
            canDelete: canDelete,
            canSoftDelete: canSoftDelete,
            onEdit: () {
              context.read<BlogBloc>().add(EditBlogPostEvent(blogId: post.id));
            },
            onSoftDelete: () => _confirmSoftDelete(context),
            onDelete: () => _confirmHardDelete(context, isAdmin: isAdmin),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: post.isAdminRemoved
                        ? '*Content removed by administrator*'
                        : sanitizeBlogContent(post.content),
                    extensionSet: md.ExtensionSet.gitHubFlavored,
                    blockSyntaxes: [UrlEmbedSyntax()],
                    builders: {'urlembed': UrlEmbedBuilder()},
                  ),
                  if (post.isAdminRemoved) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'This post has been removed by an admin because it broke site rules.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                  if (canShowComments) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Comments (${post.comments.length})',
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (post.comments.isEmpty)
                      Text('No comments yet.', style: AppTextStyles.bodySmall)
                    else
                      ...post.comments.map(
                        (comment) => ChatComment(comment: comment),
                      ),
                  ],
                ],
              ),
            ),
          ),
          if (currentUser != null) ...[
            BlocBuilder<BlogBloc, BlogState>(
              builder: (context, state) {
                final isLoading =
                    state is BlogPostLoadedState && state.isSubmittingComment;
                return ReplyBox(
                  isLoading: isLoading,
                  action: (String message) =>
                      _addComment(context, message, currentUser.id),
                );
              },
            )
          ]
        ],
      ),
    );
  }

  Future<void> _confirmHardDelete(
    BuildContext context, {
    required bool isAdmin,
  }) async {
    String? reason;

    if (isAdmin) {
      reason = await _confirmReasonedAction(
        context,
        title: 'Delete post?',
        message:
            'This permanently deletes the post and related data. This action cannot be undone.',
      );
    } else {
      final confirmed = await _confirmAction(
        context,
        title: 'Delete post?',
        message: 'This action cannot be undone.',
      );
      reason = confirmed ? 'Deleted by owner' : null;
    }

    if (reason == null || !context.mounted) {
      return;
    }

    context.read<BlogBloc>().add(
      DeleteBlogPostEvent(blogId: post.id, reason: reason),
    );
  }

  Future<void> _confirmSoftDelete(BuildContext context) async {
    final reason = await _confirmReasonedAction(
      context,
      title: 'Remove post?',
      message:
          'This hides the post from other users and makes it read-only for the owner.',
    );

    if (reason == null || !context.mounted) {
      return;
    }

    context.read<BlogBloc>().add(
      SoftDeleteBlogPostEvent(blogId: post.id, reason: reason),
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
  
  Future<void> _addComment(BuildContext context, String message, String authorId) async {
    if (!context.mounted) {
      return;
    }

    context
        .read<BlogBloc>()
        .add(AddBlogPostCommentEvent(blogId: post.id, authorId: authorId, message: message));
  }
}

class UrlEmbedBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final url = element.textContent.trim();
    final uri = Uri.tryParse(url);

    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return const SizedBox();
    }

    return Container(
      height: 800,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          mediaPlaybackRequiresUserGesture: false,
        ),
      ),
    );
  }
}

class UrlEmbedSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^<urlembed>(.*?)</urlembed>$');

  @override
  md.Node parse(md.BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content)!;
    final content = match.group(1)!;

    parser.advance();

    return md.Element.text('urlembed', content);
  }
}
