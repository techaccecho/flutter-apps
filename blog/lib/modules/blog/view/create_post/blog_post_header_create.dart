import 'package:blog/modules/blog/view/create_post/blog_menu_button.dart';
import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';

class BlogPostHeaderCreate extends StatefulWidget {
  final bool isEditing;
  final String author;
  final TextEditingController titleController;
  final VoidCallback setIsPreviewMode;
  final ValueChanged<String> onSaveDraft;
  final ValueChanged<String> onPublish;
  final VoidCallback onClose;
  final bool canSaveDraft;

  const BlogPostHeaderCreate({
    super.key,
    required this.author,
    required this.titleController,
    required this.setIsPreviewMode,
    this.isEditing = false,
    required this.onSaveDraft,
    required this.onPublish,
    required this.onClose,
    this.canSaveDraft = true,
  });

  @override
  State<BlogPostHeaderCreate> createState() => _BlogPostHeaderCreateState();
}

class _BlogPostHeaderCreateState extends State<BlogPostHeaderCreate> {
  bool isPreview = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              widget.onClose();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: widget.titleController,
                  decoration: const InputDecoration(
                    hintText: "Enter title here",
                  ),
                  style: AppTextStyles.h1,
                  maxLines: null,
                ),
                const SizedBox(height: 8),
                Text("by ${widget.author}", style: AppTextStyles.bodySmall),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  margin: const EdgeInsets.only(top: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      // BlogPostMenuButton(buttonText: "Embed url"),
                      // BlogPostMenuButton(buttonText: "Add image"),
                      // Spacer(),
                      InkWell(
                        onTap: () {
                          widget.setIsPreviewMode();
                          setState(() {
                            isPreview = !isPreview;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isPreview ? "Edit" : "Preview",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.lg),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 24,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          widget.onClose();
                        },
                      ),
                      SizedBox(width: AppSpacing.xs),
                      if (widget.canSaveDraft) ...[
                        OutlinedButton.icon(
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Save draft'),
                          onPressed: () {
                            widget.onSaveDraft(widget.titleController.text);
                          },
                        ),
                        SizedBox(width: AppSpacing.sm),
                      ],
                      ElevatedButton.icon(
                        icon: const Icon(Icons.publish, size: 18),
                        label: Text(
                          widget.isEditing ? 'Update post' : 'Publish',
                        ),
                        onPressed: () {
                          widget.onPublish(widget.titleController.text);
                        },
                      ),
                      SizedBox(width: AppSpacing.xs),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
