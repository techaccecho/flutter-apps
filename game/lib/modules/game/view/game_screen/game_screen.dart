import 'package:flutter/material.dart';

import 'package:game/modules/game/view/embed_game/embed_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  final String godotBuildUrl = 'https://your-game-host.com/build/index.html';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ARG Terminal Access')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Classified Entry Point',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

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
                'Use arrow keys / WASD to control. Solve the cipher inside to proceed.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
