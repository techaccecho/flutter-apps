import 'package:flutter/material.dart';

void main() {
  runApp(const MysticHollowApp());
}

class MysticHollowApp extends StatelessWidget {
  const MysticHollowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Mystic Hollow",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MysticHollowHome(),
    );
  }
}

class MysticHollowHome extends StatelessWidget {
  const MysticHollowHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1c1b1f),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            Header(),
            HeroSection(),
            GameInfoSection(),
            ScreenshotsSection(),
            Footer(),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xff2a2633),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Mystic Hollow",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: const [
              NavButton("Home"),
              NavButton("About"),
              NavButton("Screenshots"),
              NavButton("FAQ"),
            ],
          )
        ],
      ),
    );
  }
}

class NavButton extends StatelessWidget {
  final String label;

  const NavButton(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextButton(
        onPressed: () {},
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          const Text(
            "Explore the Haunted Forest of Mystic Hollow",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            "A mysterious 2D adventure where secrets hide beneath the fog.",
            style: TextStyle(fontSize: 18, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              backgroundColor: const Color(0xff6b4eff),
            ),
            onPressed: () {},
            child: const Text(
              "PLAY NOW",
              style: TextStyle(fontSize: 20),
            ),
          )
        ],
      ),
    );
  }
}

class GameInfoSection extends StatelessWidget {
  const GameInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: const [
          Text(
            "About the Game",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Mystic Hollow is a mysterious top-down pixel adventure game.\n\n"
            "Explore a cursed forest, discover hidden relics, and solve puzzles "
            "left behind by an ancient civilization.\n\n"
            "The deeper you go, the stranger the world becomes.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white70),
          )
        ],
      ),
    );
  }
}

class ScreenshotsSection extends StatelessWidget {
  const ScreenshotsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          const Text(
            "Screenshots",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            children: const [
              ScreenshotCard(),
              ScreenshotCard(),
              ScreenshotCard(),
            ],
          )
        ],
      ),
    );
  }
}

class ScreenshotCard extends StatelessWidget {
  const ScreenshotCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xff2c2c2c),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          "Game Screenshot",
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: const Color(0xff2a2633),
      child: const Center(
        child: Text(
          "© Mystic Hollow",
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}