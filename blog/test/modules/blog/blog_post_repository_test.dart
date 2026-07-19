import 'package:blog/modules/blog/bloc/blog_post_repository.dart';
import 'package:blog/modules/blog/model/create_blog_post.dart';
import 'package:blog/modules/blog/model/update_blog_post.dart';
import 'package:blog/shared/models/api_response.dart';
import 'package:blog/shared/models/blog.dart';
import 'package:blog/shared/models/create_blog.dart';
import 'package:blog/shared/models/update_blog.dart';
import 'package:blog/shared/models/engagement.dart';
import 'package:blog/shared/models/user_preview.dart';
import 'package:blog/shared/providers/blog_api_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBlogApiProvider extends Mock implements BlogApiProvider {}
class FakeCreateBlog extends Fake implements CreateBlog {}
class FakeUpdateBlog extends Fake implements UpdateBlog {}

void main() {
  late MockBlogApiProvider mockApiProvider;
  late BlogPostRepository repository;

  final testAuthor = UserPreview(
    id: 'user_123',
    email: 'user@example.com',
    alias: 'test_user',
    firstName: 'Test',
    lastName: 'User',
  );

  final testBlog = Blog(
    id: 'blog_1',
    author: testAuthor,
    type: 'post',
    title: 'Test Post Title',
    content: 'Test Post Content',
    priority: 5,
    isDraft: false,
    isPinned: true,
    isLocked: false,
    participants: [],
    comments: [],
    attachments: [],
    viewers: [],
    reactions: [],
    engagement: Engagement(views: 10, comments: 2, attachments: 1, reactions: 3),
    createdAt: DateTime(2026, 7, 19),
    updatedAt: DateTime(2026, 7, 20),
    deletedAt: DateTime(2026, 7, 21),
  );

  setUpAll(() {
    registerFallbackValue(FakeCreateBlog());
    registerFallbackValue(FakeUpdateBlog());
  });

  setUp(() {
    mockApiProvider = MockBlogApiProvider();
    repository = BlogPostRepository(apiProvider: mockApiProvider);
  });

  group('BlogPostRepository - getPosts', () {
    test('correctly forwards parameters including search and returns mapped result', () async {
      when(() => mockApiProvider.fetchBlogsByType(
            type: 'post',
            cursor: 'cursor_123',
            limit: 10,
            sort: 'desc',
            search: 'search-query',
            authorId: 'user_123',
          )).thenAnswer((_) async => ApiResponse<List<Blog>>(
            code: 'SUCCESS',
            message: 'Fetched blogs successfully',
            data: [testBlog],
            meta: ApiMeta(nextCursor: 'cursor_456', hasMore: true),
          ));

      final result = await repository.getPosts(
        cursor: 'cursor_123',
        limit: 10,
        sort: 'desc',
        search: 'search-query',
        authorId: 'user_123',
      );

      // Verify parameters sent
      verify(() => mockApiProvider.fetchBlogsByType(
            type: 'post',
            cursor: 'cursor_123',
            limit: 10,
            sort: 'desc',
            search: 'search-query',
            authorId: 'user_123',
          )).called(1);

      // Verify mapping of all Blog fields to BlogPost
      expect(result.posts.length, 1);
      final mappedPost = result.posts.first;
      expect(mappedPost.id, 'blog_1');
      expect(mappedPost.author.id, 'user_123');
      expect(mappedPost.author.email, 'user@example.com');
      expect(mappedPost.author.alias, 'test_user');
      expect(mappedPost.title, 'Test Post Title');
      expect(mappedPost.content, 'Test Post Content');
      expect(mappedPost.priority, 5);
      expect(mappedPost.isDraft, false);
      expect(mappedPost.isPinned, true);
      expect(mappedPost.isLocked, false);
      expect(mappedPost.engagement.views, 10);
      expect(mappedPost.engagement.comments, 2);
      expect(mappedPost.engagement.attachments, 1);
      expect(mappedPost.engagement.reactions, 3);
      expect(mappedPost.createdAt, DateTime(2026, 7, 19));
      expect(mappedPost.updatedAt, DateTime(2026, 7, 20));
      expect(mappedPost.deletedAt, DateTime(2026, 7, 21));

      expect(result.nextCursor, 'cursor_456');
      expect(result.hasMore, true);
    });

    test('handles null metadata correctly in the response', () async {
      when(() => mockApiProvider.fetchBlogsByType(
            type: 'post',
            cursor: null,
            limit: 10,
            sort: 'desc',
            search: null,
            authorId: null,
          )).thenAnswer((_) async => ApiResponse<List<Blog>>(
            code: 'SUCCESS',
            message: 'Fetched blogs successfully',
            data: [testBlog],
            meta: null,
          ));

      final result = await repository.getPosts(limit: 10);

      expect(result.nextCursor, isNull);
      expect(result.hasMore, isFalse);
    });
  });

  group('BlogPostRepository - getPost', () {
    test('calls fetchBlog and maps response to BlogPost', () async {
      when(() => mockApiProvider.fetchBlog('blog_1'))
          .thenAnswer((_) async => ApiResponse<Blog>(
                code: 'SUCCESS',
                message: 'Fetched blog successfully',
                data: testBlog,
              ));

      final result = await repository.getPost('blog_1');

      verify(() => mockApiProvider.fetchBlog('blog_1')).called(1);
      expect(result.id, 'blog_1');
      expect(result.title, 'Test Post Title');
    });
  });

  group('BlogPostRepository - createPost', () {
    test('calls createBlog with correct arguments and maps response to BlogPost', () async {
      final createRequest = CreateBlogPost(
        authorId: 'user_123',
        title: 'New Post',
        content: 'New Content',
        isDraft: true,
        createdAt: DateTime(2026, 7, 19),
      );

      when(() => mockApiProvider.createBlog(any()))
          .thenAnswer((_) async => ApiResponse<Blog>(
                code: 'SUCCESS',
                message: 'Created successfully',
                data: testBlog,
              ));

      final result = await repository.createPost(createRequest);

      final captured = verify(() => mockApiProvider.createBlog(captureAny())).captured.single as CreateBlog;
      expect(captured.authorId, 'user_123');
      expect(captured.title, 'New Post');
      expect(captured.content, 'New Content');
      expect(captured.type, 'post');
      expect(captured.isDraft, true);
      expect(captured.createdAt, DateTime(2026, 7, 19));

      expect(result.id, 'blog_1');
    });
  });

  group('BlogPostRepository - updatePost', () {
    test('calls updateBlog with correct parameters and maps response to BlogPost', () async {
      final updateRequest = UpdateBlogPost(
        title: 'Updated Title',
        content: 'Updated Content',
        isDraft: false,
      );

      when(() => mockApiProvider.updateBlog(
            blogId: 'blog_1',
            update: any(named: 'update'),
          )).thenAnswer((_) async => ApiResponse<Blog>(
                code: 'SUCCESS',
                message: 'Updated successfully',
                data: testBlog,
              ));

      final result = await repository.updatePost(id: 'blog_1', update: updateRequest);

      final captured = verify(() => mockApiProvider.updateBlog(
            blogId: 'blog_1',
            update: captureAny(named: 'update'),
          )).captured.single as UpdateBlog;
      expect(captured.title, 'Updated Title');
      expect(captured.content, 'Updated Content');
      expect(captured.isDraft, false);

      expect(result.id, 'blog_1');
    });
  });

  group('BlogPostRepository - deletePost', () {
    test('calls deleteBlog with correct reason', () async {
      when(() => mockApiProvider.deleteBlog('blog_1', reason: 'Spam reason'))
          .thenAnswer((_) async => {});

      await repository.deletePost('blog_1', reason: 'Spam reason');

      verify(() => mockApiProvider.deleteBlog('blog_1', reason: 'Spam reason')).called(1);
    });
  });

  group('BlogPostRepository - softDeletePost', () {
    test('calls softDeleteBlog with correct reason and maps response to BlogPost', () async {
      when(() => mockApiProvider.softDeleteBlog(id: 'blog_1', reason: 'Spam reason'))
          .thenAnswer((_) async => ApiResponse<Blog>(
                code: 'SUCCESS',
                message: 'Soft deleted successfully',
                data: testBlog,
              ));

      final result = await repository.softDeletePost(id: 'blog_1', reason: 'Spam reason');

      verify(() => mockApiProvider.softDeleteBlog(id: 'blog_1', reason: 'Spam reason')).called(1);
      expect(result.id, 'blog_1');
    });
  });
}
