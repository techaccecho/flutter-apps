import 'package:blog/resources/resources.dart';
import 'package:blog/shared/view/retro_icon_button.dart';
import 'package:flutter/material.dart';

class ReplyBox extends StatefulWidget {
  final String hintText;
  final String actionText;
  final bool isLoading;
  final ValueChanged<String> action;

  const ReplyBox({
    this.hintText = 'C:\\> type your reply here...',
    this.actionText = 'SEND',
    this.isLoading = false,
    required this.action,
  });

  @override
  State<ReplyBox> createState() => _ReplyBoxState();
}

class _ReplyBoxState extends State<ReplyBox> {
  final controller = TextEditingController();

  void _handleAction() {
    final text = controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A message cannot be empty')),
      );
      return;
    }

    widget.action(text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: AppTextStyles.inputText,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.inputHint,
                filled: true,
                fillColor: AppColors.surface,
                hoverColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 4,
            ), // Tiny vertical adjustment to match alignment
            child: RetroIconButton(
              size: 42, // Matches the 42px height constraint of your previous layout perfectly
              icon: Icons.send_sharp, // Sharp corners on the icon fit the Web 1.0 look best
              isLoading: widget.isLoading,
              action: () => _handleAction(),
            ),
          ),
        ],
      ),
    );
  }
}
