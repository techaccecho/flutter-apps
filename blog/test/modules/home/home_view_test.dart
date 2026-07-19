import 'package:bloc_test/bloc_test.dart';
import 'package:blog/modules/blog/bloc/blog_post_repository.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_repository.dart';
import 'package:blog/modules/core/application_bloc.dart';
import 'package:blog/modules/core/application_event.dart';
import 'package:blog/modules/core/application_state.dart';
import 'package:blog/modules/faq/model/faq_content.dart';
import 'package:blog/modules/faq/view/faq_view.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/modules/home/view/home_view.dart';
import 'package:blog/modules/profile/view/archived_users_list_view.dart';
import 'package:blog/modules/profile/view/user_profile_view.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/shared/models/api_response.dart';
import 'package:blog/shared/models/user.dart';
import 'package:blog/shared/providers/blog_api_provider.dart';
import 'package:blog/shared/repositories/auth_repository.dart';
import 'package:blog/shared/view/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockBlogPostRepository extends Mock implements BlogPostRepository {}

class MockChatForumRepository extends Mock implements ChatForumRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockBlogApiProvider extends Mock implements BlogApiProvider {}

class MockApplicationBloc extends MockBloc<ApplicationEvent, ApplicationState>
    implements ApplicationBloc {}

void main() {
  late MockBlogPostRepository mockBlogPostRepository;
  late MockChatForumRepository mockChatForumRepository;
  late MockAuthRepository mockAuthRepository;
  late MockBlogApiProvider mockBlogApiProvider;
  late MockApplicationBloc mockApplicationBloc;

  final adminUser = User(
    id: 'admin_123',
    authId: 'auth_admin',
    email: 'admin@example.com',
    role: Strings.roleAdmin,
    isLocked: false,
    createdAt: DateTime.now(),
    lastActivityAt: DateTime.now(),
  );

  final regularUser = User(
    id: 'user_123',
    authId: 'auth_user',
    email: 'user@example.com',
    role: 'user',
    isLocked: false,
    createdAt: DateTime.now(),
    lastActivityAt: DateTime.now(),
  );

  setUp(() {
    mockBlogPostRepository = MockBlogPostRepository();
    mockChatForumRepository = MockChatForumRepository();
    mockAuthRepository = MockAuthRepository();
    mockBlogApiProvider = MockBlogApiProvider();
    mockApplicationBloc = MockApplicationBloc();

    // Stub BLoC state
    when(
      () => mockApplicationBloc.state,
    ).thenReturn(const ApplicationInitialState());

    // Stub repositories to return empty pages immediately
    when(
      () => mockBlogPostRepository.getPosts(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
        sort: any(named: 'sort'),
        authorId: any(named: 'authorId'),
        search: any(named: 'search'),
      ),
    ).thenAnswer(
      (_) async => BlogPostPaginatedResult(posts: [], hasMore: false),
    );

    when(
      () => mockChatForumRepository.getThreads(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
        sort: any(named: 'sort'),
        authorId: any(named: 'authorId'),
        search: any(named: 'search'),
      ),
    ).thenAnswer(
      (_) async => ThreadPaginatedResult(threads: [], hasMore: false),
    );

    when(() => mockBlogApiProvider.fetchRulesOfEngagementFaq()).thenAnswer(
      (_) async => ApiResponse<FaqContent>(
        code: 'SUCCESS',
        message: 'Success',
        data: FaqContent(title: 'FAQ Title', description: 'Desc', items: []),
      ),
    );

    when(
      () => mockAuthRepository.getArchivedUsersPage(
        limit: any(named: 'limit'),
        cursor: any(named: 'cursor'),
      ),
    ).thenAnswer(
      (_) async => ArchivedUsersPaginatedResult(users: [], hasMore: false),
    );
  });

  Future<void> pumpHomeView(WidgetTester tester, {double width = 1200}) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<BlogPostRepository>.value(value: mockBlogPostRepository),
          Provider<ChatForumRepository>.value(value: mockChatForumRepository),
          Provider<AuthRepository>.value(value: mockAuthRepository),
          Provider<BlogApiProvider>.value(value: mockBlogApiProvider),
          BlocProvider<ApplicationBloc>.value(value: mockApplicationBloc),
        ],
        child: const MaterialApp(home: HomeView()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('HomeView Responsiveness Tests', () {
    testWidgets('renders Mobile layout when width < 600', (
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

      await pumpHomeView(tester, width: 500);

      // Verify mobile header is shown
      expect(find.text('BlogNet'), findsOneWidget);
      // Sidebar should not be visible in main tree (it is in the drawer, which is closed)
      expect(find.byType(Sidebar), findsNothing);
    });

    testWidgets('renders Tablet layout when width is between 600 and 1023', (
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

      await pumpHomeView(tester, width: 800);

      // Mobile header should not be shown
      expect(find.text('BlogNet'), findsNothing);
      // Sidebar should be directly in the layout tree and visible
      expect(find.byType(Sidebar), findsOneWidget);
      // Warning banner (desktop only) should not be shown
      expect(find.text(Strings.notificationContent), findsNothing);
    });

    testWidgets('renders Desktop layout when width is 1024 or greater', (
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

      await pumpHomeView(tester, width: 1200);

      // Warning banner (desktop only) should be visible
      expect(find.text(Strings.notificationContent), findsOneWidget);
      // Sidebar should be visible
      expect(find.byType(Sidebar), findsOneWidget);
    });
  });

  group('HomeView Route Sub-view Switching', () {
    testWidgets('renders PostLanding (blog route)', (
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

      await pumpHomeView(tester);

      // PostLanding should render the PostList widget containing latest posts title
      expect(find.text(Strings.blogPostLatest), findsOneWidget);
    });

    testWidgets('renders ChatForumView (chatForum route)', (
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

      await pumpHomeView(tester);

      // ChatForumView contains thread list / latest threads title
      expect(find.text(Strings.threadLatest), findsOneWidget);
    });

    testWidgets('renders UserProfileView (profile route)', (
      WidgetTester tester,
    ) async {
      when(
        () => mockAuthRepository.getUser('user_123'),
      ).thenAnswer((_) async => regularUser);
      when(() => mockApplicationBloc.currentUser).thenReturn(regularUser);
      when(() => mockApplicationBloc.state).thenReturn(
        ApplicationContentLoadedState(
          route: HomeViewState.profile,
          isLoggedIn: true,
          timestamp: 0,
          currentUser: regularUser,
          viewUserId: 'user_123',
        ),
      );

      await pumpHomeView(tester);

      // UserProfileView has alias/display name
      expect(
        find.descendant(
          of: find.byType(UserProfileView),
          matching: find.text('user@example.com'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders FaqView (faq route)', (WidgetTester tester) async {
      when(() => mockApplicationBloc.state).thenReturn(
        const ApplicationContentLoadedState(
          route: HomeViewState.faq,
          isLoggedIn: false,
          timestamp: 0,
          currentUser: null,
        ),
      );

      await pumpHomeView(tester);

      // FAQ view displays loading / empty FAQ contents
      expect(find.byType(FaqView), findsOneWidget);
    });
  });

  group('HomeView Archived Users View Guard', () {
    testWidgets('blocks non-admins from viewing archived route', (
      WidgetTester tester,
    ) async {
      when(() => mockApplicationBloc.state).thenReturn(
        ApplicationContentLoadedState(
          route: HomeViewState.archived,
          isLoggedIn: true,
          timestamp: 0,
          currentUser: regularUser,
        ),
      );

      await pumpHomeView(tester);

      // Access Denied warning should be displayed
      expect(
        find.text(
          'Access Denied: Only administrators can view the archived user directory.',
        ),
        findsOneWidget,
      );
      expect(find.byType(ArchivedUsersListView), findsNothing);
    });

    testWidgets('allows admins to view archived route', (
      WidgetTester tester,
    ) async {
      when(() => mockApplicationBloc.state).thenReturn(
        ApplicationContentLoadedState(
          route: HomeViewState.archived,
          isLoggedIn: true,
          timestamp: 0,
          currentUser: adminUser,
        ),
      );

      await pumpHomeView(tester);

      // ArchivedUsersListView should be displayed
      expect(find.byType(ArchivedUsersListView), findsOneWidget);
      expect(
        find.text(
          'Access Denied: Only administrators can view the archived user directory.',
        ),
        findsNothing,
      );
    });
  });
}
