import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';

class RaisedButton extends StatefulWidget {
  final VoidCallback action;
  final String title;

  const RaisedButton({
    super.key,
    required this.action,
    required this.title,
  });

  @override
  State<RaisedButton> createState() => _RaisedButtonState();
}

class _RaisedButtonState extends State<RaisedButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.action();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.center,
            height: 24,
            width: double.infinity,
            padding: isMobile
                ? const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                    horizontal: AppSpacing.md,
                  )
                : null,
            decoration: BoxDecoration(
              color: _isHovered
                  ? const Color.fromARGB(255, 200, 205, 215) // darker on hover
                  : const Color.fromARGB(255, 220, 224, 230),
              borderRadius: BorderRadius.circular(8),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.button.copyWith(
                color: _isHovered ? Colors.black : Colors.indigo,
              ),
              child: Text(widget.title),
            ),
          ),
        ),
      ),
    );
  }
}