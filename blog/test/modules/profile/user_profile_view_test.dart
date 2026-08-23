import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_post_repository.dart';
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_repository.dart';
import 'package:blog/modules/chat_forum/model/thread.dart';
import 'package:blog/modules/core/application_bloc.dart';
import 'package:blog/modules/core/application_event.dart';
import 'package:blog/modules/core/application_state.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_state.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/modules/profile/view/user_profile_view.dart';
import 'package:blog/shared/models/user.dart';
import 'package:blog/shared/models/author.dart';
import 'package:blog/shared/models/engagement.dart';
import 'package:blog/shared/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockBlogPostRepository extends Mock implements BlogPostRepository {}

class MockChatForumRepository extends Mock implements ChatForumRepository {}

class MockBlogBloc extends MockBloc<BlogEvent, BlogState> implements BlogBloc {}

class MockChatForumBloc extends MockBloc<ChatForumEvent, ChatForumState>
    implements ChatForumBloc {}

class MockApplicationBloc extends MockBloc<ApplicationEvent, ApplicationState>
    implements ApplicationBloc {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockBlogPostRepository mockBlogPostRepository;
  late MockChatForumRepository mockChatForumRepository;
  late MockBlogBloc mockBlogBloc;
  late MockChatForumBloc mockChatForumBloc;
  late MockApplicationBloc mockApplicationBloc;

  final testUser = User(
    id: 'user_123',
    authId: 'auth_123',
    email: 'user@example.com',
    alias: 'testalias',
    firstName: 'First',
    lastName: 'Last',
    role: 'user',
    isLocked: false,
    createdAt: DateTime(2026, 1, 1),
    lastActivityAt: DateTime(2026, 7, 1),
  );

  final otherUser = User(
    id: 'user_456',
    authId: 'auth_456',
    email: 'other@example.com',
    alias: 'otheralias',
    role: 'user',
    isLocked: false,
    createdAt: DateTime(2026, 1, 1),
    lastActivityAt: DateTime(2026, 7, 1),
  );

  BlogPost createTestPost({
    required String id,
    required String authorId,
    required String title,
    required String content,
    required DateTime createdAt,
  }) {
    return BlogPost(
      id: id,
      author: Author(
        id: authorId,
        email: 'author@example.com',
        alias: 'author_alias',
      ),
      title: title,
      content: content,
      priority: 0,
      isDraft: false,
      isPinned: false,
      isLocked: false,
      comments: [],
      attachments: [],
      viewers: [],
      reactions: [],
      engagement: Engagement(
        views: 0,
        comments: 0,
        attachments: 0,
        reactions: 0,
      ),
      createdAt: createdAt,
    );
  }

  Thread createTestThread({
    required String id,
    required String authorId,
    required String title,
    required String content,
    required DateTime createdAt,
  }) {
    return Thread(
      id: id,
      author: Author(
        id: authorId,
        email: 'author@example.com',
        alias: 'author_alias',
      ),
      title: title,
      content: content,
      priority: 0,
      isDraft: false,
      isPinned: false,
      isLocked: false,
      participants: [],
      comments: [],
      attachments: [],
      viewers: [],
      reactions: [],
      engagement: Engagement(
        views: 0,
        comments: 0,
        attachments: 0,
        reactions: 0,
      ),
      createdAt: createdAt,
    );
  }

  setUpAll(() {
    registerFallbackValue(ApplicationUpdateUserEvent(testUser));
    registerFallbackValue(OpenBlogPostEvent(blogId: ''));
    registerFallbackValue(ChatLoadThreadEvent(''));
    registerFallbackValue(
      const ApplicationNavigateEvent(route: HomeViewState.blog),
    );
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockBlogPostRepository = MockBlogPostRepository();
    mockChatForumRepository = MockChatForumRepository();
    mockBlogBloc = MockBlogBloc();
    mockChatForumBloc = MockChatForumBloc();
    mockApplicationBloc = MockApplicationBloc();

    // Stub BLoC states to prevent null state throws
    when(() => mockBlogBloc.state).thenReturn(BlogLoadingState());
    when(
      () => mockChatForumBloc.state,
    ).thenReturn(const ChatForumLoadingState());
    when(
      () => mockApplicationBloc.state,
    ).thenReturn(const ApplicationInitialState());
  });

  Future<void> pumpProfileView(WidgetTester tester, {String? userId}) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: mockAuthRepository),
          Provider<BlogPostRepository>.value(value: mockBlogPostRepository),
          Provider<ChatForumRepository>.value(value: mockChatForumRepository),
          BlocProvider<BlogBloc>.value(value: mockBlogBloc),
          BlocProvider<ChatForumBloc>.value(value: mockChatForumBloc),
          BlocProvider<ApplicationBloc>.value(value: mockApplicationBloc),
        ],
        child: MaterialApp(home: UserProfileView(userId: userId)),
      ),
    );
  }

  group('UserProfileView Widget Tests', () {
    testWidgets('shows loading indicator while profile data is pending', (
      WidgetTester tester,
    ) async {
      final completer = Completer<User>();
      when(
        () => mockAuthRepository.getUser('user_123'),
      ).thenAnswer((_) => completer.future);
      when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

      // stub activity calls
      when(
        () => mockBlogPostRepository.getPosts(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
          authorId: 'user_123',
        ),
      ).thenAnswer(
        (_) async => BlogPostPaginatedResult(posts: [], hasMore: false),
      );
      when(
        () => mockChatForumRepository.getThreads(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
          authorId: 'user_123',
        ),
      ).thenAnswer(
        (_) async => ThreadPaginatedResult(threads: [], hasMore: false),
      );

      await pumpProfileView(tester, userId: 'user_123');

      // Verify that progress indicator is rendered
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(testUser);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('testalias'), findsOneWidget);
    });

    testWidgets('shows could not load profile when userId is null', (
      WidgetTester tester,
    ) async {
      await pumpProfileView(tester, userId: null);
      await tester.pump();

      expect(
        find.text(
          'Could not load user profile. Please sign in to view profiles.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'shows error state when both active and archived user fetches fail',
      (WidgetTester tester) async {
        when(
          () => mockAuthRepository.getUser('user_456'),
        ).thenAnswer((_) => Future.error(Exception('getUser fail')));
        when(
          () => mockAuthRepository.getArchivedUser('user_456'),
        ).thenAnswer((_) => Future.error(Exception('getArchivedUser fail')));
        when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

        when(
          () => mockBlogPostRepository.getPosts(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_456',
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(posts: [], hasMore: false),
        );
        when(
          () => mockChatForumRepository.getThreads(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_456',
          ),
        ).thenAnswer(
          (_) async => ThreadPaginatedResult(threads: [], hasMore: false),
        );

        await pumpProfileView(tester, userId: 'user_456');
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Could not load user profile. Please sign in to view profiles.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'fetches archived user when regular user fetch fails for another user profile',
      (WidgetTester tester) async {
        when(
          () => mockAuthRepository.getUser('user_456'),
        ).thenAnswer((_) => Future.error(Exception('getUser fail')));
        when(
          () => mockAuthRepository.getArchivedUser('user_456'),
        ).thenAnswer((_) async => otherUser);
        when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

        when(
          () => mockBlogPostRepository.getPosts(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_456',
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(posts: [], hasMore: false),
        );
        when(
          () => mockChatForumRepository.getThreads(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_456',
          ),
        ).thenAnswer(
          (_) async => ThreadPaginatedResult(threads: [], hasMore: false),
        );

        await pumpProfileView(tester, userId: 'user_456');
        await tester.pumpAndSettle();

        expect(find.text('otheralias'), findsOneWidget);
        verify(() => mockAuthRepository.getArchivedUser('user_456')).called(1);
      },
    );

    testWidgets(
      'does not fetch archived user for the current user own profile on failure',
      (WidgetTester tester) async {
        when(
          () => mockAuthRepository.getUser('user_123'),
        ).thenAnswer((_) => Future.error(Exception('getUser fail')));
        when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

        when(
          () => mockBlogPostRepository.getPosts(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(posts: [], hasMore: false),
        );
        when(
          () => mockChatForumRepository.getThreads(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async => ThreadPaginatedResult(threads: [], hasMore: false),
        );

        await pumpProfileView(tester, userId: 'user_123');
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Could not load user profile. Please sign in to view profiles.',
          ),
          findsOneWidget,
        );
        verifyNever(() => mockAuthRepository.getArchivedUser('user_123'));
      },
    );

    testWidgets('renders archived account badge when isLocked is true', (
      WidgetTester tester,
    ) async {
      final lockedUser = User(
        id: 'user_456',
        authId: 'auth_456',
        email: 'other@example.com',
        alias: 'lockeduser',
        role: 'user',
        isLocked: true,
        createdAt: DateTime(2026, 1, 1),
        lastActivityAt: DateTime(2026, 7, 1),
      );

      when(
        () => mockAuthRepository.getUser('user_456'),
      ).thenAnswer((_) async => lockedUser);
      when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

      when(
        () => mockBlogPostRepository.getPosts(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
          authorId: 'user_456',
        ),
      ).thenAnswer(
        (_) async => BlogPostPaginatedResult(posts: [], hasMore: false),
      );
      when(
        () => mockChatForumRepository.getThreads(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
          authorId: 'user_456',
        ),
      ).thenAnswer(
        (_) async => ThreadPaginatedResult(threads: [], hasMore: false),
      );

      await pumpProfileView(tester, userId: 'user_456');
      await tester.pumpAndSettle();

      expect(find.text('Archived Account'), findsOneWidget);
    });

    testWidgets(
      'merges and sorts posts and threads into timeline, and deduplicates repeated IDs',
      (WidgetTester tester) async {
        when(
          () => mockAuthRepository.getUser('user_123'),
        ).thenAnswer((_) async => testUser);
        when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

        // Create posts and threads with different timestamps
        final post1 = createTestPost(
          id: 'p1',
          authorId: 'user_123',
          title: 'Post One',
          content: 'C1',
          createdAt: DateTime(2026, 7, 10),
        );
        final post2 = createTestPost(
          id: 'p1',
          authorId: 'user_123',
          title: 'Post One Duplicate',
          content: 'C1',
          createdAt: DateTime(2026, 7, 10),
        );
        final thread1 = createTestThread(
          id: 't1',
          authorId: 'user_123',
          title: 'Thread One',
          content: 'C2',
          createdAt: DateTime(2026, 7, 11),
        );

        when(
          () => mockBlogPostRepository.getPosts(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async =>
              BlogPostPaginatedResult(posts: [post1, post2], hasMore: false),
        );

        when(
          () => mockChatForumRepository.getThreads(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async =>
              ThreadPaginatedResult(threads: [thread1], hasMore: false),
        );

        await pumpProfileView(tester, userId: 'user_123');
        await tester.pumpAndSettle();

        // Verify that 'Post One' and 'Thread One' are shown, but 'Post One Duplicate' is not duplicated
        expect(find.text('Post One'), findsOneWidget);
        expect(find.text('Thread One'), findsOneWidget);

        // Let's verify the order. Thread One (July 11) is newer than Post One (July 10).
        // Find elements of type ListTile
        final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
        expect(tiles.length, 2);

        // Thread One should be the first tile because it's newer
        final threadTextFinder = find.descendant(
          of: find.byType(ListTile).first,
          matching: find.text('Thread One'),
        );
        expect(threadTextFinder, findsOneWidget);
      },
    );

    testWidgets(
      'timeline pagination cursor handling and loading older activity',
      (WidgetTester tester) async {
        when(
          () => mockAuthRepository.getUser('user_123'),
        ).thenAnswer((_) async => testUser);
        when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

        final post1 = createTestPost(
          id: 'p1',
          authorId: 'user_123',
          title: 'Post One',
          content: 'C1',
          createdAt: DateTime(2026, 7, 10),
        );
        final post2 = createTestPost(
          id: 'p2',
          authorId: 'user_123',
          title: 'Post Two',
          content: 'C2',
          createdAt: DateTime(2026, 7, 5),
        );

        // Page 1
        when(
          () => mockBlogPostRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(
            posts: [post1],
            hasMore: true,
            nextCursor: 'post_c1',
          ),
        );

        when(
          () => mockChatForumRepository.getThreads(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async => ThreadPaginatedResult(threads: [], hasMore: false),
        );

        // Page 2 (triggered by Load Older Activity)
        when(
          () => mockBlogPostRepository.getPosts(
            cursor: 'post_c1',
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(
            posts: [post2],
            hasMore: false,
            nextCursor: null,
          ),
        );

        when(
          () => mockChatForumRepository.getThreads(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async => ThreadPaginatedResult(threads: [], hasMore: false),
        );

        await pumpProfileView(tester, userId: 'user_123');
        await tester.pumpAndSettle();

        expect(find.text('Post One'), findsOneWidget);
        expect(find.text('Post Two'), findsNothing);

        // Verify the 'Load older activity' button is present
        final loadMoreButton = find.text('Load older activity');
        expect(loadMoreButton, findsOneWidget);

        await tester.tap(loadMoreButton);
        await tester.pumpAndSettle();

        expect(find.text('Post Two'), findsOneWidget);
        expect(find.text('Load older activity'), findsNothing);
      },
    );

    testWidgets('pagination empty batches retries up to limit of 3 batches', (
      WidgetTester tester,
    ) async {
      when(
        () => mockAuthRepository.getUser('user_123'),
      ).thenAnswer((_) async => testUser);
      when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

      // Batch 1 returns empty posts but says there's more with cursor c1.
      when(
        () => mockBlogPostRepository.getPosts(
          cursor: null,
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
          authorId: 'user_123',
        ),
      ).thenAnswer(
        (_) async =>
            BlogPostPaginatedResult(posts: [], hasMore: true, nextCursor: 'c1'),
      );

      // Batch 2 returns empty posts but says there's more with cursor c2.
      when(
        () => mockBlogPostRepository.getPosts(
          cursor: 'c1',
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
          authorId: 'user_123',
        ),
      ).thenAnswer(
        (_) async =>
            BlogPostPaginatedResult(posts: [], hasMore: true, nextCursor: 'c2'),
      );

      // Batch 3 returns a valid post from user_123, hasMore: false
      final post = createTestPost(
        id: 'p3',
        authorId: 'user_123',
        title: 'Post Three',
        content: 'C3',
        createdAt: DateTime(2026, 7, 8),
      );
      when(
        () => mockBlogPostRepository.getPosts(
          cursor: 'c2',
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
          authorId: 'user_123',
        ),
      ).thenAnswer(
        (_) async => BlogPostPaginatedResult(posts: [post], hasMore: false),
      );

      when(
        () => mockChatForumRepository.getThreads(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
          authorId: 'user_123',
        ),
      ).thenAnswer(
        (_) async => ThreadPaginatedResult(threads: [], hasMore: false),
      );

      await pumpProfileView(tester, userId: 'user_123');
      await tester.pumpAndSettle();

      expect(find.text('Post Three'), findsOneWidget);
      verify(
        () => mockBlogPostRepository.getPosts(
          cursor: null,
          limit: 10,
          sort: 'desc',
          authorId: 'user_123',
        ),
      ).called(1);
      verify(
        () => mockBlogPostRepository.getPosts(
          cursor: 'c1',
          limit: 10,
          sort: 'desc',
          authorId: 'user_123',
        ),
      ).called(1);
      verify(
        () => mockBlogPostRepository.getPosts(
          cursor: 'c2',
          limit: 10,
          sort: 'desc',
          authorId: 'user_123',
        ),
      ).called(1);
    });

    testWidgets(
      'shows activity retry UI when both initial activity sources fail',
      (WidgetTester tester) async {
        when(
          () => mockAuthRepository.getUser('user_123'),
        ).thenAnswer((_) async => testUser);
        when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

        when(
          () => mockBlogPostRepository.getPosts(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenThrow(Exception('Blog fetch failed'));

        when(
          () => mockChatForumRepository.getThreads(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenThrow(Exception('Chat fetch failed'));

        await pumpProfileView(tester, userId: 'user_123');
        await tester.pumpAndSettle();

        expect(find.text('Unable to load activity history.'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      },
    );

    testWidgets(
      'allows partial success when one activity source fails but other returns items',
      (WidgetTester tester) async {
        when(
          () => mockAuthRepository.getUser('user_123'),
        ).thenAnswer((_) async => testUser);
        when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

        final post1 = createTestPost(
          id: 'p1',
          authorId: 'user_123',
          title: 'Post One',
          content: 'C1',
          createdAt: DateTime(2026, 7, 10),
        );

        when(
          () => mockBlogPostRepository.getPosts(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(posts: [post1], hasMore: false),
        );

        when(
          () => mockChatForumRepository.getThreads(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenThrow(Exception('Chat fetch failed'));

        await pumpProfileView(tester, userId: 'user_123');
        await tester.pumpAndSettle();

        expect(find.text('Post One'), findsOneWidget);
        expect(find.text('Unable to load activity history.'), findsNothing);
      },
    );

    testWidgets(
      'preserves existing activity items when a load-more request fails',
      (WidgetTester tester) async {
        when(
          () => mockAuthRepository.getUser('user_123'),
        ).thenAnswer((_) async => testUser);
        when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

        final post1 = createTestPost(
          id: 'p1',
          authorId: 'user_123',
          title: 'Post One',
          content: 'C1',
          createdAt: DateTime(2026, 7, 10),
        );

        when(
          () => mockBlogPostRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(
            posts: [post1],
            hasMore: true,
            nextCursor: 'c1',
          ),
        );

        when(
          () => mockChatForumRepository.getThreads(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async => ThreadPaginatedResult(threads: [], hasMore: false),
        );

        await pumpProfileView(tester, userId: 'user_123');
        await tester.pumpAndSettle();

        expect(find.text('Post One'), findsOneWidget);

        // Setup load more call to throw
        when(
          () => mockBlogPostRepository.getPosts(
            cursor: 'c1',
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenThrow(Exception('Load more failed'));

        final loadMoreButton = find.text('Load older activity');
        expect(loadMoreButton, findsOneWidget);

        await tester.tap(loadMoreButton);
        await tester.pumpAndSettle();

        // Post One should still be displayed
        expect(find.text('Post One'), findsOneWidget);
      },
    );

    testWidgets(
      'ignores stale in-flight activity results when userId changes',
      (WidgetTester tester) async {
        final stalePostCompleter = Completer<BlogPostPaginatedResult>();
        final staleThreadCompleter = Completer<ThreadPaginatedResult>();

        when(
          () => mockAuthRepository.getUser('user_123'),
        ).thenAnswer((_) async => testUser);
        when(
          () => mockAuthRepository.getUser('user_456'),
        ).thenAnswer((_) async => otherUser);
        when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

        when(
          () => mockBlogPostRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer((_) => stalePostCompleter.future);
        when(
          () => mockChatForumRepository.getThreads(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer((_) => staleThreadCompleter.future);

        when(
          () => mockBlogPostRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_456',
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(posts: [], hasMore: false),
        );
        when(
          () => mockChatForumRepository.getThreads(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_456',
          ),
        ).thenAnswer(
          (_) async => ThreadPaginatedResult(threads: [], hasMore: false),
        );

        await pumpProfileView(tester, userId: 'user_123');
        await tester.pump();

        await pumpProfileView(tester, userId: 'user_456');
        await tester.pumpAndSettle();

        final stalePost = createTestPost(
          id: 'stale_post',
          authorId: 'user_123',
          title: 'Stale Post',
          content: 'Old content',
          createdAt: DateTime(2026, 7, 12),
        );
        stalePostCompleter.complete(
          BlogPostPaginatedResult(posts: [stalePost], hasMore: false),
        );
        staleThreadCompleter.complete(
          ThreadPaginatedResult(threads: [], hasMore: false),
        );
        await tester.pumpAndSettle();

        expect(find.text('otheralias'), findsOneWidget);
        expect(find.text('Stale Post'), findsNothing);
      },
    );

    testWidgets(
      'activity item taps dispatch detail load events and navigate to the correct route',
      (WidgetTester tester) async {
        when(
          () => mockAuthRepository.getUser('user_123'),
        ).thenAnswer((_) async => testUser);
        when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

        final post = createTestPost(
          id: 'post_1',
          authorId: 'user_123',
          title: 'Clickable Post',
          content: 'Post content',
          createdAt: DateTime(2026, 7, 10),
        );
        final thread = createTestThread(
          id: 'thread_1',
          authorId: 'user_123',
          title: 'Clickable Thread',
          content: 'Thread content',
          createdAt: DateTime(2026, 7, 9),
        );

        when(
          () => mockBlogPostRepository.getPosts(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(posts: [post], hasMore: false),
        );
        when(
          () => mockChatForumRepository.getThreads(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async => ThreadPaginatedResult(threads: [thread], hasMore: false),
        );

        await pumpProfileView(tester, userId: 'user_123');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Clickable Post'));
        await tester.pump();

        verify(
          () => mockBlogBloc.add(const OpenBlogPostEvent(blogId: 'post_1')),
        ).called(1);
        verify(
          () => mockApplicationBloc.add(
            const ApplicationNavigateEvent(route: HomeViewState.blog),
          ),
        ).called(1);

        await tester.tap(find.text('Clickable Thread'));
        await tester.pump();

        verify(
          () => mockChatForumBloc.add(const ChatLoadThreadEvent('thread_1')),
        ).called(1);
        verify(
          () => mockApplicationBloc.add(
            const ApplicationNavigateEvent(route: HomeViewState.chatForum),
          ),
        ).called(1);
      },
    );

    testWidgets('edit profile dialog validation and successful save', (
      WidgetTester tester,
    ) async {
      when(
        () => mockAuthRepository.getUser('user_123'),
      ).thenAnswer((_) async => testUser);
      when(() => mockApplicationBloc.currentUser).thenReturn(testUser);

      when(
        () => mockBlogPostRepository.getPosts(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
          authorId: 'user_123',
        ),
      ).thenAnswer(
        (_) async => BlogPostPaginatedResult(posts: [], hasMore: false),
      );
      when(
        () => mockChatForumRepository.getThreads(
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
          authorId: 'user_123',
        ),
      ).thenAnswer(
        (_) async => ThreadPaginatedResult(threads: [], hasMore: false),
      );

      await pumpProfileView(tester, userId: 'user_123');
      await tester.pumpAndSettle();

      // Find and tap edit profile button
      final editButton = find.byTooltip('Edit Profile');
      expect(editButton, findsOneWidget);
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // The dialog should be shown
      expect(find.text('Edit Profile'), findsWidgets); // title is Edit Profile

      // 1. Validation test - Empty Alias
      final aliasField = find.widgetWithText(
        TextFormField,
        'Alias / Display Name',
      );
      expect(aliasField, findsOneWidget);
      await tester.enterText(aliasField, '');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Alias / Display Name is required'), findsOneWidget);

      // 2. Validation test - Too short Alias
      await tester.enterText(aliasField, 'ab');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Must be between 3 and 20 characters'), findsOneWidget);

      // 3. Validation test - Invalid characters
      await tester.enterText(aliasField, 'abc!');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Can only contain letters, numbers, underscores, and hyphens',
        ),
        findsOneWidget,
      );

      // 4. Successful Save
      final updatedUser = User(
        id: 'user_123',
        authId: 'auth_123',
        email: 'user@example.com',
        alias: 'newalias',
        firstName: 'NewFirst',
        lastName: 'NewLast',
        bio: 'NewBio',
        role: 'user',
        isLocked: false,
        createdAt: testUser.createdAt,
        lastActivityAt: testUser.lastActivityAt,
      );

      when(
        () => mockAuthRepository.updateUser(
          'user_123',
          alias: 'newalias',
          firstName: 'NewFirst',
          lastName: 'NewLast',
          bio: 'NewBio',
          dateOfBirth: null,
        ),
      ).thenAnswer((_) async => updatedUser);

      await tester.enterText(aliasField, 'newalias');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name'),
        'NewFirst',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name'),
        'NewLast',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Bio'),
        'NewBio',
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify repository call and BLoC event
      verify(
        () => mockAuthRepository.updateUser(
          'user_123',
          alias: 'newalias',
          firstName: 'NewFirst',
          lastName: 'NewLast',
          bio: 'NewBio',
          dateOfBirth: null,
        ),
      ).called(1);

      verify(
        () => mockApplicationBloc.add(
          any(that: isA<ApplicationUpdateUserEvent>()),
        ),
      ).called(1);

      // Dialog should be dismissed, and UI updated with new details
      expect(find.text('newalias'), findsOneWidget);
      expect(find.text('NewFirst NewLast'), findsOneWidget);
      expect(find.text('NewBio'), findsOneWidget);
    });
  });
}
