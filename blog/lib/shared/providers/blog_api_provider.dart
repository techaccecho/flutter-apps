import 'package:dio/dio.dart';
import 'package:blog/shared/models/api_response.dart';
import 'package:blog/shared/models/blog.dart';
import 'package:blog/shared/models/create_blog.dart';
import 'package:blog/shared/models/update_blog.dart';
import 'package:blog/shared/models/add_comment.dart';

class BlogApiProvider {
  final Dio _dio;

  BlogApiProvider(this._dio);

  Future<ApiResponse<Blog>> createBlog(CreateBlog request) async {
    try {
      final response = await _dio.post('/blogs', data: request.toJson());

      return ApiResponse.fromJson(
        response.data,
        (jsonMap) => Blog.fromJson(jsonMap),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ApiResponse<List<Blog>>> fetchBlogsByType({
    required String type,
    String? cursor,
    int? limit,
    String? sort,
  }) async {
    try {
      final response = await _dio.get(
        '/${type}s',
        queryParameters: {'cursor': ?cursor, 'limit': ?limit, 'sort': ?sort},
      );

      return ApiResponse.fromJson(
        response.data,
        (jsonList) =>
            (jsonList as List).map((item) => Blog.fromJson(item)).toList(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ApiResponse<Blog>> fetchBlog(String blogId) async {
    try {
      final response = await _dio.get('/blogs/$blogId');

      return ApiResponse.fromJson(
        response.data,
        (jsonMap) => Blog.fromJson(jsonMap),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ApiResponse<Blog>> updateBlog({
    required String blogId,
    required UpdateBlog update,
  }) async {
    try {
      final response = await _dio.patch(
        '/blogs/$blogId',
        data: update.toJson(),
      );

      return ApiResponse.fromJson(
        response.data,
        (jsonMap) => Blog.fromJson(jsonMap),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteBlog(String id, {String? reason}) async {
    try {
      await _dio.delete(
        '/blogs/$id',
        data: reason != null ? {'reason': reason} : null,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ApiResponse<Blog>> softDeleteBlog({
    required String id,
    required String reason,
  }) async {
    try {
      final response = await _dio.patch(
        '/blogs/$id/soft-delete',
        data: {'reason': reason},
      );

      return ApiResponse.fromJson(
        response.data,
        (jsonMap) => Blog.fromJson(jsonMap),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ApiResponse<Blog>> addComment({
    required String blogId,
    required AddComment request,
  }) async {
    try {
      final response = await _dio.post(
        '/blogs/$blogId/comments',
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data,
        (jsonMap) => Blog.fromJson(jsonMap),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null && e.response?.data is Map) {
      final data = e.response!.data;

      if (data.containsKey('statusCode')) {
        return Exception(data['message'] ?? 'Route not found');
      }

      if (data.containsKey('code')) {
        return Exception('[${data['code']}] ${data['message']}');
      }
    }

    return Exception('Network connectivity error occurred');
  }
}
