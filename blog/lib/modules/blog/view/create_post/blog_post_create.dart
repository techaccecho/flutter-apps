import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_view.dart';
import 'package:blog/modules/blog/view/create_post/blog_post_header_create.dart';
import 'package:blog/resources/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/shared/models/author.dart';


class BlogPostCreateView extends StatefulWidget {

  final BlogPost? post;
  final Author? author;
  final bool isEditing;

  const BlogPostCreateView({super.key, required this.post, required this.author, required this.isEditing});

  @override
  State<BlogPostCreateView> createState() => _BlogPostHeaderCreateState();
}

class _BlogPostHeaderCreateState extends State<BlogPostCreateView> {

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave(String titleText) {
    final String bodyText = _controller.text;

    if (titleText.trim().isEmpty || bodyText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body cannot be empty')),
      );
      return;
    }

    context.read<BlogBloc>().add(SaveNewBlogPostEvent(authorId: widget.author?.id ?? '', title: titleText, content: bodyText));
  }

  bool isPreview = false;

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        BlogPostHeaderCreate(
          title: widget.post?.title??"",
          author: widget.author?.alias??"",
          setIsPreviewMode: () => setState(() {
            isPreview = !isPreview;
          }),
          onSave: (String titleText) => _handleSave(titleText),
          onClose: () {
            
          }
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