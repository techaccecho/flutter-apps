import 'package:flutter/material.dart';

class Chat extends StatelessWidget {

  final String title;
  final int participants;

  const Chat({super.key, required this.title, required this.participants});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
      children: [
        Text(title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text("Participants: $participants"),
      ],
    );
  }
}