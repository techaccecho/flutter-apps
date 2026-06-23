// lib/modules/core/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:blog/shared/services/authentication_service.dart';

class AuthInterceptor extends Interceptor {
  final AuthenticationService authService;

  AuthInterceptor({required this.authService});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await authService.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      authService.logout();
    }
    return handler.next(err);
  }
}
