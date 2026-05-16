import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/blog/view/blog_post_view.dart';
import 'package:blog/modules/blog/view/create_post/blog_post_header_create.dart';
import 'package:blog/resources/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;


class BlogPostCreateView extends StatefulWidget {

  final BlogPost? post;
  final String author;

  const BlogPostCreateView({super.key, required this.post, required this.author});

  @override
  State<BlogPostCreateView> createState() => _BlogPostHeaderCreateState();
}

class _BlogPostHeaderCreateState extends State<BlogPostCreateView> {

  final TextEditingController _controller = TextEditingController();

  bool isPreview = false;


  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        BlogPostHeaderCreate(
          title: widget.post?.title??"",
          author: widget.author,
          setIsPreviewMode: () => setState(() {
            isPreview = !isPreview;
          }),
        ),

        isPreview ? Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: MarkdownBody(
              data: _controller.text, 
              extensionSet: md.ExtensionSet.gitHubFlavored,
              blockSyntaxes: [UrlEmbedSyntax()],
              builders: {
                'urlembed': UrlEmbedBuilder(),
              },
            ),
          ),
        ) : Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Write your blog post in Markdown...',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        )

      ],
    );
  }

}