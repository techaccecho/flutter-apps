import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:blog/shared/models/user.dart';
import 'package:blog/shared/repositories/auth_repository.dart';
import 'package:blog/shared/services/auth0_service.dart';
import 'package:blog/shared/services/authentication_service.dart';
import 'package:blog/shared/util/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuth0Service extends Mock implements Auth0Service {}
class MockAuth0Web extends Mock implements Auth0Web {}
class MockCredentials extends Mock implements Credentials {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuth0Service mockAuth0Service;
  late MockAuth0Web mockAuth0Web;
  late AuthenticationService authService;

  final testUser = User(
    id: 'user_123',
    authId: 'auth_123',
    email: 'user@example.com',
    role: 'user',
    isLocked: false,
    createdAt: DateTime.now(),
    lastActivityAt: DateTime.now(),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuth0Service = MockAuth0Service();
    mockAuth0Web = MockAuth0Web();

    when(() => mockAuth0Service.auth0Web).thenReturn(mockAuth0Web);

    authService = AuthenticationService(
      authRepository: mockAuthRepository,
      auth0Service: mockAuth0Service,
    );
  });

  group('AuthenticationService Tests', () {
    group('init() tests', () {
      test('init returns authenticated user when credentials exist on load', () async {
        final mockCredentials = MockCredentials();
        when(() => mockAuth0Web.onLoad(
              audience: any(named: 'audience'),
              cacheLocation: any(named: 'cacheLocation'),
            )).thenAnswer((_) async => mockCredentials);

        when(() => mockAuthRepository.authenticate()).thenAnswer((_) async => testUser);

        final result = await authService.init();

        expect(result, testUser);
        verify(() => mockAuth0Web.onLoad(
              audience: AppConfig.audience,
              cacheLocation: CacheLocation.localStorage,
            )).called(1);
        verify(() => mockAuthRepository.authenticate()).called(1);
      });

      test('init returns null when onLoad returns null credentials', () async {
        when(() => mockAuth0Web.onLoad(
              audience: any(named: 'audience'),
              cacheLocation: any(named: 'cacheLocation'),
            )).thenAnswer((_) async => null);

        final result = await authService.init();

        expect(result, isNull);
        verifyNever(() => mockAuthRepository.authenticate());
      });

      test('init returns null and recovers gracefully when onLoad throws', () async {
        when(() => mockAuth0Web.onLoad(
              audience: any(named: 'audience'),
              cacheLocation: any(named: 'cacheLocation'),
            )).thenThrow(Exception('Auth0 load failed'));

        final result = await authService.init();

        expect(result, isNull);
        verifyNever(() => mockAuthRepository.authenticate());
      });
    });

    group('login() tests', () {
      test('login calls loginWithRedirect on Auth0Web', () async {
        when(() => mockAuth0Web.loginWithRedirect(
              redirectUrl: any(named: 'redirectUrl'),
              audience: any(named: 'audience'),
            )).thenAnswer((_) async => {});

        await authService.login();

        verify(() => mockAuth0Web.loginWithRedirect(
              redirectUrl: AppConfig.redirectUrl,
              audience: AppConfig.audience,
            )).called(1);
      });

      test('login handles error and completes gracefully when redirection throws', () async {
        when(() => mockAuth0Web.loginWithRedirect(
              redirectUrl: any(named: 'redirectUrl'),
              audience: any(named: 'audience'),
            )).thenThrow(Exception('Redirect failed'));

        await authService.login();
        // Should complete without throwing exception
      });
    });

    group('logout() tests', () {
      test('logout calls logout on Auth0Web', () async {
        when(() => mockAuth0Web.logout(
              returnToUrl: any(named: 'returnToUrl'),
            )).thenAnswer((_) async => {});

        await authService.logout();

        verify(() => mockAuth0Web.logout(
              returnToUrl: AppConfig.redirectUrl,
            )).called(1);
      });

      test('logout handles error and completes gracefully when logout throws', () async {
        when(() => mockAuth0Web.logout(
              returnToUrl: any(named: 'returnToUrl'),
            )).thenThrow(Exception('Logout failed'));

        await authService.logout();
        // Should complete without throwing exception
      });
    });

    group('isLoggedIn() tests', () {
      test('isLoggedIn returns true when hasValidCredentials returns true', () async {
        when(() => mockAuth0Web.hasValidCredentials()).thenAnswer((_) async => true);

        final result = await authService.isLoggedIn();

        expect(result, isTrue);
      });

      test('isLoggedIn returns false when hasValidCredentials returns false', () async {
        when(() => mockAuth0Web.hasValidCredentials()).thenAnswer((_) async => false);

        final result = await authService.isLoggedIn();

        expect(result, isFalse);
      });

      test('isLoggedIn returns false when hasValidCredentials throws', () async {
        when(() => mockAuth0Web.hasValidCredentials()).thenThrow(Exception('Check credentials failed'));

        final result = await authService.isLoggedIn();

        expect(result, isFalse);
      });
    });

    group('getAccessToken() tests', () {
      test('getAccessToken returns access token when credentials exist', () async {
        final mockCredentials = MockCredentials();
        when(() => mockCredentials.accessToken).thenReturn('test_access_token');

        when(() => mockAuth0Web.credentials(
              audience: any(named: 'audience'),
            )).thenAnswer((_) async => mockCredentials);

        final result = await authService.getAccessToken();

        expect(result, 'test_access_token');
        verify(() => mockAuth0Web.credentials(audience: AppConfig.audience)).called(1);
      });

      test('getAccessToken returns null when fetching credentials throws', () async {
        when(() => mockAuth0Web.credentials(
              audience: any(named: 'audience'),
            )).thenThrow(Exception('Fetch credentials failed'));

        final result = await authService.getAccessToken();

        expect(result, isNull);
      });
    });
  });
}
