import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_view.dart';
import 'package:blog/modules/blog/view/create_post/blog_post_header_create.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/resources/resources.dart';
import 'package:blog/modules/core/application.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/blog/util/blog_content.dart';
import 'package:blog/shared/models/author.dart';
import 'package:intl/intl.dart';

class BlogPostCreateView extends StatefulWidget {
  final BlogPost? post;
  final Author? author;
  final BlogPost? latestPost;
  final bool isEditing;

  const BlogPostCreateView({
    super.key,
    required this.post,
    required this.author,
    required this.latestPost,
    required this.isEditing,
  });

  @override
  State<BlogPostCreateView> createState() => _BlogPostHeaderCreateState();
}

class _BlogPostHeaderCreateState extends State<BlogPostCreateView> {
  late final TextEditingController _controller;
  late final TextEditingController _titleController;
  DateTime _selectedPublishDate = DateTime.now();
  bool _adminOverride = false;
  late final String _initialContent;
  late final String _initialTitle;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.post?.content ?? '');
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _initialContent = _controller.text;
    _initialTitle = _titleController.text;
    if (widget.post != null) {
      _selectedPublishDate = widget.post!.createdAt;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
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

  void _handleSave(String titleText, {required bool isDraft}) {
    final String bodyText = sanitizeBlogContent(_controller.text);
    final contentError = validateBlogContent(bodyText);

    if (titleText.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title cannot be empty')));
      return;
    }

    if (contentError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(contentError)));
      return;
    }

    if (widget.isEditing && widget.post?.isDraft == false && isDraft) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Published posts cannot be saved as draft'),
        ),
      );
      return;
    }

    final latestPost = _latestPostForTimelineCheck();

    if (_shouldValidateTimeline(isDraft: isDraft) &&
        latestPost != null &&
        _selectedPublishDate.isBefore(latestPost.createdAt)) {
      final currentUser = context.read<ApplicationBloc>().currentUser;
      final isAdmin = currentUser?.role == Strings.roleAdmin;

      if (!isAdmin || !_adminOverride) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Timeline Integrity Violation'),
            content: Text(
              'Posts must follow a chronological narrative. You cannot publish a post dated before the latest post (${DateFormat('yyyy-MM-dd HH:mm').format(latestPost.createdAt.toLocal())}).'
              '\n\n${isAdmin ? "Please enable 'Admin Override' to bypass this check." : "Only system administrators can publish out-of-order."}',
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

    final post = widget.post;
    if (widget.isEditing && post != null) {
      context.read<BlogBloc>().add(
        UpdateBlogPostEvent(
          blogId: post.id,
          title: titleText.trim(),
          content: bodyText,
          isDraft: isDraft,
        ),
      );
      return;
    }

    final authorId = widget.author?.id;
    if (authorId == null || authorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save a post')),
      );
      return;
    }

    context.read<BlogBloc>().add(
      SaveNewBlogPostEvent(
        authorId: authorId,
        title: titleText.trim(),
        content: bodyText,
        isDraft: isDraft,
        publishDate: _selectedPublishDate,
      ),
    );
  }

  BlogPost? _latestPostForTimelineCheck() {
    final blogState = context.read<BlogBloc>().state;
    if (blogState is BlogLoadedState && blogState.posts.isNotEmpty) {
      final currentPostId = widget.post?.id;
      final posts = blogState.posts.where(
        (post) => post.id != currentPostId && !post.isDraft,
      );

      BlogPost? latestPost;
      for (final post in posts) {
        if (latestPost == null ||
            post.createdAt.isAfter(latestPost.createdAt)) {
          latestPost = post;
        }
      }

      return latestPost;
    }

    return widget.latestPost;
  }

  bool _shouldValidateTimeline({required bool isDraft}) {
    if (isDraft) {
      return false;
    }

    return !widget.isEditing || widget.post?.isDraft == true;
  }

  Future<void> _handleClose() async {
    if (_controller.text != _initialContent ||
        _titleController.text != _initialTitle) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('You have unsaved changes.'),
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

      if (shouldDiscard != true || !mounted) {
        return;
      }
    }

    context.read<BlogBloc>().add(const LoadBlogPostsEvent(fromCache: true));
  }

  bool isPreview = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<ApplicationBloc>().currentUser;
    final isAdmin = currentUser?.role == Strings.roleAdmin;

    final showPublishControls =
        !widget.isEditing || widget.post?.isDraft == true;
    final latestPost = _latestPostForTimelineCheck();
    final isOutOfOrder =
        showPublishControls &&
        latestPost != null &&
        _selectedPublishDate.isBefore(latestPost.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlogPostHeaderCreate(
          titleController: _titleController,
          author: widget.author?.displayName ?? "",
          isEditing: widget.isEditing,
          setIsPreviewMode: () => setState(() {
            isPreview = !isPreview;
          }),
          onSaveDraft: (String titleText) =>
              _handleSave(titleText, isDraft: true),
          onPublish: (String titleText) =>
              _handleSave(titleText, isDraft: false),
          onClose: _handleClose,
          canSaveDraft: showPublishControls,
        ),

        if (showPublishControls)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Publish Date: ',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: widget.isEditing ? null : _selectPublishDate,
                  child: Text(
                    DateFormat(
                      'yyyy-MM-dd HH:mm',
                    ).format(_selectedPublishDate.toLocal()),
                    style: AppTextStyles.link.copyWith(fontSize: 12),
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(width: AppSpacing.lg),
                  Text(
                    'Admin Override: ',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                  const SizedBox(width: AppSpacing.lg),
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

        isPreview
            ? Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: MarkdownBody(
                    data: sanitizeBlogContent(_controller.text),
                    extensionSet: md.ExtensionSet.gitHubFlavored,
                    blockSyntaxes: [UrlEmbedSyntax()],
                    builders: {'urlembed': UrlEmbedBuilder()},
                  ),
                ),
              )
            : Expanded(
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
                    style: TextStyle(fontFamily: 'monospace', fontSize: 14),
                  ),
                ),
              ),
      ],
    );
  }
}
