import 'package:game/modules/home/view/home_view.dart';
import 'package:game/resources/app_theme.dart';
import 'package:game/resources/app_strings.dart';
import 'package:game/shared/bloc/app/app.dart';
import 'package:game/shared/util/app_config.dart';
import 'package:game/shared/util/auth/auth0_service.dart';
import 'package:game/shared/util/auth/auth_api_provider.dart';
import 'package:game/shared/util/auth/auth_repository.dart';
import 'package:game/shared/util/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.gameApiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final auth0Service = Auth0Service();
    final authApiProvider = AuthApiProvider(dio);
    final authRepository = AuthRepository(apiProvider: authApiProvider);
    // Falls back to Auth0-only user data when the backend /auth call fails.
    final authService = AuthService(
      authRepository: authRepository,
      auth0Service: auth0Service,
    );

    final appBloc = AppBloc(
      repository: AppRepository(authenticationService: authService),
    );

    return MultiProvider(
      providers: [
        Provider<Auth0Service>(create: (_) => auth0Service),
        Provider<AuthRepository>(create: (_) => authRepository),
        Provider<AuthService>(create: (_) => authService),
        BlocProvider<AppBloc>(
          create: (_) => appBloc..add(const AppStartupEvent()),
        ),
      ],
      child: MaterialApp(
        title: Strings.appName,
        theme: AppTheme.light(),
        home: const HomeView(),
      ),
    );
  }
}
