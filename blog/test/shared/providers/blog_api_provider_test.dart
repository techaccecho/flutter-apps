import 'package:blog/shared/models/add_comment.dart';
import 'package:blog/shared/models/create_blog.dart';
import 'package:blog/shared/models/update_blog.dart';
import 'package:blog/modules/faq/model/faq_content.dart';
import 'package:blog/shared/providers/blog_api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late BlogApiProvider provider;

  final blogJson = {
    'id': 'blog_1',
    'author': {
      'id': 'user_1',
      'email': 'user@example.com',
      'alias': 'author',
      'firstName': 'First',
      'lastName': 'Last',
    },
    'type': 'post',
    'title': 'Title',
    'content': 'Content',
    'priority': 1,
    'isDraft': false,
    'isPinned': true,
    'isLocked': false,
    'participants': [],
    'comments': [],
    'attachments': [],
    'viewers': [],
    'reactions': [],
    'engagement': {'views': 1, 'comments': 2, 'attachments': 3, 'reactions': 4},
    'createdAt': '2026-07-19T10:00:00.000Z',
    'updatedAt': null,
    'deletedAt': null,
  };

  Response<dynamic> responseFor(dynamic data) => Response<dynamic>(
    data: data,
    requestOptions: RequestOptions(path: ''),
  );

  setUp(() {
    dio = MockDio();
    provider = BlogApiProvider(dio);
  });

  group('BlogApiProvider', () {
    test(
      'fetchBlogsByType builds path, filters empty query params, and decodes metadata',
      () async {
        when(
          () => dio.get<dynamic>(
            '/posts',
            queryParameters: {
              'limit': 10,
              'sort': 'desc',
              'search': 'flutter',
              'authorId': 'user_1',
            },
          ),
        ).thenAnswer(
          (_) async => responseFor({
            'code': 'SUCCESS',
            'message': 'ok',
            'data': [blogJson],
            'meta': {'nextCursor': 'next_1', 'hasMore': true},
          }),
        );

        final result = await provider.fetchBlogsByType(
          type: 'post',
          cursor: '',
          limit: 10,
          sort: 'desc',
          search: 'flutter',
          authorId: 'user_1',
        );

        expect(result.data.single.id, 'blog_1');
        expect(result.meta?.nextCursor, 'next_1');
        expect(result.meta?.hasMore, isTrue);
        verify(
          () => dio.get<dynamic>(
            '/posts',
            queryParameters: {
              'limit': 10,
              'sort': 'desc',
              'search': 'flutter',
              'authorId': 'user_1',
            },
          ),
        ).called(1);
      },
    );

    test(
      'createBlog, updateBlog, deleteBlog, softDeleteBlog, and addComment use expected paths and payloads',
      () async {
        when(
          () => dio.post<dynamic>('/blogs', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => responseFor({
            'code': 'SUCCESS',
            'message': 'ok',
            'data': blogJson,
          }),
        );
        when(
          () => dio.patch<dynamic>('/blogs/blog_1', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => responseFor({
            'code': 'SUCCESS',
            'message': 'ok',
            'data': blogJson,
          }),
        );
        when(
          () => dio.delete<dynamic>('/blogs/blog_1', data: any(named: 'data')),
        ).thenAnswer((_) async => responseFor(null));
        when(
          () => dio.patch<dynamic>(
            '/blogs/blog_1/soft-delete',
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => responseFor({
            'code': 'SUCCESS',
            'message': 'ok',
            'data': blogJson,
          }),
        );
        when(
          () => dio.post<dynamic>(
            '/blogs/blog_1/comments',
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => responseFor({
            'code': 'SUCCESS',
            'message': 'ok',
            'data': blogJson,
          }),
        );

        await provider.createBlog(
          CreateBlog(
            authorId: 'user_1',
            title: 'New',
            content: 'Body',
            type: 'post',
            isDraft: true,
          ),
        );
        await provider.updateBlog(
          blogId: 'blog_1',
          update: UpdateBlog(
            title: 'Updated',
            content: 'Changed',
            isDraft: false,
          ),
        );
        await provider.deleteBlog('blog_1', reason: 'cleanup');
        await provider.softDeleteBlog(id: 'blog_1', reason: 'rules');
        await provider.addComment(
          blogId: 'blog_1',
          request: AddComment(authorId: 'user_2', content: 'Comment'),
        );

        verify(
          () => dio.post<dynamic>(
            '/blogs',
            data: {
              'authorId': 'user_1',
              'title': 'New',
              'content': 'Body',
              'type': 'post',
              'isDraft': true,
            },
          ),
        ).called(1);
        verify(
          () => dio.patch<dynamic>(
            '/blogs/blog_1',
            data: {'title': 'Updated', 'content': 'Changed', 'isDraft': false},
          ),
        ).called(1);
        verify(
          () =>
              dio.delete<dynamic>('/blogs/blog_1', data: {'reason': 'cleanup'}),
        ).called(1);
        verify(
          () => dio.patch<dynamic>(
            '/blogs/blog_1/soft-delete',
            data: {'reason': 'rules'},
          ),
        ).called(1);
        verify(
          () => dio.post<dynamic>(
            '/blogs/blog_1/comments',
            data: {'authorId': 'user_2', 'content': 'Comment'},
          ),
        ).called(1);
      },
    );

    test('converts API error payloads into readable exceptions', () async {
      when(() => dio.get<dynamic>('/blogs/blog_1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/blogs/blog_1'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/blogs/blog_1'),
            data: {'code': 'NOT_FOUND', 'message': 'Blog not found'},
          ),
        ),
      );

      expect(
        () => provider.fetchBlog('blog_1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('[NOT_FOUND] Blog not found'),
          ),
        ),
      );
    });

    test(
      'fetchRulesOfEngagementFaq uses expected path and decodes content',
      () async {
        when(() => dio.get<dynamic>('/rules-of-engagement/faq')).thenAnswer(
          (_) async => responseFor({
            'code': 'SUCCESS',
            'message': 'ok',
            'data': {
              'title': 'Rules',
              'description': 'Community guidance',
              'items': [
                {'sortOrder': 1, 'question': 'Question?', 'answer': 'Answer.'},
              ],
            },
          }),
        );

        final result = await provider.fetchRulesOfEngagementFaq();

        expect(result.data, isA<FaqContent>());
        expect(result.data.title, 'Rules');
        expect(result.data.items.single.question, 'Question?');
        verify(() => dio.get<dynamic>('/rules-of-engagement/faq')).called(1);
      },
    );

    test('converts route error payloads into readable exceptions', () async {
      when(() => dio.get<dynamic>('/blogs/blog_1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/blogs/blog_1'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/blogs/blog_1'),
            data: {'statusCode': 404, 'message': 'Cannot GET /blogs/blog_1'},
          ),
        ),
      );

      expect(
        () => provider.fetchBlog('blog_1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot GET /blogs/blog_1'),
          ),
        ),
      );
    });

    test(
      'uses fallback route message when statusCode payload omits message',
      () async {
        when(() => dio.get<dynamic>('/blogs/blog_1')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/blogs/blog_1'),
            response: Response<dynamic>(
              requestOptions: RequestOptions(path: '/blogs/blog_1'),
              data: {'statusCode': 404},
            ),
          ),
        );

        expect(
          () => provider.fetchBlog('blog_1'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Route not found'),
            ),
          ),
        );
      },
    );

    test('converts network failures into connectivity exception', () async {
      when(() => dio.get<dynamic>('/blogs/blog_1')).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/blogs/blog_1')),
      );

      expect(
        () => provider.fetchBlog('blog_1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Network connectivity error occurred'),
          ),
        ),
      );
    });
  });
}
