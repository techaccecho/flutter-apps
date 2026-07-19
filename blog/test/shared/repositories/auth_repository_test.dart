import 'package:blog/shared/models/api_response.dart';
import 'package:blog/shared/models/user.dart';
import 'package:blog/shared/providers/auth_api_provider.dart';
import 'package:blog/shared/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthApiProvider extends Mock implements AuthApiProvider {}

void main() {
  late MockAuthApiProvider mockApiProvider;
  late AuthRepository repository;

  setUp(() {
    mockApiProvider = MockAuthApiProvider();
    repository = AuthRepository(apiProvider: mockApiProvider);
  });

  group('AuthRepository Tests', () {
    final testUser = User(
      id: 'user_123',
      authId: 'auth_123',
      email: 'user@example.com',
      alias: 'alias_abc',
      firstName: 'First',
      lastName: 'Last',
      role: 'user',
      isLocked: false,
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );

    test('authenticate calls apiProvider.authenticate and returns user', () async {
      when(() => mockApiProvider.authenticate()).thenAnswer(
        (_) async => ApiResponse<User>(
          code: 'SUCCESS',
          message: 'Authenticated successfully',
          data: testUser,
        ),
      );

      final result = await repository.authenticate();

      expect(result, testUser);
      verify(() => mockApiProvider.authenticate()).called(1);
    });

    test('getUser forwards userId and returns user', () async {
      when(() => mockApiProvider.getUser('user_123')).thenAnswer(
        (_) async => ApiResponse<User>(
          code: 'SUCCESS',
          message: 'Fetched user successfully',
          data: testUser,
        ),
      );

      final result = await repository.getUser('user_123');

      expect(result.id, 'user_123');
      expect(result.email, 'user@example.com');
      verify(() => mockApiProvider.getUser('user_123')).called(1);
    });

    test('getUsers forwards limit and cursor and returns list of users', () async {
      when(() => mockApiProvider.getUsers(limit: 5, cursor: 'abc')).thenAnswer(
        (_) async => ApiResponse<List<User>>(
          code: 'SUCCESS',
          message: 'Fetched users',
          data: [testUser],
        ),
      );

      final result = await repository.getUsers(limit: 5, cursor: 'abc');

      expect(result, [testUser]);
      verify(() => mockApiProvider.getUsers(limit: 5, cursor: 'abc')).called(1);
    });

    test('getArchivedUsers delegates to getArchivedUsersPage and returns users list', () async {
      when(() => mockApiProvider.getArchivedUsers(limit: 10, cursor: 'xyz')).thenAnswer(
        (_) async => ApiResponse<List<User>>(
          code: 'SUCCESS',
          message: 'Fetched archived users',
          data: [testUser],
          meta: ApiMeta(nextCursor: 'next_xyz', hasMore: true),
        ),
      );

      final result = await repository.getArchivedUsers(limit: 10, cursor: 'xyz');

      expect(result, [testUser]);
      verify(() => mockApiProvider.getArchivedUsers(limit: 10, cursor: 'xyz')).called(1);
    });

    group('getArchivedUsersPage tests', () {
      test('maps meta/pagination correctly', () async {
        when(() => mockApiProvider.getArchivedUsers(limit: 10, cursor: 'xyz')).thenAnswer(
          (_) async => ApiResponse<List<User>>(
            code: 'SUCCESS',
            message: 'Fetched archived users',
            data: [testUser],
            meta: ApiMeta(nextCursor: 'next_xyz', hasMore: true),
          ),
        );

        final result = await repository.getArchivedUsersPage(limit: 10, cursor: 'xyz');

        expect(result.users, [testUser]);
        expect(result.nextCursor, 'next_xyz');
        expect(result.hasMore, true);
      });

      test('handles null metadata by returning null nextCursor and false hasMore', () async {
        when(() => mockApiProvider.getArchivedUsers(limit: 10, cursor: 'xyz')).thenAnswer(
          (_) async => ApiResponse<List<User>>(
            code: 'SUCCESS',
            message: 'Fetched archived users',
            data: [testUser],
            meta: null,
          ),
        );

        final result = await repository.getArchivedUsersPage(limit: 10, cursor: 'xyz');

        expect(result.users, [testUser]);
        expect(result.nextCursor, isNull);
        expect(result.hasMore, false);
      });
    });

    test('getArchivedUser calls apiProvider.getArchivedUser and returns user', () async {
      when(() => mockApiProvider.getArchivedUser('user_123')).thenAnswer(
        (_) async => ApiResponse<User>(
          code: 'SUCCESS',
          message: 'Fetched archived user successfully',
          data: testUser,
        ),
      );

      final result = await repository.getArchivedUser('user_123');

      expect(result, testUser);
      verify(() => mockApiProvider.getArchivedUser('user_123')).called(1);
    });

    group('updateUser payload scenario tests', () {
      test('updateUser forwards payload with non-null values and returns updated user', () async {
        when(() => mockApiProvider.updateUser('user_123', {
              'alias': 'new_alias',
              'bio': 'new_bio',
            })).thenAnswer(
          (_) async => ApiResponse<User>(
            code: 'SUCCESS',
            message: 'Updated user successfully',
            data: testUser,
          ),
        );

        final result = await repository.updateUser(
          'user_123',
          alias: 'new_alias',
          bio: 'new_bio',
        );

        expect(result.id, 'user_123');
        verify(() => mockApiProvider.updateUser('user_123', {
              'alias': 'new_alias',
              'bio': 'new_bio',
            })).called(1);
      });

      test('updateUser omits null fields and sends empty payload when all optional fields are null', () async {
        when(() => mockApiProvider.updateUser('user_123', {})).thenAnswer(
          (_) async => ApiResponse<User>(
            code: 'SUCCESS',
            message: 'Updated user successfully',
            data: testUser,
          ),
        );

        final result = await repository.updateUser('user_123');

        expect(result.id, 'user_123');
        verify(() => mockApiProvider.updateUser('user_123', {})).called(1);
      });
    });
  });
}
