import 'package:bloc_test/bloc_test.dart';
import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/blog/view/view_posts/blog_post_view.dart';
import 'package:blog/modules/core/application_bloc.dart';
import 'package:blog/modules/core/application_event.dart';
import 'package:blog/modules/core/application_state.dart';
import 'package:blog/shared/models/author.dart';
import 'package:blog/shared/models/comment.dart';
import 'package:blog/shared/models/engagement.dart';
import 'package:blog/shared/models/user.dart';
import 'package:blog/shared/models/user_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockBlogBloc extends MockBloc<BlogEvent, BlogState> implements BlogBloc {}
class MockApplicationBloc extends MockBloc<ApplicationEvent, ApplicationState> implements ApplicationBloc {}

void main() {
  late MockBlogBloc mockBlogBloc;
  late MockApplicationBloc mockApplicationBloc;

  final postAuthor = Author(id: 'owner_123', email: 'owner@example.com', alias: 'postowner');

  final ownerUser = User(
    id: 'owner_123',
    authId: 'auth_owner',
    email: 'owner@example.com',
    alias: 'postowner',
    firstName: 'Post',
    lastName: 'Owner',
    role: 'user',
    isLocked: false,
    createdAt: DateTime(2026, 1, 1),
    lastActivityAt: DateTime(2026, 7, 1),
  );

  final adminUser = User(
    id: 'admin_123',
    authId: 'auth_admin',
    email: 'admin@example.com',
    alias: 'sysadmin',
    firstName: 'System',
    lastName: 'Admin',
    role: 'admin',
    isLocked: false,
    createdAt: DateTime(2026, 1, 1),
    lastActivityAt: DateTime(2026, 7, 1),
  );

  final otherUser = User(
    id: 'other_123',
    authId: 'auth_other',
    email: 'other@example.com',
    alias: 'otheruser',
    firstName: 'Other',
    lastName: 'User',
    role: 'user',
    isLocked: false,
    createdAt: DateTime(2026, 1, 1),
    lastActivityAt: DateTime(2026, 7, 1),
  );

  BlogPost createTestPost({
    required String id,
    DateTime? deletedAt,
    List<Comment> comments = const [],
  }) {
    return BlogPost(
      id: id,
      author: postAuthor,
      title: 'Post Title',
      content: 'This is the main post content.',
      priority: 0,
      isDraft: false,
      isPinned: false,
      isLocked: false,
      comments: comments,
      attachments: [],
      viewers: [],
      reactions: [],
      engagement: Engagement(views: 10, comments: comments.length, attachments: 0, reactions: 2),
      createdAt: DateTime(2026, 7, 19),
      deletedAt: deletedAt,
    );
  }

  setUpAll(() {
    registerFallbackValue(const LoadBlogPostsEvent());
    registerFallbackValue(const EditBlogPostEvent(blogId: ''));
    registerFallbackValue(const DeleteBlogPostEvent(blogId: ''));
    registerFallbackValue(const SoftDeleteBlogPostEvent(blogId: '', reason: ''));
  });

  setUp(() {
    mockBlogBloc = MockBlogBloc();
    mockApplicationBloc = MockApplicationBloc();

    when(() => mockBlogBloc.state).thenReturn(BlogLoadedState([], hasMore: false));
    when(() => mockApplicationBloc.state).thenReturn(const ApplicationInitialState());
  });

  Future<void> pumpPostView(WidgetTester tester, BlogPost post) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          BlocProvider<BlogBloc>.value(value: mockBlogBloc),
          BlocProvider<ApplicationBloc>.value(value: mockApplicationBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                BlogPostView(post: post),
              ],
            ),
          ),
        ),
      ),
    );
  }

  group('BlogPostView Widget Tests', () {
    testWidgets('evaluates permissions correctly for Owner (regular user)', (WidgetTester tester) async {
      when(() => mockApplicationBloc.currentUser).thenReturn(ownerUser);
      final post = createTestPost(id: 'blog_1');

      await pumpPostView(tester, post);

      // Owner can edit: Edit button should be visible
      expect(find.byIcon(Icons.edit), findsOneWidget);

      // Owner can delete: Delete button should be visible
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      // Owner cannot soft delete: Block button should not be visible
      expect(find.byIcon(Icons.block), findsNothing);
    });

    testWidgets('evaluates permissions correctly for Admin (non-owner)', (WidgetTester tester) async {
      when(() => mockApplicationBloc.currentUser).thenReturn(adminUser);
      final post = createTestPost(id: 'blog_1');

      await pumpPostView(tester, post);

      // Admin (non-owner) cannot edit: Edit button should not be visible
      expect(find.byIcon(Icons.edit), findsNothing);

      // Admin can delete: Delete button should be visible
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      // Admin can soft delete: Block button should be visible
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('evaluates permissions correctly for Other Regular User', (WidgetTester tester) async {
      when(() => mockApplicationBloc.currentUser).thenReturn(otherUser);
      final post = createTestPost(id: 'blog_1');

      await pumpPostView(tester, post);

      // Other regular user has no permissions: No edit, delete, or block buttons
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byIcon(Icons.block), findsNothing);
    });

    testWidgets('displays content, comments, and admin removed notices correctly', (WidgetTester tester) async {
      when(() => mockApplicationBloc.currentUser).thenReturn(ownerUser);

      // 1. Regular active post: shows content, comments
      final List<Comment> comments = [
        Comment(
          id: 'c1',
          author: UserPreview(
            id: 'other_123',
            email: 'other@example.com',
            alias: 'commenter',
            firstName: 'Other',
            lastName: 'Commenter',
          ),
          content: 'Nice post!',
          replies: const [],
          attachments: const [],
          viewers: const [],
          reactions: const [],
          engagement: Engagement(views: 0, comments: 0, attachments: 0, reactions: 0),
          createdAt: DateTime(2026, 7, 20),
        )
      ];
      final post = createTestPost(id: 'blog_1', comments: comments);

      await pumpPostView(tester, post);

      expect(find.text('This is the main post content.'), findsOneWidget);
      expect(find.text('Comments (1)'), findsOneWidget);
      expect(find.text('Nice post!'), findsOneWidget);
      expect(find.text('This post has been removed by an admin because it broke site rules.'), findsNothing);

      // 2. Removed post: hides content under warning notice
      final removedPost = createTestPost(id: 'blog_2', deletedAt: DateTime.now());

      await pumpPostView(tester, removedPost);

      // Content replaced by placeholder notice
      expect(find.text('This is the main post content.'), findsNothing);
      expect(find.text('This post has been removed by an admin because it broke site rules.'), findsOneWidget);
    });

    testWidgets('edit action dispatches EditBlogPostEvent', (WidgetTester tester) async {
      when(() => mockApplicationBloc.currentUser).thenReturn(ownerUser);
      final post = createTestPost(id: 'blog_1');

      await pumpPostView(tester, post);

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      verify(() => mockBlogBloc.add(const EditBlogPostEvent(blogId: 'blog_1'))).called(1);
    });

    testWidgets('delete action (Owner) dispatches DeleteBlogPostEvent on confirmation', (WidgetTester tester) async {
      when(() => mockApplicationBloc.currentUser).thenReturn(ownerUser);
      final post = createTestPost(id: 'blog_1');

      await pumpPostView(tester, post);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Delete post?'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      verify(() => mockBlogBloc.add(const DeleteBlogPostEvent(
            blogId: 'blog_1',
            reason: 'Deleted by owner',
          ))).called(1);
    });

    testWidgets('delete action (Admin) shows reasoned action dialog and dispatches event with reason', (WidgetTester tester) async {
      when(() => mockApplicationBloc.currentUser).thenReturn(adminUser);
      final post = createTestPost(id: 'blog_1');

      await pumpPostView(tester, post);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Should show reasoned confirmation dialog
      expect(find.text('Delete post?'), findsOneWidget);
      expect(find.text('Reason'), findsOneWidget);

      // Tap Confirm
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      verify(() => mockBlogBloc.add(const DeleteBlogPostEvent(
            blogId: 'blog_1',
            reason: 'Broke site rules',
          ))).called(1);
    });

    testWidgets('soft delete action (Admin) shows reasoned action dialog and dispatches soft delete event', (WidgetTester tester) async {
      when(() => mockApplicationBloc.currentUser).thenReturn(adminUser);
      final post = createTestPost(id: 'blog_1');

      await pumpPostView(tester, post);

      await tester.tap(find.byIcon(Icons.block));
      await tester.pumpAndSettle();

      // Should show soft delete confirmation dialog
      expect(find.text('Remove post?'), findsOneWidget);
      expect(find.text('Reason'), findsOneWidget);

      // Tap Confirm
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      verify(() => mockBlogBloc.add(const SoftDeleteBlogPostEvent(
            blogId: 'blog_1',
            reason: 'Broke site rules',
          ))).called(1);
    });
  });
}
