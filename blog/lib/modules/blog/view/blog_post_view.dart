import 'package:blog/modules/blog/model/post.dart';
import 'package:blog/modules/blog/view/blog_post_header.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

class BlogPostView extends StatelessWidget {
  final Post post;

  const BlogPostView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlogPostHeader(
          title: post.title,
          author: post.author.alias??"",
          date: DateTime.fromMillisecondsSinceEpoch(post.createdAt.toInt()).toLocal().toString().split(" ").first,
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: MarkdownBody(
              data: post.content, 
              extensionSet: md.ExtensionSet.gitHubFlavored,
              blockSyntaxes: [UrlEmbedSyntax()],
              builders: {
                'urlembed': UrlEmbedBuilder(),
              },
            ),
          ),
        ),
      ],
    );
  }
}

class UrlEmbedBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final url = element.textContent.trim();

    if (url.isEmpty) return const SizedBox();

    return Container(
      height: 300,
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