import 'package:blog/shared/providers/auth_api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late AuthApiProvider provider;

  final userJson = {
    'id': 'user_1',
    'authId': 'auth_1',
    'email': 'user@example.com',
    'alias': 'alias',
    'firstName': 'First',
    'lastName': 'Last',
    'dateOfBirth': null,
    'bio': 'Bio',
    'role': 'user',
    'isLocked': false,
    'avatar': null,
    'createdAt': '2026-07-19T10:00:00.000Z',
    'updatedAt': null,
    'lastActivityAt': '2026-07-19T11:00:00.000Z',
  };

  Response<dynamic> responseFor(dynamic data) => Response<dynamic>(
    data: data,
    requestOptions: RequestOptions(path: ''),
  );

  setUp(() {
    dio = MockDio();
    provider = AuthApiProvider(dio);
  });

  group('AuthApiProvider', () {
    test(
      'authenticate, getUser, getArchivedUser, and updateUser use expected paths and payloads',
      () async {
        when(() => dio.get<dynamic>('/auth')).thenAnswer(
          (_) async => responseFor({
            'code': 'SUCCESS',
            'message': 'ok',
            'data': userJson,
          }),
        );
        when(() => dio.get<dynamic>('/users/user_1')).thenAnswer(
          (_) async => responseFor({
            'code': 'SUCCESS',
            'message': 'ok',
            'data': userJson,
          }),
        );
        when(() => dio.get<dynamic>('/users/archived/user_1')).thenAnswer(
          (_) async => responseFor({
            'code': 'SUCCESS',
            'message': 'ok',
            'data': userJson,
          }),
        );
        when(
          () => dio.patch<dynamic>('/users/user_1', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => responseFor({
            'code': 'SUCCESS',
            'message': 'ok',
            'data': userJson,
          }),
        );

        expect((await provider.authenticate()).data.id, 'user_1');
        expect(
          (await provider.getUser('user_1')).data.email,
          'user@example.com',
        );
        expect((await provider.getArchivedUser('user_1')).data.id, 'user_1');
        await provider.updateUser('user_1', {'alias': 'new_alias'});

        verify(() => dio.get<dynamic>('/auth')).called(1);
        verify(() => dio.get<dynamic>('/users/user_1')).called(1);
        verify(() => dio.get<dynamic>('/users/archived/user_1')).called(1);
        verify(
          () =>
              dio.patch<dynamic>('/users/user_1', data: {'alias': 'new_alias'}),
        ).called(1);
      },
    );

    test(
      'getUsers and getArchivedUsers send pagination query params and decode metadata',
      () async {
        when(
          () => dio.get<dynamic>(
            '/users',
            queryParameters: {'limit': 10, 'cursor': 'cursor_1'},
          ),
        ).thenAnswer(
          (_) async => responseFor({
            'code': 'SUCCESS',
            'message': 'ok',
            'data': [userJson],
            'meta': {'nextCursor': 'cursor_2', 'hasMore': true},
          }),
        );
        when(
          () => dio.get<dynamic>(
            '/users/archived',
            queryParameters: {'limit': 5, 'cursor': 'archived_1'},
          ),
        ).thenAnswer(
          (_) async => responseFor({
            'code': 'SUCCESS',
            'message': 'ok',
            'data': [userJson],
            'meta': {'nextCursor': null, 'hasMore': false},
          }),
        );

        final users = await provider.getUsers(limit: 10, cursor: 'cursor_1');
        final archivedUsers = await provider.getArchivedUsers(
          limit: 5,
          cursor: 'archived_1',
        );

        expect(users.data.single.id, 'user_1');
        expect(users.meta?.nextCursor, 'cursor_2');
        expect(archivedUsers.data.single.id, 'user_1');
        expect(archivedUsers.meta?.hasMore, isFalse);
      },
    );

    test(
      'uses validation detail messages when API returns structured validation errors',
      () async {
        when(
          () => dio.patch<dynamic>('/users/user_1', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/users/user_1'),
            response: Response<dynamic>(
              requestOptions: RequestOptions(path: '/users/user_1'),
              data: {
                'details': [
                  {'message': 'Alias is already taken'},
                ],
              },
            ),
          ),
        );

        expect(
          () => provider.updateUser('user_1', {'alias': 'taken'}),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Alias is already taken'),
            ),
          ),
        );
      },
    );

    test('uses server error message for 500 responses', () async {
      when(() => dio.get<dynamic>('/users/user_1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/user_1'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/users/user_1'),
            statusCode: 500,
            data: {'message': 'raw server error'},
          ),
        ),
      );

      expect(
        () => provider.getUser('user_1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('A server error occurred. Please try again later.'),
          ),
        ),
      );
    });

    test('uses server error message for INTERNAL_SERVER_ERROR code', () async {
      when(() => dio.get<dynamic>('/users/user_1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/user_1'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/users/user_1'),
            data: {
              'code': 'INTERNAL_SERVER_ERROR',
              'message': 'Internal failure',
            },
          ),
        ),
      );

      expect(
        () => provider.getUser('user_1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('A server error occurred. Please try again later.'),
          ),
        ),
      );
    });

    test(
      'uses code and message payload when no validation details exist',
      () async {
        when(() => dio.get<dynamic>('/users/user_1')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/users/user_1'),
            response: Response<dynamic>(
              requestOptions: RequestOptions(path: '/users/user_1'),
              data: {'code': 'NOT_FOUND', 'message': 'User not found'},
            ),
          ),
        );

        expect(
          () => provider.getUser('user_1'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('[NOT_FOUND] User not found'),
            ),
          ),
        );
      },
    );

    test('uses message payload when no code exists', () async {
      when(() => dio.get<dynamic>('/users/user_1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/user_1'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/users/user_1'),
            data: {'message': 'Plain error message'},
          ),
        ),
      );

      expect(
        () => provider.getUser('user_1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Plain error message'),
          ),
        ),
      );
    });

    test('converts network failures into connectivity exception', () async {
      when(() => dio.get<dynamic>('/users/user_1')).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/users/user_1')),
      );

      expect(
        () => provider.getUser('user_1'),
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
