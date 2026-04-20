import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/bloc/application/application.dart';
import 'package:flutter_template/component/landing/landing_error.dart';
import 'package:flutter_template/component/landing/landing_success.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key, required this.title});

  final String title;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {

  @override
  void initState() {
    // TODO: Just here to show that we can do this
    super.initState();
  }

  @override
  void dispose() {
    // TODO: Just here to show that we should do this if we have controllers or listeners we need to dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: BlocBuilder<ApplicationBloc, ApplicationState>(builder: (context, state) {

          if (state is ApplicationContentLoadedState) {
            return LandingSuccess(title: state.title, description: state.description);
          } else if (state is ApplicationContentFailedState) {
            return LandingError(title: state.title, description: state.description);
          }

          return Column(
            mainAxisAlignment: .center,
            children: [
              if (state is ApplicationLoadingState) ...[
                const Text('Blog.NET is loading...'),
              ] else ...[
                const Text('Welcome...')
              ]
            ],
          );
        })
      )
    );
  }
}
