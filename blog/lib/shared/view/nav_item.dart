import 'package:blog/resources/app_text_styles.dart';
import 'package:flutter/material.dart';

class NavItem extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.black87;
    final highlightColor = Colors.blueAccent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? highlightColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 3,
                height: 16,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? highlightColor
                      : (_isHovered ? highlightColor.withOpacity(0.5) : Colors.transparent),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.link.copyWith(
                  color: widget.isSelected
                      ? highlightColor
                      : (_isHovered ? Colors.black : baseColor),
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(widget.title),
              ),
            ],
          ),
        ),
      ),
    );
  }
}