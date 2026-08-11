import 'dart:async';
import 'dart:typed_data';

import 'package:blog/shared/interceptors/auth_interceptor.dart';
import 'package:blog/shared/services/authentication_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

class CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;
  int statusCode = 200;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody.fromString(
      statusCode == 200 ? '{"ok":true}' : '{"error":"Unauthorized"}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  late MockAuthenticationService authService;
  late CapturingAdapter adapter;
  late Dio dio;

  setUp(() {
    authService = MockAuthenticationService();
    adapter = CapturingAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(authService: authService));
  });

  group('AuthInterceptor', () {
    test(
      'adds bearer authorization header when an access token is available',
      () async {
        when(
          () => authService.getAccessToken(),
        ).thenAnswer((_) async => 'token_123');

        await dio.get<dynamic>('/protected');

        expect(
          adapter.lastOptions?.headers['Authorization'],
          'Bearer token_123',
        );
      },
    );

    test(
      'leaves request headers unchanged when no token is available',
      () async {
        when(() => authService.getAccessToken()).thenAnswer((_) async => null);

        await dio.get<dynamic>('/public');

        expect(
          adapter.lastOptions?.headers.containsKey('Authorization'),
          isFalse,
        );
      },
    );

    group('onError', () {
      test(
        'calls authService.logout() when request fails with 401 and contains Authorization header',
        () async {
          adapter.statusCode = 401;
          when(() => authService.getAccessToken()).thenAnswer((_) async => 'token_123');
          when(() => authService.logout()).thenAnswer((_) async => {});

          try {
            await dio.get<dynamic>('/protected');
          } catch (_) {
            // Expected to throw DioException
          }

          verify(() => authService.logout()).called(1);
        },
      );

      test(
        'does not call authService.logout() when request fails with 401 but contains no Authorization header',
        () async {
          adapter.statusCode = 401;
          when(() => authService.getAccessToken()).thenAnswer((_) async => null);

          try {
            await dio.get<dynamic>('/public');
          } catch (_) {
            // Expected to throw DioException
          }

          verifyNever(() => authService.logout());
        },
      );

      test(
        'does not call authService.logout() when request fails with other status code (e.g. 403) even with Authorization header',
        () async {
          adapter.statusCode = 403;
          when(() => authService.getAccessToken()).thenAnswer((_) async => 'token_123');

          try {
            await dio.get<dynamic>('/forbidden');
          } catch (_) {
            // Expected to throw DioException
          }

          verifyNever(() => authService.logout());
        },
      );
    });
  });
}

