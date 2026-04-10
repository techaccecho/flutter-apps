import 'package:blog/modules/core/application_bloc.dart';
import 'package:blog/modules/core/application_repository.dart';
import 'package:blog/modules/home/view/home_view.dart';
import 'package:blog/resources/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        title: 'Blog.NET',
        theme: AppTheme.light(),
        home: const HomeView(),
      ),
    );
  }
}