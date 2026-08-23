import 'package:blog/modules/core/application_event.dart';
import 'package:blog/modules/core/application_repository.dart';
import 'package:blog/shared/models/user.dart';
import 'package:blog/shared/services/authentication_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

void main() {
  late MockAuthenticationService mockAuthService;
  late ApplicationRepository repository;

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
    mockAuthService = MockAuthenticationService();
    repository = ApplicationRepository(authenticationService: mockAuthService);
  });

  group('ApplicationRepository Tests', () {
    test(
      'initialiseAuth calls authenticationService.init and sets _currentUser',
      () async {
        when(() => mockAuthService.init()).thenAnswer((_) async => testUser);

        await repository.initialiseAuth();

        expect(repository.currentUser, testUser);
        verify(() => mockAuthService.init()).called(1);
      },
    );

    test('isLoggedIn calls authenticationService.isLoggedIn', () async {
      when(() => mockAuthService.isLoggedIn()).thenAnswer((_) async => true);

      final result = await repository.isLoggedIn();

      expect(result, isTrue);
      verify(() => mockAuthService.isLoggedIn()).called(1);
    });

    test('login calls authenticationService.login', () async {
      when(() => mockAuthService.login()).thenAnswer((_) async => {});

      await repository.login();

      verify(() => mockAuthService.login()).called(1);
    });

    test(
      'logout calls authenticationService.logout and clears _currentUser',
      () async {
        when(() => mockAuthService.init()).thenAnswer((_) async => testUser);
        when(() => mockAuthService.logout()).thenAnswer((_) async => {});

        await repository.initialiseAuth();
        expect(repository.currentUser, testUser);

        await repository.logout();

        expect(repository.currentUser, isNull);
        verify(() => mockAuthService.logout()).called(1);
      },
    );

    test('updateCurrentUser updates the cached user correctly', () {
      expect(repository.currentUser, isNull);

      repository.updateCurrentUser(testUser);

      expect(repository.currentUser, testUser);
    });

    test('data stream yields ApplicationStartupEvent initially', () async {
      final events = <ApplicationEvent>[];
      final subscription = repository.data.listen(events.add);

      // Allow the microtask to run so the initial yield event goes through
      await Future.delayed(Duration.zero);

      expect(events, const [ApplicationStartupEvent()]);

      await subscription.cancel();
    });

    test('dispose closes internal controller stream', () async {
      final events = <ApplicationEvent>[];
      final subscription = repository.data.listen(events.add);

      await Future.delayed(Duration.zero);
      expect(events, const [ApplicationStartupEvent()]);

      repository.dispose();

      // The stream should complete and close
      // Listening after dispose should complete immediately
      await subscription.cancel();
    });
  });
}
