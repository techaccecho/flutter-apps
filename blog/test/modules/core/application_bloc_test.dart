import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:blog/modules/core/application_bloc.dart';
import 'package:blog/modules/core/application_event.dart';
import 'package:blog/modules/core/application_repository.dart';
import 'package:blog/modules/core/application_state.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/shared/models/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApplicationRepository extends Mock implements ApplicationRepository {}

void main() {
  late MockApplicationRepository mockRepository;
  late ApplicationBloc applicationBloc;

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
    mockRepository = MockApplicationRepository();
    // Stub stream returned by repository data getter to prevent null stream errors
    when(() => mockRepository.data).thenAnswer((_) => const Stream.empty());
    // Stub dispose to prevent errors during teardown
    when(() => mockRepository.dispose()).thenAnswer((_) async => {});

    applicationBloc = ApplicationBloc(repository: mockRepository);
  });

  tearDown(() {
    applicationBloc.close();
  });

  group('ApplicationBloc Tests', () {
    blocTest<ApplicationBloc, ApplicationState>(
      'ApplicationStartupEvent emits ApplicationContentLoadedState with login status and user, and default route as blog',
      build: () {
        when(() => mockRepository.initialiseAuth()).thenAnswer((_) async => {});
        when(() => mockRepository.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockRepository.currentUser).thenReturn(testUser);
        return applicationBloc;
      },
      act: (bloc) => bloc.add(const ApplicationStartupEvent()),
      expect: () => [
        isA<ApplicationContentLoadedState>()
            .having((s) => s.isLoggedIn, 'isLoggedIn', true)
            .having((s) => s.currentUser?.id, 'currentUser.id', 'user_123')
            .having((s) => s.route, 'route', HomeViewState.blog),
      ],
    );

    blocTest<ApplicationBloc, ApplicationState>(
      'ApplicationStartupEvent handles logged-out startup with no current user',
      build: () {
        when(() => mockRepository.initialiseAuth()).thenAnswer((_) async => {});
        when(() => mockRepository.isLoggedIn()).thenAnswer((_) async => false);
        when(() => mockRepository.currentUser).thenReturn(null);
        return applicationBloc;
      },
      act: (bloc) => bloc.add(const ApplicationStartupEvent()),
      expect: () => [
        isA<ApplicationContentLoadedState>()
            .having((s) => s.isLoggedIn, 'isLoggedIn', false)
            .having((s) => s.currentUser, 'currentUser', isNull)
            .having((s) => s.route, 'route', HomeViewState.blog),
      ],
    );

    group('ApplicationNavigateEvent', () {
      blocTest<ApplicationBloc, ApplicationState>(
        'updates route and preserves login status and current user',
        build: () {
          when(() => mockRepository.isLoggedIn()).thenAnswer((_) async => true);
          when(() => mockRepository.currentUser).thenReturn(testUser);
          return applicationBloc;
        },
        act: (bloc) => bloc.add(
          const ApplicationNavigateEvent(route: HomeViewState.chatForum),
        ),
        expect: () => [
          isA<ApplicationContentLoadedState>()
              .having((s) => s.route, 'route', HomeViewState.chatForum)
              .having((s) => s.isLoggedIn, 'isLoggedIn', true)
              .having((s) => s.currentUser, 'currentUser', testUser),
        ],
        verify: (bloc) {
          expect(bloc.currentRoute, HomeViewState.chatForum);
        },
      );

      blocTest<ApplicationBloc, ApplicationState>(
        'sets viewUserId from explicit userId when provided',
        build: () {
          when(() => mockRepository.isLoggedIn()).thenAnswer((_) async => true);
          when(() => mockRepository.currentUser).thenReturn(testUser);
          return applicationBloc;
        },
        act: (bloc) => bloc.add(
          const ApplicationNavigateEvent(
            route: HomeViewState.profile,
            userId: 'user_456',
          ),
        ),
        expect: () => [
          isA<ApplicationContentLoadedState>()
              .having((s) => s.route, 'route', HomeViewState.profile)
              .having((s) => s.viewUserId, 'viewUserId', 'user_456'),
        ],
      );

      blocTest<ApplicationBloc, ApplicationState>(
        'sets viewUserId to current user ID when navigating to profile without explicit userId',
        build: () {
          when(() => mockRepository.isLoggedIn()).thenAnswer((_) async => true);
          when(() => mockRepository.currentUser).thenReturn(testUser);
          return applicationBloc;
        },
        act: (bloc) => bloc.add(
          const ApplicationNavigateEvent(route: HomeViewState.profile),
        ),
        expect: () => [
          isA<ApplicationContentLoadedState>()
              .having((s) => s.route, 'route', HomeViewState.profile)
              .having((s) => s.viewUserId, 'viewUserId', 'user_123'),
        ],
      );

      blocTest<ApplicationBloc, ApplicationState>(
        'clears viewUserId for non-profile routes',
        build: () {
          when(() => mockRepository.isLoggedIn()).thenAnswer((_) async => true);
          when(() => mockRepository.currentUser).thenReturn(testUser);
          return applicationBloc;
        },
        act: (bloc) =>
            bloc.add(const ApplicationNavigateEvent(route: HomeViewState.faq)),
        expect: () => [
          isA<ApplicationContentLoadedState>()
              .having((s) => s.route, 'route', HomeViewState.faq)
              .having((s) => s.viewUserId, 'viewUserId', isNull),
        ],
      );
    });

    group('login/logout events', () {
      blocTest<ApplicationBloc, ApplicationState>(
        'ApplicationLoginEvent calls repository login and emits content state with updated status',
        build: () {
          when(() => mockRepository.login()).thenAnswer((_) async => {});
          when(() => mockRepository.isLoggedIn()).thenAnswer((_) async => true);
          when(() => mockRepository.currentUser).thenReturn(testUser);
          return applicationBloc;
        },
        act: (bloc) => bloc.add(const ApplicationLoginEvent()),
        expect: () => [
          isA<ApplicationContentLoadedState>()
              .having((s) => s.isLoggedIn, 'isLoggedIn', true)
              .having((s) => s.currentUser, 'currentUser', testUser)
              .having((s) => s.route, 'route', HomeViewState.blog),
        ],
        verify: (bloc) {
          verify(() => mockRepository.login()).called(1);
        },
      );

      blocTest<ApplicationBloc, ApplicationState>(
        'ApplicationLogoutEvent calls repository logout, resets route to blog, and clears user',
        build: () {
          when(() => mockRepository.logout()).thenAnswer((_) async => {});
          when(
            () => mockRepository.isLoggedIn(),
          ).thenAnswer((_) async => false);
          when(() => mockRepository.currentUser).thenReturn(null);
          // Set initial route to something else to verify reset
          applicationBloc.currentRoute = HomeViewState.faq;
          return applicationBloc;
        },
        act: (bloc) => bloc.add(const ApplicationLogoutEvent()),
        expect: () => [
          isA<ApplicationContentLoadedState>()
              .having((s) => s.isLoggedIn, 'isLoggedIn', false)
              .having((s) => s.currentUser, 'currentUser', isNull)
              .having((s) => s.route, 'route', HomeViewState.blog),
        ],
        verify: (bloc) {
          verify(() => mockRepository.logout()).called(1);
          expect(applicationBloc.currentRoute, HomeViewState.blog);
        },
      );
    });

    group('ApplicationUpdateUserEvent', () {
      final updatedUser = User(
        id: 'user_123',
        authId: 'auth_123',
        email: 'user@example.com',
        role: 'user',
        isLocked: false,
        alias: 'NewAlias',
        createdAt: testUser.createdAt,
        lastActivityAt: testUser.lastActivityAt,
      );

      blocTest<ApplicationBloc, ApplicationState>(
        'updates user and preserves route and existing viewUserId',
        seed: () => const ApplicationContentLoadedState(
          route: HomeViewState.profile,
          isLoggedIn: true,
          timestamp: 0,
          currentUser: null,
          viewUserId: 'user_456',
        ),
        build: () {
          when(
            () => mockRepository.updateCurrentUser(updatedUser),
          ).thenAnswer((_) {});
          when(() => mockRepository.isLoggedIn()).thenAnswer((_) async => true);
          return applicationBloc;
        },
        act: (bloc) {
          bloc.currentRoute = HomeViewState.profile;
          bloc.add(ApplicationUpdateUserEvent(updatedUser));
        },
        expect: () => [
          isA<ApplicationContentLoadedState>()
              .having((s) => s.isLoggedIn, 'isLoggedIn', true)
              .having((s) => s.currentUser, 'currentUser', updatedUser)
              .having((s) => s.route, 'route', HomeViewState.profile)
              .having((s) => s.viewUserId, 'viewUserId', 'user_456'),
        ],
        verify: (bloc) {
          verify(() => mockRepository.updateCurrentUser(updatedUser)).called(1);
        },
      );
    });

    group('Repository stream handling', () {
      test(
        'subscribes to repository data stream, forwards events, cancels subscription, and disposes repo',
        () async {
          final controller = StreamController<ApplicationEvent>();
          final repo = MockApplicationRepository();
          when(() => repo.data).thenAnswer((_) => controller.stream);
          when(() => repo.dispose()).thenAnswer((_) async => {});

          final bloc = ApplicationBloc(repository: repo);
          expect(controller.hasListener, isTrue);

          // Emit an event through repository and check if bloc handles it
          // We need to stub repo.isLoggedIn and repo.currentUser to prevent throws in event handler
          when(() => repo.isLoggedIn()).thenAnswer((_) async => true);
          when(() => repo.currentUser).thenReturn(testUser);

          final stateExpectation = expectLater(
            bloc.stream,
            emits(
              isA<ApplicationContentLoadedState>().having(
                (s) => s.route,
                'route',
                HomeViewState.faq,
              ),
            ),
          );

          controller.add(
            const ApplicationNavigateEvent(route: HomeViewState.faq),
          );
          await stateExpectation;

          await bloc.close();

          expect(controller.hasListener, isFalse);
          verify(() => repo.dispose()).called(1);
          await controller.close();
        },
      );
    });
  });
}
