import 'package:bloc_test/bloc_test.dart';
import 'package:blog/modules/blog/bloc/blog_bloc.dart';
import 'package:blog/modules/blog/bloc/blog_event.dart';
import 'package:blog/modules/blog/bloc/blog_post_repository.dart';
import 'package:blog/modules/blog/bloc/blog_state.dart';
import 'package:blog/modules/blog/model/blog_post.dart';
import 'package:blog/modules/blog/model/create_blog_post.dart';
import 'package:blog/modules/blog/model/update_blog_post.dart';
import 'package:blog/shared/models/engagement.dart';
import 'package:blog/shared/models/author.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBlogPostRepository extends Mock implements BlogPostRepository {}

class FakeCreateBlogPost extends Fake implements CreateBlogPost {}

class FakeUpdateBlogPost extends Fake implements UpdateBlogPost {}

void main() {
  late MockBlogPostRepository mockRepository;
  late BlogBloc blogBloc;

  final testAuthor = Author(
    id: 'user_123',
    email: 'user@example.com',
    alias: 'user',
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
    registerFallbackValue(FakeCreateBlogPost());
    registerFallbackValue(FakeUpdateBlogPost());
  });

  setUp(() {
    mockRepository = MockBlogPostRepository();
    blogBloc = BlogBloc(repository: mockRepository);
  });

  tearDown(() {
    blogBloc.close();
  });

  group('BlogBloc - LoadBlogPostsEvent', () {
    test('initial state is BlogLoadingState', () {
      expect(blogBloc.state, isA<BlogLoadingState>());
    });

    blocTest<BlogBloc, BlogState>(
      'emits BlogLoadedState and forwards search query to repository',
      build: () {
        when(
          () => mockRepository.getPosts(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            search: 'search-query',
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(
            posts: [createTestPost(id: 'blog_1')],
            nextCursor: 'cursor_abc',
            hasMore: true,
          ),
        );
        return blogBloc;
      },
      act: (bloc) => bloc.add(const LoadBlogPostsEvent(search: 'search-query')),
      expect: () => [
        isA<BlogLoadedState>()
            .having((s) => s.posts.first.id, 'posts[0].id', 'blog_1')
            .having((s) => s.nextCursor, 'nextCursor', 'cursor_abc')
            .having((s) => s.hasMore, 'hasMore', true)
            .having((s) => s.search, 'search', 'search-query'),
      ],
    );

    blocTest<BlogBloc, BlogState>(
      'emits empty BlogLoadedState when repository returns no posts',
      build: () {
        when(
          () => mockRepository.getPosts(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            search: any(named: 'search'),
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(
            posts: [],
            nextCursor: null,
            hasMore: false,
          ),
        );
        return blogBloc;
      },
      act: (bloc) => bloc.add(const LoadBlogPostsEvent(search: 'empty-query')),
      expect: () => [
        isA<BlogLoadedState>()
            .having((s) => s.posts, 'posts', isEmpty)
            .having((s) => s.nextCursor, 'nextCursor', null)
            .having((s) => s.hasMore, 'hasMore', false)
            .having((s) => s.search, 'search', 'empty-query'),
      ],
    );

    blocTest<BlogBloc, BlogState>(
      'emits BlogErrorState when LoadBlogPostsEvent fails',
      build: () {
        when(
          () => mockRepository.getPosts(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            search: any(named: 'search'),
          ),
        ).thenThrow(Exception('Failed to load posts'));
        return blogBloc;
      },
      act: (bloc) => bloc.add(const LoadBlogPostsEvent()),
      expect: () => [isA<BlogErrorState>()],
    );
  });

  group('BlogBloc - LoadMoreBlogPostsEvent', () {
    blocTest<BlogBloc, BlogState>(
      'does nothing when current state is not BlogLoadedState',
      build: () => blogBloc,
      act: (bloc) => bloc.add(const LoadMoreBlogPostsEvent()),
      expect: () => [],
    );

    blocTest<BlogBloc, BlogState>(
      'does nothing when hasMore is false',
      seed: () =>
          BlogLoadedState([createTestPost(id: 'blog_1')], hasMore: false),
      build: () => blogBloc,
      act: (bloc) => bloc.add(const LoadMoreBlogPostsEvent()),
      expect: () => [],
    );

    blocTest<BlogBloc, BlogState>(
      'does nothing when isLoadingMore is already true',
      seed: () => BlogLoadedState(
        [createTestPost(id: 'blog_1')],
        hasMore: true,
        isLoadingMore: true,
      ),
      build: () => blogBloc,
      act: (bloc) => bloc.add(const LoadMoreBlogPostsEvent()),
      expect: () => [],
    );

    blocTest<BlogBloc, BlogState>(
      'emits loading-more state, fetches with nextCursor/search, and appends posts on success',
      seed: () => BlogLoadedState(
        [createTestPost(id: 'blog_1')],
        nextCursor: 'cursor_1',
        hasMore: true,
        search: 'query',
      ),
      build: () {
        when(
          () => mockRepository.getPosts(
            cursor: 'cursor_1',
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            search: 'query',
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(
            posts: [createTestPost(id: 'blog_2')],
            nextCursor: 'cursor_2',
            hasMore: false,
          ),
        );
        return blogBloc;
      },
      act: (bloc) => bloc.add(const LoadMoreBlogPostsEvent()),
      expect: () => [
        isA<BlogLoadedState>()
            .having((s) => s.posts.length, 'posts.length', 1)
            .having((s) => s.isLoadingMore, 'isLoadingMore', true)
            .having((s) => s.hasLoadMoreError, 'hasLoadMoreError', false),
        isA<BlogLoadedState>()
            .having((s) => s.posts.length, 'posts.length', 2)
            .having((s) => s.posts.first.id, 'first post id', 'blog_1')
            .having((s) => s.posts.last.id, 'last post id', 'blog_2')
            .having((s) => s.nextCursor, 'nextCursor', 'cursor_2')
            .having((s) => s.hasMore, 'hasMore', false)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false),
      ],
    );

    blocTest<BlogBloc, BlogState>(
      'resets isLoadingMore and sets hasLoadMoreError when loading next page fails',
      seed: () => BlogLoadedState(
        [createTestPost(id: 'blog_1')],
        nextCursor: 'cursor_1',
        hasMore: true,
        search: 'query',
      ),
      build: () {
        when(
          () => mockRepository.getPosts(
            cursor: 'cursor_1',
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
            search: 'query',
          ),
        ).thenThrow(Exception('Network Error'));
        return blogBloc;
      },
      act: (bloc) => bloc.add(const LoadMoreBlogPostsEvent()),
      expect: () => [
        isA<BlogLoadedState>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true)
            .having((s) => s.hasLoadMoreError, 'hasLoadMoreError', false),
        isA<BlogLoadedState>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.hasLoadMoreError, 'hasLoadMoreError', true),
      ],
    );
  });

  group('BlogBloc - OpenBlogPostEvent', () {
    blocTest<BlogBloc, BlogState>(
      'emits BlogPostLoadedState on success',
      build: () {
        when(
          () => mockRepository.getPost('blog_1'),
        ).thenAnswer((_) async => createTestPost(id: 'blog_1'));
        return blogBloc;
      },
      act: (bloc) => bloc.add(const OpenBlogPostEvent(blogId: 'blog_1')),
      expect: () => [
        isA<BlogPostLoadedState>().having(
          (s) => s.blogPost.id,
          'blogPost.id',
          'blog_1',
        ),
      ],
    );

    blocTest<BlogBloc, BlogState>(
      'emits BlogErrorState on failure',
      build: () {
        when(
          () => mockRepository.getPost('blog_1'),
        ).thenThrow(Exception('Not Found'));
        return blogBloc;
      },
      act: (bloc) => bloc.add(const OpenBlogPostEvent(blogId: 'blog_1')),
      expect: () => [isA<BlogErrorState>()],
    );
  });

  group('BlogBloc - CreateNewBlogPostEvent', () {
    blocTest<BlogBloc, BlogState>(
      'emits BlogPostCreateState with selected author',
      build: () => blogBloc,
      act: (bloc) => bloc.add(CreateNewBlogPostEvent(author: testAuthor)),
      expect: () => [
        isA<BlogPostCreateState>().having(
          (s) => s.author,
          'author',
          testAuthor,
        ),
      ],
    );
  });

  group('BlogBloc - EditBlogPostEvent', () {
    final editedPost = createTestPost(
      id: 'blog_edit',
      createdAt: DateTime(2026, 7, 19),
    );
    final draftPost = createTestPost(
      id: 'blog_draft',
      isDraft: true,
      createdAt: DateTime(2026, 7, 18),
    );
    final olderPost = createTestPost(
      id: 'blog_older',
      createdAt: DateTime(2026, 7, 10),
    );
    final newestPost = createTestPost(
      id: 'blog_newest',
      createdAt: DateTime(2026, 7, 15),
    );

    blocTest<BlogBloc, BlogState>(
      'fetches post and latest list, excluding edited post and draft posts, selecting newest by createdAt',
      build: () {
        when(
          () => mockRepository.getPost('blog_edit'),
        ).thenAnswer((_) async => editedPost);
        when(
          () => mockRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(
            posts: [editedPost, draftPost, olderPost, newestPost],
            hasMore: false,
          ),
        );
        return blogBloc;
      },
      act: (bloc) => bloc.add(const EditBlogPostEvent(blogId: 'blog_edit')),
      expect: () => [
        isA<BlogPostEditState>()
            .having((s) => s.blogPost?.id, 'blogPost.id', 'blog_edit')
            .having((s) => s.latestPost?.id, 'latestPost.id', 'blog_newest'),
      ],
    );

    blocTest<BlogBloc, BlogState>(
      'emits BlogErrorState on failure',
      build: () {
        when(
          () => mockRepository.getPost('blog_edit'),
        ).thenThrow(Exception('Database Error'));
        return blogBloc;
      },
      act: (bloc) => bloc.add(const EditBlogPostEvent(blogId: 'blog_edit')),
      expect: () => [isA<BlogErrorState>()],
    );
  });

  group('BlogBloc - SaveNewBlogPostEvent', () {
    final testDate = DateTime(2026, 7, 19);

    blocTest<BlogBloc, BlogState>(
      'sanitizes content, sends request, and reloads first page on success',
      build: () {
        when(
          () => mockRepository.createPost(any()),
        ).thenAnswer((_) async => createTestPost(id: 'new_blog'));
        when(
          () => mockRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(
            posts: [createTestPost(id: 'new_blog')],
            hasMore: false,
          ),
        );
        return blogBloc;
      },
      act: (bloc) => bloc.add(
        SaveNewBlogPostEvent(
          authorId: 'user_123',
          title: 'New Post',
          content: '  Trimmed content with <script>delete()</script>  ',
          isDraft: false,
          publishDate: testDate,
        ),
      ),
      verify: (_) {
        final captured =
            verify(
                  () => mockRepository.createPost(captureAny()),
                ).captured.single
                as CreateBlogPost;
        expect(captured.authorId, 'user_123');
        expect(captured.title, 'New Post');
        expect(captured.content, 'Trimmed content with');
        expect(captured.isDraft, false);
        expect(captured.createdAt, testDate);

        verify(
          () => mockRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          ),
        ).called(1);
      },
      expect: () => [
        isA<BlogLoadedState>().having(
          (s) => s.posts.first.id,
          'posts[0].id',
          'new_blog',
        ),
      ],
    );

    blocTest<BlogBloc, BlogState>(
      'emits BlogErrorState on failure',
      build: () {
        when(
          () => mockRepository.createPost(any()),
        ).thenThrow(Exception('Fail to create'));
        return blogBloc;
      },
      act: (bloc) => bloc.add(
        SaveNewBlogPostEvent(
          authorId: 'user_123',
          title: 'New Post',
          content: 'Content',
          isDraft: false,
          publishDate: testDate,
        ),
      ),
      expect: () => [isA<BlogErrorState>()],
    );

    blocTest<BlogBloc, BlogState>(
      'emits BlogErrorState when reload after create fails',
      build: () {
        when(
          () => mockRepository.createPost(any()),
        ).thenAnswer((_) async => createTestPost(id: 'new_blog'));
        when(
          () => mockRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          ),
        ).thenThrow(Exception('Reload failed'));
        return blogBloc;
      },
      act: (bloc) => bloc.add(
        SaveNewBlogPostEvent(
          authorId: 'user_123',
          title: 'New Post',
          content: 'Content',
          isDraft: false,
          publishDate: testDate,
        ),
      ),
      expect: () => [isA<BlogErrorState>()],
    );
  });

  group('BlogBloc - UpdateBlogPostEvent', () {
    blocTest<BlogBloc, BlogState>(
      'sanitizes content, sends title/draft flag, and reloads first page on success',
      build: () {
        when(
          () => mockRepository.updatePost(
            id: 'blog_1',
            update: any(named: 'update'),
          ),
        ).thenAnswer((_) async => createTestPost(id: 'blog_1'));
        when(
          () => mockRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(
            posts: [createTestPost(id: 'blog_1', title: 'Updated Title')],
            hasMore: false,
          ),
        );
        return blogBloc;
      },
      act: (bloc) => bloc.add(
        const UpdateBlogPostEvent(
          blogId: 'blog_1',
          title: 'Updated Title',
          content: '  Cleaned content <script>run()</script>  ',
          isDraft: true,
        ),
      ),
      verify: (_) {
        final captured =
            verify(
                  () => mockRepository.updatePost(
                    id: 'blog_1',
                    update: captureAny(named: 'update'),
                  ),
                ).captured.single
                as UpdateBlogPost;
        expect(captured.title, 'Updated Title');
        expect(captured.content, 'Cleaned content');
        expect(captured.isDraft, true);

        verify(
          () => mockRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          ),
        ).called(1);
      },
      expect: () => [
        isA<BlogLoadedState>()
            .having((s) => s.posts.first.id, 'posts[0].id', 'blog_1')
            .having(
              (s) => s.posts.first.title,
              'posts[0].title',
              'Updated Title',
            ),
      ],
    );

    blocTest<BlogBloc, BlogState>(
      'emits BlogErrorState on failure',
      build: () {
        when(
          () => mockRepository.updatePost(
            id: any(named: 'id'),
            update: any(named: 'update'),
          ),
        ).thenThrow(Exception('Fail to update'));
        return blogBloc;
      },
      act: (bloc) => bloc.add(
        const UpdateBlogPostEvent(
          blogId: 'blog_1',
          title: 'Updated Title',
          content: 'Content',
          isDraft: true,
        ),
      ),
      expect: () => [isA<BlogErrorState>()],
    );

    blocTest<BlogBloc, BlogState>(
      'emits BlogErrorState when reload after update fails',
      build: () {
        when(
          () => mockRepository.updatePost(
            id: 'blog_1',
            update: any(named: 'update'),
          ),
        ).thenAnswer((_) async => createTestPost(id: 'blog_1'));
        when(
          () => mockRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          ),
        ).thenThrow(Exception('Reload failed'));
        return blogBloc;
      },
      act: (bloc) => bloc.add(
        const UpdateBlogPostEvent(
          blogId: 'blog_1',
          title: 'Updated Title',
          content: 'Content',
          isDraft: false,
        ),
      ),
      expect: () => [isA<BlogErrorState>()],
    );
  });

  group('BlogBloc - DeleteBlogPostEvent / SoftDeleteBlogPostEvent', () {
    blocTest<BlogBloc, BlogState>(
      'DeleteBlogPostEvent sends reason and reloads first page on success',
      build: () {
        when(
          () => mockRepository.deletePost('blog_1', reason: 'Spam Reason'),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(posts: [], hasMore: false),
        );
        return blogBloc;
      },
      act: (bloc) => bloc.add(
        const DeleteBlogPostEvent(blogId: 'blog_1', reason: 'Spam Reason'),
      ),
      verify: (_) {
        verify(
          () => mockRepository.deletePost('blog_1', reason: 'Spam Reason'),
        ).called(1);
        verify(
          () => mockRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          ),
        ).called(1);
      },
      expect: () => [
        isA<BlogLoadedState>().having((s) => s.posts, 'posts', isEmpty),
      ],
    );

    blocTest<BlogBloc, BlogState>(
      'DeleteBlogPostEvent emits BlogErrorState on failure',
      build: () {
        when(
          () =>
              mockRepository.deletePost('blog_1', reason: any(named: 'reason')),
        ).thenThrow(Exception('Delete failed'));
        return blogBloc;
      },
      act: (bloc) => bloc.add(
        const DeleteBlogPostEvent(blogId: 'blog_1', reason: 'Spam Reason'),
      ),
      expect: () => [isA<BlogErrorState>()],
    );

    blocTest<BlogBloc, BlogState>(
      'DeleteBlogPostEvent emits BlogErrorState when reload fails',
      build: () {
        when(
          () => mockRepository.deletePost('blog_1', reason: 'Spam Reason'),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          ),
        ).thenThrow(Exception('Reload failed'));
        return blogBloc;
      },
      act: (bloc) => bloc.add(
        const DeleteBlogPostEvent(blogId: 'blog_1', reason: 'Spam Reason'),
      ),
      expect: () => [isA<BlogErrorState>()],
    );

    blocTest<BlogBloc, BlogState>(
      'SoftDeleteBlogPostEvent sends reason and reloads first page on success',
      build: () {
        when(
          () => mockRepository.softDeletePost(
            id: 'blog_1',
            reason: 'Spam Reason',
          ),
        ).thenAnswer((_) async => createTestPost(id: 'blog_1'));
        when(
          () => mockRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer(
          (_) async => BlogPostPaginatedResult(posts: [], hasMore: false),
        );
        return blogBloc;
      },
      act: (bloc) => bloc.add(
        const SoftDeleteBlogPostEvent(blogId: 'blog_1', reason: 'Spam Reason'),
      ),
      verify: (_) {
        verify(
          () => mockRepository.softDeletePost(
            id: 'blog_1',
            reason: 'Spam Reason',
          ),
        ).called(1);
        verify(
          () => mockRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          ),
        ).called(1);
      },
      expect: () => [
        isA<BlogLoadedState>().having((s) => s.posts, 'posts', isEmpty),
      ],
    );

    blocTest<BlogBloc, BlogState>(
      'SoftDeleteBlogPostEvent emits BlogErrorState on failure',
      build: () {
        when(
          () => mockRepository.softDeletePost(
            id: any(named: 'id'),
            reason: any(named: 'reason'),
          ),
        ).thenThrow(Exception('Soft delete failed'));
        return blogBloc;
      },
      act: (bloc) => bloc.add(
        const SoftDeleteBlogPostEvent(blogId: 'blog_1', reason: 'Spam Reason'),
      ),
      expect: () => [isA<BlogErrorState>()],
    );

    blocTest<BlogBloc, BlogState>(
      'SoftDeleteBlogPostEvent emits BlogErrorState when reload fails',
      build: () {
        when(
          () => mockRepository.softDeletePost(
            id: 'blog_1',
            reason: 'Spam Reason',
          ),
        ).thenAnswer((_) async => createTestPost(id: 'blog_1'));
        when(
          () => mockRepository.getPosts(
            cursor: null,
            limit: any(named: 'limit'),
            sort: any(named: 'sort'),
          ),
        ).thenThrow(Exception('Reload failed'));
        return blogBloc;
      },
      act: (bloc) => bloc.add(
        const SoftDeleteBlogPostEvent(blogId: 'blog_1', reason: 'Spam Reason'),
      ),
      expect: () => [isA<BlogErrorState>()],
    );
  });
}
