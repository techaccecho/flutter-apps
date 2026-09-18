import 'package:game/shared/util/auth/auth_api_provider.dart';
import 'package:game/shared/util/user/user.dart';

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

  Future<User> updateUser(
    String userId, {
    String? alias,
    String? firstName,
    String? lastName,
    String? bio,
    String? dateOfBirth,
  }) async {
    final payload = <String, dynamic>{};
    if (alias != null) payload['alias'] = alias;
    if (firstName != null) payload['firstName'] = firstName;
    if (lastName != null) payload['lastName'] = lastName;
    if (bio != null) payload['bio'] = bio;
    if (dateOfBirth != null) payload['dateOfBirth'] = dateOfBirth;

    final response = await apiProvider.updateUser(userId, payload);
    return response.data;
  }
}
