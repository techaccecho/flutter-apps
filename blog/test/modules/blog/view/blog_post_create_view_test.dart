import 'package:bloc_test/bloc_test.dart';
import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/blog/util/blog_content.dart';
import 'package:blog/modules/blog/view/create_post/blog_post_create.dart';
import 'package:blog/modules/core/application_bloc.dart';
import 'package:blog/modules/core/application_event.dart';
import 'package:blog/modules/core/application_state.dart';
import 'package:blog/shared/models/author.dart';
import 'package:blog/shared/models/engagement.dart';
import 'package:blog/shared/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockBlogBloc extends MockBloc<BlogEvent, BlogState> implements BlogBloc {}

class MockApplicationBloc extends MockBloc<ApplicationEvent, ApplicationState>
    implements ApplicationBloc {}

void main() {
  late MockBlogBloc mockBlogBloc;
  late MockApplicationBloc mockApplicationBloc;

  final testAuthor = Author(
    id: 'user_123',
    email: 'user@example.com',
    alias: 'user',
  );
  final testAdminUser = User(
    id: 'user_123',
    authId: 'auth_123',
    email: 'user@example.com',
    alias: 'user',
    firstName: 'System',
    lastName: 'Admin',
    role: 'admin',
    isLocked: false,
    createdAt: DateTime(2026, 1, 1),
    lastActivityAt: DateTime(2026, 7, 1),
  );
  final testRegularUser = User(
    id: 'user_123',
    authId: 'auth_123',
    email: 'user@example.com',
    alias: 'user',
    firstName: 'Regular',
    lastName: 'User',
    role: 'user',
    isLocked: false,
    createdAt: DateTime(2026, 1, 1),
    lastActivityAt: DateTime(2026, 7, 1),
  );

  BlogPost createTestPost({
    required String id,
    bool isDraft = false,
    DateTime? createdAt,
    String title = 'Test Post',
    String content = 'Content',
  }) {
    return BlogPost(
      id: id,
      author: testAuthor,
      title: title,
      content: content,
      priority: 0,
      isDraft: isDraft,
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
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  setUpAll(() {
    registerFallbackValue(const LoadBlogPostsEvent());
    registerFallbackValue(
      SaveNewBlogPostEvent(
        authorId: '',
        title: '',
        content: '',
        isDraft: false,
        publishDate: DateTime.now(),
      ),
    );
    registerFallbackValue(
      const UpdateBlogPostEvent(
        blogId: '',
        title: '',
        content: '',
        isDraft: false,
      ),
    );
  });

  setUp(() {
    mockBlogBloc = MockBlogBloc();
    mockApplicationBloc = MockApplicationBloc();

    when(
      () => mockBlogBloc.state,
    ).thenReturn(BlogLoadedState([], hasMore: false));
    when(
      () => mockApplicationBloc.state,
    ).thenReturn(const ApplicationInitialState());
  });

  Future<void> pumpCreateView(
    WidgetTester tester, {
    BlogPost? post,
    Author? author,
    BlogPost? latestPost,
    required bool isEditing,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          BlocProvider<BlogBloc>.value(value: mockBlogBloc),
          BlocProvider<ApplicationBloc>.value(value: mockApplicationBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: BlogPostCreateView(
              post: post,
              author: author,
              latestPost: latestPost,
              isEditing: isEditing,
            ),
          ),
        ),
      ),
    );
  }

  group('BlogPostCreateView Widget Tests', () {
    testWidgets('pre-populates fields on edit', (WidgetTester tester) async {
      final post = createTestPost(
        id: 'blog_1',
        title: 'Edit Me',
        content: 'Some Old Content',
      );
      when(() => mockApplicationBloc.currentUser).thenReturn(testRegularUser);

      await pumpCreateView(
        tester,
        post: post,
        author: testAuthor,
        isEditing: true,
      );

      // Verify that Title field is prepopulated
      final titleFinder = find.byType(TextField).first;
      expect(tester.widget<TextField>(titleFinder).controller?.text, 'Edit Me');

      // Verify that Content field is prepopulated
      final contentFinder = find.byType(TextField).last;
      expect(
        tester.widget<TextField>(contentFinder).controller?.text,
        'Some Old Content',
      );
    });

    testWidgets('validates empty title and body with SnackBars', (
      WidgetTester tester,
    ) async {
      when(() => mockApplicationBloc.currentUser).thenReturn(testRegularUser);

      await pumpCreateView(tester, author: testAuthor, isEditing: false);

      // Tap Publish with empty title
      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();

      expect(find.text('Title cannot be empty'), findsOneWidget);

      // Dismiss previous snackbar to avoid display queuing delay
      ScaffoldMessenger.of(
        tester.element(find.byType(BlogPostCreateView)),
      ).clearSnackBars();
      await tester.pumpAndSettle();

      // Enter a title, but keep content empty
      final titleFinder = find.byType(TextField).first;
      await tester.enterText(titleFinder, 'Valid Title');

      // Unfocus before tapping to ensure keyboard dismissal doesn't obscure the button tap
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();

      expect(find.text('Body cannot be empty'), findsOneWidget);
    });

    testWidgets('validates maximum body length and does not dispatch save', (
      WidgetTester tester,
    ) async {
      when(() => mockApplicationBloc.currentUser).thenReturn(testRegularUser);

      await pumpCreateView(tester, author: testAuthor, isEditing: false);

      await tester.enterText(find.byType(TextField).first, 'Valid Title');
      await tester.enterText(
        find.byType(TextField).last,
        'a' * (maxBlogPostContentLength + 1),
      );

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();

      expect(
        find.text('Body must be $maxBlogPostContentLength characters or less'),
        findsOneWidget,
      );
      verifyNever(
        () => mockBlogBloc.add(any(that: isA<SaveNewBlogPostEvent>())),
      );
    });

    testWidgets(
      'shows warning and blocks out-of-order publish for regular user, allows admin override',
      (WidgetTester tester) async {
        final futureDate = DateTime.now().add(const Duration(days: 2));
        final latestPost = createTestPost(id: 'latest', createdAt: futureDate);

        // 1. Check for Regular User: Shows Timeline Integrity Violation Dialog on Publish
        when(() => mockApplicationBloc.currentUser).thenReturn(testRegularUser);

        await pumpCreateView(
          tester,
          author: testAuthor,
          latestPost: latestPost,
          isEditing: false,
        );

        // Warning indicator should be on screen since default selectedPublishDate is now() which is before latestPost
        expect(find.text('Out-of-order publishing'), findsOneWidget);

        // Enter title & content
        await tester.enterText(
          find.byType(TextField).first,
          'My Out-of-order Post',
        );
        await tester.enterText(find.byType(TextField).last, 'Valid Content');

        // Tap Publish
        await tester.tap(find.text('Publish'));
        await tester.pumpAndSettle();

        // Should show warning dialog
        expect(find.text('Timeline Integrity Violation'), findsOneWidget);
        expect(
          find.textContaining(
            'Only system administrators can publish out-of-order.',
          ),
          findsOneWidget,
        );

        // Dismiss dialog
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // 2. Check for Admin: Allows enabling override and bypassing the dialog
        when(() => mockApplicationBloc.currentUser).thenReturn(testAdminUser);

        await pumpCreateView(
          tester,
          author: testAuthor,
          latestPost: latestPost,
          isEditing: false,
        );

        // Toggle Admin Override Switch
        final switchFinder = find.byType(Switch);
        expect(switchFinder, findsOneWidget);
        await tester.tap(switchFinder);
        await tester.pump();

        // Enter details
        await tester.enterText(
          find.byType(TextField).first,
          'Admin Bypass Post',
        );
        await tester.enterText(find.byType(TextField).last, 'Valid Content');

        // Tap Publish
        await tester.tap(find.text('Publish'));
        await tester.pumpAndSettle();

        // Dialog should NOT be shown. SaveNewBlogPostEvent should be dispatched.
        expect(find.text('Timeline Integrity Violation'), findsNothing);
        verify(
          () => mockBlogBloc.add(any(that: isA<SaveNewBlogPostEvent>())),
        ).called(1);
      },
    );

    testWidgets('dispatches SaveNewBlogPostEvent on creation publish', (
      WidgetTester tester,
    ) async {
      when(() => mockApplicationBloc.currentUser).thenReturn(testRegularUser);

      await pumpCreateView(tester, author: testAuthor, isEditing: false);

      await tester.enterText(find.byType(TextField).first, 'Brand New Post');
      await tester.enterText(find.byType(TextField).last, 'Fresh Content');

      await tester.tap(find.text('Publish'));
      await tester.pump();

      final captured =
          verify(() => mockBlogBloc.add(captureAny())).captured.single
              as SaveNewBlogPostEvent;
      expect(captured.title, 'Brand New Post');
      expect(captured.content, 'Fresh Content');
      expect(captured.isDraft, false);
    });

    testWidgets('shows login error when creating without an author', (
      WidgetTester tester,
    ) async {
      when(() => mockApplicationBloc.currentUser).thenReturn(null);

      await pumpCreateView(tester, author: null, isEditing: false);

      await tester.enterText(find.byType(TextField).first, 'Guest Post');
      await tester.enterText(find.byType(TextField).last, 'Valid content');

      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();

      expect(find.text('You must be logged in to save a post'), findsOneWidget);
      verifyNever(
        () => mockBlogBloc.add(any(that: isA<SaveNewBlogPostEvent>())),
      );
    });

    testWidgets('saving draft bypasses out-of-order publish validation', (
      WidgetTester tester,
    ) async {
      final futureDate = DateTime.now().add(const Duration(days: 2));
      final latestPost = createTestPost(id: 'latest', createdAt: futureDate);
      when(() => mockApplicationBloc.currentUser).thenReturn(testRegularUser);

      await pumpCreateView(
        tester,
        author: testAuthor,
        latestPost: latestPost,
        isEditing: false,
      );

      await tester.enterText(find.byType(TextField).first, 'Draft Post');
      await tester.enterText(find.byType(TextField).last, 'Draft content');

      await tester.tap(find.text('Save draft'));
      await tester.pumpAndSettle();

      expect(find.text('Timeline Integrity Violation'), findsNothing);
      final captured =
          verify(() => mockBlogBloc.add(captureAny())).captured.single
              as SaveNewBlogPostEvent;
      expect(captured.title, 'Draft Post');
      expect(captured.content, 'Draft content');
      expect(captured.isDraft, true);
    });

    testWidgets('dispatches UpdateBlogPostEvent on editing update', (
      WidgetTester tester,
    ) async {
      final post = createTestPost(
        id: 'blog_1',
        title: 'Old Title',
        content: 'Old Content',
      );
      when(() => mockApplicationBloc.currentUser).thenReturn(testRegularUser);

      await pumpCreateView(
        tester,
        post: post,
        author: testAuthor,
        isEditing: true,
      );

      await tester.enterText(find.byType(TextField).first, 'Updated Title');
      await tester.enterText(find.byType(TextField).last, 'Updated Content');

      await tester.tap(find.text('Update post'));
      await tester.pump();

      final captured =
          verify(() => mockBlogBloc.add(captureAny())).captured.single
              as UpdateBlogPostEvent;
      expect(captured.blogId, 'blog_1');
      expect(captured.title, 'Updated Title');
      expect(captured.content, 'Updated Content');
      expect(captured.isDraft, false);
    });

    testWidgets('hides save draft action when editing a published post', (
      WidgetTester tester,
    ) async {
      final post = createTestPost(
        id: 'blog_1',
        isDraft: false,
        title: 'Published Title',
        content: 'Published Content',
      );
      when(() => mockApplicationBloc.currentUser).thenReturn(testRegularUser);

      await pumpCreateView(
        tester,
        post: post,
        author: testAuthor,
        isEditing: true,
      );

      expect(find.text('Save draft'), findsNothing);
      expect(find.text('Update post'), findsOneWidget);
    });
  });
}
