import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/view/create_post/blog_menu_button.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogPostHeaderCreate extends StatefulWidget {
  final bool isEditing;
  final String author;
  final String? title;
  final VoidCallback setIsPreviewMode;

  const BlogPostHeaderCreate({
    super.key,
    required this.author,
    required this.title,
    required this.setIsPreviewMode,
    this.isEditing = false,
  });

  @override
  State<BlogPostHeaderCreate> createState() => _BlogPostHeaderCreateState();
}

class _BlogPostHeaderCreateState extends State<BlogPostHeaderCreate> {
  late final TextEditingController _titleController;
  bool isPreview = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title ?? "");
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              context
                  .read<BlogBloc>()
                  .add(LoadBlogPostsEvent(fromCache: true));
            },
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: "Enter title here",
                  ),
                  style: AppTextStyles.h1,
                  maxLines: null,
                ),
                const SizedBox(height: 8),
                Text(
                  "by ${widget.author}",
                  style: AppTextStyles.bodySmall,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  margin: const EdgeInsets.only(top: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                  child: Row(children: [
                    BlogPostMenuButton(buttonText: "Embed url"),
                    BlogPostMenuButton(buttonText: "Add image"),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        widget.setIsPreviewMode();
                        // setState(() {
                        //   isPreview = !isPreview;
                        // });
                      },
                      child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPreview ? "Edit" : "Preview",
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                      ),
                    ),),
                    SizedBox(width: AppSpacing.lg),
                    Icon(Icons.close, size: 24, color: AppColors.textPrimary),
                    SizedBox(width: AppSpacing.xs),
                    Icon(Icons.save, size: 24, color: AppColors.textPrimary),
                    SizedBox(width: AppSpacing.xs),
                  ],),
                ),
              
              ],
            ),
          ),
        ],
      ),
    );
  }
}