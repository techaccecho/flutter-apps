import 'package:blog/resources/resources.dart';
import 'package:flutter/material.dart';

class RaisedButton extends StatelessWidget {

  final VoidCallback action;
  final String title;

  const RaisedButton({super.key, required this.action, required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => action(),
      child: Container(
        alignment: Alignment.center,
        height: 24,
        width: double.infinity,
        color: const Color.fromARGB(255, 220, 224, 230),
        padding: MediaQuery.of(context).size.width > 600 ? null : const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
        child: Text(title, style: AppTextStyles.button),
      ),
    );
  }
}