import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_bloc.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_event.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_state.dart';
import 'package:blog/modules/chat_forum/bloc/chat_forum_repository.dart';
import 'package:blog/modules/chat_forum/model/thread.dart';
import 'package:blog/modules/chat_forum/view/chat_forum_view.dart';
import 'package:blog/modules/chat_forum/view/chat_reply_box.dart';
import 'package:blog/modules/core/application.dart';
import 'package:blog/modules/home/model/home_view_state.dart';
import 'package:blog/resources/app_strings.dart';
import 'package:blog/shared/models/author.dart';
import 'package:blog/shared/models/comment.dart';
import 'package:blog/shared/models/engagement.dart';
import 'package:blog/shared/models/user.dart';
import 'package:blog/shared/models/user_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatForumBloc extends MockBloc<ChatForumEvent, ChatForumState>
    implements ChatForumBloc {}

class MockApplicationBloc extends MockBloc<ApplicationEvent, ApplicationState>
    implements ApplicationBloc {}

void main() {
  late MockChatForumBloc mockChatForumBloc;
  late MockApplicationBloc mockApplicationBloc;

  setUpAll(() {
    registerFallbackValue(const ChatForumLoadEvent());
    registerFallbackValue(
      const ChatCreateThreadEvent(authorId: '', title: '', content: ''),
    );
    registerFallbackValue(
      const ChatAddCommentEvent(threadId: '', authorId: '', message: ''),
    );
    registerFallbackValue(
      const ApplicationNavigateEvent(route: HomeViewState.profile),
    );
  });

  setUp(() {
    mockChatForumBloc = MockChatForumBloc();
    mockApplicationBloc = MockApplicationBloc();

    when(
      () => mockChatForumBloc.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockApplicationBloc.stream,
    ).thenAnswer((_) => const Stream.empty());
  });

  Widget buildTestWidget({
    required ChatForumBloc chatForumBloc,
    required ApplicationBloc applicationBloc,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: chatForumBloc),
            BlocProvider.value(value: applicationBloc),
          ],
          child: const ChatForumView(),
        ),
      ),
    );
  }

  group('ChatForumView - List View', () {
    final testThread = Thread(
      id: 'thread_123',
      author: Author(
        id: 'user_123',
        email: 'user@example.com',
        alias: 'user_alias',
      ),
      title: 'Awesome Title',
      content: 'Some interesting details.',
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
      createdAt: DateTime.now(),
    );

    testWidgets(
      'shows list of threads when state is ChatForumContentLoadedState',
      (tester) async {
        when(() => mockApplicationBloc.currentUser).thenReturn(null);
        when(
          () => mockApplicationBloc.state,
        ).thenReturn(const ApplicationInitialState());
        when(() => mockChatForumBloc.state).thenReturn(
          ChatForumContentLoadedState(
            chat: ThreadPaginatedResult(threads: [testThread], hasMore: false),
          ),
        );

        await tester.pumpWidget(
          buildTestWidget(
            chatForumBloc: mockChatForumBloc,
            applicationBloc: mockApplicationBloc,
          ),
        );

        expect(find.text('Awesome Title'), findsOneWidget);
        expect(find.text(Strings.threadLatest), findsOneWidget);
      },
    );

    testWidgets('debounces search input by 900ms', (tester) async {
      when(() => mockApplicationBloc.currentUser).thenReturn(null);
      when(
        () => mockApplicationBloc.state,
      ).thenReturn(const ApplicationInitialState());
      when(() => mockChatForumBloc.state).thenReturn(
        ChatForumContentLoadedState(
          chat: ThreadPaginatedResult(threads: [], hasMore: false),
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(
          chatForumBloc: mockChatForumBloc,
          applicationBloc: mockApplicationBloc,
        ),
      );

      // Enter search query
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'flutter');

      // Verify no event is sent immediately
      verifyNever(() => mockChatForumBloc.add(any()));

      // Advance clock by 899ms and verify no event
      await tester.pump(const Duration(milliseconds: 899));
      verifyNever(() => mockChatForumBloc.add(any()));

      // Advance clock by 1ms (total 900ms) and verify event is dispatched
      await tester.pump(const Duration(milliseconds: 1));
      verify(
        () =>
            mockChatForumBloc.add(const ChatForumLoadEvent(search: 'flutter')),
      ).called(1);
    });

    testWidgets(
      'Creation dialog validates input and dispatches ChatCreateThreadEvent on success',
      (tester) async {
        final testUser = User(
          id: 'user_123',
          authId: 'auth_123',
          email: 'user@example.com',
          alias: 'user_alias',
          firstName: 'John',
          lastName: 'Doe',
          role: 'user',
          isLocked: false,
          createdAt: DateTime.now(),
          lastActivityAt: DateTime.now(),
        );

        when(() => mockApplicationBloc.currentUser).thenReturn(testUser);
        when(() => mockApplicationBloc.state).thenReturn(
          ApplicationContentLoadedState(
            route: HomeViewState.blog,
            isLoggedIn: true,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            currentUser: testUser,
          ),
        );
        when(() => mockChatForumBloc.state).thenReturn(
          ChatForumContentLoadedState(
            chat: ThreadPaginatedResult(threads: [], hasMore: false),
          ),
        );

        await tester.pumpWidget(
          buildTestWidget(
            chatForumBloc: mockChatForumBloc,
            applicationBloc: mockApplicationBloc,
          ),
        );

        // Tap on New Thread button
        final newThreadBtn = find.text(Strings.threadNew);
        expect(newThreadBtn, findsOneWidget);
        await tester.tap(newThreadBtn);
        await tester.pumpAndSettle();

        // Find create and cancel buttons inside dialog
        final createButton = find.text('Create');
        expect(createButton, findsOneWidget);

        // Tap create with empty inputs (Title and Message empty)
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Verify SnackBar shown and no event dispatched
        expect(find.text('Title and message cannot be empty'), findsOneWidget);
        verifyNever(
          () => mockChatForumBloc.add(any(that: isA<ChatCreateThreadEvent>())),
        );

        // Enter valid data
        final titleField = find
            .descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(TextField),
            )
            .at(0);
        final messageField = find
            .descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(TextField),
            )
            .at(1);

        await tester.enterText(titleField, 'My First Thread');
        await tester.enterText(messageField, 'This is the message details.');

        // Unfocus before popping the dialog to avoid FocusManager build scope assertions
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();

        await tester.tap(createButton);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify event is dispatched
        verify(
          () => mockChatForumBloc.add(
            const ChatCreateThreadEvent(
              authorId: 'user_123',
              title: 'My First Thread',
              content: 'This is the message details.',
            ),
          ),
        ).called(1);
      },
    );
  });

  group('ChatForumView - Details View', () {
    final commenter = UserPreview(
      id: 'commenter_123',
      email: 'commenter@example.com',
      alias: 'commenter_alias',
      firstName: 'Jane',
      lastName: 'Doe',
    );

    final testThread = Thread(
      id: 'thread_123',
      author: Author(
        id: 'owner_123',
        email: 'owner@example.com',
        alias: 'owner_alias',
      ),
      title: 'Awesome Thread Title',
      content: 'Interesting content here.',
      priority: 0,
      isDraft: false,
      isPinned: false,
      isLocked: false,
      participants: [],
      comments: [
        Comment(
          id: 'comment_1',
          author: commenter,
          content: 'This is a great comment!',
          replies: const [],
          attachments: const [],
          viewers: const [],
          reactions: const [],
          engagement: Engagement(
            views: 0,
            comments: 0,
            attachments: 0,
            reactions: 0,
          ),
          createdAt: DateTime.now(),
        ),
      ],
      attachments: [],
      viewers: [],
      reactions: [],
      engagement: Engagement(
        views: 1,
        comments: 1,
        attachments: 0,
        reactions: 0,
      ),
      createdAt: DateTime.now(),
    );

    testWidgets(
      'shows thread header and comments, and handles reply validation/submission',
      (tester) async {
        final guestUser = User(
          id: 'guest_123',
          authId: 'auth_guest',
          email: 'guest@example.com',
          alias: 'guest_alias',
          role: 'user',
          isLocked: false,
          createdAt: DateTime.now(),
          lastActivityAt: DateTime.now(),
        );

        when(() => mockApplicationBloc.currentUser).thenReturn(guestUser);
        when(() => mockApplicationBloc.state).thenReturn(
          ApplicationContentLoadedState(
            route: HomeViewState.blog,
            isLoggedIn: true,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            currentUser: guestUser,
          ),
        );
        when(
          () => mockChatForumBloc.state,
        ).thenReturn(ChatForumThreadLoadedState(thread: testThread));

        await tester.pumpWidget(
          buildTestWidget(
            chatForumBloc: mockChatForumBloc,
            applicationBloc: mockApplicationBloc,
          ),
        );

        // Header title & content check
        expect(find.text('Awesome Thread Title'), findsOneWidget);
        expect(find.text('Interesting content here.'), findsOneWidget);

        // Comments list content check
        expect(find.text('This is a great comment!'), findsOneWidget);
        expect(find.text('commenter_alias'), findsOneWidget);

        // Reply Box: try empty submission
        final replyField = find.descendant(
          of: find.byType(ChatReplyBox),
          matching: find.byType(TextField),
        );
        expect(replyField, findsOneWidget);

        await tester.enterText(replyField, '   ');
        await tester.tap(find.text('Post'));
        await tester.pumpAndSettle();

        expect(find.text('A message cannot be empty'), findsOneWidget);
        verifyNever(
          () => mockChatForumBloc.add(any(that: isA<ChatAddCommentEvent>())),
        );

        // Dismiss the previous snackbar so it doesn't block the UI
        ScaffoldMessenger.of(
          tester.element(find.byType(ChatReplyBox)),
        ).clearSnackBars();
        await tester.pumpAndSettle();

        // Reply Box: valid submission
        await tester.enterText(replyField, 'My reply');

        // Unfocus to prevent focus node leaks into subsequent widget tests
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Post'));
        await tester.pumpAndSettle();

        verify(
          () => mockChatForumBloc.add(
            const ChatAddCommentEvent(
              threadId: 'thread_123',
              authorId: 'guest_123',
              message: 'My reply',
            ),
          ),
        ).called(1);
      },
    );

    testWidgets('Owner can edit and delete, but cannot soft delete', (
      tester,
    ) async {
      final ownerUser = User(
        id: 'owner_123',
        authId: 'auth_owner',
        email: 'owner@example.com',
        alias: 'owner_alias',
        role: 'user',
        isLocked: false,
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      );

      when(() => mockApplicationBloc.currentUser).thenReturn(ownerUser);
      when(() => mockApplicationBloc.state).thenReturn(
        ApplicationContentLoadedState(
          route: HomeViewState.blog,
          isLoggedIn: true,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          currentUser: ownerUser,
        ),
      );
      when(
        () => mockChatForumBloc.state,
      ).thenReturn(ChatForumThreadLoadedState(thread: testThread));

      await tester.pumpWidget(
        buildTestWidget(
          chatForumBloc: mockChatForumBloc,
          applicationBloc: mockApplicationBloc,
        ),
      );

      expect(find.byTooltip('Edit thread'), findsOneWidget);
      expect(find.byTooltip('Delete thread'), findsOneWidget);
      expect(find.byTooltip('Remove thread'), findsNothing);
    });

    testWidgets('Admin can delete and soft delete, but cannot edit', (
      tester,
    ) async {
      final adminUser = User(
        id: 'admin_123',
        authId: 'auth_admin',
        email: 'admin@example.com',
        alias: 'admin_alias',
        role: 'admin',
        isLocked: false,
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      );

      when(() => mockApplicationBloc.currentUser).thenReturn(adminUser);
      when(() => mockApplicationBloc.state).thenReturn(
        ApplicationContentLoadedState(
          route: HomeViewState.blog,
          isLoggedIn: true,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          currentUser: adminUser,
        ),
      );
      when(
        () => mockChatForumBloc.state,
      ).thenReturn(ChatForumThreadLoadedState(thread: testThread));

      await tester.pumpWidget(
        buildTestWidget(
          chatForumBloc: mockChatForumBloc,
          applicationBloc: mockApplicationBloc,
        ),
      );

      expect(find.byTooltip('Edit thread'), findsNothing);
      expect(find.byTooltip('Delete thread'), findsOneWidget);
      expect(find.byTooltip('Remove thread'), findsOneWidget);
    });

    testWidgets('Non-owner non-admin cannot edit, delete, or soft delete', (
      tester,
    ) async {
      final guestUser = User(
        id: 'guest_123',
        authId: 'auth_guest',
        email: 'guest@example.com',
        alias: 'guest_alias',
        role: 'user',
        isLocked: false,
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      );

      when(() => mockApplicationBloc.currentUser).thenReturn(guestUser);
      when(() => mockApplicationBloc.state).thenReturn(
        ApplicationContentLoadedState(
          route: HomeViewState.blog,
          isLoggedIn: true,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          currentUser: guestUser,
        ),
      );
      when(
        () => mockChatForumBloc.state,
      ).thenReturn(ChatForumThreadLoadedState(thread: testThread));

      await tester.pumpWidget(
        buildTestWidget(
          chatForumBloc: mockChatForumBloc,
          applicationBloc: mockApplicationBloc,
        ),
      );

      expect(find.byTooltip('Edit thread'), findsNothing);
      expect(find.byTooltip('Delete thread'), findsNothing);
      expect(find.byTooltip('Remove thread'), findsNothing);
    });

    testWidgets(
      'shows warning message and disables edit for admin removed thread',
      (tester) async {
        final ownerUser = User(
          id: 'owner_123',
          authId: 'auth_owner',
          email: 'owner@example.com',
          alias: 'owner_alias',
          role: 'user',
          isLocked: false,
          createdAt: DateTime.now(),
          lastActivityAt: DateTime.now(),
        );

        final removedThread = Thread(
          id: 'thread_123',
          author: Author(
            id: 'owner_123',
            email: 'owner@example.com',
            alias: 'owner_alias',
          ),
          title: 'Removed Thread Title',
          content: 'Content',
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
          createdAt: DateTime.now(),
          deletedAt: DateTime.now(), // admin removed
        );

        when(() => mockApplicationBloc.currentUser).thenReturn(ownerUser);
        when(() => mockApplicationBloc.state).thenReturn(
          ApplicationContentLoadedState(
            route: HomeViewState.blog,
            isLoggedIn: true,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            currentUser: ownerUser,
          ),
        );
        when(
          () => mockChatForumBloc.state,
        ).thenReturn(ChatForumThreadLoadedState(thread: removedThread));

        await tester.pumpWidget(
          buildTestWidget(
            chatForumBloc: mockChatForumBloc,
            applicationBloc: mockApplicationBloc,
          ),
        );

        // Warning text visible
        expect(
          find.text(
            'This thread has been removed by an admin because it broke site rules.',
          ),
          findsOneWidget,
        );
        // Edit button hidden
        expect(find.byTooltip('Edit thread'), findsNothing);
      },
    );
  });
}
