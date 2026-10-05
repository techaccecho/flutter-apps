import 'package:flutter/material.dart';

import 'package:game/modules/game/view/embed_game/embed_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  // Bundled under web/godot-game/ so it ships with the Flutter web build.
  final String godotBuildUrl = 'godot-game/index.html';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Echo')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 960),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: EmbedGame(gameUrl: godotBuildUrl),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Use arrow keys / WASD to control.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
