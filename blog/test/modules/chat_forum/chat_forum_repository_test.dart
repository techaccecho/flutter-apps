import 'package:blog/modules/chat_forum/bloc/chat_forum_repository.dart';
import 'package:blog/modules/chat_forum/model/create_thread.dart';
import 'package:blog/modules/chat_forum/model/update_thread.dart';
import 'package:blog/modules/chat_forum/model/add_thread_comment.dart';
import 'package:blog/shared/models/api_response.dart';
import 'package:blog/shared/models/blog.dart';
import 'package:blog/shared/models/create_blog.dart';
import 'package:blog/shared/models/update_blog.dart';
import 'package:blog/shared/models/add_comment.dart';
import 'package:blog/shared/models/engagement.dart';
import 'package:blog/shared/models/user_preview.dart';
import 'package:blog/shared/providers/blog_api_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBlogApiProvider extends Mock implements BlogApiProvider {}

void main() {
  late MockBlogApiProvider mockApiProvider;
  late ChatForumRepository repository;

  setUpAll(() {
    registerFallbackValue(
      CreateBlog(
        authorId: '',
        title: '',
        content: '',
        type: '',
        isDraft: false,
      ),
    );
    registerFallbackValue(UpdateBlog(title: ''));
    registerFallbackValue(AddComment(authorId: '', content: ''));
  });

  setUp(() {
    mockApiProvider = MockBlogApiProvider();
    repository = ChatForumRepository(apiProvider: mockApiProvider);
  });

  group('ChatForumRepository - getThreads', () {
    final testAuthor = UserPreview(
      id: 'user_123',
      email: 'user@example.com',
      alias: 'test_user',
      firstName: 'Test',
      lastName: 'User',
    );

    final testThreadBlog = Blog(
      id: 'thread_1',
      author: testAuthor,
      type: 'thread',
      title: 'Test Thread Title',
      content: 'Test Thread Content',
      priority: 1,
      isDraft: false,
      isPinned: true,
      isLocked: false,
      participants: [testAuthor],
      comments: [],
      attachments: [],
      viewers: [],
      reactions: [],
      engagement: Engagement(
        views: 5,
        comments: 2,
        attachments: 1,
        reactions: 3,
      ),
      createdAt: DateTime.utc(2026, 7, 19, 10, 0, 0),
      updatedAt: DateTime.utc(2026, 7, 19, 11, 0, 0),
      deletedAt: DateTime.utc(2026, 7, 19, 12, 0, 0),
    );

    test(
      'correctly forwards parameters including search and authorId, and maps all fields',
      () async {
        when(
          () => mockApiProvider.fetchBlogsByType(
            type: 'thread',
            cursor: 'cursor_123',
            limit: 10,
            sort: 'desc',
            search: 'flutter',
            authorId: 'user_123',
          ),
        ).thenAnswer(
          (_) async => ApiResponse<List<Blog>>(
            code: 'SUCCESS',
            message: 'Fetched threads successfully',
            data: [testThreadBlog],
            meta: ApiMeta(nextCursor: 'cursor_456', hasMore: true),
          ),
        );

        final result = await repository.getThreads(
          cursor: 'cursor_123',
          limit: 10,
          sort: 'desc',
          search: 'flutter',
          authorId: 'user_123',
        );

        expect(result.threads.length, 1);
        final thread = result.threads.first;
        expect(thread.id, 'thread_1');
        expect(thread.author.id, 'user_123');
        expect(thread.author.email, 'user@example.com');
        expect(thread.author.alias, 'test_user');
        expect(thread.title, 'Test Thread Title');
        expect(thread.content, 'Test Thread Content');
        expect(thread.priority, 1);
        expect(thread.isDraft, false);
        expect(thread.isPinned, true);
        expect(thread.isLocked, false);
        expect(thread.participants.length, 1);
        expect(thread.participants.first.id, 'user_123');
        expect(thread.engagement.views, 5);
        expect(thread.engagement.comments, 2);
        expect(thread.engagement.attachments, 1);
        expect(thread.engagement.reactions, 3);
        expect(thread.createdAt, DateTime.utc(2026, 7, 19, 10, 0, 0));
        expect(thread.updatedAt, DateTime.utc(2026, 7, 19, 11, 0, 0));
        expect(thread.deletedAt, DateTime.utc(2026, 7, 19, 12, 0, 0));
        expect(result.nextCursor, 'cursor_456');
        expect(result.hasMore, true);

        verify(
          () => mockApiProvider.fetchBlogsByType(
            type: 'thread',
            cursor: 'cursor_123',
            limit: 10,
            sort: 'desc',
            search: 'flutter',
            authorId: 'user_123',
          ),
        ).called(1);
      },
    );

    test('handles null metadata correctly', () async {
      when(
        () => mockApiProvider.fetchBlogsByType(
          type: 'thread',
          cursor: null,
          limit: null,
          sort: 'desc',
          search: null,
          authorId: null,
        ),
      ).thenAnswer(
        (_) async => ApiResponse<List<Blog>>(
          code: 'SUCCESS',
          message: 'Fetched threads successfully',
          data: [testThreadBlog],
          meta: null,
        ),
      );

      final result = await repository.getThreads();

      expect(result.threads.length, 1);
      expect(result.nextCursor, null);
      expect(result.hasMore, false);
    });
  });

  group('ChatForumRepository - Actions', () {
    final testAuthor = UserPreview(
      id: 'user_123',
      email: 'user@example.com',
      alias: 'test_user',
      firstName: 'Test',
      lastName: 'User',
    );

    final testBlog = Blog(
      id: 'thread_123',
      author: testAuthor,
      type: 'thread',
      title: 'Title',
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
    );

    test('getThread sends correct parameters and maps to Thread', () async {
      when(() => mockApiProvider.fetchBlog('thread_123')).thenAnswer(
        (_) async => ApiResponse<Blog>(
          code: 'SUCCESS',
          message: 'Fetched',
          data: testBlog,
        ),
      );

      final thread = await repository.getThread('thread_123');

      expect(thread.id, 'thread_123');
      expect(thread.title, 'Title');
      verify(() => mockApiProvider.fetchBlog('thread_123')).called(1);
    });

    test('createThread sends correct parameters and maps to Thread', () async {
      when(() => mockApiProvider.createBlog(any())).thenAnswer(
        (_) async => ApiResponse<Blog>(
          code: 'SUCCESS',
          message: 'Created',
          data: testBlog,
        ),
      );

      final request = CreateThread(
        authorId: 'user_123',
        title: 'Title',
        content: 'Content',
      );
      final thread = await repository.createThread(request);

      expect(thread.id, 'thread_123');
      verify(
        () => mockApiProvider.createBlog(
          any(
            that: isA<CreateBlog>()
                .having((b) => b.authorId, 'authorId', 'user_123')
                .having((b) => b.title, 'title', 'Title')
                .having((b) => b.content, 'content', 'Content')
                .having((b) => b.type, 'type', 'thread'),
          ),
        ),
      ).called(1);
    });

    test('updateThread sends correct parameters and maps to Thread', () async {
      when(
        () => mockApiProvider.updateBlog(
          blogId: 'thread_123',
          update: any(named: 'update'),
        ),
      ).thenAnswer(
        (_) async => ApiResponse<Blog>(
          code: 'SUCCESS',
          message: 'Updated',
          data: testBlog,
        ),
      );

      final update = UpdateThread(title: 'New Title', content: 'New Content');
      final thread = await repository.updateThread(
        id: 'thread_123',
        update: update,
      );

      expect(thread.id, 'thread_123');
      verify(
        () => mockApiProvider.updateBlog(
          blogId: 'thread_123',
          update: any(
            named: 'update',
            that: isA<UpdateBlog>()
                .having((b) => b.title, 'title', 'New Title')
                .having((b) => b.content, 'content', 'New Content'),
          ),
        ),
      ).called(1);
    });

    test('deleteThread sends correct parameters', () async {
      when(
        () => mockApiProvider.deleteBlog('thread_123', reason: 'inappropriate'),
      ).thenAnswer((_) async {});

      await repository.deleteThread('thread_123', reason: 'inappropriate');

      verify(
        () => mockApiProvider.deleteBlog('thread_123', reason: 'inappropriate'),
      ).called(1);
    });

    test(
      'softDeleteThread sends correct parameters and maps to Thread',
      () async {
        when(
          () => mockApiProvider.softDeleteBlog(
            id: 'thread_123',
            reason: 'offensive',
          ),
        ).thenAnswer(
          (_) async => ApiResponse<Blog>(
            code: 'SUCCESS',
            message: 'Soft deleted',
            data: testBlog,
          ),
        );

        final thread = await repository.softDeleteThread(
          id: 'thread_123',
          reason: 'offensive',
        );

        expect(thread.id, 'thread_123');
        verify(
          () => mockApiProvider.softDeleteBlog(
            id: 'thread_123',
            reason: 'offensive',
          ),
        ).called(1);
      },
    );

    test(
      'addThreadComment sends correct parameters and maps to Thread',
      () async {
        when(
          () => mockApiProvider.addComment(
            blogId: 'thread_123',
            request: any(named: 'request'),
          ),
        ).thenAnswer(
          (_) async => ApiResponse<Blog>(
            code: 'SUCCESS',
            message: 'Comment added',
            data: testBlog,
          ),
        );

        final request = AddThreadComment(
          authorId: 'user_123',
          content: 'Nice comment',
        );
        final thread = await repository.addThreadComment(
          id: 'thread_123',
          request: request,
        );

        expect(thread.id, 'thread_123');
        verify(
          () => mockApiProvider.addComment(
            blogId: 'thread_123',
            request: any(
              named: 'request',
              that: isA<AddComment>()
                  .having((c) => c.authorId, 'authorId', 'user_123')
                  .having((c) => c.content, 'content', 'Nice comment'),
            ),
          ),
        ).called(1);
      },
    );
  });
}
