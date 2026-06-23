import 'package:dio/dio.dart';
import 'package:blog/shared/models/api_response.dart';
import 'package:blog/shared/models/user.dart';

class AuthApiProvider {
  final Dio _dio;

  AuthApiProvider(this._dio);

  Future<ApiResponse<User>> authenticate() async {
    try {
      final response = await _dio.get('/auth');

      return ApiResponse.fromJson(
        response.data,
        (jsonMap) => User.fromJson(jsonMap),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null && e.response?.data is Map) {
      final data = e.response!.data;

      if (data.containsKey('code')) {
        return Exception('[${data['code']}] ${data['message']}');
      }

      if (data.containsKey('message')) {
        return Exception(data['message']);
      }
    }

    return Exception('Network connectivity error occurred');
  }
}
