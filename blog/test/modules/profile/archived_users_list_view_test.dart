import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:blog/modules/core/application_bloc.dart';
import 'package:blog/modules/core/application_event.dart';
import 'package:blog/modules/core/application_state.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/modules/profile/view/archived_users_list_view.dart';
import 'package:blog/shared/models/user.dart';
import 'package:blog/shared/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockApplicationBloc extends MockBloc<ApplicationEvent, ApplicationState>
    implements ApplicationBloc {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockApplicationBloc mockApplicationBloc;

  final user1 = User(
    id: 'user_1',
    authId: 'auth_1',
    email: 'user1@example.com',
    alias: 'User One',
    bio: 'Bio One',
    role: 'user',
    isLocked: true,
    createdAt: DateTime.now(),
    lastActivityAt: DateTime.now(),
  );

  final user2 = User(
    id: 'user_2',
    authId: 'auth_2',
    email: 'user2@example.com',
    alias: 'User Two',
    bio: 'Bio Two',
    role: 'user',
    isLocked: true,
    createdAt: DateTime.now(),
    lastActivityAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(
      const ApplicationNavigateEvent(
        route: HomeViewState.profile,
        userId: 'user_1',
      ),
    );
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockApplicationBloc = MockApplicationBloc();

    when(
      () => mockApplicationBloc.state,
    ).thenReturn(const ApplicationInitialState());
  });

  Future<void> pumpListView(WidgetTester tester, {double height = 400}) async {
    tester.view.physicalSize = Size(800, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: mockAuthRepository),
          BlocProvider<ApplicationBloc>.value(value: mockApplicationBloc),
        ],
        child: const MaterialApp(home: Scaffold(body: ArchivedUsersListView())),
      ),
    );
    await tester.pump();
  }

  group('ArchivedUsersListView Tests', () {
    testWidgets(
      'shows loading spinner while initial directory load is in progress',
      (WidgetTester tester) async {
        final completer = Completer<ArchivedUsersPaginatedResult>();
        when(
          () => mockAuthRepository.getArchivedUsersPage(limit: 10),
        ).thenAnswer((_) => completer.future);

        await pumpListView(tester);

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        completer.complete(
          ArchivedUsersPaginatedResult(users: [user1], hasMore: false),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('User One'), findsOneWidget);
      },
    );

    testWidgets('shows empty state when no archived users found', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthRepository.getArchivedUsersPage(limit: 10)).thenAnswer(
        (_) async => ArchivedUsersPaginatedResult(users: [], hasMore: false),
      );

      await pumpListView(tester);
      await tester.pumpAndSettle();

      expect(find.text('No archived users found.'), findsOneWidget);
    });

    testWidgets('shows error state and retries successfully', (
      WidgetTester tester,
    ) async {
      // First call throws error
      when(
        () => mockAuthRepository.getArchivedUsersPage(limit: 10),
      ).thenThrow(Exception('API error'));

      await pumpListView(tester);
      await tester.pumpAndSettle();

      expect(find.text('Unable to load archived users.'), findsOneWidget);
      final retryButton = find.text('Retry');
      expect(retryButton, findsOneWidget);

      // Stub next call to succeed
      when(() => mockAuthRepository.getArchivedUsersPage(limit: 10)).thenAnswer(
        (_) async =>
            ArchivedUsersPaginatedResult(users: [user1], hasMore: false),
      );

      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      expect(find.text('Unable to load archived users.'), findsNothing);
      expect(find.text('User One'), findsOneWidget);
    });

    testWidgets('tapping archived user dispatches ApplicationNavigateEvent', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthRepository.getArchivedUsersPage(limit: 10)).thenAnswer(
        (_) async =>
            ArchivedUsersPaginatedResult(users: [user1], hasMore: false),
      );

      await pumpListView(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('User One'));
      await tester.pumpAndSettle();

      verify(
        () => mockApplicationBloc.add(
          const ApplicationNavigateEvent(
            route: HomeViewState.profile,
            userId: 'user_1',
          ),
        ),
      ).called(1);
    });

    testWidgets(
      'infinite scroll pagination loads older pages and handles scroll failure retry',
      (WidgetTester tester) async {
        // Page 1
        when(
          () => mockAuthRepository.getArchivedUsersPage(limit: 10),
        ).thenAnswer(
          (_) async => ArchivedUsersPaginatedResult(
            users: [user1],
            hasMore: true,
            nextCursor: 'cursor_page_1',
          ),
        );

        // Pump on a short viewport so list scrolls
        await pumpListView(tester, height: 250);
        await tester.pumpAndSettle();

        expect(find.text('User One'), findsOneWidget);
        expect(find.text('User Two'), findsNothing);

        // Page 2 fails
        when(
          () => mockAuthRepository.getArchivedUsersPage(
            limit: 10,
            cursor: 'cursor_page_1',
          ),
        ).thenThrow(Exception('Failed to load page 2'));

        // Drag/scroll list down to trigger pagination
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();

        // Temporarily increase viewport size so the Retry footer button is built and within hit-test bounds
        tester.view.physicalSize = const Size(800, 500);
        await tester.pumpAndSettle();

        // Show retry footer
        final footerRetry = find.widgetWithText(OutlinedButton, 'Retry');
        expect(footerRetry, findsOneWidget);

        // Page 2 succeeds on retry
        when(
          () => mockAuthRepository.getArchivedUsersPage(
            limit: 10,
            cursor: 'cursor_page_1',
          ),
        ).thenAnswer(
          (_) async =>
              ArchivedUsersPaginatedResult(users: [user2], hasMore: false),
        );

        await tester.tap(footerRetry);
        await tester.pumpAndSettle();

        // Increase viewport size so User Two is built and visible in the list view
        tester.view.physicalSize = const Size(800, 800);
        await tester.pumpAndSettle();

        expect(find.text('User One'), findsOneWidget);
        expect(find.text('User Two'), findsOneWidget);
        expect(find.widgetWithText(OutlinedButton, 'Retry'), findsNothing);
      },
    );
  });
}
