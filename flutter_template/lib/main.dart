import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/bloc/application/application.dart';
import 'package:flutter_template/component/landing/landing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final ApplicationBloc applicationBloc =
        ApplicationBloc(repository: ApplicationRepository());

    return MultiBlocProvider(
      providers: [
        BlocProvider<ApplicationBloc>(create: (_) => applicationBloc),
      ],
      child: MaterialApp(
        title: 'Project Echo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 24, 113, 197)),
        ),
        home: const LandingScreen(title: 'Project Echo'),
      ),
    );
  }
}