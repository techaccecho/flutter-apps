import 'package:blog/modules/core/application_bloc.dart';
import 'package:blog/modules/core/application_repository.dart';
import 'package:blog/modules/home/view/home_view.dart';
import 'package:blog/modules/blog/bloc/blog_post_repository.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_repository.dart';
import 'package:blog/resources/app_theme.dart';
import 'package:blog/shared/services/authentication_service.dart';
import 'package:blog/shared/repositories/auth_repository.dart';
import 'package:blog/shared/providers/auth_api_provider.dart';
import 'package:blog/shared/providers/blog_api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:blog/shared/util/app_config.dart';
import 'package:dio/dio.dart';
import 'package:blog/shared/interceptors/auth_interceptor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.blogApiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final authApiProvider = AuthApiProvider(dio);
    final authRepository = AuthRepository(apiProvider: authApiProvider);
    final authenticationService = AuthenticationService(
      authRepository: authRepository,
    );
    final blogApiProvider = BlogApiProvider(dio);
    final blogPostRepository = BlogPostRepository(apiProvider: blogApiProvider);
    final chatForumRepository = ChatForumRepository(
      apiProvider: blogApiProvider,
    );

    dio.interceptors.addAll([
      AuthInterceptor(authService: authenticationService),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);

    final ApplicationBloc applicationBloc = ApplicationBloc(
      repository: ApplicationRepository(
        authenticationService: authenticationService,
      ),
    );

    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(create: (_) => authenticationService),
        Provider<AuthRepository>(create: (_) => authRepository),
        Provider<BlogApiProvider>(create: (_) => blogApiProvider),
        Provider<BlogPostRepository>(create: (_) => blogPostRepository),
        Provider<ChatForumRepository>(create: (_) => chatForumRepository),
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
