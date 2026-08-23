import 'dart:math';
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_header.dart';
import 'package:blog/modules/blog/util/blog_content.dart';
import 'package:blog/modules/chat_forum/view/chat_comment.dart';
import 'package:blog/modules/core/application.dart';
import 'package:blog/modules/core/arg_state_bloc.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/shared/services/storage_helper.dart';
import 'package:blog/shared/util/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:blog/shared/services/authentication_service.dart';
import 'package:blog/shared/view/reply_box.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';

class BlogPostView extends StatelessWidget {
  final BlogPost post;

  const BlogPostView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplicationBloc, ApplicationState>(
      builder: (context, appState) {
        String? authSub;
        try {
          authSub = context.read<AuthenticationService>().authSub;
        } catch (_) {}
        final currentUser = appState is ApplicationContentLoadedState
            ? appState.currentUser
            : context.read<ApplicationBloc>().currentUser;
        final authUserId = (currentUser?.id != null && currentUser!.id.isNotEmpty)
            ? currentUser.id
            : (currentUser?.authId != null && currentUser!.authId.isNotEmpty
                ? currentUser.authId
                : authSub);
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
                  context
                      .read<BlogBloc>()
                      .add(EditBlogPostEvent(blogId: post.id));
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
                        key: ValueKey('markdown_${post.id}_${authUserId ?? "guest"}'),
                        data: post.isAdminRemoved
                            ? '*Content removed by administrator*'
                            : sanitizeBlogContent(post.content),
                        extensionSet: md.ExtensionSet.gitHubFlavored,
                        blockSyntaxes: [UrlEmbedSyntax()],
                        builders: {
                          'urlembed': UrlEmbedBuilder(
                            userId: authUserId,
                            onCompleted: () {
                              context
                                  .read<ArgStateBloc>()
                                  .add(FetchArgStateEvent(userId: authUserId));
                            },
                          ),
                        },
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
                ),
              ],
            ],
          ),
        );
      },
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
  final String? userId;
  final VoidCallback? onCompleted;
  static String? _sessionGuestId;

  UrlEmbedBuilder({this.userId, this.onCompleted});

  static String _generateUuid() {
    final random = Random();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // v4
    values[8] = (values[8] & 0x3f) | 0x80; // variant
    return [
      values
          .sublist(0, 4)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(),
      values
          .sublist(4, 6)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(),
      values
          .sublist(6, 8)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(),
      values
          .sublist(8, 10)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(),
      values
          .sublist(10, 16)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(),
    ].join('-');
  }

  static String getEffectiveUserId(String? authenticatedUserId) {
    if (authenticatedUserId != null && authenticatedUserId.trim().isNotEmpty) {
      final cleanAuthId = authenticatedUserId.trim();
      StorageHelper.removeItem(StorageHelper.guestUserIdKey);
      return cleanAuthId;
    }

    final storedGuestId = StorageHelper.getItem(StorageHelper.guestUserIdKey);
    if (storedGuestId != null &&
        storedGuestId.trim().isNotEmpty &&
        storedGuestId.trim().startsWith('guest_')) {
      return storedGuestId.trim();
    }

    final newGuestId = 'guest_${_generateUuid()}';
    StorageHelper.setItem(StorageHelper.guestUserIdKey, newGuestId);
    return newGuestId;
  }

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var rawUrl = element.textContent.trim();

    // Only inject userId and resolve puzzle URL if this is specifically the wordsearch puzzle
    final isWordSearch = rawUrl.toLowerCase().contains('wordsearch') ||
        rawUrl.toLowerCase().contains('puzzle');

    if (isWordSearch) {
      if (rawUrl.startsWith('/')) {
        rawUrl = '${AppConfig.puzzleAppBaseUrl}$rawUrl';
      }

      final resolvedUserId = getEffectiveUserId(userId);

      final parsedUri = Uri.tryParse(rawUrl);
      if (parsedUri != null) {
        final queryParams = Map<String, String>.from(parsedUri.queryParameters);
        queryParams['userId'] = resolvedUserId;
        rawUrl = parsedUri.replace(queryParameters: queryParams).toString();
      }
    }

    final uri = Uri.tryParse(rawUrl);

    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return const SizedBox();
    }

    return Container(
      height: 800,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InAppWebView(
        key: ValueKey(rawUrl),
        initialUrlRequest: URLRequest(url: WebUri(rawUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          mediaPlaybackRequiresUserGesture: false,
          supportMultipleWindows: true,
          javaScriptCanOpenWindowsAutomatically: true,
        ),
        onCreateWindow: (controller, createWindowAction) async {
          final targetUrl = createWindowAction.request.url?.toString();
          if (targetUrl != null && targetUrl.isNotEmpty) {
            onCompleted?.call();
            StorageHelper.openInNewTab(targetUrl);
          }
          return true;
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final targetUrl = navigationAction.request.url?.toString();
          if (targetUrl != null &&
              (targetUrl.contains('/shortUrl/') ||
                  targetUrl.contains('/game-hub') ||
                  targetUrl.contains('project-echo-game') ||
                  targetUrl.contains('/download'))) {
            onCompleted?.call();
            StorageHelper.openInNewTab(targetUrl);
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
        onLoadStop: (controller, url) {
          if (isWordSearch && url != null) {
            final urlString = url.toString();
            if (urlString.contains('/shortUrl/') ||
                urlString.contains('/game-hub') ||
                urlString.contains('project-echo-game') ||
                urlString.contains('/download')) {
              onCompleted?.call();
              StorageHelper.openInNewTab(urlString);
            }
          }
        },
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
