import 'package:flutter/material.dart';

class RetroIconButton extends StatefulWidget {
  final VoidCallback action;
  final IconData icon;
  final double size;
  final bool isLoading;

  const RetroIconButton({
    super.key,
    required this.action,
    required this.icon,
    this.size = 32,
    this.isLoading = false,
  });

  @override
  State<RetroIconButton> createState() => _RetroIconButtonState();
}

class _RetroIconButtonState extends State<RetroIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final disableInteraction = widget.isLoading;

    return MouseRegion(
      onEnter: (_) {
        if (!disableInteraction) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (!disableInteraction) setState(() => _isHovered = false);
      },
      cursor: disableInteraction
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) {
          if (!disableInteraction) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (!disableInteraction) {
            setState(() => _isPressed = false);
            widget.action();
          }
        },
        onTapCancel: () {
          if (!disableInteraction) setState(() => _isPressed = false);
        },
        child: AnimatedScale(
          scale: (_isPressed && !disableInteraction) ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.center,
            height: widget.size,
            width: widget.size,
            decoration: BoxDecoration(
              color: disableInteraction
                  ? const Color.fromARGB(
                      255,
                      200,
                      205,
                      215,
                    ) 
                  : _isHovered
                  ? const Color.fromARGB(255, 200, 205, 215)
                  : const Color.fromARGB(255, 220, 224, 230),
              borderRadius: BorderRadius.circular(8),
              boxShadow: (_isHovered && !disableInteraction)
                  ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: widget.size * 0.5,
                    height: widget.size * 0.5,
                    child: CircularProgressIndicator(
                      strokeWidth:
                          2,
                      color: _isHovered ? Colors.black : Colors.indigo,
                    ),
                  )
                : Icon(
                    widget.icon,
                    size: widget.size * 0.6,
                    color: _isHovered ? Colors.black : Colors.indigo,
                  ),
          ),
        ),
      ),
    );
  }
}
