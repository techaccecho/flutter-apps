import 'package:blog/shared/providers/auth_api_provider.dart';
import 'package:blog/shared/models/user.dart';

class ArchivedUsersPaginatedResult {
  final List<User> users;
  final String? nextCursor;
  final bool hasMore;

  ArchivedUsersPaginatedResult({
    required this.users,
    this.nextCursor,
    required this.hasMore,
  });
}

class AuthRepository {
  final AuthApiProvider apiProvider;

  AuthRepository({required this.apiProvider});

  Future<User> authenticate() async {
    final existingResponse = await apiProvider.authenticate();
    return existingResponse.data;
  }

  Future<User> getUser(String userId) async {
    final response = await apiProvider.getUser(userId);
    return response.data;
  }

  Future<List<User>> getUsers({int? limit, String? cursor}) async {
    final response = await apiProvider.getUsers(limit: limit, cursor: cursor);
    return response.data;
  }

  Future<List<User>> getArchivedUsers({int? limit, String? cursor}) async {
    final response = await getArchivedUsersPage(limit: limit, cursor: cursor);
    return response.users;
  }

  Future<ArchivedUsersPaginatedResult> getArchivedUsersPage({
    int? limit,
    String? cursor,
  }) async {
    final response = await apiProvider.getArchivedUsers(
      limit: limit,
      cursor: cursor,
    );
    return ArchivedUsersPaginatedResult(
      users: response.data,
      nextCursor: response.meta?.nextCursor,
      hasMore: response.meta?.hasMore ?? false,
    );
  }

  Future<User> getArchivedUser(String userId) async {
    final response = await apiProvider.getArchivedUser(userId);
    return response.data;
  }
}
