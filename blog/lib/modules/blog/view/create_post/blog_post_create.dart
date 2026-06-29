import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_view.dart';
import 'package:blog/modules/blog/view/create_post/blog_post_header_create.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/modules/core/application.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/shared/models/author.dart';
import 'package:intl/intl.dart';

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
  DateTime _selectedPublishDate = DateTime.now();
  bool _adminOverride = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (widget.post != null) {
      _selectedPublishDate = widget.post!.createdAt;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectPublishDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedPublishDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedPublishDate),
    );
    if (time == null) return;
    if (!mounted) return;

    setState(() {
      _selectedPublishDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _handleSave(String titleText) {
    final String bodyText = _controller.text;

    if (titleText.trim().isEmpty || bodyText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body cannot be empty')),
      );
      return;
    }

    // Chronological Narrative Integrity Check (US-6.2)
    final blogState = context.read<BlogBloc>().state;
    BlogPost? latestPost;
    if (blogState is BlogLoadedState && blogState.posts.isNotEmpty) {
      latestPost = blogState.posts.reduce((curr, next) => curr.createdAt.isAfter(next.createdAt) ? curr : next);
    }

    if (latestPost != null && _selectedPublishDate.isBefore(latestPost.createdAt)) {
      final currentUser = context.read<ApplicationBloc>().currentUser;
      final isAdmin = currentUser?.role == 'admin';

      if (!isAdmin || !_adminOverride) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Timeline Integrity Violation'),
            content: Text(
              'Posts must follow a chronological narrative. You cannot publish a post dated before the latest post (${DateFormat('yyyy-MM-dd HH:mm').format(latestPost!.createdAt.toLocal())}).'
              '\n\n${isAdmin ? "Please enable 'Admin Override' to bypass this check." : "Only system administrators can publish out-of-order."}'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    context.read<BlogBloc>().add(SaveNewBlogPostEvent(
      authorId: widget.author?.id ?? '',
      title: titleText,
      content: bodyText,
      publishDate: _selectedPublishDate,
    ));
  }

  bool isPreview = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<ApplicationBloc>().currentUser;
    final isAdmin = currentUser?.role == 'admin';

    // Check if selected date is out-of-order
    final blogState = context.read<BlogBloc>().state;
    BlogPost? latestPost;
    if (blogState is BlogLoadedState && blogState.posts.isNotEmpty) {
      latestPost = blogState.posts.reduce((curr, next) => curr.createdAt.isAfter(next.createdAt) ? curr : next);
    }
    final isOutOfOrder = latestPost != null && _selectedPublishDate.isBefore(latestPost.createdAt);

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

        // Timeline settings row (Publish Date and Admin Override)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Publish Date: ',
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _selectPublishDate,
                child: Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(_selectedPublishDate.toLocal()),
                  style: AppTextStyles.link.copyWith(fontSize: 12),
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(width: AppSpacing.lg),
                Text(
                  'Admin Override: ',
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _adminOverride,
                  onChanged: (val) {
                    setState(() {
                      _adminOverride = val;
                    });
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ],
              if (isOutOfOrder) ...[
                const Spacer(),
                const Icon(Icons.warning, color: Colors.orange, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Out-of-order publishing',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
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