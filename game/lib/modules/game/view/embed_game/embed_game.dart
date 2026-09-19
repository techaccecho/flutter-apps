import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class EmbedGame extends StatefulWidget {
  final String gameUrl;
  const EmbedGame({super.key, required this.gameUrl});

  @override
  State<EmbedGame> createState() => _EmbedGameState();
}

class _EmbedGameState extends State<EmbedGame> {
  static const String viewType = 'godot-iframe-element';
  static bool _registered = false;

  @override
  void initState() {
    super.initState();
    if (!_registered) {
      ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        final iframe = web.HTMLIFrameElement()
          ..src = widget.gameUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'autoplay; fullscreen';
        return iframe;
      });
      _registered = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: HtmlElementView(viewType: viewType),
    );
  }
}
