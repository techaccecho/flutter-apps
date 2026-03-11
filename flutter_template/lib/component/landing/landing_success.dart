import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/bloc/application/application.dart';

class LandingSuccess extends StatelessWidget {

  final String title;
  final String description;

  const LandingSuccess({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      children: [
        Text(title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(description),
        ElevatedButton(
          onPressed: () => { context.read<ApplicationBloc>().add(const ApplicationRefreshEvent()) }, 
          child: Text("Refresh"),
        ),
        ElevatedButton(
          onPressed: () => { context.read<ApplicationBloc>().add(const ApplicationRefreshEvent(forceError: true)) }, 
          child: Text("Force error"),
        )
      ],
    );
  }
}