import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_header.dart';
import 'package:blog/modules/chat_forum/view/chat_comment.dart';
import 'package:blog/modules/core/application.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

class BlogPostView extends StatelessWidget {
  final BlogPost post;

  const BlogPostView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<ApplicationBloc>().currentUser;
    final canManage = currentUser?.id == post.author.id;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlogPostHeader(
            title: post.title,
            author: post.author,
            date: post.createdAt.toLocal().toString().split(" ").first,
            isDraft: post.isDraft,
            canManage: canManage,
            onEdit: () {
              context.read<BlogBloc>().add(EditBlogPostEvent(blogId: post.id));
            },
            onDelete: () => _confirmDelete(context),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: post.content,
                    extensionSet: md.ExtensionSet.gitHubFlavored,
                    blockSyntaxes: [UrlEmbedSyntax()],
                    builders: {'urlembed': UrlEmbedBuilder()},
                  ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete post?'),
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

    context.read<BlogBloc>().add(DeleteBlogPostEvent(blogId: post.id));
  }
}

class UrlEmbedBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final url = element.textContent.trim();

    if (url.isEmpty) return const SizedBox();

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
