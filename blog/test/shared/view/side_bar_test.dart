import 'package:bloc_test/bloc_test.dart';
import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_state.dart';
import 'package:blog/modules/core/application_bloc.dart';
import 'package:blog/modules/core/application_event.dart';
import 'package:blog/modules/core/application_state.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/shared/models/user.dart';
import 'package:blog/shared/view/nav_item.dart';
import 'package:blog/shared/view/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBlogBloc extends MockBloc<BlogEvent, BlogState> implements BlogBloc {}

class MockChatForumBloc extends MockBloc<ChatForumEvent, ChatForumState>
    implements ChatForumBloc {}

class MockApplicationBloc extends MockBloc<ApplicationEvent, ApplicationState>
    implements ApplicationBloc {}

void main() {
  late MockBlogBloc mockBlogBloc;
  late MockChatForumBloc mockChatForumBloc;
  late MockApplicationBloc mockApplicationBloc;

  final adminUser = User(
    id: 'admin_123',
    authId: 'auth_admin',
    email: 'admin@example.com',
    alias: 'admin_alias',
    role: Strings.roleAdmin,
    isLocked: false,
    createdAt: DateTime.now(),
    lastActivityAt: DateTime.now(),
  );

  final regularUser = User(
    id: 'user_123',
    authId: 'auth_user',
    email: 'user@example.com',
    alias: 'user_alias',
    role: 'user',
    isLocked: false,
    createdAt: DateTime.now(),
    lastActivityAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(LoadBlogPostsEvent());
    registerFallbackValue(ChatForumLoadEvent());
    registerFallbackValue(
      const ApplicationNavigateEvent(route: HomeViewState.blog),
    );
    registerFallbackValue(ApplicationLoginEvent());
    registerFallbackValue(ApplicationLogoutEvent());
  });

  setUp(() {
    mockBlogBloc = MockBlogBloc();
    mockChatForumBloc = MockChatForumBloc();
    mockApplicationBloc = MockApplicationBloc();

    when(() => mockBlogBloc.state).thenReturn(BlogLoadingState());
    when(
      () => mockChatForumBloc.state,
    ).thenReturn(const ChatForumLoadingState());
    when(
      () => mockApplicationBloc.state,
    ).thenReturn(const ApplicationInitialState());
  });

  Future<void> pumpSidebar(
    WidgetTester tester, {
    bool insideDrawer = false,
  }) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<BlogBloc>.value(value: mockBlogBloc),
          BlocProvider<ChatForumBloc>.value(value: mockChatForumBloc),
          BlocProvider<ApplicationBloc>.value(value: mockApplicationBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            drawer: insideDrawer ? const Sidebar() : null,
            body: insideDrawer
                ? Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      child: const Text('Open'),
                    ),
                  )
                : const Sidebar(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('Sidebar Widget Tests', () {
    testWidgets('displays sidebar branding and basic headers', (
      WidgetTester tester,
    ) async {
      when(() => mockApplicationBloc.state).thenReturn(
        const ApplicationContentLoadedState(
          route: HomeViewState.blog,
          isLoggedIn: false,
          timestamp: 0,
          currentUser: null,
        ),
      );

      await pumpSidebar(tester);

      expect(find.text(Strings.appName), findsOneWidget);
      expect(find.text(Strings.titleAccount), findsOneWidget);
      expect(find.text(Strings.titleNavigation), findsOneWidget);
      expect(find.text(Strings.titleAbout), findsOneWidget);
    });

    group('Authentication Section Tests', () {
      testWidgets('logged out state shows Sign In button', (
        WidgetTester tester,
      ) async {
        when(() => mockApplicationBloc.state).thenReturn(
          const ApplicationContentLoadedState(
            route: HomeViewState.blog,
            isLoggedIn: false,
            timestamp: 0,
            currentUser: null,
          ),
        );

        await pumpSidebar(tester);

        expect(find.text(Strings.linkSignIn), findsOneWidget);
        expect(find.text(Strings.welcome), findsNothing);
        expect(find.text(Strings.btnSigOut), findsNothing);

        // Tap Sign In -> verify login event dispatched
        await tester.tap(find.text(Strings.linkSignIn));
        verify(
          () =>
              mockApplicationBloc.add(any(that: isA<ApplicationLoginEvent>())),
        ).called(1);
      });

      testWidgets(
        'logged in state shows welcome, username, and sign out button',
        (WidgetTester tester) async {
          when(() => mockApplicationBloc.state).thenReturn(
            ApplicationContentLoadedState(
              route: HomeViewState.blog,
              isLoggedIn: true,
              timestamp: 0,
              currentUser: regularUser,
            ),
          );

          await pumpSidebar(tester);

          expect(find.text(Strings.linkSignIn), findsNothing);
          expect(find.text(Strings.welcome), findsOneWidget);
          expect(find.text('user_alias'), findsOneWidget);
          expect(find.text(Strings.btnSigOut), findsOneWidget);

          // Tap Sign Out -> verify logout event dispatched
          await tester.tap(find.text(Strings.btnSigOut));
          verify(
            () => mockApplicationBloc.add(
              any(that: isA<ApplicationLogoutEvent>()),
            ),
          ).called(1);
        },
      );
    });

    group('Navigation Visibility Rules', () {
      testWidgets(
        'logged out: shows home, forums, faq, hides profile and archived',
        (WidgetTester tester) async {
          when(() => mockApplicationBloc.state).thenReturn(
            const ApplicationContentLoadedState(
              route: HomeViewState.blog,
              isLoggedIn: false,
              timestamp: 0,
              currentUser: null,
            ),
          );

          await pumpSidebar(tester);

          expect(find.text(Strings.linkHome), findsOneWidget);
          expect(find.text(Strings.linkForums), findsOneWidget);
          expect(find.text(Strings.linkRulesOfEngagementFaq), findsOneWidget);
          expect(find.text(Strings.linkProfile), findsNothing);
          expect(find.text(Strings.linkArchived), findsNothing);
        },
      );

      testWidgets('logged in regular user: shows profile, hides archived', (
        WidgetTester tester,
      ) async {
        when(() => mockApplicationBloc.state).thenReturn(
          ApplicationContentLoadedState(
            route: HomeViewState.blog,
            isLoggedIn: true,
            timestamp: 0,
            currentUser: regularUser,
          ),
        );

        await pumpSidebar(tester);

        expect(find.text(Strings.linkHome), findsOneWidget);
        expect(find.text(Strings.linkProfile), findsOneWidget);
        expect(find.text(Strings.linkArchived), findsNothing);
      });

      testWidgets('logged in admin: shows profile and archived directory', (
        WidgetTester tester,
      ) async {
        when(() => mockApplicationBloc.state).thenReturn(
          ApplicationContentLoadedState(
            route: HomeViewState.blog,
            isLoggedIn: true,
            timestamp: 0,
            currentUser: adminUser,
          ),
        );

        await pumpSidebar(tester);

        expect(find.text(Strings.linkProfile), findsOneWidget);
        expect(find.text(Strings.linkArchived), findsOneWidget);
      });
    });

    group('Highlights Active State', () {
      testWidgets('highlights Home/Blog when route is blog', (
        WidgetTester tester,
      ) async {
        when(() => mockApplicationBloc.state).thenReturn(
          const ApplicationContentLoadedState(
            route: HomeViewState.blog,
            isLoggedIn: false,
            timestamp: 0,
            currentUser: null,
          ),
        );

        await pumpSidebar(tester);

        final homeItem = tester.widget<NavItem>(
          find.widgetWithText(NavItem, Strings.linkHome),
        );
        final forumItem = tester.widget<NavItem>(
          find.widgetWithText(NavItem, Strings.linkForums),
        );

        expect(homeItem.isSelected, isTrue);
        expect(forumItem.isSelected, isFalse);
      });

      testWidgets('highlights Forum when route is chatForum', (
        WidgetTester tester,
      ) async {
        when(() => mockApplicationBloc.state).thenReturn(
          const ApplicationContentLoadedState(
            route: HomeViewState.chatForum,
            isLoggedIn: false,
            timestamp: 0,
            currentUser: null,
          ),
        );

        await pumpSidebar(tester);

        final homeItem = tester.widget<NavItem>(
          find.widgetWithText(NavItem, Strings.linkHome),
        );
        final forumItem = tester.widget<NavItem>(
          find.widgetWithText(NavItem, Strings.linkForums),
        );

        expect(homeItem.isSelected, isFalse);
        expect(forumItem.isSelected, isTrue);
      });
    });

    group('Navigation Tap Dispatch Rules', () {
      testWidgets(
        'tapping Home/Blog dispatches LoadBlogPostsEvent and ApplicationNavigateEvent',
        (WidgetTester tester) async {
          when(() => mockApplicationBloc.state).thenReturn(
            const ApplicationContentLoadedState(
              route: HomeViewState.faq,
              isLoggedIn: false,
              timestamp: 0,
              currentUser: null,
            ),
          );

          await pumpSidebar(tester);

          await tester.tap(find.text(Strings.linkHome));

          verify(
            () => mockBlogBloc.add(any(that: isA<LoadBlogPostsEvent>())),
          ).called(1);
          verify(
            () => mockApplicationBloc.add(
              const ApplicationNavigateEvent(route: HomeViewState.blog),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'tapping Forums/Chat dispatches ChatForumLoadEvent and ApplicationNavigateEvent',
        (WidgetTester tester) async {
          when(() => mockApplicationBloc.state).thenReturn(
            const ApplicationContentLoadedState(
              route: HomeViewState.blog,
              isLoggedIn: false,
              timestamp: 0,
              currentUser: null,
            ),
          );

          await pumpSidebar(tester);

          await tester.tap(find.text(Strings.linkForums));

          verify(
            () => mockChatForumBloc.add(any(that: isA<ChatForumLoadEvent>())),
          ).called(1);
          verify(
            () => mockApplicationBloc.add(
              const ApplicationNavigateEvent(route: HomeViewState.chatForum),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'closes drawer on navigation or sign-out in mobile/tablet views',
        (WidgetTester tester) async {
          when(() => mockApplicationBloc.state).thenReturn(
            ApplicationContentLoadedState(
              route: HomeViewState.blog,
              isLoggedIn: true,
              timestamp: 0,
              currentUser: regularUser,
            ),
          );

          // Pump inside a drawer scaffold
          await pumpSidebar(tester, insideDrawer: true);

          // Open the drawer
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          // Verify Sidebar is present in drawer
          expect(find.byType(Sidebar), findsOneWidget);

          // Tap Forums
          await tester.tap(find.text(Strings.linkForums));
          await tester.pumpAndSettle();

          // Drawer should close, so Sidebar is no longer present/visible in the active tree
          expect(find.byType(Sidebar), findsNothing);
        },
      );
    });
  });
}
