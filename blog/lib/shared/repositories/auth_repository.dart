import 'package:blog/shared/providers/auth_api_provider.dart';
import 'package:blog/shared/models/user.dart';

class AuthRepository {
  final AuthApiProvider apiProvider;

  AuthRepository({required this.apiProvider});

  Future<User> authenticate() async {
    final existingResponse = await apiProvider.authenticate();
    return existingResponse.data;
  }
}
